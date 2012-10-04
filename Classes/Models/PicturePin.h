//
//  PicturePin.h
//  Latte
//
//  Created by Xuan Dung Bui on 2012/10/03.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface PicturePin: NSObject <MKAnnotation> {
    
    CLLocationCoordinate2D coordinate;
    
    NSString *title;
    
    NSString *subtitle;
    
    
    
}

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *subtitle;



-(id)initWithCoordinate:(CLLocationCoordinate2D) coordinate;

@end
