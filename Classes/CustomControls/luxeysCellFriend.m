//
//  luxeysCellFriend.m
//  Latte
//
//  Created by Xuan Dung Bui on 9/6/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "luxeysCellFriend.h"
#import "UIImageView+AFNetworking.h"

@implementation luxeysCellFriend
@synthesize buttonUser;
@synthesize labelName;
@synthesize labelIntro;

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

- (void)setUser:(NSDictionary*)user {
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
    //textComment.text = [comment objectForKey:@"description"];
    labelName.text = [user objectForKey:@"name"];
}

@end
