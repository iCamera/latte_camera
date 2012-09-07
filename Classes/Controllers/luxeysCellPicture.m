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

- (void)setPicture:(NSDictionary*)dictInfo
{
    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
    NSDictionary* user = [dictInfo objectForKey:@"owner"];
    // Increase counter
    NSString *url = [NSString stringWithFormat:@"api/picture/counter/%d/%d",
                     [[dictInfo objectForKey:@"id"] integerValue],
                     [[user objectForKey:@"id"] integerValue]];
    
    [[luxeysLatteAPIClient sharedClient] getPath:url
                                      parameters:[NSDictionary dictionaryWithObject:[app getToken] forKey:@"token"]
                                         success:nil
                                         failure:nil];
    // Do any additional setup after loading the view from its nib.
    labelTitle.text = [dictInfo objectForKey:@"title"];
    
    UIImageView* imageUser = [[UIImageView alloc] init];
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[user objectForKey:@"profile_picture"]]
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                          timeoutInterval:60.0];
    
    [imageUser setImageWithURLRequest:theRequest
                     placeholderImage:nil
                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                  [buttonUser setBackgroundImage:image forState:UIControlStateNormal];
                              }
                              failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                 
                              }
     ];
    labelAuthor.text = [user objectForKey:@"name"];
    
    [imagePic setImageWithURL:[NSURL URLWithString:[dictInfo objectForKey:@"url_medium"]]];
    
    float newheight = [luxeysImageUtils heightFromWidth:300
                                                  width:[[dictInfo objectForKey:@"width"] floatValue]
                                                 height:[[dictInfo objectForKey:@"height"] floatValue]];
    labelAccess.text = [[dictInfo objectForKey:@"pageviews"] stringValue];
    labelLike.text = [[dictInfo objectForKey:@"vote_count"] stringValue];
    labelComment.text = [[dictInfo objectForKey:@"comment_count"] stringValue];
    imagePic.frame = CGRectMake(imagePic.frame.origin.x, imagePic.frame.origin.y, 300, newheight);
    viewStats.frame = CGRectMake(0, imagePic.frame.origin.y + imagePic.frame.size.height + 10, viewStats.frame.size.width, viewStats.frame.size.height);
    //self.view.frame = CGRectMake(0, 0, 320, imagePic.frame.size.height + 100);
    //[buttonUser addTarget:self.parentViewController action:@selector(touchUser:) forControlEvents:UIControlEventTouchUpInside];
    
    // Style
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:buttonUser.bounds];
    buttonUser.layer.masksToBounds = NO;
    buttonUser.layer.shadowColor = [UIColor blackColor].CGColor;
    buttonUser.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    buttonUser.layer.shadowOpacity = 1.0f;
    buttonUser.layer.shadowRadius = 1.0f;
    buttonUser.layer.shadowPath = shadowPath.CGPath;
    
    UIBezierPath *shadowPathPic = [UIBezierPath bezierPathWithRect:imagePic.bounds];
    imagePic.layer.masksToBounds = NO;
    imagePic.layer.shadowColor = [UIColor blackColor].CGColor;
    imagePic.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    imagePic.layer.shadowOpacity = 1.0f;
    imagePic.layer.shadowRadius = 2.0f;
    imagePic.layer.shadowPath = shadowPathPic.CGPath;
}
@end
