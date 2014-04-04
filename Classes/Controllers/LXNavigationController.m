//
//  LXNavigationController.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 3/19/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXNavigationController.h"
#import "LXAppDelegate.h"
#import "LXButtonBack.h"

@interface LXNavigationController ()

@end

@implementation LXNavigationController

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
    
    //self.delegate = app.viewMainTab;
    self.delegate = self;
	// Do any additional setup after loading the view.
    
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    // Setup title
//    LXAppDelegate* app = [LXAppDelegate currentDelegate];
//    UIButton *buttonTittle = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
//    [buttonTittle setImage:[UIImage imageNamed:@"logo.png"] forState:UIControlStateNormal];
//    buttonTittle.showsTouchWhenHighlighted = true;
//    buttonTittle.adjustsImageWhenDisabled = false;
//    buttonTittle.adjustsImageWhenHighlighted = false;
//    [buttonTittle addTarget:app.viewMainTab action:@selector(touchTitle:) forControlEvents:UIControlEventTouchUpInside];
//    viewController.navigationItem.titleView = buttonTittle;
    
//    //setup back button
//    if ([navigationController.viewControllers indexOfObject:viewController] > 0) {
//        LXButtonBack *buttonBack = [[LXButtonBack alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
//        [buttonBack setTitle:NSLocalizedString(@"back", @"BACK") forState:UIControlStateNormal];
//        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonBack];
//        [buttonBack addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];
//    }
}

- (void)popViewController {
    [self popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
