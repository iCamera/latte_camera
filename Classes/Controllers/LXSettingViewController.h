//
//  luxeysSettingViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 8/20/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "QuickDialog.h"

@interface LXSettingViewController : QuickDialogController<QuickDialogEntryElementDelegate> {
    MBProgressHUD *HUD;
}

@end
