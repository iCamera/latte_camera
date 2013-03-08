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
    textComment.text = comment.descriptionText;
    if (comment.user.isUnregister) {
        labelAuthor.text = NSLocalizedString(@"guest", @"ゲスト");
    } else {
        [buttonUser loadBackground:comment.user.profilePicture placeholderImage:@"user.gif"];
        labelAuthor.text = comment.user.name;
    }
    CGSize labelSize = [textComment.text sizeWithFont:[UIFont fontWithName:@"AvenirNextCondensed-Regular" size:12.0]
                                    constrainedToSize:CGSizeMake(255.0f, MAXFLOAT)
                                        lineBreakMode:NSLineBreakByWordWrapping];
    
    labelDate.text = [LXUtils timeDeltaFromNow:comment.createdAt];
    CGRect frameDate = labelDate.frame;
    frameDate.size = [labelDate.text sizeWithFont:[UIFont fontWithName:@"AvenirNextCondensed-Regular" size:12.0]
                                  constrainedToSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                                      lineBreakMode:NSLineBreakByWordWrapping];
    
    CGRect frameLike = buttonLike.frame;
    frameDate.origin.y = frameLike.origin.y = labelSize.height + 22;
    frameLike.origin.x = frameDate.size.width + 47;
    
    labelDate.frame = frameDate;
    buttonLike.frame = frameLike;
   
    CGRect frame = textComment.frame;
    frame.size = labelSize;
    textComment.frame = frame;
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
}


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    buttonUser.layer.cornerRadius = 3;
    buttonUser.clipsToBounds = YES;
    viewBack.layer.cornerRadius = 3;
    viewBack.clipsToBounds = YES;
}

@end
