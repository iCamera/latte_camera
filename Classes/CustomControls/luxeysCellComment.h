//
//  luxeysCellComment.h
//  Latte
//
//  Created by Xuan Dung Bui on 8/24/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface luxeysTableViewCellComment : UITableViewCell

@property (strong, nonatomic) IBOutlet UITextView *textComment;
@property (strong, nonatomic) IBOutlet UILabel *labelAuthor;
@property (strong, nonatomic) IBOutlet UIButton *buttonUser;

- (void)setComment:(NSDictionary*)comment;

@end
