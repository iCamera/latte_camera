//
//  luxeysTemplateTimlinePicMultiItem.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/09/28.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "luxeysTemplateTimlinePicMultiItem.h"
#import "UIButton+AsyncImage.h"

@interface luxeysTemplateTimlinePicMultiItem () {
    NSDictionary *pic;
    id parent;
}

@end

@implementation luxeysTemplateTimlinePicMultiItem

@synthesize buttonComment;
@synthesize buttonImage;
@synthesize buttonVote;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithPic:(NSDictionary *)aPic parent:(id)aParent
{
    self = [super init];
    if (self) {
        pic = aPic;
        parent = aParent;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [buttonImage loadBackground:[pic objectForKey:@"url_square"]];
    
    buttonImage.layer.borderColor = [[UIColor whiteColor] CGColor];
    buttonImage.layer.borderWidth = 5;
    UIBezierPath *shadowPathPic = [UIBezierPath bezierPathWithRect:buttonImage.bounds];
    buttonImage.layer.masksToBounds = NO;
    buttonImage.layer.shadowColor = [UIColor blackColor].CGColor;
    buttonImage.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    buttonImage.layer.shadowOpacity = 0.5f;
    buttonImage.layer.shadowRadius = 1.5f;
    buttonImage.layer.shadowPath = shadowPathPic.CGPath;
    
    buttonComment.layer.cornerRadius = 5;
    buttonVote.layer.cornerRadius = 5;
    
    [buttonComment setTitle:[[pic objectForKey:@"comment_count"] stringValue] forState:UIControlStateNormal];
    [buttonVote setTitle:[[pic objectForKey:@"vote_count"] stringValue] forState:UIControlStateNormal];
    
    if ([[pic objectForKey:@"can_vote"] boolValue])
        if (![[pic objectForKey:@"is_voted"] boolValue])
            buttonVote.enabled = YES;
    
    
    buttonComment.tag = [[pic objectForKey:@"id"] integerValue];
    buttonImage.tag = [[pic objectForKey:@"id"] integerValue];
    buttonVote.tag = [[pic objectForKey:@"id"] integerValue];
    
    
    [buttonImage addTarget:parent action:@selector(showPicWithID:) forControlEvents:UIControlEventTouchUpInside];
    [buttonComment addTarget:parent action:@selector(showPicWithID:) forControlEvents:UIControlEventTouchUpInside];
    [buttonVote addTarget:parent action:@selector(showPicWithID:) forControlEvents:UIControlEventTouchUpInside];

    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
