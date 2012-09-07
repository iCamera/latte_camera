//
//  luxeysCellComment.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/24/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "luxeysCellComment.h"
#import "UIImageView+AFNetworking.h"

@implementation luxeysTableViewCellComment
@synthesize textComment;
@synthesize labelAuthor;
@synthesize buttonUser;

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

- (void)setComment:(NSDictionary *)comment {
    NSDictionary* user = [comment objectForKey:@"user"];
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
    textComment.text = [comment objectForKey:@"description"];
    labelAuthor.text = [user objectForKey:@"name"];
}

@end
