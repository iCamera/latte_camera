//
//  luxeysCellWelcomeSingle.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/11/06.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "luxeysCellWelcomeSingle.h"

@implementation luxeysCellWelcomeSingle

@synthesize viewController;
@synthesize feed;

@synthesize labelTitle;
@synthesize labelUser;
@synthesize labelAccess;
@synthesize buttonPic;
@synthesize buttonUser;

@synthesize labelComment;
@synthesize labelLike;
@synthesize viewStat;
@synthesize viewPic;
@synthesize buttonComment;
@synthesize buttonInfo;
@synthesize buttonMap;
@synthesize buttonLike;
@synthesize tableComment;
@synthesize buttonExpand;
@synthesize viewBackground;

@synthesize isExpanded;

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

- (void)setFeed:(Feed *)aFeed {
    feed = aFeed;
    Picture *pic = feed.targets[0];
    CGRect frame = buttonPic.frame;
    frame.size.height = [luxeysUtils heightFromWidth:308.0 width:[pic.width floatValue] height:[pic.height floatValue]];
    buttonPic.frame = frame;
    buttonPic.layer.borderColor = [[UIColor whiteColor] CGColor];
    buttonPic.layer.borderWidth = 3;
    UIBezierPath *shadowPathPic = [UIBezierPath bezierPathWithRect:buttonPic.bounds];
    buttonPic.layer.masksToBounds = NO;
    buttonPic.layer.shadowColor = [UIColor blackColor].CGColor;
    buttonPic.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    buttonPic.layer.shadowOpacity = 0.5f;
    buttonPic.layer.shadowRadius = 1.5f;
    buttonPic.layer.shadowPath = shadowPathPic.CGPath;
    [buttonPic loadBackground:pic.urlMedium];
    viewStat.frame = CGRectMake(0.0, 0.0, 320.0, frame.size.height + 85.0);
    viewPic.frame = CGRectMake(0.0, 0.0, 320.0, frame.size.height + 49.0);
    
    viewStat.drawTriangle = pic.comments.count > 0;

    [viewStat setNeedsDisplay];
    [viewPic setNeedsDisplay];
    
    // UIBezierPath *aPath = [UIBezierPath bezierPath];
    // [aPath moveToPoint:CGPointMake(0, 0)];
    // [aPath addLineToPoint:CGPointMake(0, viewStat.frame.size.height)];
    // [aPath addLineToPoint:CGPointMake(16.0, viewStat.frame.size.height)];
    // [aPath addLineToPoint:CGPointMake(20.0, viewStat.frame.size.height-5)];
    // [aPath addLineToPoint:CGPointMake(24.0, viewStat.frame.size.height)];
    // [aPath addLineToPoint:CGPointMake(viewStat.frame.size.width, viewStat.frame.origin.y + viewStat.frame.size.height)];
    // [aPath addLineToPoint:CGPointMake(viewStat.frame.size.width, viewStat.frame.origin.y)];
    
    // viewStat.layer.masksToBounds = NO;
    // viewStat.layer.shadowColor = [UIColor blackColor].CGColor;
    // viewStat.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    // viewStat.layer.shadowOpacity = 1.0f;
    // viewStat.layer.shadowRadius = 2.5f;
    // viewStat.layer.shadowPath = aPath.CGPath;

    [tableComment reloadData];
    CGFloat commentHeight = tableComment.contentSize.height;

    buttonExpand.hidden = pic.comments.count <= 3;
    if (!buttonExpand.hidden)
    {
        CGRect expandFrame = buttonExpand.frame;
        expandFrame.origin.y = viewStat.frame.size.height + 6.0;
        buttonExpand.frame = expandFrame;
        tableComment.frame = CGRectMake(0.0, viewStat.frame.size.height + 6.0 + 25.0, 320.0, commentHeight);
        
    } else {
        tableComment.frame = CGRectMake(0.0, viewStat.frame.size.height + 6.0, 320.0, commentHeight);
    }
    
    viewBackground.frame = CGRectMake(0.0, 0.0, 320.0, tableComment.frame.origin.y
                                      + commentHeight + 6.0);
    
    buttonPic.tag = [pic.pictureId integerValue];
    buttonLike.tag = [pic.pictureId integerValue];
    buttonMap.tag = [pic.pictureId integerValue];
    buttonInfo.tag = [pic.pictureId integerValue];
    buttonComment.tag = [pic.pictureId integerValue];
    buttonExpand.tag = [pic.pictureId integerValue];

    labelAccess.text = [pic.pageviews stringValue];
    labelLike.text = [pic.voteCount stringValue];
    labelComment.text = [pic.commentCount stringValue];

    if (pic.canVote)
        if (!pic.isVoted)
            buttonLike.enabled = YES;
    
    if (pic.canComment) {
        buttonComment.enabled = YES;
    }
    
    if ((pic.latitude != nil) && (pic.longitude != nil)) {
        buttonMap.enabled = YES;
    }
    
    buttonUser.clipsToBounds = YES;
    buttonUser.layer.cornerRadius = 3;
    buttonUser.tag = [feed.user.userId integerValue];

    [buttonUser loadBackground:feed.user.profilePicture placeholderImage:@"user.gif"];
    if (pic.title.length > 0)
        labelTitle.text = pic.title;
    else
        labelTitle.text = @"タイトルなし";
    labelUser.text = [NSString stringWithFormat:@"photo by %@ | %@", feed.user.name, [luxeysUtils timeDeltaFromNow:feed.updatedAt]];
    
    self.clipsToBounds = NO;
    
    [buttonUser addTarget:viewController action:@selector(showUser:) forControlEvents:UIControlEventTouchUpInside];
    [buttonPic addTarget:viewController action:@selector(showPic:) forControlEvents:UIControlEventTouchUpInside];
    [buttonInfo addTarget:viewController action:@selector(showInfo:) forControlEvents:UIControlEventTouchUpInside];
    [buttonComment addTarget:viewController action:@selector(showComment:) forControlEvents:UIControlEventTouchUpInside];
    [buttonLike addTarget:viewController action:@selector(submitLike:) forControlEvents:UIControlEventTouchUpInside];
    [buttonMap addTarget:viewController action:@selector(showMap:) forControlEvents:UIControlEventTouchUpInside];
    [buttonExpand addTarget:viewController action:@selector(toggleComment:) forControlEvents:UIControlEventTouchUpInside];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Picture *pic = feed.targets[0];
    Comment *comment = pic.comments[indexPath.row];
    
    luxeysTableViewCellComment *cell = [tableView dequeueReusableCellWithIdentifier:@"Comment" forIndexPath:indexPath];
    if (cell == nil)
    {
        cell = [[luxeysTableViewCellComment alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Comment"];
    }
    
    if (!comment.user.isUnregister) {
        cell.buttonUser.tag = [comment.user.userId integerValue];
        [cell.buttonUser addTarget:viewController action:@selector(showUser:) forControlEvents:UIControlEventTouchUpInside];
    }
//
//    cell.viewBack.layer.cornerRadius = 3;
//    cell.viewBack.clipsToBounds = YES;
    
    [cell setComment:comment];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (feed.targets.count == 1) {
        Picture *pic = feed.targets[0];
        NSInteger commentCount = [pic.commentCount integerValue];
        
        if (!isExpanded)
            return commentCount>3?3:commentCount;
        else
            return commentCount;
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Picture *pic = feed.targets[0];
    Comment *comment = pic.comments[indexPath.row];

    CGSize labelSize = [comment.descriptionText sizeWithFont:[UIFont systemFontOfSize:11]
                              constrainedToSize:CGSizeMake(255.0f, MAXFLOAT)
                                  lineBreakMode:NSLineBreakByWordWrapping];
    return MAX(labelSize.height + 24.0, 36.0);
}

@end
