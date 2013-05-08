//
//  luxeysPicMapViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 2012/10/03.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "PicturePin.h"
#import "Picture.h"

#define METERS_PER_MILE 1609.344

@interface LXPicMapViewController : UIViewController <MKMapViewDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapPic;

@property (strong, nonatomic) Picture *picture;
@property (strong, nonatomic) IBOutlet UIView *viewHidden;

@end
