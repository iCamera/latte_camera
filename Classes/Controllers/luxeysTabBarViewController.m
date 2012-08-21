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

@interface luxeysTabBarViewController ()

@end

@implementation luxeysTabBarViewController

@synthesize navigationBarPanGestureRecognizer;

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
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    UIImage* buttonImage = [UIImage imageNamed:@"camera.png"];
    UIImage* buttonBg = [UIImage imageNamed:@"bg_bottom_center.png"];
    button.frame = CGRectMake(0.0, 0.0, buttonBg.size.width, buttonBg.size.height);
    button.showsTouchWhenHighlighted = YES;

    [button setImage:buttonImage forState:UIControlStateNormal];
    [button setImage:buttonImage forState:UIControlStateHighlighted];
    [button setBackgroundImage:buttonBg forState:UIControlStateNormal];
    [button setBackgroundImage:buttonBg forState:UIControlStateHighlighted];
    
    CGFloat heightDifference = buttonBg.size.height - self.tabBar.frame.size.height;
    if (heightDifference < 0)
        button.center = self.tabBar.center;
    else
    {
        CGPoint center = self.tabBar.center;
        center.y = center.y - heightDifference/2.0;
        button.center = center;
    }
    [button addTarget:self action:@selector(cameraView:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button];
    
    // Re-style tabbar item
    for(UIViewController *tab in self.viewControllers)
        
    {
        [tab.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                [UIColor whiteColor], UITextAttributeTextColor, nil]
                                      forState:UIControlStateNormal];
    }
}

- (void)cameraView:(id)sender {
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    luxeysCameraViewController *viewCamera = [[UIStoryboard storyboardWithName:@"CameraStoryboard"
                                                                        bundle: nil] instantiateInitialViewController];
    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
    [UIView transitionWithView:app.window duration:0.5 options: UIViewAnimationOptionTransitionFlipFromLeft animations:^{
        app.storyCamera = viewCamera;
        app.window.rootViewController = viewCamera;
    } completion:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setButtonReveal:nil];
    [super viewDidUnload];
}

- (void)addLoginBehavior{
    // Init side bar
    //NSLog(NSStringFromClass([self.navigationController.parentViewController class]));
    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
    navigationBarPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:app.storyMain action:@selector(revealGesture:)];
	[self.navigationController.navigationBar addGestureRecognizer:navigationBarPanGestureRecognizer];
        //[self.buttonReveal addTarget:self.navigationController.parentViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)removeLoginBehavior{
    [self.navigationController.navigationBar removeGestureRecognizer:navigationBarPanGestureRecognizer];
    //[self.buttonReveal addTarget:self.navigationController.parentViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
}

- (IBAction)loginPressed:(id)sender {
    [self performSegueWithIdentifier:@"Login" sender:self];
}

- (void)userLoggedIn {
    [self addLoginBehavior];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Login"]) {
        luxeysLoginViewController *viewLogin = (luxeysLoginViewController*)segue.destinationViewController;
        [viewLogin setDelegate:self];
    }
}

@end
