//
//  luxeysUserViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/20/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "luxeysUserViewController.h"
#import "UIImageView+AFNetworking.h"
#import "luxeysLatteAPIClient.h"
#import "luxeysAppDelegate.h"
#import "luxeysUserProfileViewController.h"

@interface luxeysUserViewController ()

@end

@implementation luxeysUserViewController
@synthesize viewScroll;
@synthesize imageUser;
@synthesize labelVote;
@synthesize labelPhoto;
@synthesize labelFriend;
@synthesize viewStats;
@synthesize viewContent;
@synthesize dictUser;
@synthesize buttonProfile;
@synthesize buttonCalendar;
@synthesize buttonMap;

int intTab = 1;

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
    // Style
//    viewContent.layer.shadowColor = [UIColor blackColor].CGColor;
//    viewContent.layer.shadowOffset = CGSizeMake(0, 1);
//    viewContent.layer.shadowOpacity = 1;
//    viewContent.layer.shadowRadius = 1.0;
//    viewContent.clipsToBounds = NO;
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:imageUser.bounds];
    imageUser.layer.masksToBounds = NO;
    imageUser.layer.shadowColor = [UIColor blackColor].CGColor;
    imageUser.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    imageUser.layer.shadowOpacity = 1.0f;
    imageUser.layer.shadowRadius = 1.0f;
    imageUser.layer.shadowPath = shadowPath.CGPath;

    // Data
    
    [self.imageUser setImageWithURL:[NSURL URLWithString:[dictUser objectForKey:@"profile_picture"]]];
    [self.navigationItem setTitle:[dictUser objectForKey:@"name"]];
    self.viewScroll.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_sub_back.png"]];
    luxeysAppDelegate* app = (luxeysAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSString* strURL = [NSString stringWithFormat:@"api/user/%d", [[dictUser objectForKey:@"id"] integerValue]];
    [[luxeysLatteAPIClient sharedClient] getPath:strURL
                                      parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                         success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                             NSDictionary* dictAdd = [JSON objectForKey:@"user"];
                                             labelFriend.text = [[dictAdd objectForKey:@"count_friends"] stringValue];
                                             labelPhoto.text = [[dictAdd objectForKey:@"count_pictures"] stringValue];
                                             labelVote.text = [[dictAdd objectForKey:@"vote_count"] stringValue];
                                             
                                             UIStoryboard* storyUser = [UIStoryboard storyboardWithName:@"UserStoryboard" bundle:nil];
                                             luxeysUserProfileViewController* viewProfile = (luxeysUserProfileViewController*)[storyUser instantiateViewControllerWithIdentifier:@"Profile"];
                                             viewProfile.arData = [JSON objectForKey:@"profile"];
                                             viewProfile.view.frame = CGRectMake(0, 179, self.view.frame.size.width, viewProfile.view.frame.size.height);
                                             
                                             UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:viewProfile.view.bounds];
                                             viewProfile.view.layer.masksToBounds = NO;
                                             viewProfile.view.layer.shadowColor = [UIColor blackColor].CGColor;
                                             viewProfile.view.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
                                             viewProfile.view.layer.shadowOpacity = 0.5f;
                                             viewProfile.view.layer.shadowRadius = 2.0f;
                                             viewProfile.view.layer.shadowPath = shadowPath.CGPath;
                                             
                                             //[viewContent addSubview:(id)viewProfile.view];
                                             [viewScroll addSubview:viewProfile.view];
                                             [viewScroll setContentSize:CGSizeMake(320, viewStats.frame.size.height + viewProfile.view.frame.size.height)];
                                         }
                                         failure:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setImageUser:nil];
    [self setLabelVote:nil];
    [self setLabelPhoto:nil];
    [self setLabelFriend:nil];
    [self setViewStats:nil];
    [self setViewContent:nil];
    [self setButtonProfile:nil];
    [self setButtonCalendar:nil];
    [self setButtonMap:nil];
    [self setViewScroll:nil];
    [super viewDidUnload];
}

- (IBAction)touchTab:(UIButton *)sender {
    sender.enabled = NO;
    switch (sender.tag) {
        case 1:
            buttonCalendar.enabled = YES;
            buttonMap.enabled = YES;
            break;
        case 2:
            buttonProfile.enabled = YES;
            buttonMap.enabled = YES;
            break;
        case 3:
            buttonCalendar.enabled = YES;
            buttonProfile.enabled = YES;
            break;
    }
}

@end
