//
//  luxeysTabBarViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 8/14/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "luxeysButtonNav.h"
#import "luxeysLoginViewController.h"

@interface luxeysTabBarViewController : UITabBarController<UserLoginDelegate> {
    
}

@property (strong, nonatomic) IBOutlet luxeysButtonNav *buttonReveal;
@property (strong, nonatomic) UIPanGestureRecognizer *navigationBarPanGestureRecognizer;

- (void)addLoginBehavior;
- (void)removeLoginBehavior;
- (IBAction)loginPressed:(id)sender;

@end
