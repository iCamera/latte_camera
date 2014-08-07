//
//  LXNotificationBar.m
//  Latte camera
//
//  Created by Xuan Dung Bui on 8/7/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import "LXNotificationBar.h"
#import "LXAppDelegate.h"
#import "LatteAPIClient.h"
#import "MZFormSheetController.h"

@implementation LXNotificationBar {
    UIButton *buttonNotify;
    UILabel *labelNotifyCount;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        buttonNotify = [UIButton buttonWithType:UIButtonTypeSystem];
        buttonNotify.frame = CGRectMake(0, 0, 33, 33);
        buttonNotify.tintColor = [UIColor whiteColor];
        
        labelNotifyCount = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 14, 14)];
        labelNotifyCount.backgroundColor = [UIColor redColor];
        labelNotifyCount.textColor = [UIColor whiteColor];
        labelNotifyCount.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0];
        labelNotifyCount.textAlignment = NSTextAlignmentCenter;
        labelNotifyCount.layer.masksToBounds = YES;
        labelNotifyCount.layer.cornerRadius = 7;
        labelNotifyCount.hidden = YES;
        
        [buttonNotify setImage:[UIImage imageNamed:@"icon40-notify-brown.png"] forState:UIControlStateNormal];
        [buttonNotify addTarget:self action:@selector(showNotify:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:buttonNotify];
        [self addSubview:labelNotifyCount];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCount:) name:@"NotifyCount" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveLoggedIn:) name:@"LoggedIn" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveLoggedOut:) name:@"LoggedOut" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userUpdate:) name:@"user_update" object:nil];
        
        LXAppDelegate *app = [LXAppDelegate currentDelegate];
        if (app.currentUser) {
            self.hidden = NO;
        } else {
            self.hidden = YES;
        }
        
        if ([UIApplication sharedApplication].applicationIconBadgeNumber > 0) {
            labelNotifyCount.hidden = NO;
            labelNotifyCount.text = [NSString stringWithFormat:@"%ld", (long)[UIApplication sharedApplication].applicationIconBadgeNumber];
        } else {
            labelNotifyCount.hidden = YES;
        }
    }
    return self;
}

- (void)receiveLoggedIn:(NSNotification *) notification {
    self.hidden = NO;
}

- (void)receiveLoggedOut:(NSNotification *) notification {
    self.hidden = YES;
}

- (void)updateCount:(NSNotification *)notification {
    NSNumber *notifyCount = notification.object;
    if (notifyCount.longValue > 0) {
        labelNotifyCount.hidden = NO;
        labelNotifyCount.text = notifyCount.stringValue;
    } else {
        labelNotifyCount.hidden = YES;
    }
}

- (void)userUpdate:(NSNotification *)notification {
    NSDictionary *rawUser = notification.object;
    if (rawUser[@"notification_count"]) {
        LXAppDelegate* app = [LXAppDelegate currentDelegate];
        if (app.currentUser) {
            if ([app.currentUser.userId integerValue] == [rawUser[@"id"] integerValue]) {
                NSInteger notifyCount = [rawUser[@"notification_count"] integerValue];
                if (notifyCount > 0) {
                    labelNotifyCount.hidden = NO;
                    labelNotifyCount.text = [NSString stringWithFormat:@"%ld", (long)notifyCount];
                } else {
                    labelNotifyCount.hidden = YES;
                }
            }
        }
    }
}

- (void)showNotify:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NotifyCount" object:[NSNumber numberWithInteger:0]];
    UIStoryboard *storyMain = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UIViewController *viewNotification = [storyMain instantiateViewControllerWithIdentifier:@"Notification"];
    
    // present form sheet with view controller
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:viewNotification];
    
    formSheet.cornerRadius = 0;
    formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromBottom;
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    formSheet.portraitTopInset = 44;
    formSheet.presentedFormSheetSize = CGSizeMake(320, _parent.view.bounds.size.height - formSheet.formSheetController.portraitTopInset);
    
    [_parent mz_presentFormSheetController:formSheet animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
        //do sth
    }];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
