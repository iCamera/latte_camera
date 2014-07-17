//
//  luxeysTemplateTimlinePicMultiItem.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/09/28.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "LXTimelineMultiItemViewController.h"
#import "LXAppDelegate.h"
#import "UIImageView+AFNetworking.h"
#import "UIImageView+loadProgress.h"
#import "LXSocketIO.h"

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

- (void)awakeFromNib {
    buttonImage.layer.cornerRadius = 2;
    buttonComment.layer.cornerRadius = 2;
    buttonVote.layer.cornerRadius = 2;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pictureUpdate:) name:@"picture_update" object:nil];
    
    buttonImage.imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    buttonImage.tag = _index;
    buttonComment.tag = _index;
    buttonVote.tag = _index;
    
    
    [buttonImage addTarget:_parent action:@selector(showPicture:) forControlEvents:UIControlEventTouchUpInside];
    [buttonComment addTarget:_parent action:@selector(showComment:) forControlEvents:UIControlEventTouchUpInside];
    [buttonVote addTarget:_parent action:@selector(toggleLike:) forControlEvents:UIControlEventTouchUpInside];
    
    LXSocketIO *socket = [LXSocketIO sharedClient];
    [socket sendEvent:@"join" withData:[NSString stringWithFormat:@"picture_%ld", [_pic.pictureId longValue]]];
    
    _progressLoad.progress = 0;
    [_imagePicture loadProgess:_pic.urlMedium withCompletion:^(BOOL isCache){
        if (!isCache) {
            _imagePicture.alpha = 0;
            [UIView animateWithDuration:0.3 animations:^{
                _imagePicture.alpha = 1;
            }];
        }

    } progress:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        _progressLoad.progress = (float)totalBytesRead/(float)totalBytesExpectedToRead;
    }];
    
    _imageStatus.hidden = !_pic.isOwner;
    if (_pic.isOwner) {
        if (_pic.status == PictureStatusPublic) {
            [_imageStatus setImage:[UIImage imageNamed:@"icon28-status40-white.png"]];
        } else if (_pic.status == PictureStatusMember) {
            [_imageStatus setImage:[UIImage imageNamed:@"icon28-status30-white.png"]];
        } else if (_pic.status == PictureStatusFriendsOnly) {
            [_imageStatus setImage:[UIImage imageNamed:@"icon28-status10-white.png"]];
        } else if (_pic.status == PictureStatusPrivate) {
            [_imageStatus setImage:[UIImage imageNamed:@"icon28-status0-white.png"]];
        }
    }
    
    [self renderPicture];

    // Do any additional setup after loading the view from its nib.
}

- (void)renderPicture {
    [buttonComment setTitle:[_pic.commentCount stringValue] forState:UIControlStateNormal];
    [buttonVote setTitle:[_pic.voteCount stringValue] forState:UIControlStateNormal];
    
    LXAppDelegate* app = (LXAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    buttonVote.enabled = NO;
    if (!(_pic.isVoted && !app.currentUser))
        buttonVote.enabled = YES;
    buttonVote.selected = _pic.isVoted;
}

- (void)pictureUpdate:(NSNotification*)notify {
    NSDictionary *raw = notify.object;
    if ([_pic.pictureId longValue] == [raw[@"id"] longValue]) {
        [_pic setAttributesFromDictionary:raw];

        [UIView transitionWithView:self.view duration:kGlobalAnimationSpeed options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            [self renderPicture];
        } completion:nil];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [super viewDidUnload];
}
@end
