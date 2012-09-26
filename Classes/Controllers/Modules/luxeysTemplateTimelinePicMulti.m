//
//  luxeysTemplateTimelinePicMulti.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/09/26.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "luxeysTemplateTimelinePicMulti.h"
#import "UIButton+AsyncImage.h"
#import "luxeysPicDetailViewController.h"

@interface luxeysTemplateTimelinePicMulti () {
    NSArray *pics;
    NSDictionary *user;
    UIViewController *sender;
    NSInteger section;
}
@end

@implementation luxeysTemplateTimelinePicMulti

@synthesize buttonUser;
@synthesize labelUser;
@synthesize labelDate;
@synthesize scrollImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithPics:(NSArray *)_pics user:(NSDictionary *)_user section:(NSInteger)_section sender:(id)_sender {
    self = [super init];
    if (self) {
        pics = _pics;
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
    labelUser.text = [user objectForKey:@"name"];
    buttonUser.tag = section;
    
    [buttonUser loadBackground:[user objectForKey:@"profile_picture"]];
    [buttonUser addTarget:sender action:@selector(showUser:) forControlEvents:UIControlEventTouchUpInside];
    
    CGSize size = CGSizeMake(10, 190);
    for (NSDictionary *pic in pics) {
        UIButton *buttonImage = [[UIButton alloc] initWithFrame:CGRectMake(size.width, 10, 170, 170)];
        buttonImage.tag = [[pic objectForKey:@"id"] integerValue];
        [buttonImage loadBackground:[pic objectForKey:@"url_square"]];
        [buttonImage addTarget:sender action:@selector(showPicWithID:) forControlEvents:UIControlEventTouchUpInside];
        size.width += 180;
        [scrollImage addSubview:buttonImage];
    }
    scrollImage.contentSize = size;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
