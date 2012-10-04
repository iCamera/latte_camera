//
//  PicturePin.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/10/03.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "PicturePin.h"

@implementation PicturePin

@synthesize coordinate;
@synthesize title;
@synthesize subtitle;

-(id)initWithCoordinate:(CLLocationCoordinate2D) c{
    coordinate=c;
    return self;
}

@end
