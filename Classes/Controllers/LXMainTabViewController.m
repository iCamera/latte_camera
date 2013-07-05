//
//  luxeysTabBarViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/14/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "LXLoginViewController.h"
#import "User.h"
#import "Picture.h"
#import "LXCanvasViewController.h"
#import "LXMainTabViewController.h"
#import "LXAppDelegate.h"
#import "LXAboutViewController.h"
#import "LXUserNavButton.h"
#import "LXMyPageViewController.h"
#import "LXNavMypageController.h"
#import "LXNotifySideViewController.h"
#import "LXUploadStatusViewController.h"
#import "LXUploadObject.h"
#import "MBProgressHUD.h"

@interface LXMainTabViewController ()

@end

@implementation LXMainTabViewController {
    UIView *viewCamera;
    BOOL isFirst;

    LXNotifySideViewController *viewNotify;
    LXUploadStatusViewController *viewUpload;
    LXUserNavButton *viewNav;
    UIButton *buttonUploadStatus;
    MBRoundProgressView *hudUpload;
    
    UINavigationController *navTop;
    UINavigationController *navRank;
    UINavigationController *navSearch;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveLoggedIn:)
                                                 name:@"LoggedIn"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveLoggedOut:)
                                                 name:@"LoggedOut"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadSuccess:) name:@"LXUploaderSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadProgess:) name:@"LXUploaderProgress" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadStart:) name:@"LXUploaderStart" object:nil];
    
    isFirst = true;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    // Init View
    UIStoryboard* storyMain = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    viewNotify = [storyMain instantiateViewControllerWithIdentifier:@"Notification"];
    viewUpload = [storyMain instantiateViewControllerWithIdentifier:@"UploadStatus"];
    navTop = [storyMain instantiateViewControllerWithIdentifier:@"NavigationTop"];
    navRank = [storyMain instantiateViewControllerWithIdentifier:@"NavigationRank"];
    navSearch = [storyMain instantiateViewControllerWithIdentifier:@"NavigationSearch"];

    
    // Tab style
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    for (UITabBarItem* tab in [self.tabBarController.tabBar items]) {
        DLog(@"text");
        [tab setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                     [UIColor blackColor], UITextAttributeTextShadowColor,
                                     [NSValue valueWithUIOffset:UIOffsetMake(0, 1)], UITextAttributeTextShadowOffset,
                                     nil] forState:UIControlStateNormal];
    }

    
    UILabel *labelCamera = [[UILabel alloc] init];
    labelCamera.frame = CGRectMake(0.0, 0.0, 60, 14);
    
    labelCamera.font = [UIFont fontWithName:@"HelveticaNeue" size:9];

    labelCamera.text = NSLocalizedString(@"start_camera", @"写真を追加");
    labelCamera.backgroundColor = [UIColor clearColor];
    labelCamera.textColor = [UIColor whiteColor];
    labelCamera.shadowColor = [UIColor blackColor];
    labelCamera.shadowOffset = CGSizeMake(0, 1);
    labelCamera.textAlignment = NSTextAlignmentCenter;

    UIButton *buttonCamera = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage* buttonImage = [UIImage imageNamed:@"camera.png"];
    UIImage* buttonBg = [UIImage imageNamed:@"bg_bottom_center.png"];

    viewCamera = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, buttonBg.size.width, buttonBg.size.height)];
    viewCamera.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    buttonCamera.frame = viewCamera.frame;
    buttonCamera.showsTouchWhenHighlighted = YES;

    [buttonCamera setImage:buttonImage forState:UIControlStateNormal];
    [buttonCamera setImage:buttonImage forState:UIControlStateHighlighted];
    [buttonCamera setBackgroundImage:buttonBg forState:UIControlStateNormal];
    [buttonCamera setBackgroundImage:buttonBg forState:UIControlStateHighlighted];
    
    CGFloat heightDifference = buttonBg.size.height - self.tabBar.frame.size.height;
    if (heightDifference < 0)
        viewCamera.center = self.tabBar.center;
    else
    {
        CGPoint center = self.tabBar.center;
        center.y = center.y - heightDifference/2.0 + 1;
        viewCamera.center = center;
    }
    [buttonCamera addTarget:self action:@selector(cameraView:) forControlEvents:UIControlEventTouchUpInside];

    [viewCamera addSubview:buttonCamera];
    CGPoint center = buttonCamera.center;
    center.y += 20;
    labelCamera.center = center;
    [viewCamera addSubview:labelCamera];
    [self.view addSubview:viewCamera];
    

    self.tabBar.selectionIndicatorImage = [UIImage imageNamed:@"bg_bottom_on.png"];
    self.tabBar.backgroundImage = [UIImage imageNamed: @"bg_bottom.png"];
    
    // add the drop shadow
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.tabBar.bounds];
    self.tabBar.layer.masksToBounds = NO;
    self.tabBar.layer.shadowColor = [UIColor blackColor].CGColor;
    self.tabBar.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    self.tabBar.layer.shadowOpacity = 0.8f;
    self.tabBar.layer.shadowRadius = 2.5f;
    self.tabBar.layer.shadowPath = shadowPath.CGPath;
    
    LXAppDelegate* app = [LXAppDelegate currentDelegate];
    if (app.currentUser != nil) {
        [self setUser];
    } else {
        [self setGuest];
    }
    
    viewNav = [[LXUserNavButton alloc] init];
    viewNav.view.frame = CGRectMake(210, 0, 110, 60);

    [viewNav.buttonSetting addTarget:self action:@selector(showSetting:) forControlEvents:UIControlEventTouchUpInside];
    [viewNav.buttonNotify addTarget:self action:@selector(toggleNotify:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:viewNav.view];
//    [self addChildViewController:viewNav];
    [viewNav didMoveToParentViewController:self];
    
    for(UIViewController *tab in self.viewControllers) {
        
        UIFont *font;

        font = [UIFont fontWithName:@"HelveticaNeue" size:9];
        
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    font, UITextAttributeFont,
                                    [UIColor whiteColor], UITextAttributeTextColor,
                                    [NSValue valueWithCGSize:CGSizeMake(0, 1)], UITextAttributeTextShadowOffset,
                                    [UIColor blackColor], UITextAttributeTextShadowColor,
                                    nil];
        
        [tab.tabBarItem setTitleTextAttributes:attributes
                                      forState:UIControlStateNormal];
    }
    
    viewNotify.view.frame = self.view.bounds;
    viewNotify.parent = self;
//    [self addChildViewController:viewNotify];
    [self.view addSubview:viewNotify.view];
    [viewNotify didMoveToParentViewController:self];
    viewNotify.view.hidden = true;
    
    viewUpload.view.frame = self.view.bounds;
//    [self addChildViewController:viewUpload];
    [self.view addSubview:viewUpload.view];
    [viewUpload didMoveToParentViewController:self];
    viewUpload.view.hidden = true;
    
    UIScreen *screen = [UIScreen mainScreen];
    
    buttonUploadStatus = [[UIButton alloc] initWithFrame:CGRectMake(280, screen.bounds.size.height-110, 30, 30)];
    [buttonUploadStatus addTarget:self action:@selector(toggleUpload:) forControlEvents:UIControlEventTouchUpInside];
    hudUpload = [[MBRoundProgressView alloc] initWithFrame:buttonUploadStatus.bounds];
    hudUpload.userInteractionEnabled = NO;
    [buttonUploadStatus addSubview:hudUpload];
    [self.view addSubview:buttonUploadStatus];
    buttonUploadStatus.hidden = YES;
}

- (void)showNotify {
    viewNav.notifyCount = 0;
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    viewNotify.view.alpha = 0;
    viewNotify.view.hidden = false;
    [viewNotify switchTab:viewNotify.buttonNotifyAll];
    
    [UIView animateWithDuration:kGlobalAnimationSpeed animations:^{
        viewNotify.view.alpha = 1;
    }];
}

- (void)toggleNotify:(id)sender {
    if (viewNotify.view.hidden) {
        [self showNotify];
    } else {
        [UIView animateWithDuration:kGlobalAnimationSpeed animations:^{
            viewNotify.view.alpha = 0;
        } completion:^(BOOL finished) {
            viewNotify.view.hidden = true;
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:animated];
    [super viewWillAppear:animated];
}

- (void)showSetting:(id)sender {
    UIStoryboard* storySetting = [UIStoryboard storyboardWithName:@"Setting" bundle:nil];
    [self presentViewController:[storySetting instantiateInitialViewController] animated:YES completion:nil];

}


- (void)cameraView:(id)sender {
    UIStoryboard* storySetting = [UIStoryboard storyboardWithName:@"Camera" bundle:nil];
    [self presentViewController:[storySetting instantiateInitialViewController] animated:YES completion:nil];
}

- (void)imagePickerController:(LXCanvasViewController *)picker didFinishPickingMediaWithData:(NSDictionary *)info {
    [picker performSegueWithIdentifier:@"Edit" sender:info];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [super viewDidUnload];
}


- (void)setGuest {
    LXNavMypageController *navMypage = self.viewControllers[4];
    navMypage.tabBarItem.image = [UIImage imageNamed:@"icon_login.png"];    
    UIStoryboard* storyMain = [UIStoryboard storyboardWithName:@"Authentication" bundle:nil];
    UIViewController *viewLogin = [storyMain instantiateViewControllerWithIdentifier:@"Login"];
    
    navMypage.viewControllers = [NSArray arrayWithObject:viewLogin];
    
    LXAppDelegate *app = [LXAppDelegate currentDelegate];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    app.controllerSide.leftPanel = [mainStoryboard instantiateViewControllerWithIdentifier:@"LeftGuest"];
}

- (void)setUser {
    LXNavMypageController *navMypage = self.viewControllers[4];
    navMypage.tabBarItem.image = [UIImage imageNamed:@"icon_mypage.png"];
    UIStoryboard* storyMain = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UIViewController *viewMypage = [storyMain instantiateViewControllerWithIdentifier:@"UserPage"];
    navMypage.viewControllers = [NSArray arrayWithObject:viewMypage];
    
    LXAppDelegate *app = [LXAppDelegate currentDelegate];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    app.controllerSide.leftPanel = [mainStoryboard instantiateViewControllerWithIdentifier:@"LeftUser"];
}

- (void)receiveLoggedIn:(NSNotification *) notification {
    [self setUser];
    
    // Register for Push Notification
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
}

- (void)receiveLoggedOut:(NSNotification *) notification {
    [self setGuest];
    if (!viewNotify.view.hidden) {
        [self toggleNotify:nil];
    }
}

- (void)showUser:(NSNotification *)notify {
    self.selectedIndex = 4;
    UINavigationController *nav = (id)self.selectedViewController;
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    LXMyPageViewController *viewUser = [mainStoryboard instantiateViewControllerWithIdentifier:@"UserPage"];
    User *user = notify.object;
    viewUser.user = user;
    [nav pushViewController:viewUser animated:YES];
}


- (void)touchTitle:(id)sender {
    LXAppDelegate* app = [LXAppDelegate currentDelegate];
    if (app.currentUser != nil) {
        if (self.selectedIndex == 4) {
            UINavigationController *nav = (UINavigationController*)self.viewControllers[4];
            LXMyPageViewController *controllerMyPage = (LXMyPageViewController*)nav.viewControllers[0];
            [controllerMyPage.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
        } else
            self.selectedIndex = 4;
    } else {
        self.selectedIndex = 0;
    }
}

- (void)uploadStart:(NSNotification *) notification {
    buttonUploadStatus.hidden = NO;
}

- (void)uploadSuccess:(NSNotification *) notification {
    LXAppDelegate* app = [LXAppDelegate currentDelegate];
    buttonUploadStatus.hidden = app.uploader.count == 0;
}

- (void)uploadProgess:(NSNotification *) notification {
    float percent = 0;
    LXAppDelegate* app = [LXAppDelegate currentDelegate];
    for (LXUploadObject *uploader in app.uploader) {
        percent += uploader.percent;
    }
    hudUpload.progress = percent/app.uploader.count;
}

- (void)toggleUpload:(id)sender {
    if (viewUpload.view.hidden) {
        viewUpload.view.alpha = 0;
        viewUpload.view.hidden = false;
        [UIView animateWithDuration:kGlobalAnimationSpeed animations:^{
            viewUpload.view.alpha = 1;
        }];
    } else {
        [UIView animateWithDuration:kGlobalAnimationSpeed animations:^{
            viewUpload.view.alpha = 0;
        } completion:^(BOOL finished) {
            viewUpload.view.hidden = true;
        }];
    }
}


@end
