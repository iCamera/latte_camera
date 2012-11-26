//
//  LXDrawView.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/11/19.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "LXDrawView.h"

@interface LXDrawView()
    - (CGPoint)calculateMidPointForPoint:(CGPoint)p1 andPoint:(CGPoint)p2;
@end
@implementation LXDrawView

@synthesize drawImageView;
@synthesize lineWidth;
@synthesize currentColor;
@synthesize isEmpty;
@synthesize delegate;

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    aPath = [[UIBezierPath alloc] init];
    
    [aPath moveToPoint:[touch locationInView:self]];
    isEmpty = YES;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (isEmpty)
    {
        drawImageView.image = nil;
        isEmpty = NO;
    }
    
    UITouch *touch = [touches anyObject];
    
    CGPoint currentPoint = [touch locationInView:self];
    
    
    UIGraphicsBeginImageContextWithOptions(self.drawImageView.frame.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [[self currentColor] setStroke];
    
    [aPath addLineToPoint:currentPoint];
    aPath.lineWidth = self.lineWidth;
    aPath.lineCapStyle = kCGLineCapRound;
    [aPath stroke];

    [drawImageView.image drawInRect:drawImageView.frame];
    
    CGContextStrokePath(context);
    
    drawImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

- (CGPoint)calculateMidPointForPoint:(CGPoint)p1 andPoint:(CGPoint)p2 {
    return CGPointMake((p1.x+p2.x)/2, (p1.y+p2.y)/2);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    //NSLog(@"Tap count %d", touch.tapCount);
    if (touch.tapCount == 0)
        [self redraw];
}

- (void)redraw {
    UIGraphicsBeginImageContextWithOptions(drawImageView.frame.size, NO, 0);
    
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    CGGradientRef glossGradient;
    CGColorSpaceRef rgbColorspace;
    size_t num_locations = 2;
    CGFloat locations[2] = { 1.0, 0.0 };
    CGFloat components[8] = { 1.0, 0.0, 0.0, 1.0,  // Start color
        1.0, 0.0, 0.0, 1.0 }; // End color
    
    rgbColorspace = CGColorSpaceCreateDeviceRGB();
    glossGradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, num_locations);
    
    CGRect currentBounds = self.bounds;
    CGPoint topCenter = CGPointMake(0, 0.0f);
    CGPoint bottomCenter = CGPointMake(currentBounds.size.width, currentBounds.size.height);
    CGContextDrawLinearGradient(currentContext, glossGradient, topCenter, bottomCenter, 0);
    
    CGContextSetBlendMode(currentContext, kCGBlendModeClear);
    CGContextSetStrokeColorWithColor(currentContext, [[UIColor clearColor] CGColor]);
    
    [aPath fill];
    
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    GPUImageFastBlurFilter *blur = [[GPUImageFastBlurFilter alloc] init];
    blur.blurSize = lineWidth/2.0;
    blur.blurPasses = 4;
    
    mask = [UIImage imageWithCGImage:[blur newCGImageByFilteringImage:viewImage]];

    drawImageView.image = mask;
    [delegate newMask:mask];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    drawImageView.image = mask;
}



/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
