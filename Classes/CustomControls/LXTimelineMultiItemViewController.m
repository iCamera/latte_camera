//
//  luxeysTemplateTimlinePicMultiItem.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/09/28.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "LXTimelineMultiItemViewController.h"
#import "LXAppDelegate.h"
#import "UIButton+AFNetworking.h"

@interface LXTimelineMultiItemViewController ()

@end

@implementation LXTimelineMultiItemViewController

@synthesize buttonComment;
@synthesize buttonImage;
@synthesize buttonVote;
@synthesize labelView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)awakeFromNib {
    buttonImage.layer.cornerRadius = 2;
    buttonComment.layer.cornerRadius = 2;
    buttonVote.layer.cornerRadius = 2;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[buttonImage loadBackground:_pic.urlSquare];
    [buttonImage setImageForState:UIControlStateNormal withURL:[NSURL URLWithString:_pic.urlMedium]];
    buttonImage.imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    buttonImage.tag = _index;
    buttonComment.tag = _index;
    buttonVote.tag = _index;
    
    [buttonComment setTitle:[_pic.commentCount stringValue] forState:UIControlStateNormal];
    [buttonVote setTitle:[_pic.voteCount stringValue] forState:UIControlStateNormal];
    
    LXAppDelegate* app = (LXAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    buttonVote.enabled = NO;
    if (!(_pic.isVoted && !app.currentUser))
        buttonVote.enabled = YES;
    buttonVote.selected = _pic.isVoted;
    
    labelView.text = [_pic.pageviews stringValue];
    
    [buttonImage addTarget:_parent action:@selector(showPicture:) forControlEvents:UIControlEventTouchUpInside];
    [buttonComment addTarget:_parent action:@selector(showComment:) forControlEvents:UIControlEventTouchUpInside];
    [buttonVote addTarget:_parent action:@selector(toggleLike:) forControlEvents:UIControlEventTouchUpInside];
    
//    buttonComment.hidden = !_showButton;
//    buttonVote.hidden = !_showButton;

    // Do any additional setup after loading the view from its nib.
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setLabelView:nil];
    [super viewDidUnload];
}
@end
