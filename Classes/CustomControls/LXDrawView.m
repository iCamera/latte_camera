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

@synthesize lastPoint;
@synthesize prePreviousPoint;
@synthesize previousPoint;
@synthesize drawImageView;
@synthesize lineWidth;
@synthesize currentColor;
@synthesize isEraser;
@synthesize isEmpty;

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
    
    self.previousPoint = [touch locationInView:self];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    self.prePreviousPoint = self.previousPoint;
    self.previousPoint = [touch previousLocationInView:self];
    CGPoint currentPoint = [touch locationInView:self];
    
    // calculate mid point
    CGPoint mid1 = [self calculateMidPointForPoint:self.previousPoint andPoint:self.prePreviousPoint];
    CGPoint mid2 = [self calculateMidPointForPoint:currentPoint andPoint:self.previousPoint];
    
    UIGraphicsBeginImageContextWithOptions(self.drawImageView.frame.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [[self currentColor] setStroke];
    
    CGContextSetAllowsAntialiasing(UIGraphicsGetCurrentContext(), true);
    CGContextSetShouldAntialias(UIGraphicsGetCurrentContext(), true);
    
    [self.drawImageView.image drawInRect:CGRectMake(0, 0, self.drawImageView.frame.size.width, self.drawImageView.frame.size.height)];
    
    CGContextMoveToPoint(context, mid1.x, mid1.y);
    // Use QuadCurve is the key
    CGContextAddQuadCurveToPoint(context, self.previousPoint.x, self.previousPoint.y, mid2.x, mid2.y);
    
    CGContextSetLineCap(context, kCGLineCapRound);
    
    CGFloat xDist = (previousPoint.x - currentPoint.x); //[2]
    CGFloat yDist = (previousPoint.y - currentPoint.y); //[3]
    CGFloat distance = sqrt((xDist * xDist) + (yDist * yDist)); //[4]
    
    distance = distance / 10;
    
    if (distance > 10) {
        distance = 10.0;
    }
    
    distance = distance / 10;
    distance = distance * 3;
    
//    if (4.0 - distance > self.lineWidth) {
//        lineWidth = lineWidth + 0.3;
//    } else {
//        lineWidth = lineWidth - 0.3;
//    }
    
    CGContextSetLineWidth(context, self.lineWidth);
    if (isEraser) {
        CGContextSetBlendMode(context, kCGBlendModeClear);
        CGContextSetStrokeColorWithColor(context, [[UIColor clearColor] CGColor]);
    } else {
        CGContextSetBlendMode(context, kCGBlendModeNormal);
    }
    //    CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
    CGContextStrokePath(context);
    
    self.drawImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

- (CGPoint)calculateMidPointForPoint:(CGPoint)p1 andPoint:(CGPoint)p2 {
    return CGPointMake((p1.x+p2.x)/2, (p1.y+p2.y)/2);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self];
    
//    [self setLineWidth:1.0];
    
    if ([touch tapCount] == 1) {
        UIGraphicsBeginImageContextWithOptions(self.drawImageView.frame.size, NO, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        [[self currentColor] setStroke];
        
        CGContextSetAllowsAntialiasing(context, NO);
        CGContextSetShouldAntialias(context, NO);
        
        [self.drawImageView.image drawInRect:CGRectMake(0, 0, self.drawImageView.frame.size.width, self.drawImageView.frame.size.height)];
        
        CGContextMoveToPoint(context, currentPoint.x, currentPoint.y);
        CGContextAddLineToPoint(context, currentPoint.x, currentPoint.y);
        
        CGContextSetLineCap(context, kCGLineCapRound);
        
        CGContextSetLineWidth(context, lineWidth);
        if (isEraser) {
            CGContextSetBlendMode(context, kCGBlendModeClear);
            CGContextSetStrokeColorWithColor(context, [[UIColor clearColor] CGColor]);
        }
        
        CGContextStrokePath(context);
        
        self.drawImageView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    isEmpty = NO;
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
