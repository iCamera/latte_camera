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
#import "MZFormSheetSegue.h"

#import "LXPicVoteCollectionController.h"
#import "LXPicInfoViewController.h"
#import "LXPicCommentViewController.h"
#import "LXPicEditViewController.h"
#import "LXMyPageViewController.h"
#import "LXShare.h"
#import "Comment.h"
#import "LXTagHome.h"
#import "LXUserPageViewController.h"
#import "LXSocketIO.h"
#import "LXReportAbuseViewController.h"
#import "UIButton+AFNetworking.h"


@interface LXGalleryViewController ()

@end

@implementation LXGalleryViewController {
    UIPageViewController *pageController;
    UITapGestureRecognizer *tapPage;
    UITapGestureRecognizer *tapDouble;
    UILongPressGestureRecognizer *gestureLongPress;
    NSMutableArray *currentComments;
    LXShare *lxShare;
    UIScrollView *viewDesc;
    AFHTTPRequestOperation *currentRequest;
}

@synthesize buttonComment;
@synthesize buttonLike;
@synthesize viewTab;
@synthesize labelDesc;
@synthesize buttonEdit;
@synthesize labelNickname;
@synthesize buttonUser;
@synthesize labelView;
@synthesize viewInfoTop;
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

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (_picture.pictureId == nil)
        return;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pictureUpdate:) name:@"picture_update" object:nil];

    pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                     navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                   options:nil];
    
    
    pageController.dataSource = self;
    pageController.delegate = self;
    CGRect frame = self.view.bounds;

    pageController.view.frame = self.view.bounds;

    tapPage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleInfo:)];
    tapPage.numberOfTapsRequired = 1;

    tapDouble = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapZoom:)];
    tapDouble.numberOfTapsRequired = 2;
    
    gestureLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(holdShare:)];
    
    [tapPage requireGestureRecognizerToFail:tapDouble];
    
    [pageController.view addGestureRecognizer:tapPage];
    [pageController.view addGestureRecognizer:tapDouble];
    [pageController.view addGestureRecognizer:gestureLongPress];
    
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
    labelDesc.textSelectable = NO;
    [labelDesc setAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0]}];
    [labelDesc setAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0]} hotWord:STTweetHandle];
    [labelDesc setAttributes:@{NSForegroundColorAttributeName: [UIColor cyanColor], NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0]} hotWord:STTweetHashtag];
    labelDesc.shadowColor = [UIColor blackColor];
    labelDesc.shadowOffset = CGSizeMake(0, 1);
    
    __weak LXGalleryViewController *weakSelf = self;

    [labelDesc setDetectionBlock:^(STTweetHotWord hotWord, NSString *string, NSString *protocol, NSRange range) {
        NSString *displayString = NULL;
        
        // determine what the user clicked on
        switch (hotWord) {
                
                // if the user clicked on an account (@_max_k)
            case STTweetHandle:
                displayString = [NSString stringWithFormat:@"Twitter account:\n%@", string];
                break;
                
                // if the user clicked on a hashtag (#thisisreallycool)
            case STTweetHashtag: {
                displayString = [NSString stringWithFormat:@"Twitter hashtag:\n%@", string];
                
                UIStoryboard *storyMain = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                                    bundle:nil];
                LXTagHome *viewTag = [storyMain instantiateViewControllerWithIdentifier:@"TagHome"];
                viewTag.tag = [string substringFromIndex:1];
                viewTag.navigationItem.title = viewTag.tag;
                
                [weakSelf.navigationController pushViewController:viewTag animated:YES];
                
                break;
            }
                // if the user clicked on a website (http://github.com/SebastienThiebaud)
            case STTweetLink:
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:string]];
                break;
        }
    }];
    viewDesc = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 480, 320, 0)];
    viewDesc.backgroundColor = [UIColor colorWithWhite:0 alpha:0.25];
    viewDesc.indicatorStyle = UIScrollViewIndicatorStyleWhite;

    [self.view addSubview:viewDesc];
    [viewDesc addSubview:labelDesc];

    [self joinRoom];
    [self renderPicture];
    [self increaseCounter];
    [self reloadPicture];
    
    buttonUser.layer.cornerRadius = 17.5;
    buttonUser.layer.shouldRasterize = YES;
    buttonUser.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    buttonEdit.layer.cornerRadius = 17.5;
    _buttonClose.layer.cornerRadius = 17.5;
    _buttonStatus.layer.cornerRadius = 17.5;

    
    lxShare = [[LXShare alloc] init];
    lxShare.controller = self;
    
    LXAppDelegate *app = [LXAppDelegate currentDelegate];
    
    [app.tracker set:kGAIScreenName
               value:@"Gallery Screen"];
    
    [app.tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)reloadPicture {
    LXZoomPictureViewController *currentPage = pageController.viewControllers[0];
    NSString *url = [NSString stringWithFormat:@"picture/%ld", [currentPage.picture.pictureId longValue]];
    if (currentRequest && currentRequest.isExecuting) {
        [currentRequest cancel];
    }
    currentRequest = [[LatteAPIClient sharedClient] GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        [currentPage.picture setAttributesFromDictionary:JSON[@"picture"]];
        [self renderPicture];
    } failure:nil];
}

- (void)tapZoom:(UITapGestureRecognizer*)sender {
    LXZoomPictureViewController *currentPage = pageController.viewControllers[0];
    [currentPage performSelector:@selector(tapZoom:) withObject:sender];
}


- (void)toggleInfo:(UITapGestureRecognizer*)sender {
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
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    [super viewWillDisappear:animated];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    LXZoomPictureViewController *currentPage = pageController.viewControllers[0];
    
    if ([segue.identifier isEqualToString:@"Edit"]) {
        LXPicEditViewController *viewEdit = segue.destinationViewController;
        viewEdit.picture = currentPage.picture;
    } else if ([segue.identifier isEqualToString:@"Like"]) {
        MZFormSheetSegue *sheet = (MZFormSheetSegue*)segue;
        sheet.formSheetController.transitionStyle = MZFormSheetTransitionStyleSlideFromBottom;
        sheet.formSheetController.cornerRadius = 0;
        sheet.formSheetController.shouldDismissOnBackgroundViewTap = YES;
        sheet.formSheetController.portraitTopInset = 50;
        sheet.formSheetController.presentedFormSheetSize = CGSizeMake(320, self.view.bounds.size.height - sheet.formSheetController.portraitTopInset);
        
        LXPicVoteCollectionController *viewVote = segue.destinationViewController;
        viewVote.picture = currentPage.picture;
        viewVote.isModal = true;
        viewVote.parent = self;

    } else if ([segue.identifier isEqualToString:@"Comment"]) {
        MZFormSheetSegue *sheet = (MZFormSheetSegue*)segue;
        sheet.formSheetController.transitionStyle = MZFormSheetTransitionStyleSlideFromBottom;
        sheet.formSheetController.cornerRadius = 0;
        sheet.formSheetController.shouldDismissOnBackgroundViewTap = YES;
        sheet.formSheetController.portraitTopInset = 50;
        sheet.formSheetController.presentedFormSheetSize = CGSizeMake(320, self.view.bounds.size.height - sheet.formSheetController.portraitTopInset);

        LXPicCommentViewController *viewComment = segue.destinationViewController;
        viewComment.parent = self;
        viewComment.picture = currentPage.picture;
        viewComment.isModal = true;
    } else if ([segue.identifier isEqualToString:@"Info"]) {
        MZFormSheetSegue *sheet = (MZFormSheetSegue*)segue;
        sheet.formSheetController.transitionStyle = MZFormSheetTransitionStyleSlideFromBottom;
        sheet.formSheetController.cornerRadius = 0;
        sheet.formSheetController.shouldDismissOnBackgroundViewTap = YES;
        sheet.formSheetController.portraitTopInset = 50;
        sheet.formSheetController.presentedFormSheetSize = CGSizeMake(320, self.view.bounds.size.height - sheet.formSheetController.portraitTopInset);

        LXPicInfoViewController *viewInfo = segue.destinationViewController;
        viewInfo.parent = self;
        viewInfo.picture = currentPage.picture;
        viewInfo.isModal = true;
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
        [self joinRoom];
        [self renderPicture];
        [self increaseCounter];
        [self reloadPicture];
    }
    
    [UIView animateWithDuration:kGlobalAnimationSpeed animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {

}

- (void)joinRoom {
    LXZoomPictureViewController *currentPage = pageController.viewControllers[0];
    Picture *newPicture = currentPage.picture;
    
    LXSocketIO *socket = [LXSocketIO sharedClient];
    [socket sendEvent:@"join" withData:[NSString stringWithFormat:@"picture_%ld", [newPicture.pictureId longValue]]];
}

- (void)renderPicture {
    LXZoomPictureViewController *currentPage = pageController.viewControllers[0];
    Picture *newPicture = currentPage.picture;
    
    [labelDesc setText:newPicture.descriptionText];
    CGSize labelSize = [labelDesc suggestedFrameSizeToFitEntireStringConstraintedToWidth:308];
                   
    CGRect frame = labelDesc.frame;
    frame.size.height = labelSize.height;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGRect frameDesc = viewDesc.frame;
    frameDesc.size.height = MIN(frame.size.height + 12, 200);
    frameDesc.origin.y = screenRect.size.height-frameDesc.size.height-35;
    viewDesc.contentSize = CGSizeMake(320, frame.size.height + 12);
    
    if (newPicture.descriptionText.length == 0) {
        frameDesc.size.height = 0;
    }
    
    [UIView animateWithDuration:kGlobalAnimationSpeed
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         labelDesc.frame = frame;
                         viewDesc.frame = frameDesc;
                         
                     }
                     completion:^(BOOL finished) {
                         [viewDesc flashScrollIndicators];
                     }];
    
    
    if (currentPage.user) {
        labelNickname.text = currentPage.user.name;
        [LXUtils setNationalityOfUser:currentPage.user forImage:imageNationality nextToLabel:labelNickname];
        [buttonUser setImageForState:UIControlStateNormal withURL:[NSURL URLWithString:currentPage.user.profilePicture]];
        
    } else if (newPicture.user) {
        labelNickname.text = currentPage.picture.user.name;
        [LXUtils setNationalityOfUser:newPicture.user forImage:imageNationality nextToLabel:labelNickname];
        [buttonUser setImageForState:UIControlStateNormal withURL:[NSURL URLWithString:newPicture.user.profilePicture]];
    } else {
        NSString *url = [NSString stringWithFormat:@"user/%ld", [newPicture.userId longValue]];
        [[LatteAPIClient sharedClient] GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
            User *user = [User instanceFromDictionary:JSON[@"user"]];
            currentPage.user = user;
            labelNickname.text = user.name;
            [LXUtils setNationalityOfUser:user forImage:imageNationality nextToLabel:labelNickname];
            [buttonUser setImageForState:UIControlStateNormal withURL:[NSURL URLWithString:user.profilePicture]];
        } failure:nil];
    }
    
    [UIView transitionWithView:self.viewInfoTop duration:kGlobalAnimationSpeed options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        labelView.text = [NSString stringWithFormat:NSLocalizedString(@"d_views", @""), [newPicture.pageviews integerValue]];
        
        buttonEdit.hidden = !newPicture.isOwner;
    } completion:nil];
    
    _buttonStatus.hidden = !newPicture.isOwner;
    if (newPicture.isOwner) {
        if (newPicture.status == PictureStatusPublic) {
            [_buttonStatus setImage:[UIImage imageNamed:@"icon28-status40-white.png"] forState:UIControlStateNormal];
        } else if (newPicture.status == PictureStatusMember) {
            [_buttonStatus setImage:[UIImage imageNamed:@"icon28-status30-white.png"] forState:UIControlStateNormal];
        } else if (newPicture.status == PictureStatusFriendsOnly) {
            [_buttonStatus setImage:[UIImage imageNamed:@"icon28-status10-white.png"] forState:UIControlStateNormal];
        } else if (newPicture.status == PictureStatusPrivate) {
            [_buttonStatus setImage:[UIImage imageNamed:@"icon28-status0-white.png"] forState:UIControlStateNormal];
        }
    }
    

    buttonLike.selected = newPicture.isVoted;
    [buttonLike setTitle:[newPicture.voteCount stringValue] forState:UIControlStateNormal];
    
    [buttonComment setTitle:[newPicture.commentCount stringValue] forState:UIControlStateNormal];
    
    buttonEdit.hidden = !newPicture.isOwner;
}

- (void)increaseCounter {
    // Increase counter
    LXZoomPictureViewController *currentPage = pageController.viewControllers[0];
    NSString *urlCounter = [NSString stringWithFormat:@"picture/counter/%ld/%ld",
                            [currentPage.picture.pictureId longValue],
                            [currentPage.picture.userId longValue]];
    
    [[LatteAPIClient sharedClient] GET:urlCounter parameters:nil success:nil failure:nil];
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
    if (currentPage.picture.isOwner) {
        [self performSegueWithIdentifier:@"Like" sender:self];
    } else {
        LXAppDelegate* app = [LXAppDelegate currentDelegate];
        if (!app.currentUser) {
            UIStoryboard *storyAuth = [UIStoryboard storyboardWithName:@"Authentication" bundle:nil];
            UIViewController *viewLogin = [storyAuth instantiateViewControllerWithIdentifier:@"Login"];
            
            [self.navigationController pushViewController:viewLogin animated:YES];
        } else {
            [LXUtils toggleLike:sender ofPicture:currentPage.picture];
        }
    }
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
    [self showShare];
}

- (IBAction)touchStatus:(id)sender {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"privacy_setting", @"公開設定")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"cancel", @"キャンセル")
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:
                            NSLocalizedString(@"status_public", @"公開"),
                            NSLocalizedString(@"status_members", @"会員まで"),
                            NSLocalizedString(@"status_friends", @"友達まで"),
                            NSLocalizedString(@"status_private", @"非公開"), nil];
    sheet.tag = 1;
    sheet.delegate = self;
    [sheet showInView:self.view];
}

- (IBAction)holdShare:(UILongPressGestureRecognizer*)sender {
    if (sender.state == UIGestureRecognizerStateBegan){
        [self showShare];
    }
}

- (void)showShare {
    LXZoomPictureViewController *currentPage = pageController.viewControllers[0];
    Picture *pic = currentPage.picture;
    
    NSString *destructiveButtonTitle;
    if (pic.isOwner) {
        destructiveButtonTitle = NSLocalizedString(@"delete_photo", @"");
    } else {
        destructiveButtonTitle = NSLocalizedString(@"report", @"");
    }
    
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil
                                                        delegate:self
                                               cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:NSLocalizedString(@"Copy URL", @""), NSLocalizedString(@"Share to Facebook", @""), NSLocalizedString(@"Share to Twitter", @""), NSLocalizedString(@"Send email", @""), destructiveButtonTitle, nil];
    action.destructiveButtonIndex = 4;
    action.tag = 2;
    [action showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    LXZoomPictureViewController *currentPage = pageController.viewControllers[0];
    
    Picture *pic = currentPage.picture;
    if (actionSheet.tag == 1) {
        PictureStatus status = PictureStatusPublic;
        switch (buttonIndex) {
            case 0:
                status = PictureStatusPublic;
                break;
            case 1:
                status = PictureStatusMember;
                break;
            case 2:
                status = PictureStatusFriendsOnly;
                break;
            case 3:
                status = PictureStatusPrivate;
                break;
            default:
                return;
                break;
        }
        
        
        NSString *url = [NSString stringWithFormat:@"picture/%ld/edit", [_picture.pictureId longValue]];
        pic.status = status;
        [self renderPicture];
        [[LatteAPIClient sharedClient] POST:url parameters: @{@"status": [NSNumber numberWithInteger:status]} success:nil failure:nil];
    } else if (actionSheet.tag == 10) {
        if (buttonIndex == 0) { // Remove Pic
            NSString *url = [NSString stringWithFormat:@"picture/%ld/delete", [pic.pictureId longValue]];
            
            [[LatteAPIClient sharedClient] POST:url parameters: nil success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                [self dismissViewControllerAnimated:YES completion:^{
                    if ([_delegate respondsToSelector:@selector(reloadView)]) {
                        [_delegate performSelector:@selector(reloadView)];
                    }
                }];
                
            } failure:nil];
        }
    } else if (actionSheet.tag == 2) {
        lxShare = [[LXShare alloc] init];
        
        lxShare.url = pic.urlWeb;
        lxShare.controller = self;
        
        switch (buttonIndex) {
            case 0: {
                UIPasteboard *pb = [UIPasteboard generalPasteboard];
                [pb setString:pic.urlWeb];
                break;
            }
            case 1: // email
                [lxShare facebookPost];
                break;
            case 2: // twitter
                [lxShare tweet];
                break;
            case 3: // facebook
                [lxShare emailIt];
                break;
            case 4: {
                if (pic.isOwner) {
                    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                       delegate:self
                                                              cancelButtonTitle:NSLocalizedString(@"cancel", @"キャンセル")
                                                         destructiveButtonTitle:NSLocalizedString(@"delete_photo", @"この写真を削除する")
                                                              otherButtonTitles:nil];
                    sheet.tag = 10;
                    sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
                    [sheet showInView:self.view];
                } else {
                    UIStoryboard *storyGallery = [UIStoryboard storyboardWithName:@"Gallery" bundle:nil];
                    LXReportAbuseViewController *controllerReport = [storyGallery instantiateViewControllerWithIdentifier:@"Report"];
                    controllerReport.picture = pic;
                    [self.navigationController pushViewController:controllerReport animated:YES];
                }
            }
                break;
            default:
                break;
        }
    }
}


- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationFade;
}

- (void)pictureUpdate:(NSNotification*)notify {
    LXZoomPictureViewController *currentPage = pageController.viewControllers[0];
    
    NSDictionary *raw = notify.object;
    if ([currentPage.picture.pictureId longValue] == [raw[@"id"] longValue]) {
        [currentPage.picture setAttributesFromDictionary:raw];
        [self renderPicture];
    }
}

@end
