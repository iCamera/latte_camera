//
//  luxeysCollectionCellPic.h
//  Latte
//
//  Created by Xuan Dung Bui on 2012/10/12.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Picture.h"

@interface luxeysCollectionCellPic : UICollectionViewCell {
    Picture *pic;
}
@property (strong, nonatomic) IBOutlet UIButton *buttonPic;

- (void)setPic:(Picture *)aPic;

@end
