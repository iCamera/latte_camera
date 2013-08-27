//
//  luxeysCellComment.h
//  Latte
//
//  Created by Xuan Dung Bui on 8/24/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LXUtils.h"
#import "UIButton+AsyncImage.h"
#import "Comment.h"
#import "User.h"

@interface LXCellComment : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *textComment;
@property (strong, nonatomic) IBOutlet UILabel *labelAuthor;
@property (strong, nonatomic) IBOutlet UIButton *buttonUser;
@property (strong, nonatomic) IBOutlet UIButton *buttonReply;
@property (strong, nonatomic) IBOutlet UIButton *buttonReport;
@property (strong, nonatomic) IBOutlet UILabel *labelDate;
@property (strong, nonatomic) IBOutlet UIView *viewBack;
@property (strong, nonatomic) IBOutlet UIButton *buttonLike;
@property (strong, nonatomic) IBOutlet UILabel *labelLike;
@property (strong, nonatomic) IBOutlet UIImageView *imageLike;
@property (strong, nonatomic) IBOutlet UIImageView *imageNationality;

@property (strong, nonatomic) Comment *comment;

@end
