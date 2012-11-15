//
//  luxeysTabBarViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/14/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "luxeysTabBarViewController.h"
#import "luxeysAppDelegate.h"

@interface luxeysTabBarViewController ()

@end

@implementation luxeysTabBarViewController


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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showTab:)
                                                 name:@"TabbarShow"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideTab:)
                                                 name:@"TabbarHide"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newPicture:)
                                                 name:@"UploadedNewPicture"
                                               object:nil];
    
    isFirst = true;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    // Tab style
    for (UITabBarItem* tab in [self.tabBarController.tabBar items]) {
        NSLog(@"text");
        [tab setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                     [UIColor blackColor], UITextAttributeTextShadowColor,
                                     [NSValue valueWithUIOffset:UIOffsetMake(0, 1)], UITextAttributeTextShadowOffset,
                                     nil] forState:UIControlStateNormal];
    }

    
    UILabel *labelCamera = [[UILabel alloc] init];
    labelCamera.frame = CGRectMake(0.0, 0.0, 60, 11);
    labelCamera.font = [UIFont boldSystemFontOfSize:10];
    labelCamera.text = @"写真を追加";
    labelCamera.backgroundColor = [UIColor clearColor];
    labelCamera.textColor = [UIColor whiteColor];
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
    
    // Re-style tabbar item
    for(UIViewController *tab in self.viewControllers) {
        [tab.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                [UIColor whiteColor], UITextAttributeTextColor,
                                                CGSizeMake(0, 1), UITextAttributeTextShadowOffset,
                                                [UIColor blackColor], UITextAttributeTextShadowColor,
                                                nil]
                                      forState:UIControlStateNormal];
//        [tab.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"bt_info.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"bt_add.png"]];
    }
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
}


- (void)cameraView:(id)sender {
    [self pickPhoto];
}

- (void)pickPhoto {
    UINavigationController *storyCapture = [[UIStoryboard storyboardWithName:@"CameraStoryboard"
                                                                         bundle: nil] instantiateInitialViewController];
    luxeysCameraViewController *viewCapture = storyCapture.viewControllers[0];
    viewCapture.delegate = self;
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
    [self presentViewController:storyCapture animated:NO completion:nil];
}

- (void)imagePickerController:(luxeysCameraViewController *)picker didFinishPickingMediaWithData:(NSData *)data {
    [picker performSegueWithIdentifier:@"Edit" sender:data];
}

- (void)viewWillAppear:(BOOL)animated {
    
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    [super viewWillAppear:animated];
}


- (void)viewDidAppear:(BOOL)animated {
    if (isFirst) {
        isFirst = false;
        [self pickPhoto];
    }
    
    [super viewDidAppear:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillDisappear:(BOOL)animated {
    //[self setTabBarHidden:YES];
}

- (void)receiveLoggedIn:(NSNotification *) notification
{
    [[self.tabBar.items objectAtIndex:3] setEnabled:YES];
    [[self.tabBar.items objectAtIndex:4] setEnabled:YES];
}

- (void)receiveLoggedOut:(NSNotification *) notification
{
    [[self.tabBar.items objectAtIndex:3] setEnabled:NO];
    [[self.tabBar.items objectAtIndex:4] setEnabled:NO];
}


- (BOOL)isTabBarHidden {
	CGRect viewFrame = self.view.frame;
	CGRect tabBarFrame = self.tabBar.frame;
	return tabBarFrame.origin.y >= viewFrame.size.height;
}


- (void)setTabBarHidden:(BOOL)hidden {
	[self setTabBarHidden:hidden animated:NO];
}


- (void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated {
	BOOL isHidden = self.tabBarHidden;
	if(hidden == isHidden)
		return;
	UIView *transitionView = [[[self.view.subviews reverseObjectEnumerator] allObjects] lastObject];
	if(transitionView == nil) {
		NSLog(@"could not get the container view!");
		return;
	}
	CGRect viewFrame = self.view.frame;
	CGRect tabBarFrame = self.tabBar.frame;
    CGRect cameraFrame = viewCamera.frame;
	CGRect containerFrame = transitionView.frame;
	
	containerFrame.size.height = viewFrame.size.height - (hidden ? 0 : tabBarFrame.size.height);
    tabBarFrame.origin.y = viewFrame.size.height - (hidden ? (tabBarFrame.size.height - cameraFrame.size.height) : tabBarFrame.size.height);
    cameraFrame.origin.y = viewFrame.size.height - (hidden ? 0 : cameraFrame.size.height);
    if (hidden) {
        transitionView.frame = containerFrame;
        [UIView animateWithDuration:kAnimationDuration
                         animations:^{
                             self.tabBar.frame = tabBarFrame;
                             viewCamera.frame = cameraFrame;
                         }
         ];
    } else {
        [UIView animateWithDuration:kAnimationDuration
                         animations:^{
                             self.tabBar.frame = tabBarFrame;
                             viewCamera.frame = cameraFrame;
                         }
                         completion:^(BOOL finished) {
                             transitionView.frame = containerFrame;
                         }
         ];
    }
    
}

- (void)showTab:(NSNotification *) notification
{
    [self setTabBarHidden:FALSE];
}

- (void)hideTab:(NSNotification *) notification
{
    [self setTabBarHidden:TRUE];
}

- (void)newPicture:(NSNotification *) notification
{
    self.selectedIndex = 4;
}

@end
