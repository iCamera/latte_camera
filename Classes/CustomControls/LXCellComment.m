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
@synthesize viewBack;
@synthesize buttonLike;
@synthesize labelLike;
@synthesize imageLike;

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

- (void)setComment:(Comment *)comment {
    _comment = comment;
    textComment.text = comment.descriptionText;
    labelDate.text = [NSString stringWithFormat:@"%@ -", [LXUtils timeDeltaFromNow:comment.createdAt]];
    labelLike.text = [comment.voteCount stringValue];
    if (comment.user.isUnregister) {
        labelAuthor.text = NSLocalizedString(@"guest", @"ゲスト");
    } else {
        [buttonUser loadBackground:comment.user.profilePicture placeholderImage:@"user.gif"];
        labelAuthor.text = comment.user.name;
    }

    LXAppDelegate *app = [LXAppDelegate currentDelegate];
    if (app.currentUser != nil) {
        buttonLike.hidden = [comment.user.userId integerValue] == [app.currentUser.userId integerValue];
        buttonLike.selected = comment.isVoted;
        buttonLike.enabled = true;
    }
    else {
        buttonLike.hidden = false;
        buttonLike.selected = true;
        buttonLike.enabled = !comment.isVoted;
    }
    [buttonLike addTarget:self action:@selector(toggleLikeComment:) forControlEvents:UIControlEventTouchUpInside];
    
    [self relayout];
}

- (void)relayout {
    CGSize labelSize = [textComment.text sizeWithFont:textComment.font
                                    constrainedToSize:CGSizeMake(255.0f, CGFLOAT_MAX)
                                        lineBreakMode:NSLineBreakByWordWrapping];
    
    CGSize sizeLabelDate = [labelDate.text sizeWithFont:labelDate.font
                                      constrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                          lineBreakMode:NSLineBreakByWordWrapping];
    
    CGPoint pointer = CGPointMake(42, labelSize.height + 22);
    
    CGRect frameComment = textComment.frame;
    CGRect frameDate = labelDate.frame;
    CGRect frameLike = buttonLike.frame;
    CGRect frameLikeImage = imageLike.frame;
    CGRect frameLikeCount = labelLike.frame;
    
    frameDate.origin.y = frameLikeCount.origin.y = frameLike.origin.y = frameLikeImage.origin.y = pointer.y;
    frameComment.size = labelSize;
    
    frameDate.size.width = sizeLabelDate.width;
    pointer.x += sizeLabelDate.width + 2;
    
    LXAppDelegate *app = [LXAppDelegate currentDelegate];
    if (app.currentUser != nil) {
        if ([_comment.user.userId integerValue] != [app.currentUser.userId integerValue]) {
            frameLike.origin.x = pointer.x;
            
            NSString *buttonString;
            if (buttonLike.selected) {
                buttonString = [buttonLike titleForState:UIControlStateSelected];
            } else if (!buttonLike.enabled) {
                buttonString = [buttonLike titleForState:UIControlStateDisabled];
            } else
                buttonString = [buttonLike titleForState:UIControlStateNormal];
            frameLike.size.width = [buttonString sizeWithFont:labelDate.font
                                            constrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)].width + 3;
            pointer.x += frameLike.size.width + 3;
        }
    }
    frameLikeImage.origin.y = pointer.y + 2;
    frameLikeImage.origin.x = pointer.x;
    pointer.x += 10 + 3;
    frameLikeCount.origin.x = pointer.x;
    
    [UIView animateWithDuration:kGlobalAnimationSpeed
                     animations:^{
                         labelLike.frame = frameLikeCount;
                         labelDate.frame = frameDate;
                         buttonLike.frame = frameLike;
                         imageLike.frame = frameLikeImage;
                         textComment.frame = frameComment;
                     }];
}

- (void)toggleLikeComment:(UIButton*)sender {
    LXAppDelegate* app = [LXAppDelegate currentDelegate];
    if (!app.currentUser) {
        sender.enabled = NO;
    }
    
    _comment.isVoted = !_comment.isVoted;
    BOOL increase = _comment.isVoted;
    sender.selected = _comment.isVoted;
    
    _comment.voteCount = [NSNumber numberWithInteger:[_comment.voteCount integerValue] + (increase?1:-1)];
    
    labelLike.text = [_comment.voteCount stringValue];
    
    [self relayout];
    
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  @"1", @"vote_type",
                                  nil];
    if (app.currentUser != nil) {
        [param setObject:[app getToken] forKey:@"token"];
    }
    
    
    NSString *url = [NSString stringWithFormat:@"picture/comment/%d/vote", [_comment.commentId integerValue]];
    [[LatteAPIClient sharedClient] postPath:url
                                 parameters:param
                                    success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                        TFLog(@"Submited like");
                                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", "Error")
                                                                                        message:error.localizedDescription
                                                                                       delegate:nil
                                                                              cancelButtonTitle:NSLocalizedString(@"close", "Close")
                                                                              otherButtonTitles:nil];
                                        [alert show];
                                        TFLog(@"Something went wrong (Vote)");
                                    }];
}


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    buttonUser.layer.cornerRadius = 3;
    buttonUser.clipsToBounds = YES;
    viewBack.layer.cornerRadius = 3;
    viewBack.clipsToBounds = YES;
}

@end
