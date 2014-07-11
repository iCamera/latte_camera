//
//  luxeysCellComment.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/24/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "LXCellComment.h"
#import "LXAppDelegate.h"

@implementation LXCellComment
@synthesize textComment;
@synthesize labelAuthor;
@synthesize labelDate;
@synthesize buttonUser;
@synthesize buttonLike;
@synthesize imageNationality;
@synthesize buttonReply;
@synthesize buttonReport;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)awakeFromNib {
    buttonUser.layer.cornerRadius = 17.5;
    buttonUser.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    buttonUser.layer.shouldRasterize = YES;
}

- (void)setComment:(Comment *)comment {
    _comment = comment;
    textComment.text = comment.descriptionText;
    labelDate.text = [LXUtils timeDeltaFromNow:comment.createdAt];
    [buttonLike setTitle:[comment.voteCount stringValue] forState:UIControlStateNormal];

    if (comment.user.isUnregister) {
        labelAuthor.text = NSLocalizedString(@"guest", @"ゲスト");
    } else {
        [buttonUser loadBackground:comment.user.profilePicture placeholderImage:@"user.gif"];
        labelAuthor.text = comment.user.name;
    }

    LXAppDelegate *app = [LXAppDelegate currentDelegate];
    if (app.currentUser != nil) {
        buttonLike.hidden = [comment.user.userId integerValue] == [app.currentUser.userId integerValue];
        buttonReply.hidden = [comment.user.userId integerValue] == [app.currentUser.userId integerValue];
        buttonReport.hidden = [comment.user.userId integerValue] == [app.currentUser.userId integerValue];
        buttonLike.selected = comment.isVoted;
        buttonLike.enabled = true;
    }
    else {
        buttonLike.hidden = false;
        buttonReply.hidden = YES;
        buttonLike.enabled = !comment.isVoted;
    }
    
    [LXUtils setNationalityOfUser:comment.user forImage:imageNationality nextToLabel:labelAuthor];
}


- (IBAction)toggleLike:(UIButton*)sender {
    LXAppDelegate* app = [LXAppDelegate currentDelegate];
    if (!app.currentUser) {
        sender.enabled = NO;
        sender.selected = _comment.isVoted;
    } else {
        sender.selected = !_comment.isVoted;
    }
    
    _comment.isVoted = !_comment.isVoted;
    BOOL increase = _comment.isVoted;
    
    _comment.voteCount = [NSNumber numberWithInteger:[_comment.voteCount integerValue] + (increase?1:-1)];
    
    [buttonLike setTitle:[_comment.voteCount stringValue] forState:UIControlStateNormal];
    
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  @"1", @"vote_type",
                                  nil];
    if (app.currentUser != nil) {
        [param setObject:[app getToken] forKey:@"token"];
    }
    
    
    NSString *url = [NSString stringWithFormat:@"picture/comment/%ld/vote", [_comment.commentId longValue]];
    [[LatteAPIClient sharedClient] POST:url parameters:param success:nil failure:nil];
}


@end
