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
#import "LXMyPageViewController.h"
#import "LXShare.h"


@interface LXGalleryViewController ()

@end

@implementation LXGalleryViewController {
    UIPageViewController *pageController;
    LXPicDetailTabViewController *viewPicTab;
    LXZoomPictureViewController *currentInfo;
    NSInteger currentTab;
    UITapGestureRecognizer *tapPage;
    UITapGestureRecognizer *tapDouble;
    NSMutableArray *currentComments;
}

@synthesize buttonComment;
@synthesize buttonLike;
@synthesize buttonMap;
@synthesize viewTab;
@synthesize labelDesc;
@synthesize buttonEdit;
@synthesize labelNickname;
@synthesize buttonUser;
@synthesize labelView;
@synthesize viewInfoTop;
@synthesize viewDesc;


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
    
    UIStoryboard *storyGallery = [UIStoryboard storyboardWithName:@"Gallery"
                                                           bundle:nil];
    viewPicTab = [storyGallery instantiateViewControllerWithIdentifier:@"DetailScroll"];
    CGRect frameTab = [[UIScreen mainScreen] bounds];
    frameTab.origin.y = frameTab.size.height;
    viewPicTab.picture = _picture;
    viewPicTab.view.frame = frameTab;
    [self.view insertSubview:viewPicTab.view atIndex:1]; // Above description
    [self addChildViewController:viewPicTab];
    [viewPicTab didMoveToParentViewController:self];
    
    pageController.dataSource = self;
    pageController.delegate = self;
    CGRect frame = self.view.bounds;
    frame.size.height -= 31;
    pageController.view.frame = frame;

    tapPage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapScrollImage:)];
    tapDouble = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapZoom:)];
    tapDouble.numberOfTapsRequired = 2;
    [tapPage requireGestureRecognizerToFail:tapDouble];
    
    [pageController.view addGestureRecognizer:tapPage];
    [pageController.view addGestureRecognizer:tapDouble];
    
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
    
    currentTab = 2;
    
    buttonUser.layer.cornerRadius = 5;
    buttonUser.clipsToBounds = YES;
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:) name: UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:) name: UIKeyboardWillHideNotification object:nil];
}

- (void)tapZoom:(UITapGestureRecognizer*)sender {
    [currentInfo performSelector:@selector(tapZoom:) withObject:sender];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    if (screenRect.size.height - viewTab.frame.origin.y - 100 < keyboardSize.height) {
        [self setTabHeight:keyboardSize.height + 100];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationCurve:[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
        [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
        
        
        [UIView commitAnimations];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
 
}

- (void)tapScrollImage:(UITapGestureRecognizer*)sender {
    if ([self isShowingContainer]) {
        [self toggleFrame];
    } else {
        [self toggleInfo];
    }
}

- (void)toggleInfo {
    [UIView animateWithDuration:kGlobalAnimationSpeed
                     animations:^{
                         if (viewTab.alpha == 1) {
                             viewTab.alpha = 0;
                             viewInfoTop.alpha = 0;
                             viewDesc.alpha = 0;
                         } else {
                             viewTab.alpha = 1;
                             viewInfoTop.alpha = 1;
                             viewDesc.alpha = 1;
                         }
                     }];
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
    if ([segue.identifier isEqualToString:@"Map"]) {
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
    [UIView animateWithDuration:kGlobalAnimationSpeed
                     animations:^{
                         viewDesc.alpha = 0;
                     }];
}

- (void)setPicture {
    currentInfo = pageController.viewControllers[0];
    _picture = currentInfo.picture;
    _user = currentInfo.user;
    
    if (_picture.descriptionText.length > 0) {
        CGSize size = [_picture.descriptionText sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0] constrainedToSize:CGSizeMake(308, 999)];
        CGRect frame = labelDesc.frame;
        frame.size = size;
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGRect frameDesc = CGRectMake(0, screenRect.size.height-frame.size.height-12-31, 320, frame.size.height + 12);
        [UIView animateWithDuration:kGlobalAnimationSpeed
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             viewDesc.alpha = 1;
                             labelDesc.frame = frame;
                             viewDesc.frame = frameDesc;
                             labelDesc.text = _picture.descriptionText;
                         }
                         completion:nil];
    } else {

    }
    
    labelNickname.text = _user.name;
    labelView.text = [NSString stringWithFormat:@"%d views", [_picture.pageviews integerValue]];
    [buttonUser loadBackground:_user.profilePicture placeholderImage:@"user.gif"];
    
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
                                       if (_user == nil) {
                                           _user = [User instanceFromDictionary:[JSON objectForKey:@"user"]];
                                           labelNickname.text = _user.name;
                                           [buttonUser loadBackground:_user.profilePicture placeholderImage:@"user.gif"];
                                       }

                                       currentComments = [Comment mutableArrayFromDictionary:JSON withKey:@"comments"];
                                       viewPicTab.comments = currentComments;
                                       
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
    [LXUtils toggleLike:sender ofPicture:_picture];
}

- (IBAction)switchTab:(UIButton *)sender {
    if (sender.tag == 1) { //Vote button
        if (!_picture.isOwner)
            return;
    }
    
    if (![self isShowingContainer]) {
        [self toggleFrame];
        if (currentTab != sender.tag) {
            currentTab = sender.tag;
            viewPicTab.tab = sender.tag;   
        }
    } else {
        if (sender.tag == currentTab) {
            [self toggleFrame];
        } else {
            viewPicTab.tab = sender.tag;
            currentTab = sender.tag;
        }
    }
}

- (IBAction)dragTab:(UIPanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan || sender.state == UIGestureRecognizerStateChanged) {
        CGPoint translatedPoint = [sender translationInView:self.view];
        
        CGRect frameTab = viewTab.frame;
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        
        frameTab.origin.y += translatedPoint.y;
        if (frameTab.origin.y < 0) {
            frameTab.origin.y = 0;
        }
        if (frameTab.origin.y + frameTab.size.height > screenRect.size.height) {
            frameTab.origin.y = screenRect.size.height - frameTab.size.height;
        }
        
        CGRect frameContainer = viewPicTab.view.frame;
        frameContainer.origin.y = frameTab.origin.y + frameTab.size.height;
        
        viewTab.frame = frameTab;
        viewPicTab.view.frame = frameContainer;
        
        [viewPicTab updateContent];
        
        [sender setTranslation:CGPointZero inView:self.view];
    }
}

- (void)setTabHeight:(CGFloat)height {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGRect frameTab = viewTab.frame;
    frameTab.origin = CGPointMake(0, screenRect.size.height - height - viewTab.frame.size.height);
    CGRect frameContainer = viewPicTab.view.frame;
    frameContainer.origin.y = screenRect.size.height - height;
    
    [UIView animateWithDuration:kGlobalAnimationSpeed animations:^{
        viewTab.frame = frameTab;
        viewPicTab.view.frame = frameContainer;
    } completion:^(BOOL finished) {
        [viewPicTab updateContent];
    }];
    
    
}

- (IBAction)touchUser:(UIButton *)sender {
    if (_user == nil) {
        return;
    }
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    LXMyPageViewController *viewUserPage = [mainStoryboard instantiateViewControllerWithIdentifier:@"UserPage"];
    viewUserPage.user = _user;
    [self.navigationController pushViewController:viewUserPage animated:YES];
    
}

- (IBAction)touchShare:(id)sender {
    RDActionSheet *actionSheet = [[RDActionSheet alloc] initWithCancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                                               primaryButtonTitle:nil
                                                           destructiveButtonTitle:nil
                                                                otherButtonTitles:@"Email", @"Twitter", @"Facebook", nil];
    LXShare *lxShare = [[LXShare alloc] init];
    actionSheet.callbackBlock = ^(RDActionSheetResult result, NSInteger buttonIndex)
    {
        switch (result) {
            case RDActionSheetButtonResultSelected: {
                lxShare.text = _picture.urlMedium;
                
                switch (buttonIndex) {
                    case 0: // email
                        [lxShare emailIt];
                        break;
                    case 1: // twitter
                        [lxShare tweet];
                        break;
                    case 2: // facebook
                        [lxShare facebookPost];
                        break;
                    default:
                        break;
                }
            }
                break;
            case RDActionSheetResultResultCancelled:
                NSLog(@"Sheet cancelled");
        }
    };
    
    [actionSheet showFrom:self.view];
}

- (void)toggleFrame {
    if (![self isShowingContainer]) {
        [self setTabHeight:200];
    } else {
        [self setTabHeight:0];
        [viewPicTab.viewComment.growingComment resignFirstResponder];
    }
}

- (BOOL)isShowingContainer {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGRect frameTab = viewTab.frame;

    return screenRect.size.height - frameTab.origin.y - frameTab.size.height > 0;
}

@end
