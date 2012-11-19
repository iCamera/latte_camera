//
//  luxeysPictureViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/23/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "luxeysCellPicture.h"

@implementation luxeysTableViewCellPicture
@synthesize labelTitle;
@synthesize labelDate;
@synthesize imagePic;
@synthesize labelAccess;
@synthesize labelLike;
@synthesize labelAuthor;
@synthesize buttonLike;
@synthesize buttonUser;
@synthesize labelComment;
@synthesize viewStats;
@synthesize buttonComment;
@synthesize buttonInfo;
@synthesize buttonMap;

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

- (void)setPicture:(Picture *)pic user:(User *)user;
{
    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
    // NSDictionary* user = [pic objectForKey:@"owner"];
    // Increase counter
    NSString *url = [NSString stringWithFormat:@"api/picture/counter/%d/%d",
                     [pic.pictureId integerValue],
                     [user.userId integerValue]];
    
    [[LatteAPIClient sharedClient] getPath:url
                                      parameters:[NSDictionary dictionaryWithObject:[app getToken] forKey:@"token"]
                                         success:nil
                                         failure:nil];
    // Do any additional setup after loading the view from its nib.
    if (pic.title.length > 0)
        labelTitle.text = pic.title;
    
    [buttonUser loadBackground:user.profilePicture placeholderImage:@"user.gif"];
    labelAuthor.text = user.name;
    
    float newheight = [luxeysUtils heightFromWidth:308
                                                  width:[pic.width floatValue]
                                                 height:[pic.height floatValue]];
    
    labelDate.text = [luxeysUtils timeDeltaFromNow:pic.createdAt];
    labelAccess.text = [pic.pageviews stringValue];
    labelLike.text = [pic.voteCount stringValue];
    labelComment.text = [pic.commentCount stringValue];
    imagePic.frame = CGRectMake(imagePic.frame.origin.x, imagePic.frame.origin.y, 308, newheight);
    viewStats.autoresizingMask = UIViewAutoresizingNone;
    viewStats.frame = CGRectMake(0, newheight + 48, viewStats.frame.size.width, viewStats.frame.size.height);

    if (pic.canVote)
        if (!pic.isVoted)
            buttonLike.enabled = YES;


    if (pic.canComment) {
        buttonComment.enabled = YES;
    }
    
    if ((pic.latitude != nil) && (pic.longitude != nil)) {
        buttonMap.enabled = YES;
    }

    //self.view.frame = CGRectMake(0, 0, 320, imagePic.frame.size.height + 100);
    //[buttonUser addTarget:self.parentViewController action:@selector(touchUser:) forControlEvents:UIControlEventTouchUpInside];
    
    // Style
    buttonUser.clipsToBounds = YES;
    buttonUser.layer.cornerRadius = 3;
    
    UIBezierPath *shadowPathPic = [UIBezierPath bezierPathWithRect:imagePic.bounds];
    imagePic.layer.masksToBounds = NO;
    imagePic.layer.shadowColor = [UIColor blackColor].CGColor;
    imagePic.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    imagePic.layer.shadowOpacity = 1.0f;
    imagePic.layer.shadowRadius = 2.0f;
    imagePic.layer.shadowPath = shadowPathPic.CGPath;
    
    [imagePic loadProgess:pic.urlMedium];
}
@end
