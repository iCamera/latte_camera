//
//  LXGalleryViewController.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 2/26/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXAppDelegate.h"
#import "LXGalleryViewController.h"
#import "LXZoomPictureViewController.h"

#import "LXPicDetailTabViewController.h"
#import "LXPicCommentViewController.h"
#import "LXPicInfoViewController.h"
#import "LXPicMapViewController.h"
#import "LXPicEditViewController.h"

#import "DAKeyboardControl.h"


@interface LXGalleryViewController ()

@end

@implementation LXGalleryViewController {
    UIPageViewController *pageController;
    LXPicDetailTabViewController *viewPicTab;
    LXZoomPictureViewController *currentInfo;
    NSInteger currentTab;
    UITapGestureRecognizer *tapPage;
    NSMutableArray *currentComments;
}

@synthesize buttonComment;
@synthesize buttonLike;
@synthesize buttonMap;
@synthesize viewTab;
@synthesize viewContainerTab;
@synthesize buttonEdit;

@synthesize constraintViewTab;
@synthesize constraintViewContainer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                     navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                   options:nil];
    pageController.dataSource = self;
    pageController.delegate = self;
    CGRect frame = self.view.bounds;
    frame.size.height -= 31;
    pageController.view.frame = frame;

    tapPage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapScrollImage:)];
    [pageController.view addGestureRecognizer:tapPage];
    
    LXZoomPictureViewController *init = [[LXZoomPictureViewController alloc] init];

    init.picture = _picture;
    init.user = _user;
    
    init.view.bounds = frame;
    
    [pageController setViewControllers:[NSArray arrayWithObject:init]
                             direction:UIPageViewControllerNavigationDirectionForward
                              animated:NO
                            completion:nil];

    [self addChildViewController:pageController];
    [self.view insertSubview:pageController.view atIndex:0];
    [pageController didMoveToParentViewController:self];

    [self setPicture];
    
    currentTab = 1;
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:) name: UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:) name: UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    if (constraintViewContainer.constant < keyboardSize.height) {
        constraintViewTab.constant = -keyboardSize.height-42; //42 = comment box height
        constraintViewContainer.constant = keyboardSize.height+42;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationCurve:[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
        [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
        
        [self.view setNeedsUpdateConstraints];
        [UIView animateWithDuration:kGlobalAnimationSpeed animations:^{
            [self.view layoutIfNeeded];
        }];
        
        [UIView commitAnimations];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
 
}

- (void)tapScrollImage:(UITapGestureRecognizer*)sender {
    if ([self isShowingContainer]) {
        [self toggleFrame];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [LXUtils globalShadow:viewTab];
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillDisappear:animated];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Tab"]) {
        viewPicTab = segue.destinationViewController;
        viewPicTab.picture = _picture;
    } else if ([segue.identifier isEqualToString:@"Map"]) {
        LXPicMapViewController *viewMap = segue.destinationViewController;
        viewMap.picture = _picture;
    } else if ([segue.identifier isEqualToString:@"Edit"]) {
        LXPicEditViewController *viewEdit = segue.destinationViewController;
        viewEdit.picture = _picture;
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(LXZoomPictureViewController *)viewController {
    NSDictionary *nextInfo = [_delegate pictureAfterPicture:viewController.picture];
    if (nextInfo != nil) {
        LXZoomPictureViewController *viewZoom = [[LXZoomPictureViewController alloc] init];
        viewZoom.picture = [nextInfo objectForKey:@"picture"];
        viewZoom.user = [nextInfo objectForKey:@"user"];
        return viewZoom;
    } else
        return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(LXZoomPictureViewController *)viewController {
    NSDictionary *prevInfo = [_delegate pictureBeforePicture:viewController.picture];
    if (prevInfo != nil) {
        LXZoomPictureViewController *viewZoom = [[LXZoomPictureViewController alloc] init];
        viewZoom.picture = [prevInfo objectForKey:@"picture"];
        viewZoom.user = [prevInfo objectForKey:@"user"];
        return viewZoom;
    } else
        return nil;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (completed) {
        [self setPicture];
        viewPicTab.picture = _picture;
    }
    
    [UIView animateWithDuration:kGlobalAnimationSpeed animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
    if ([self isShowingContainer]) {
        [self toggleFrame];
    }
}

- (void)setPicture {
    currentInfo = pageController.viewControllers[0];
    _picture = currentInfo.picture;
    
    LXAppDelegate *app = [LXAppDelegate currentDelegate];

    buttonLike.enabled = NO;
    if (!(_picture.isVoted && !app.currentUser))
        buttonLike.enabled = YES;
    buttonLike.selected = _picture.isVoted;
    
    if ((_picture.latitude != nil) && (_picture.longitude != nil)) {
        buttonMap.enabled = YES;
    } else {
        buttonMap.enabled = NO;
    }
    
    [buttonComment setTitle:[_picture.commentCount stringValue] forState:UIControlStateNormal];
    [buttonLike setTitle:[_picture.voteCount stringValue] forState:UIControlStateNormal];
    
    // Increase counter
    NSString *urlCounter = [NSString stringWithFormat:@"picture/counter/%d/%d",
                     [_picture.pictureId integerValue],
                     [_picture.userId integerValue]];
    
    [[LatteAPIClient sharedClient] getPath:urlCounter
                                parameters:[NSDictionary dictionaryWithObject:[app getToken] forKey:@"token"]
                                   success:nil
                                   failure:nil];
    buttonEdit.hidden = !_picture.isOwner;
    
    NSString *urlDetail = [NSString stringWithFormat:@"picture/%d", [_picture.pictureId integerValue]];
    [[LatteAPIClient sharedClient] getPath:urlDetail
                                parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       
                                       _user = [User instanceFromDictionary:[JSON objectForKey:@"user"]];
                                       currentComments = [Comment mutableArrayFromDictionary:JSON withKey:@"comments"];
                                       viewPicTab.comments = currentComments;
                                       currentInfo.user = _user;
                                       
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       TFLog(@"Something went wrong PicDetail Gallery");
                                       
                                       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", "Error")
                                                                                       message:error.localizedDescription
                                                                                      delegate:nil
                                                                             cancelButtonTitle:NSLocalizedString(@"close", "Close")
                                                                             otherButtonTitles:nil];
                                       [alert show];
                                   }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)touchClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)toggleLike:(UIButton *)sender {
    if (_picture.isOwner)
        return;
    [LXUtils toggleLike:sender ofPicture:currentInfo.picture];
}

- (IBAction)switchTab:(UIButton *)sender {
    if (![self isShowingContainer]) {
        [self toggleFrame];
    } else {
        if (sender.tag == currentTab) {
            [self toggleFrame];
            return;
        }
    }
    
    currentTab = sender.tag;
    if (sender.tag == 1)
        if (!_picture.isOwner)
            return;
    viewPicTab.tab = sender.tag;
}

- (IBAction)dragTab:(UIPanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan || sender.state == UIGestureRecognizerStateChanged) {
        CGPoint translatedPoint = [sender translationInView:self.view];
        constraintViewTab.constant += translatedPoint.y;
        constraintViewContainer.constant -= translatedPoint.y;
        [sender setTranslation:CGPointZero inView:self.view];
    }
}

- (void)toggleFrame {
    if (![self isShowingContainer]) {
        constraintViewTab.constant -= 200;
        constraintViewContainer.constant += 200;
    } else {
        constraintViewTab.constant = 0;
        constraintViewContainer.constant = 0;
        [viewPicTab.viewComment.growingComment resignFirstResponder];
    }
    [self.view setNeedsUpdateConstraints];
    
    [UIView animateWithDuration:kGlobalAnimationSpeed animations:^{
        [self.view layoutIfNeeded];
    }];

}

- (BOOL)isShowingContainer {
    return constraintViewTab.constant != 0;
}

@end
