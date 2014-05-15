//
//  LXAnouncementViewController.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 5/13/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import "LXAnouncementViewController.h"
#import "LatteAPIClient.h"

@interface LXAnouncementViewController ()

@end

@implementation LXAnouncementViewController

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
    LatteAPIClient *api = [LatteAPIClient sharedClient];
    NSURLRequest* request = [api.requestSerializer requestWithMethod:@"GET"
                                                           URLString:[[NSURL URLWithString:@"user/announce" relativeToURL:api.baseURL] absoluteString]
                                                          parameters:nil
                                                               error:nil];
    [_webView loadRequest:request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
