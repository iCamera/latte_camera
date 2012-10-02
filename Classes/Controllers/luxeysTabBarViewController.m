//
//  luxeysTabBarViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/14/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "luxeysTabBarViewController.h"
#import "luxeysSideMenuViewController.h"
#import "luxeysAppDelegate.h"
#import "luxeysLoginViewController.h"
#import "luxeysCameraViewController.h"

#define kAnimationDuration .3

@interface luxeysTabBarViewController () {
    UIButton* buttonCamera;
}

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
    
    buttonCamera = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonCamera.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    UIImage* buttonImage = [UIImage imageNamed:@"camera.png"];
    UIImage* buttonBg = [UIImage imageNamed:@"bg_bottom_center.png"];
    buttonCamera.frame = CGRectMake(0.0, 0.0, buttonBg.size.width, buttonBg.size.height);
    buttonCamera.showsTouchWhenHighlighted = YES;

    [buttonCamera setImage:buttonImage forState:UIControlStateNormal];
    [buttonCamera setImage:buttonImage forState:UIControlStateHighlighted];
    [buttonCamera setBackgroundImage:buttonBg forState:UIControlStateNormal];
    [buttonCamera setBackgroundImage:buttonBg forState:UIControlStateHighlighted];
    
    CGFloat heightDifference = buttonBg.size.height - self.tabBar.frame.size.height;
    if (heightDifference < 0)
        buttonCamera.center = self.tabBar.center;
    else
    {
        CGPoint center = self.tabBar.center;
        center.y = center.y - heightDifference/2.0 + 1;
        buttonCamera.center = center;
    }
    [buttonCamera addTarget:self action:@selector(cameraView:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:buttonCamera];
    
    // Re-style tabbar item
    for(UIViewController *tab in self.viewControllers)
        
    {
        [tab.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                [UIColor whiteColor], UITextAttributeTextColor, nil]
                                      forState:UIControlStateNormal];
    }
}


- (void)cameraView:(id)sender {
    luxeysCameraViewController *viewCamera = [[UIStoryboard storyboardWithName:@"CameraStoryboard"
                                                                        bundle: nil] instantiateInitialViewController];
    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    app.storyCamera = viewCamera;
    app.window.rootViewController = viewCamera;
/*    [UIView transitionWithView:app.window duration:0.5 options: UIViewAnimationOptionTransitionFlipFromLeft animations:^{
        
    } completion:nil];*/
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
    CGRect cameraFrame = buttonCamera.frame;
	CGRect containerFrame = transitionView.frame;
	
	containerFrame.size.height = viewFrame.size.height - (hidden ? 0 : tabBarFrame.size.height);
    tabBarFrame.origin.y = viewFrame.size.height - (hidden ? (tabBarFrame.size.height - cameraFrame.size.height) : tabBarFrame.size.height);
    cameraFrame.origin.y = viewFrame.size.height - (hidden ? 0 : cameraFrame.size.height);
    if (hidden) {
        transitionView.frame = containerFrame;
        [UIView animateWithDuration:kAnimationDuration
                         animations:^{
                             self.tabBar.frame = tabBarFrame;
                             buttonCamera.frame = cameraFrame;
                         }
         ];
    } else {
        [UIView animateWithDuration:kAnimationDuration
                         animations:^{
                             self.tabBar.frame = tabBarFrame;
                             buttonCamera.frame = cameraFrame;
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



- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if (item.tag == 5)
    {
        [[NSNotificationCenter defaultCenter]
           postNotificationName:@"ShowTimeline"
           object:self];
    }
}

@end
