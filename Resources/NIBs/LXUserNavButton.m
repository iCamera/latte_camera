//
//  LXUserNavButton.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 2/26/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXUserNavButton.h"
#import "LXAppDelegate.h"

@interface LXUserNavButton ()

@end

@implementation LXUserNavButton

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

- (IBAction)touchNotify:(id)sender {
}

- (IBAction)touchSetting:(id)sender {

}
- (void)viewDidUnload {
    [self setButtonNotify:nil];
    [self setButtonSetting:nil];
    [super viewDidUnload];
}
@end
