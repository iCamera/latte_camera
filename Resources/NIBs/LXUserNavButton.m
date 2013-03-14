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

@synthesize labelCount;

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
    self.notifyCount = [UIApplication sharedApplication].applicationIconBadgeNumber;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivePushNotify:)
                                                 name:@"ReceivedPushNotify"
                                               object:nil];
    labelCount.layer.cornerRadius = 5.0;
    labelCount.layer.masksToBounds = YES;
    
    // Do any additional setup after loading the view from its nib.
}

- (void)receivePushNotify:(NSNotification*)notify {
    NSDictionary *userInfo = notify.object;
    if ([userInfo objectForKey:@"aps"]) {
        NSDictionary *aps = [userInfo objectForKey:@"aps"];
        if ([aps objectForKey:@"badge"]) {
            NSNumber *count = [aps objectForKey:@"badge"];
            self.notifyCount = [count integerValue];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setNotifyCount:(NSInteger)notifyCount {
    labelCount.hidden = notifyCount == 0;
    labelCount.text = [NSString stringWithFormat:@"%d", notifyCount];
}

- (void)viewDidUnload {
    [self setButtonNotify:nil];
    [self setButtonSetting:nil];
    [super viewDidUnload];
}
@end
