//
//  LXNavGalleryViewController.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 3/7/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXNavGalleryViewController.h"
#import "LXButtonBack.h"
#import "MTStatusBarOverlay.h"

@interface LXNavGalleryViewController ()

@end

@implementation LXNavGalleryViewController

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
	// Do any additional setup after loading the view.
    self.delegate = self;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {    
    //setup back button
    if ([navigationController.viewControllers indexOfObject:viewController] > 0) {
        LXButtonBack *buttonBack = [[LXButtonBack alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
        [buttonBack setTitle:NSLocalizedString(@"back", @"BACK") forState:UIControlStateNormal];
        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonBack];
        [buttonBack addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)popViewController {
    [self popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:animated];
//    MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedInstance];
//    [overlay hideTemporary];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
//    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:animated];
    [super viewWillDisappear:animated];
}

@end
