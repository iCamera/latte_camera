//
//  LXUserPageHead.m
//  Latte camera
//
//  Created by Xuan Dung Bui on 7/29/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import "LXUserPageHead.h"

@interface LXUserPageHead ()

@end

@implementation LXUserPageHead

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)touchBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
