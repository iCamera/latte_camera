//
//  luxeysCellComment.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/24/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "luxeysCellComment.h"

@implementation luxeysTableViewCellComment
@synthesize textComment;
@synthesize labelAuthor;
@synthesize labelDate;
@synthesize buttonUser;
@synthesize constraintCommentHeight;

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
        labelAuthor.text = @"ゲスト";
    } else {
        [buttonUser loadBackground:comment.user.profilePicture];
        labelAuthor.text = comment.user.name;
    }
    labelDate.text = [luxeysUtils timeDeltaFromNow:comment.createdAt];
    
    CGSize labelSize = [textComment.text sizeWithFont:[UIFont systemFontOfSize:11]
                              constrainedToSize:CGSizeMake(255.0f, MAXFLOAT)
                                  lineBreakMode:NSLineBreakByWordWrapping];
    
    constraintCommentHeight.constant = labelSize.height;
    
    // buttonUser.layer.cornerRadius = 3;
    // buttonUser.clipsToBounds = YES;
}

@end
