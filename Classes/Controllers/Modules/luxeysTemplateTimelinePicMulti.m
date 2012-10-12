//
//  luxeysTemplateTimelinePicMulti.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/09/26.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "luxeysTemplateTimelinePicMulti.h"

@interface luxeysTemplateTimelinePicMulti ()
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

- (id)initWithFeed:(Feed *)aFeed section:(NSInteger)aSection sender:(id)aSender {
    self = [super init];
    if (self) {
        section = aSection;
        sender = aSender;
        feed = aFeed;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    labelUser.text = feed.user.name;
    labelDate.text = [luxeysUtils timeDeltaFromNow:feed.updatedAt];
    buttonUser.tag = section;
    
    [buttonUser loadBackground:feed.user.profilePicture];
    [buttonUser addTarget:sender action:@selector(showUser:) forControlEvents:UIControlEventTouchUpInside];
    
    CGSize size = CGSizeMake(10, 190);
    for (Picture *pic in feed.targets) {
        luxeysTemplateTimlinePicMultiItem *viewPic = [[luxeysTemplateTimlinePicMultiItem alloc] initWithPic:pic parent:sender];
        viewPic.view.frame = CGRectMake(size.width, 2, 190, 190);
        [scrollImage addSubview:viewPic.view];
        
        size.width += 200;
    }
    scrollImage.contentSize = size;
    
    buttonUser.layer.borderColor = [[UIColor whiteColor] CGColor];
    buttonUser.layer.borderWidth = 2;
    UIBezierPath *shadowPathPic = [UIBezierPath bezierPathWithRect:buttonUser.bounds];
    buttonUser.layer.masksToBounds = NO;
    buttonUser.layer.shadowColor = [UIColor blackColor].CGColor;
    buttonUser.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    buttonUser.layer.shadowOpacity = 0.5f;
    buttonUser.layer.shadowRadius = 1.5f;
    buttonUser.layer.shadowPath = shadowPathPic.CGPath;
    
    if (section != 0) {
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 1)];
        lineView.backgroundColor = [UIColor colorWithRed:0.74f green:0.72f blue:0.66f alpha:1];
        [self.view addSubview:lineView];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
