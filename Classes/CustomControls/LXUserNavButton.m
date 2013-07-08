//
//  LXUserNavButton.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 2/26/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXUserNavButton.h"
#import "LXAppDelegate.h"
#import "LatteAPIClient.h"
#import "LXAppDelegate.h"

@interface LXUserNavButton ()

@end

@implementation LXUserNavButton

@synthesize labelCount;
@synthesize buttonNotify;

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
    
    LXAppDelegate *app = [LXAppDelegate currentDelegate];
    if (app.currentUser != nil) {
        labelCount.hidden = false;
        buttonNotify.hidden = false;
    }
    self.notifyCount = [UIApplication sharedApplication].applicationIconBadgeNumber;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveLoggedIn:)
                                                 name:@"LoggedIn"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveLoggedOut:)
                                                 name:@"LoggedOut"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(becomeActive:)
                                                 name:@"BecomeActive" object:nil];
    
    labelCount.layer.cornerRadius = 5.0;
    labelCount.layer.masksToBounds = YES;
    
    // Do any additional setup after loading the view from its nib.
}

- (void)loadUnread {
    LXAppDelegate *app = [LXAppDelegate currentDelegate];
    [[LatteAPIClient sharedClient] getPath:@"user/me/unread_notify"
                                parameters: [NSDictionary dictionaryWithObject:[app getToken] forKey:@"token" ]
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       self.notifyCount = [[JSON objectForKey:@"notify_count"] integerValue];
                                   }
                                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       DLog(@"Something went wrong (Notify count)");
                                   }];
}

- (void)becomeActive:(NSNotification *) notification {
    LXAppDelegate *app = [LXAppDelegate currentDelegate];
    if (app.currentUser) {     
        [self loadUnread];
    }
}

- (void)receiveLoggedIn:(NSNotification *) notification {
    buttonNotify.hidden = false;
    
    [self loadUnread];
}

- (void)receiveLoggedOut:(NSNotification *) notification {
    labelCount.hidden = true;
    buttonNotify.hidden = true;
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
