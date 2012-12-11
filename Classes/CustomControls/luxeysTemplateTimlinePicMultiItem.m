//
//  luxeysTemplateTimlinePicMultiItem.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/09/28.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "luxeysTemplateTimlinePicMultiItem.h"

@interface luxeysTemplateTimlinePicMultiItem ()

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

- (id)initWithPic:(Picture *)aPic parent:(id)aParent showButton:(BOOL)button
{
    self = [super init];
    if (self) {
        pic = aPic;
        parent = aParent;
        showButton = button;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [buttonImage loadBackground:pic.urlSquare];
    
    buttonImage.layer.borderColor = [[UIColor whiteColor] CGColor];
    buttonImage.layer.borderWidth = 3;
    UIBezierPath *shadowPathPic = [UIBezierPath bezierPathWithRect:buttonImage.bounds];
    buttonImage.layer.masksToBounds = NO;
    buttonImage.layer.shadowColor = [UIColor blackColor].CGColor;
    buttonImage.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    buttonImage.layer.shadowOpacity = 0.5f;
    buttonImage.layer.shadowRadius = 1.5f;
    buttonImage.layer.shadowPath = shadowPathPic.CGPath;
    
    buttonComment.layer.cornerRadius = 5;
    buttonVote.layer.cornerRadius = 5;
    
    [buttonComment setTitle:[pic.commentCount stringValue] forState:UIControlStateNormal];
    [buttonVote setTitle:[pic.voteCount stringValue] forState:UIControlStateNormal];
    
    if (pic.canVote)
        if (!pic.isVoted)
            buttonVote.enabled = YES;
    
    buttonComment.tag = [pic.pictureId integerValue];
    buttonImage.tag = [pic.pictureId integerValue];
    buttonVote.tag = [pic.pictureId integerValue];
    
    [buttonImage addTarget:parent action:@selector(showPic:) forControlEvents:UIControlEventTouchUpInside];
    [buttonComment addTarget:parent action:@selector(showComment:) forControlEvents:UIControlEventTouchUpInside];
    [buttonVote addTarget:parent action:@selector(submitLike:) forControlEvents:UIControlEventTouchUpInside];
    
    buttonComment.hidden = !showButton;
    buttonVote.hidden = !showButton;

    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
