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
#import "LXPicMapViewController.h"
#import "LXPicEditViewController.h"
#import "LXMyPageViewController.h"
#import "LXShare.h"
#import "UIButton+AsyncImage.h"
#import "Comment.h"
#import "LXTagViewController.h"
#import "LXUserPageViewController.h"


@interface LXGalleryViewController ()

@end

@implementation LXGalleryViewController {
    UIPageViewController *pageController;
    UITapGestureRecognizer *tapPage;
    UITapGestureRecognizer *tapDouble;
    NSMutableArray *currentComments;
    LXShare *lxShare;
    BOOL loadedInfo;
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
@synthesize labelComment;
@synthesize labelLike;
@synthesize imageNationality;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        _currentTab = kGalleryTabComment;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (_picture.pictureId == nil)
        return;
    

    pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                     navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                   options:nil];
    
    
    pageController.dataSource = self;
    pageController.delegate = self;
    CGRect frame = self.view.bounds;

    pageController.view.frame = self.view.bounds;

    tapPage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapScrollImage:)];
    tapPage.numberOfTapsRequired = 1;

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
    
    labelDesc = [[STTweetLabel alloc] initWithFrame:CGRectMake(6, 6, 308, 0)];
    labelDesc.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0];
    labelDesc.textColor = [UIColor whiteColor];
    
    __weak LXGalleryViewController *weakSelf = self;
    STLinkCallbackBlock callbackBlock = ^(STLinkActionType actionType, NSString *link) {
        
        NSString *displayString = NULL;
        
        // determine what the user clicked on
        switch (actionType) {
                
                // if the user clicked on an account (@_max_k)
            case STLinkActionTypeAccount:
                displayString = [NSString stringWithFormat:@"Twitter account:\n%@", link];
                break;
                
                // if the user clicked on a hashtag (#thisisreallycool)
            case STLinkActionTypeHashtag: {
                displayString = [NSString stringWithFormat:@"Twitter hashtag:\n%@", link];
                
                UIStoryboard *storyMain = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                                       bundle:nil];
                LXTagViewController *viewTag = [storyMain instantiateViewControllerWithIdentifier:@"Tag"];
                viewTag.keyword = [link substringFromIndex:1];
                
                [weakSelf.navigationController pushViewController:viewTag animated:YES];

                break;
            }
                // if the user clicked on a website (http://github.com/SebastienThiebaud)
            case STLinkActionTypeWebsite:
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:link]];
                break;
        }
    };
    [labelDesc setCallbackBlock:callbackBlock];
    [viewDesc addSubview:labelDesc];

    [self setPicture];
    
    buttonUser.layer.cornerRadius = 15;
    buttonUser.layer.shouldRasterize = YES;
    buttonUser.layer.rasterizationScale = [[UIScreen mainScreen] scale];

    
    lxShare = [[LXShare alloc] init];
    lxShare.controller = self;
    
    LXAppDelegate *app = [LXAppDelegate currentDelegate];
    
    [app.tracker set:kGAIScreenName
               value:@"Gallery Screen"];
    
    [app.tracker send:[[GAIDictionaryBuilder createAppView] build]];
}


- (void)tapZoom:(UITapGestureRecognizer*)sender {
    LXZoomPictureViewController *currentPage = pageController.viewControllers[0];
    [currentPage performSelector:@selector(tapZoom:) withObject:sender];
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

- (void)viewWillAppear:(BOOL)animated
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:) name: UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:) name: UIKeyboardWillHideNotification object:nil];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [nc removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [super viewWillDisappear:animated];
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    LXZoomPictureViewController *currentPage = pageController.viewControllers[0];
    
    if ([segue.identifier isEqualToString:@"Map"]) {
        LXPicMapViewController *viewMap = segue.destinationViewController;
        viewMap.picture = currentPage.picture;
    } else if ([segue.identifier isEqualToString:@"Edit"]) {
        LXPicEditViewController *viewEdit = segue.destinationViewController;
        viewEdit.picture = currentPage.picture;
    } else if ([segue.identifier isEqualToString:@"Detail"]) {
        LXPicDetailTabViewController *viewPicTab = segue.destinationViewController;
        viewPicTab.picture = currentPage.picture;
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(LXZoomPictureViewController *)viewController {
    @try {
        NSDictionary *nextInfo = [_delegate pictureAfterPicture:viewController.picture];
        if (nextInfo != nil) {
            LXZoomPictureViewController *viewZoom = [[LXZoomPictureViewController alloc] init];
            viewZoom.picture = [nextInfo objectForKey:@"picture"];
            viewZoom.user = [nextInfo objectForKey:@"user"];
            return viewZoom;
        } else
            return nil;
    }
    @catch (NSException *exception) {
        return nil;
    }
    @finally {
        
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(LXZoomPictureViewController *)viewController {
    @try {
        NSDictionary *prevInfo = [_delegate pictureBeforePicture:viewController.picture];
        if (prevInfo != nil) {
            LXZoomPictureViewController *viewZoom = [[LXZoomPictureViewController alloc] init];
            viewZoom.picture = [prevInfo objectForKey:@"picture"];
            viewZoom.user = [prevInfo objectForKey:@"user"];
            return viewZoom;
        } else
            return nil;
    }
    @catch (NSException *exception) {
        return nil;
    }
    @finally {
        
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (completed) {
        [self setPicture];
    }
    
    [UIView animateWithDuration:kGlobalAnimationSpeed animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {

}

- (void)setPicture {
    loadedInfo = false;
    LXZoomPictureViewController *currentPage = pageController.viewControllers[0];
    
    CGSize size = [currentPage.picture.descriptionText sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0]
                                                  constrainedToSize:CGSizeMake(308, CGFLOAT_MAX)
                                                      lineBreakMode:labelDesc.lineBreakMode];
    CGRect frame = labelDesc.frame;
    frame.size.height = size.height;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGRect frameDesc = viewDesc.frame;
    frameDesc.size.height = MIN(frame.size.height + 12, 200);
    frameDesc.origin.y = screenRect.size.height-frameDesc.size.height-35;
    viewDesc.contentSize = CGSizeMake(320, frame.size.height + 12);
    
    if (currentPage.picture.descriptionText.length == 0) {
        frameDesc.size.height = 0;
    }
    
    [UIView animateWithDuration:kGlobalAnimationSpeed
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         labelDesc.frame = frame;
                         viewDesc.frame = frameDesc;
                         
                         [labelDesc setText:currentPage.picture.descriptionText];
                     }
                     completion:^(BOOL finished) {
                         [viewDesc flashScrollIndicators];
                     }];
    
    
    if (currentPage.user) {
        labelNickname.text = currentPage.user.name;
        [LXUtils setNationalityOfUser:currentPage.user forImage:imageNationality nextToLabel:labelNickname];
        [buttonUser loadBackground:currentPage.user.profilePicture placeholderImage:@"user.gif"];
        
    } else if (currentPage.picture.user) {
        labelNickname.text = currentPage.picture.user.name;
        [LXUtils setNationalityOfUser:currentPage.picture.user forImage:imageNationality nextToLabel:labelNickname];
        [buttonUser loadBackground:currentPage.picture.user.profilePicture placeholderImage:@"user.gif"];
    } else {
        [self loadInfo];
    }
    
    labelView.text = [NSString stringWithFormat:NSLocalizedString(@"d_views", @""), [currentPage.picture.pageviews integerValue]];
    
    LXAppDelegate *app = [LXAppDelegate currentDelegate];

    buttonLike.enabled = NO;
    if (!(currentPage.picture.isVoted && !app.currentUser))
        buttonLike.enabled = YES;
    buttonLike.selected = currentPage.picture.isVoted;
    labelLike.highlighted = currentPage.picture.isVoted;
    
    if ((currentPage.picture.latitude != nil) && (currentPage.picture.longitude != nil)) {
        buttonMap.enabled = YES;
    } else {
        buttonMap.enabled = NO;
    }
    
    labelComment.text = [currentPage.picture.commentCount stringValue];
    labelLike.text = [currentPage.picture.voteCount stringValue];
    
    // Increase counter
    NSString *urlCounter = [NSString stringWithFormat:@"picture/counter/%ld/%ld",
                     [currentPage.picture.pictureId integerValue],
                     [currentPage.picture.userId integerValue]];
    
    [[LatteAPIClient sharedClient] GET:urlCounter parameters:nil success:nil failure:nil];
    buttonEdit.hidden = !currentPage.picture.isOwner;
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
    LXZoomPictureViewController *currentPage = pageController.viewControllers[0];
    if (currentPage.picture.isOwner)
        return;
    [LXUtils toggleLike:sender ofPicture:currentPage.picture setCount:labelLike];
}

- (IBAction)switchTab:(UIButton *)sender {
    switch (sender.tag) {
        case 1:
            self.currentTab = kGalleryTabVote;
            break;
        case 2:
            self.currentTab = kGalleryTabComment;
            break;
        case 3:
            self.currentTab = kGalleryTabInfo;
            break;
        default:
            break;
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
        
        [sender setTranslation:CGPointZero inView:self.view];
    }
}

- (void)loadInfo {
    loadedInfo = true;
    LXZoomPictureViewController *currentPage = pageController.viewControllers[0];
    LXAppDelegate *app = [LXAppDelegate currentDelegate];
}

- (IBAction)touchUser:(UIButton *)sender {
    LXZoomPictureViewController *currentPage = pageController.viewControllers[0];
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    LXUserPageViewController *viewUserPage = [mainStoryboard instantiateViewControllerWithIdentifier:@"UserPage"];
    
    if (currentPage.user)
        viewUserPage.user = currentPage.user;
    else if (currentPage.picture.user)
        viewUserPage.user = currentPage.picture.user;
    
    [self dismissViewControllerAnimated:YES completion:^{
        [_delegate.navigationController pushViewController:viewUserPage animated:YES];
    }];
    
}

- (IBAction)touchShare:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                               destructiveButtonTitle:nil otherButtonTitles:@"Email", @"Twitter", @"Facebook", nil];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    LXZoomPictureViewController *currentPage = pageController.viewControllers[0];
    lxShare.url = currentPage.picture.urlWeb;
    lxShare.text = currentPage.picture.urlWeb;
    
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


- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    
    return UIStatusBarAnimationFade;
}


@end
