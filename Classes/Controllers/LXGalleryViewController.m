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
#import "UIButton+AsyncImage.h"
#import "Comment.h"
#import "LXTagViewController.h"


@interface LXGalleryViewController ()

@end

@implementation LXGalleryViewController {
    UIPageViewController *pageController;
    LXPicDetailTabViewController *viewPicTab;
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
    
    UIStoryboard *storyGallery = [UIStoryboard storyboardWithName:@"Gallery"
                                                           bundle:nil];
    viewPicTab = [storyGallery instantiateViewControllerWithIdentifier:@"DetailScroll"];
    viewPicTab.parent = self;
    CGRect frameTab = [[UIScreen mainScreen] bounds];
    frameTab.origin.y = frameTab.size.height;

    viewPicTab.view.frame = frameTab;
    [self.view insertSubview:viewPicTab.view atIndex:1]; // Above description
    [self addChildViewController:viewPicTab];
    [viewPicTab didMoveToParentViewController:self];
    
    pageController.dataSource = self;
    pageController.delegate = self;
    CGRect frame = self.view.bounds;
    frame.size.height -= 35;
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
    
    labelDesc = [[STTweetLabel alloc] initWithFrame:CGRectMake(6, 6, 308, 0)];
    labelDesc.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0];
    labelDesc.textColor = [UIColor whiteColor];
    
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
                [self.navigationController pushViewController:viewTag animated:YES];

                break;
            }
                // if the user clicked on a website (http://github.com/SebastienThiebaud)
            case STLinkActionTypeWebsite:
                displayString = [NSString stringWithFormat:@"Website:\n%@", link];
                break;
        }
    };
    [labelDesc setCallbackBlock:callbackBlock];
    [viewDesc addSubview:labelDesc];

    [self setPicture];
    
    buttonUser.layer.cornerRadius = 5;
    buttonUser.clipsToBounds = YES;
    
    lxShare = [[LXShare alloc] init];
    
    lxShare.controller = self;
    
}

- (void)setCurrentTab:(GalleryTab)currentTab {
    LXZoomPictureViewController *currentPage = pageController.viewControllers[0];
    if (currentTab == kGalleryTabVote) { //Vote button
        if (!currentPage.picture.isOwner)
            return;
    }
    
    if (![self isShowingContainer]) {
        [self toggleFrame];
        if (_currentTab != currentTab) {
            _currentTab = currentTab;
            viewPicTab.tab = currentTab;
        }
    } else {
        if (currentTab == _currentTab) {
            [self toggleFrame];
        } else {
            viewPicTab.tab = currentTab;
            _currentTab = currentTab;
        }
    }
}

- (void)tapZoom:(UITapGestureRecognizer*)sender {
    LXZoomPictureViewController *currentPage = pageController.viewControllers[0];
    [currentPage performSelector:@selector(tapZoom:) withObject:sender];
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
    loadedInfo = false;
    LXZoomPictureViewController *currentPage = pageController.viewControllers[0];
    
    if (currentPage.picture.descriptionText.length > 0) {
        CGSize size = [currentPage.picture.descriptionText sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0]
                                                      constrainedToSize:CGSizeMake(308, CGFLOAT_MAX)
                                                          lineBreakMode:labelDesc.lineBreakMode];
        CGRect frame = labelDesc.frame;
        frame.size.height = size.height;
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGRect frameDesc = CGRectMake(0, screenRect.size.height-frame.size.height-12-35, 320, frame.size.height + 12);
        [UIView animateWithDuration:kGlobalAnimationSpeed
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             viewDesc.alpha = 1;
                             labelDesc.frame = frame;
                             viewDesc.frame = frameDesc;
                             
                             [labelDesc setText:currentPage.picture.descriptionText];
                         }
                         completion:nil];
    } else {

    }
    
    viewPicTab.picture = currentPage.picture;
    viewPicTab.viewComment.comments = nil;
    
    
    if (currentPage.user == nil) {
        [self loadInfo];
    } else {
        labelNickname.text = currentPage.user.name;
        [buttonUser loadBackground:currentPage.user.profilePicture placeholderImage:@"user.gif"];
    }
    
    labelView.text = [NSString stringWithFormat:@"%d views", [currentPage.picture.pageviews integerValue]];
    
    LXAppDelegate *app = [LXAppDelegate currentDelegate];

    buttonLike.enabled = NO;
    if (!(currentPage.picture.isVoted && !app.currentUser))
        buttonLike.enabled = YES;
    buttonLike.selected = currentPage.picture.isVoted;
    
    if ((currentPage.picture.latitude != nil) && (currentPage.picture.longitude != nil)) {
        buttonMap.enabled = YES;
    } else {
        buttonMap.enabled = NO;
    }
    
    labelComment.text = [currentPage.picture.commentCount stringValue];
    labelLike.text = [currentPage.picture.voteCount stringValue];
    
    // Increase counter
    NSString *urlCounter = [NSString stringWithFormat:@"picture/counter/%d/%d",
                     [currentPage.picture.pictureId integerValue],
                     [currentPage.picture.userId integerValue]];
    
    [[LatteAPIClient sharedClient] getPath:urlCounter
                                parameters:[NSDictionary dictionaryWithObject:[app getToken] forKey:@"token"]
                                   success:nil
                                   failure:nil];
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
        
        CGRect frameContainer = viewPicTab.view.frame;
        frameContainer.origin.y = frameTab.origin.y + frameTab.size.height;
        
        viewTab.frame = frameTab;
        viewPicTab.view.frame = frameContainer;
        
//        [viewPicTab updateContent];
        
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
//        [viewPicTab updateContent];
    }];
    
    // Start loading extra info if rollup tab
    if (!loadedInfo) {
        [self loadInfo];
    }
}

- (void)loadInfo {
    loadedInfo = true;
    LXZoomPictureViewController *currentPage = pageController.viewControllers[0];
    LXAppDelegate *app = [LXAppDelegate currentDelegate];
    
    viewPicTab.picture = currentPage.picture;
    viewPicTab.viewVote.picture = currentPage.picture;
    if (viewPicTab.picture.comments) {
        viewPicTab.viewComment.comments = viewPicTab.picture.comments;
    } else {
        NSString *urlDetail = [NSString stringWithFormat:@"picture/%d", [currentPage.picture.pictureId integerValue]];
        [viewPicTab.viewComment.activityLoad startAnimating];
        [[LatteAPIClient sharedClient] getPath:urlDetail
                                    parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                       success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                           if (currentPage.user == nil) {
                                               currentPage.user = [User instanceFromDictionary:[JSON objectForKey:@"user"]];
                                               labelNickname.text = currentPage.user.name;
                                               [buttonUser loadBackground:currentPage.user.profilePicture placeholderImage:@"user.gif"];
                                           }
                                           
                                           currentComments = [Comment mutableArrayFromDictionary:JSON withKey:@"comments"];
                                           viewPicTab.viewComment.comments = currentComments;
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
}

- (IBAction)touchUser:(UIButton *)sender {
    LXZoomPictureViewController *currentPage = pageController.viewControllers[0];
    if (currentPage.user == nil) {
        return;
    }
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    LXMyPageViewController *viewUserPage = [mainStoryboard instantiateViewControllerWithIdentifier:@"UserPage"];
    viewUserPage.user = currentPage.user;
    [self.navigationController pushViewController:viewUserPage animated:YES];
    
}

- (IBAction)touchShare:(id)sender {
    LXZoomPictureViewController *currentPage = pageController.viewControllers[0];
    RDActionSheet *actionSheet = [[RDActionSheet alloc] initWithCancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                                               primaryButtonTitle:nil
                                                           destructiveButtonTitle:nil
                                                                otherButtonTitles:@"Email", @"Twitter", @"Facebook", nil];

    actionSheet.callbackBlock = ^(RDActionSheetResult result, NSInteger buttonIndex)
    {
        switch (result) {
            case RDActionSheetButtonResultSelected: {
                lxShare.url = currentPage.picture.urlWeb;
                lxShare.text = @"Latte";
                
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
        [self setTabHeight:320];
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
