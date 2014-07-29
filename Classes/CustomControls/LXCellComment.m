//
//  luxeysCellComment.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/24/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "LXCellComment.h"
#import "LXAppDelegate.h"
#import "MZFormSheetController.h"

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
        [buttonUser setBackgroundImage:[UIImage imageNamed:@"user.gif"] forState:UIControlStateNormal];
    } else {
        [buttonUser loadBackground:comment.user.profilePicture placeholderImage:@"user.gif"];
        labelAuthor.text = comment.user.name;
    }

    buttonLike.selected = comment.isVoted;
    
    LXAppDelegate *app = [LXAppDelegate currentDelegate];
    if (app.currentUser != nil) {
        buttonLike.enabled = [comment.user.userId integerValue] != [app.currentUser.userId integerValue];
        buttonReply.enabled = [comment.user.userId integerValue] != [app.currentUser.userId integerValue];
        buttonReport.hidden = [comment.user.userId integerValue] == [app.currentUser.userId integerValue];
    } else {
        buttonLike.enabled = YES;
        buttonReply.enabled = YES;
    }
    
    [LXUtils setNationalityOfUser:comment.user forImage:imageNationality nextToLabel:labelAuthor];
}


- (IBAction)toggleLike:(UIButton*)sender {
    LXAppDelegate* app = [LXAppDelegate currentDelegate];
    if (!app.currentUser) {
        UIStoryboard *storyAuth = [UIStoryboard storyboardWithName:@"Authentication" bundle:nil];
        UIViewController *viewLogin = [storyAuth instantiateViewControllerWithIdentifier:@"Login"];
        
        if (_parent.isModal) {
            [_parent mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
                [_parent.parent.navigationController pushViewController:viewLogin animated:YES];
            }];
        } else {
            [_parent.navigationController pushViewController:viewLogin animated:YES];
        }

        return;
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
