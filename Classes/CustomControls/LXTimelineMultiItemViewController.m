//
//  luxeysTemplateTimlinePicMultiItem.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/09/28.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "LXTimelineMultiItemViewController.h"

#import "LXAppDelegate.h"

@interface LXTimelineMultiItemViewController ()

@end

@implementation LXTimelineMultiItemViewController

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [buttonImage loadBackground:_pic.urlSquare];
    
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
    
    [buttonComment setTitle:[_pic.commentCount stringValue] forState:UIControlStateNormal];
    [buttonVote setTitle:[_pic.voteCount stringValue] forState:UIControlStateNormal];
    
    LXAppDelegate* app = (LXAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    if (_pic.canVote) {
        if (!(_pic.isVoted && !app.currentUser))
            buttonVote.enabled = YES;
    }
    
    buttonVote.selected = _pic.isVoted;
    
    buttonComment.tag = [_pic.pictureId integerValue];
    buttonImage.tag = [_pic.pictureId integerValue];
    buttonVote.tag = [_pic.pictureId integerValue];
    
    [buttonImage addTarget:_parent action:@selector(showPic:) forControlEvents:UIControlEventTouchUpInside];
    [buttonComment addTarget:_parent action:@selector(showComment:) forControlEvents:UIControlEventTouchUpInside];
    [buttonVote addTarget:_parent action:@selector(submitLike:) forControlEvents:UIControlEventTouchUpInside];
    
    buttonComment.hidden = !_showButton;
    buttonVote.hidden = !_showButton;

    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
