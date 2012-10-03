//
//  luxeysTemplateTimlinePicMultiItem.h
//  Latte
//
//  Created by Xuan Dung Bui on 2012/09/28.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIButton+AsyncImage.h"
#import "LuxeysPicture.h"

@interface luxeysTemplateTimlinePicMultiItem : UIViewController {
    LuxeysPicture *pic;
    id parent;
}
@property (strong, nonatomic) IBOutlet UIButton *buttonComment;
@property (strong, nonatomic) IBOutlet UIButton *buttonImage;
@property (strong, nonatomic) IBOutlet UIButton *buttonVote;

- (id)initWithPic:(LuxeysPicture *)aPic parent:(id)aParent;

@end
