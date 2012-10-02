//
//  luxeysPictureViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/23/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "luxeysCellPicture.h"
#import "UIImageView+AFNetworking.h"
#import "luxeysImageUtils.h"
#import "luxeysLatteAPIClient.h"
#import "luxeysAppDelegate.h"
#import "UIButton+AsyncImage.h"

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

- (void)setPicture:(NSDictionary*)pic user:(NSDictionary*)user
{
    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
    // NSDictionary* user = [pic objectForKey:@"owner"];
    // Increase counter
    NSString *url = [NSString stringWithFormat:@"api/picture/counter/%d/%d",
                     [[pic objectForKey:@"id"] integerValue],
                     [[user objectForKey:@"id"] integerValue]];
    
    [[luxeysLatteAPIClient sharedClient] getPath:url
                                      parameters:[NSDictionary dictionaryWithObject:[app getToken] forKey:@"token"]
                                         success:nil
                                         failure:nil];
    // Do any additional setup after loading the view from its nib.
    labelTitle.text = [pic objectForKey:@"title"];
    
    [buttonUser loadBackground:[user objectForKey:@"profile_picture"]];
    labelAuthor.text = [user objectForKey:@"name"];
    
    [imagePic setImageWithURL:[NSURL URLWithString:[pic objectForKey:@"url_medium"]]];
    
    float newheight = [luxeysImageUtils heightFromWidth:300
                                                  width:[[pic objectForKey:@"width"] floatValue]
                                                 height:[[pic objectForKey:@"height"] floatValue]];
    labelAccess.text = [[pic objectForKey:@"pageviews"] stringValue];
    labelLike.text = [[pic objectForKey:@"vote_count"] stringValue];
    labelComment.text = [[pic objectForKey:@"comment_count"] stringValue];
    imagePic.frame = CGRectMake(imagePic.frame.origin.x, imagePic.frame.origin.y, 300, newheight);
    viewStats.autoresizingMask = UIViewAutoresizingNone;
    viewStats.frame = CGRectMake(0, newheight + 70, viewStats.frame.size.width, viewStats.frame.size.height);

    if ([[pic objectForKey:@"can_vote"] boolValue])
        if (![[pic objectForKey:@"is_voted"] boolValue])
            buttonLike.enabled = YES;


    if ([[pic objectForKey:@"can_comment"] boolValue]) {
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
