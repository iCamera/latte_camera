//
//  LXTagHome.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 6/30/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import "LXTagHome.h"
#import "LXTagDiscussionViewController.h"
#import "LXTagViewController.h"

@interface LXTagHome ()

@end

@implementation LXTagHome

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"TagChat"]) {
        LXTagDiscussionViewController *tagChat = segue.destinationViewController;
        tagChat.tag = _tag;
    } else if ([segue.identifier isEqualToString:@"TagPhoto"]) {
        LXTagViewController *tagPhoto = segue.destinationViewController;
        tagPhoto.keyword = _tag;
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
