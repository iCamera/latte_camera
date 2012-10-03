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

- (void)setPicture:(LuxeysPicture *)pic user:(LuxeysUser *)user;
{
    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
    // NSDictionary* user = [pic objectForKey:@"owner"];
    // Increase counter
    NSString *url = [NSString stringWithFormat:@"api/picture/counter/%d/%d",
                     [pic.pictureId integerValue],
                     [user.userId integerValue]];
    
    [[luxeysLatteAPIClient sharedClient] getPath:url
                                      parameters:[NSDictionary dictionaryWithObject:[app getToken] forKey:@"token"]
                                         success:nil
                                         failure:nil];
    // Do any additional setup after loading the view from its nib.
    labelTitle.text = pic.title;
    
    [buttonUser loadBackground:user.profilePicture];
    labelAuthor.text = user.name;
    
    [imagePic setImageWithURL:[NSURL URLWithString:pic.urlMedium]];
    
    float newheight = [luxeysImageUtils heightFromWidth:300
                                                  width:[pic.width floatValue]
                                                 height:[pic.height floatValue]];
    labelAccess.text = [pic.pageviews stringValue];
    labelLike.text = [pic.voteCount stringValue];
    labelComment.text = [pic.commentCount stringValue];
    imagePic.frame = CGRectMake(imagePic.frame.origin.x, imagePic.frame.origin.y, 300, newheight);
    viewStats.autoresizingMask = UIViewAutoresizingNone;
    viewStats.frame = CGRectMake(0, newheight + 70, viewStats.frame.size.width, viewStats.frame.size.height);

    if (pic.canVote)
        if (!pic.isVoted)
            buttonLike.enabled = YES;


    if (pic.canComment) {
        buttonComment.enabled = YES;
    }

    //self.view.frame = CGRectMake(0, 0, 320, imagePic.frame.size.height + 100);
    //[buttonUser addTarget:self.parentViewController action:@selector(touchUser:) forControlEvents:UIControlEventTouchUpInside];
    
    // Style
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:buttonUser.bounds];
    buttonUser.layer.masksToBounds = NO;
    buttonUser.layer.shadowColor = [UIColor blackColor].CGColor;
    buttonUser.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    buttonUser.layer.shadowOpacity = 1.0f;
    buttonUser.layer.shadowRadius = 1.0f;
    buttonUser.layer.shadowPath = shadowPath.CGPath;
    
    UIBezierPath *shadowPathPic = [UIBezierPath bezierPathWithRect:imagePic.bounds];
    imagePic.layer.masksToBounds = NO;
    imagePic.layer.shadowColor = [UIColor blackColor].CGColor;
    imagePic.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    imagePic.layer.shadowOpacity = 1.0f;
    imagePic.layer.shadowRadius = 2.0f;
    imagePic.layer.shadowPath = shadowPathPic.CGPath;
}
@end
