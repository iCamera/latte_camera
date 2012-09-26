//
//  luxeysTemplatePicTimeline.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/09/24.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "luxeysTemplatePicTimeline.h"
#import "UIImageView+AFNetworking.h"
#import "luxeysImageUtils.h"
#import "luxeysLatteAPIClient.h"
#import "luxeysAppDelegate.h"
#import "UIButton+AsyncImage.h"

@interface luxeysTemplatePicTimeline () {
    NSDictionary *pic;
    NSDictionary *user;
    id sender;
    NSInteger section;
}
@end

@implementation luxeysTemplatePicTimeline

@synthesize labelTitle;
@synthesize imagePic;
@synthesize labelAccess;
@synthesize labelLike;
@synthesize labelAuthor;
@synthesize buttonLike;
@synthesize buttonUser;
@synthesize labelComment;
@synthesize viewStats;
@synthesize buttonComment;
@synthesize buttonInfo;
@synthesize buttonMap;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        // Custom initialization
    }
    return self;
}

- (id)initWithPic:(NSDictionary *)_pic user:(NSDictionary *)_user section:(NSInteger)_section sender:(id)_sender {
    self = [super init];
    if (self) {
        pic = _pic;
        user = _user;
        section = _section;
        sender = _sender;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
    // NSDictionary* user = [pic objectForKey:@"owner"];
    // Increase counter
    NSString *url = [NSString stringWithFormat:@"api/picture/counter/%d/%d",
                     [[pic objectForKey:@"id"] integerValue],
                     [[user objectForKey:@"id"] integerValue]];
    
    [[luxeysLatteAPIClient sharedClient] getPath:url
                                      parameters:[NSDictionary dictionaryWithObject:[app getToken] forKey:@"token"]
                                         success:nil
                                         failure:nil];
    // Do any additional setup after loading the view from its nib.
    labelTitle.text = [pic objectForKey:@"title"];
    
    [buttonUser loadBackground:[user objectForKey:@"profile_picture"]];
    labelAuthor.text = [user objectForKey:@"name"];
    
    [imagePic setImageWithURL:[NSURL URLWithString:[pic objectForKey:@"url_medium"]]];
    
    float newheight = [luxeysImageUtils heightFromWidth:300
                                                  width:[[pic objectForKey:@"width"] floatValue]
                                                 height:[[pic objectForKey:@"height"] floatValue]];
    labelAccess.text = [[pic objectForKey:@"pageviews"] stringValue];
    labelLike.text = [[pic objectForKey:@"vote_count"] stringValue];
    labelComment.text = [[pic objectForKey:@"comment_count"] stringValue];
    imagePic.frame = CGRectMake(imagePic.frame.origin.x, imagePic.frame.origin.y, 300, newheight);
    viewStats.autoresizingMask = UIViewAutoresizingNone;
    viewStats.frame = CGRectMake(0, newheight + 60, viewStats.frame.size.width, viewStats.frame.size.height);
    
    if (![pic objectForKey:@"is_voted"]) {
        buttonLike.enabled = YES;
    } else if ([pic objectForKey:@"can_vote"]) {
        buttonLike.enabled = YES;
    }
    
    if ([pic objectForKey:@"can_comment"]) {
        buttonComment.enabled = YES;
    }
    
    buttonInfo.tag = section;
    buttonComment.tag = section;
    buttonUser.tag = section;
    
    [buttonUser addTarget:sender action:@selector(showUser:) forControlEvents:UIControlEventTouchUpInside];
    [buttonInfo addTarget:sender action:@selector(showInfo:) forControlEvents:UIControlEventTouchUpInside];
    [buttonComment addTarget:sender action:@selector(showComment:) forControlEvents:UIControlEventTouchUpInside];
    [buttonLike addTarget:sender action:@selector(submitLike:) forControlEvents:UIControlEventTouchUpInside];
    [buttonMap addTarget:sender action:@selector(showMap:) forControlEvents:UIControlEventTouchUpInside];
    
    // Style
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:buttonUser.bounds];
    buttonUser.layer.masksToBounds = NO;
    buttonUser.layer.shadowColor = [UIColor blackColor].CGColor;
    buttonUser.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    buttonUser.layer.shadowOpacity = 1.0f;
    buttonUser.layer.shadowRadius = 1.0f;
    buttonUser.layer.shadowPath = shadowPath.CGPath;
    
    UIBezierPath *shadowPathPic = [UIBezierPath bezierPathWithRect:imagePic.bounds];
    imagePic.layer.masksToBounds = NO;
    imagePic.layer.shadowColor = [UIColor blackColor].CGColor;
    imagePic.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    imagePic.layer.shadowOpacity = 1.0f;
    imagePic.layer.shadowRadius = 2.0f;
    imagePic.layer.shadowPath = shadowPathPic.CGPath;
    
//    UIBezierPath *shadowPathView = [UIBezierPath bezierPathWithRect:self.view.bounds];
//    self.view.layer.masksToBounds = NO;
//    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
//    self.view.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
//    self.view.layer.shadowOpacity = 1.0f;
//    self.view.layer.shadowRadius = 2.0f;
//    self.view.layer.shadowPath = shadowPathView.CGPath;
//    [self.view.layer setCornerRadius:5.0f];
//    [self.view.layer setBorderColor:[UIColor lightGrayColor].CGColor];
//    [self.view.layer setBorderWidth:0.5f];
//    [self.view.layer setShadowColor:[UIColor blackColor].CGColor];
//    [self.view.layer setShadowOpacity:0.8];
//    [self.view.layer setShadowRadius:3.0];
//    [self.view.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
