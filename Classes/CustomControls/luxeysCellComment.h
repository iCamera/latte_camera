//
//  luxeysCellComment.h
//  Latte
//
//  Created by Xuan Dung Bui on 8/24/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "luxeysUtils.h"
#import "UIButton+AsyncImage.h"
#import "Comment.h"
#import "User.h"

@interface luxeysTableViewCellComment : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *textComment;
@property (strong, nonatomic) IBOutlet UILabel *labelAuthor;
@property (strong, nonatomic) IBOutlet UIButton *buttonUser;
@property (strong, nonatomic) IBOutlet UILabel *labelDate;
@property (strong, nonatomic) IBOutlet UIView *viewBack;

@property (strong, nonatomic) Comment *comment;

@end
