//
//  luxeysWelcomeViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 8/8/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSCollectionView.h"
#import "luxeysButtonBrown30.h"
#import "luxeysLoginViewController.h"

@interface luxeysWelcomeViewController : UIViewController<SSCollectionViewDataSource, SSCollectionViewDelegate, UIScrollViewDelegate> {
    NSMutableArray *_items;
}

@property (strong, nonatomic) IBOutlet luxeysButtonBrown30 *buttonLeftMenu;
@property (strong, nonatomic) IBOutlet luxeysButtonBrown30 *buttonNavRight;
@property (strong, nonatomic) UIPanGestureRecognizer *navigationBarPanGestureRecognizer;
@property (nonatomic, retain, readonly) SSCollectionView *collectionView;

- (IBAction)loginPressed:(id)sender;

@end
