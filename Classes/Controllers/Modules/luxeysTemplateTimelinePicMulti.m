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
@synthesize labelTitle;

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
    labelTitle.text = [NSString stringWithFormat:@"写真を%d枚追加しました", feed.targets.count];
    buttonUser.tag = [feed.user.userId integerValue];
    
    [buttonUser loadBackground:feed.user.profilePicture];
    [buttonUser addTarget:sender action:@selector(showUser:) forControlEvents:UIControlEventTouchUpInside];
    
    CGSize size = CGSizeMake(6, 190);
    for (Picture *pic in feed.targets) {
        luxeysTemplateTimlinePicMultiItem *viewPic = [[luxeysTemplateTimlinePicMultiItem alloc] initWithPic:pic parent:sender];
        viewPic.view.frame = CGRectMake(size.width, 2, 190, 190);
        [scrollImage addSubview:viewPic.view];
        
        size.width += 193;
    }
    scrollImage.contentSize = size;
    
    buttonUser.layer.cornerRadius = 3;
    buttonUser.clipsToBounds = YES;
    
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

- (void)viewDidUnload {
    [self setLabelTitle:nil];
    [super viewDidUnload];
}
@end
