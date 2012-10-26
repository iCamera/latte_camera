//
//  UIActionSheet+ButtonState.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/10/26.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "UIActionSheet+ButtonState.h"

@implementation UIActionSheet (ButtonState)
- (void)setButton:(NSInteger)buttonIndex toState:(BOOL)enabled {
    for (UIView* view in self.subviews)
    {
        if ([view isKindOfClass:[UIButton class]])
        {
            if (buttonIndex == 0) {
                if ([view respondsToSelector:@selector(setEnabled:)])
                {
                    UIButton* button = (UIButton*)view;
                    button.enabled = enabled;
                }
            }
            buttonIndex--;
        }
    }
}
@end
