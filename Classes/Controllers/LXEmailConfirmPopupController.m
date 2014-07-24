//
//  LXEmailConfirmPopupController.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 8/6/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXEmailConfirmPopupController.h"

@interface LXEmailConfirmPopupController ()

@end

@implementation LXEmailConfirmPopupController
@synthesize viewWrap;

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
    viewWrap.layer.cornerRadius = 5;
    viewWrap.layer.masksToBounds = YES;
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)touchClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"LoggedIn"
         object:self];
    }];
}
- (void)viewDidUnload {
    [self setViewWrap:nil];
    [super viewDidUnload];
}
@end
