//
//  LXStreamViewController.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 4/4/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHTCollectionViewWaterfallLayout.h"
#import "LXGalleryViewController.h"

@interface LXStreamViewController : UICollectionViewController <CHTCollectionViewDelegateWaterfallLayout, LXGalleryViewControllerDataSource>

- (IBAction)showMenu;
- (IBAction)selectCountry:(id)sender;

@end
