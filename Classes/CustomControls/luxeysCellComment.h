//
//  luxeysCellComment.h
//  Latte
//
//  Created by Xuan Dung Bui on 8/24/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface luxeysTableViewCellComment : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *textComment;
@property (strong, nonatomic) IBOutlet UILabel *labelAuthor;
@property (strong, nonatomic) IBOutlet UIButton *buttonUser;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraintCommentHeight;

- (void)setComment:(NSDictionary*)comment;

@end
