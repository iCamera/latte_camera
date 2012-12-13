//
//  luxeysRevealViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/12/06.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "LXRevealViewController.h"

@interface LXRevealViewController ()

@end

@implementation LXRevealViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    LXMainTabViewController *viewMainTab = (LXMainTabViewController*)[mainStoryboard instantiateInitialViewController];
    LXNotifySideViewController *rightViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"RightSide"];
    
    self = [super initWithFrontViewController:(UIViewController*)viewMainTab
                                                             leftViewController:rightViewController
                                                            rightViewController:nil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
