//
//  luxeysPicInfoViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 9/7/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Picture.h"
#import "LXGalleryViewController.h"
#import <MapKit/MapKit.h>

@interface LXPicInfoViewController : UITableViewController<UIAlertViewDelegate, MKMapViewDelegate>

@property (strong, nonatomic) Picture *picture;
@property (assign, nonatomic) BOOL isModal;

- (IBAction)touchReport:(id)sender;
@end
