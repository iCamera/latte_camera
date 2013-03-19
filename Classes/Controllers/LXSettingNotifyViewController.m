//
//  LXSettingNotifyViewController.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 3/4/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXSettingNotifyViewController.h"

#import "LatteAPIClient.h"
#import "LXAppDelegate.h"
#import "User.h"
#import "LXButtonBack.h"

@interface LXSettingNotifyViewController ()

@end

@implementation LXSettingNotifyViewController

@synthesize buttonMailComment;
@synthesize buttonMailFollow;
@synthesize buttonMailLike;
@synthesize buttonPushComment;
@synthesize buttonPushFollow;
@synthesize buttonPushLike;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_sub_back.png"]];
    
    LXAppDelegate* app = [LXAppDelegate currentDelegate];
    NSDictionary *params = [NSDictionary dictionaryWithObject:[app getToken] forKey:@"token"];
    [[LatteAPIClient sharedClient] getPath:@"user/me" parameters:params  success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
        NSDictionary *userDict = [JSON objectForKey:@"user"];
        User* user = [User instanceFromDictionary:userDict];
        
        buttonMailComment.enabled = true;
        buttonMailFollow.enabled = true;
        buttonMailLike.enabled = true;
        buttonPushComment.enabled = true;
        buttonPushFollow.enabled = true;
        buttonPushLike.enabled = true;
        
        buttonMailComment.selected = user.mailAccepts.comment;
        buttonMailFollow.selected = user.mailAccepts.follow;
        buttonMailLike.selected = user.mailAccepts.vote;
        
        buttonPushComment.selected = user.notifyAccepts.comment;
        buttonPushFollow.selected = user.notifyAccepts.follow;
        buttonPushLike.selected = user.notifyAccepts.vote;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", "Error")
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"close", "Close")
                                              otherButtonTitles:nil];
        [alert show];
    }];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //setup back button
    UIBarButtonItem *navLeftItem = self.navigationItem.leftBarButtonItem;
    LXButtonBack *buttonBack = (LXButtonBack*)navLeftItem.customView;
    [buttonBack addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)toggleNotify:(UIButton *)sender {
    sender.selected = !sender.selected;
    LXAppDelegate* app = [LXAppDelegate currentDelegate];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:[app getToken] forKey:@"token"];
    NSString *key;
    switch (sender.tag) {
        case 1:
            key = @"mail_comment";
            break;
        case 2:
            key = @"push_notify_comment";
            break;
        case 3:
            key = @"mail_vote";
            break;
        case 4:
            key = @"push_notify_vote";
            break;
        case 5:
            key = @"mail_follow";
            break;
        case 6:
            key = @"push_notify_follow";
            break;
        default:
            return;
            break;
    }
    [params setObject:[NSNumber numberWithBool:sender.selected] forKey:key];

    
    [[LatteAPIClient sharedClient] postPath:@"user/me/update"
                                 parameters: params
                                    success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                        if ([[JSON objectForKey:@"status"] integerValue] == 0) {
                                            NSString *error = @"";
                                            NSDictionary *errors = [JSON objectForKey:@"errors"];
                                            for (NSString *tmp in [JSON objectForKey:@"errors"]) {
                                                error = [error stringByAppendingFormat:@"\n%@", [errors objectForKey:tmp]];
                                            }
                                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"エラー" message:error delegate:self cancelButtonTitle:@"YES!" otherButtonTitles:nil];
                                            [alert show];
                                        }
                                        
                                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", "Error")
                                                                                        message:error.localizedDescription
                                                                                       delegate:nil
                                                                              cancelButtonTitle:NSLocalizedString(@"close", "Close")
                                                                              otherButtonTitles:nil];
                                        [alert show];
                                    }];

}

- (void)viewDidUnload {
    [self setButtonMailComment:nil];
    [self setButtonPushComment:nil];
    [self setButtonMailLike:nil];
    [self setButtonPushLike:nil];
    [self setButtonMailFollow:nil];
    [self setButtonPushFollow:nil];
    [super viewDidUnload];
}
@end
