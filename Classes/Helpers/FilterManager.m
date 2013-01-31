//
//  FilterManager.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/10/15.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "FilterManager.h"

@implementation FilterManager

- (id)init {
    self = [super init];
    if (self != nil) {
        tonecurve = [[GPUImageToneCurveFilter alloc] init];
        rgb = [[GPUImageRGBFilter alloc] init];
        filter = [[LXFilter alloc] init];
        filterMono = [[LXFilterMono alloc] init];
        lxEffect1 = [[LXEffect1 alloc] init];
        lxEffect2 = [[LXEffect2 alloc] init];
        lxEffect3 = [[LXEffect3 alloc] init];
        lxEffect5 = [[LXEffect5 alloc] init];
    }
    return self;
}

- (GPUImageFilter*)getEffect:(NSInteger)aEffect {
    switch (aEffect) {
        case 1:
            return lxEffect1;
        case 2:
            return lxEffect2;
        case 3:
            return lxEffect3;
        case 4:
            return lxEffect5;
        case 5:
            return [self myEffect1];
        case 6:
            return [self myEffect2];
        case 7:
            return [self myEffect3];
        case 8:
            return [self myEffect4];
        case 9:
            return [self myEffect5];
        case 10:
            return [self myEffect6];
        case 11:
            return [self myEffect7];
        case 12:
            return [self tmpEffect1];
        case 13:
            return [self effect5];
        case 14:
            return [self tmpEffect5];
        case 15:
            return [self effect3];
        case 16:
            return [self effect1];
        default:
            return nil;
    }
}

- (GPUImageFilter *)effect1 {
    [tonecurve setRedControlPoints:[NSArray arrayWithObjects:
                                    [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
                                    [NSValue valueWithCGPoint:CGPointMake(102.0f/255.0f, 90.0f/255.0f)],
                                    [NSValue valueWithCGPoint:CGPointMake(111.0f/255.0f, 108.0f/255.0f)],
                                    [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)],
                                    nil]];
    [tonecurve setGreenControlPoints:[NSArray arrayWithObjects:
                                      [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
                                      [NSValue valueWithCGPoint:CGPointMake(83.0f/255.0f, 73.0f/255.0f)],
                                      [NSValue valueWithCGPoint:CGPointMake(93.0f/255.0f, 90.0f/255.0f)],
                                      [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)],
                                      nil]];
    
    [tonecurve setBlueControlPoints:[NSArray arrayWithObjects:
                                     [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
                                     [NSValue valueWithCGPoint:CGPointMake(86.0f/255.0f, 100.0f/255.0f)],
                                     [NSValue valueWithCGPoint:CGPointMake(121.0f/255.0f, 118.0f/255.0f)],
                                     [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)],
                                     nil]];
    return tonecurve;
}

- (GPUImageFilter *)effect2 {
    float curve[16][3] = {
        {23,20,60},
        {32,37,78},
        {43,54,95},
        {55,73,110},
        {68,91,124},
        {83,111,136},
        {98,130,148},
        {114,149,159},
        {130,167,168},
        {146,182,178},
        {161,198,187},
        {176,212,196},
        {191,224,204},
        {206,233,212},
        {222,241,220},
        {238,248,229}
    };
    
    [tonecurve setRedControlPoints:[self curveWithPoint:curve atIndex:0]];
    [tonecurve setGreenControlPoints:[self curveWithPoint:curve atIndex:1]];
    [tonecurve setBlueControlPoints:[self curveWithPoint:curve atIndex:2]];
    
    return tonecurve;
}

- (GPUImageFilter *)effect3 {
//    UIImage *image = [UIImage imageNamed:@"grain.jpg"];
//    texture = [[GPUImagePicture alloc] initWithImage:image smoothlyScaleOutput:YES];
    
    rgb.red = 1.36;
    rgb.green = 1.36;
    rgb.blue = 1.28;
    
//    [texture processImage];
//    [texture addTarget:grain];
//    [grain addTarget:mono];
    
//    effectIn = rgb;
    return rgb;
}


- (GPUImageFilter *)effect4 {
    rgb.red = 2.36;
    rgb.green = 2.36;
    rgb.blue = 2.28;
    
    return rgb;
}

- (GPUImageFilter *)effect5 {
//    UIImage *image = [UIImage imageNamed:@"grain.jpg"];
//    texture = [[GPUImagePicture alloc] initWithImage:image smoothlyScaleOutput:YES];
        
    float curve[16][3] = {
        {19.0, 0.0, 0.0},
        {31.0, 9.0, 0.0},
        {41.0, 24.0, 1.0},
        {53.0, 39.0, 2.0},
        {65.0, 55.0, 25.0},
        {79.0, 72.0, 46.0},
        {93.0, 89.0, 70.0},
        {109.0, 108.0, 95.0},
        {124.0, 127.0, 122.0},
        {139.0, 146.0, 148.0},
        {154.0, 165.0, 174.0},
        {169.0, 182.0, 197.0},
        {183.0, 199.0, 219.0},
        {195.0, 215.0, 242.0},
        {207.0, 229.0, 254.0},
        {218.0, 244.0, 255.0}
    };
    
    [tonecurve setRedControlPoints:[self curveWithPoint:curve atIndex:0]];
    [tonecurve setGreenControlPoints:[self curveWithPoint:curve atIndex:1]];
    [tonecurve setBlueControlPoints:[self curveWithPoint:curve atIndex:2]];
    
    return tonecurve;
}

- (GPUImageFilter*)tmpEffect1 {
    return [[GPUImageToneCurveFilter alloc] initWithACV:@"effect1"];
}

- (GPUImageFilter*)tmpEffect2 {
    return [[GPUImageToneCurveFilter alloc] initWithACV:@"effect2"];
}

- (GPUImageFilter*)tmpEffect3 {
    return [[GPUImageToneCurveFilter alloc] initWithACV:@"effect3"];
}

- (GPUImageFilter*)tmpEffect4 {
    return [[GPUImageToneCurveFilter alloc] initWithACV:@"effect4"];
}

- (GPUImageFilter*)tmpEffect5 {
    return [[GPUImageToneCurveFilter alloc] initWithACV:@"effect5"];
}

- (GPUImageFilter*)tmpEffect6 {
    return [[GPUImageToneCurveFilter alloc] initWithACV:@"effect6"];
}

- (GPUImageFilter*)tmpEffect7 {
    return [[GPUImageToneCurveFilter alloc] initWithACV:@"effect7"];
}

- (GPUImageFilter*)curve1 {
    float curve[16][3] = {
        {12.0, 0.0, 0.0},
        {24.0, 9.0, 4.0},
        {37.0, 24.0, 10.0},
        {50.0, 40.0, 21.0},
        {64.0, 55.0, 40.0},
        {78.0, 73.0, 62.0},
        {93.0, 89.0, 83.0},
        {108.0, 107.0, 104.0},
        {125.0, 125.0, 126.0},
        {139.0, 142.0, 149.0},
        {154.0, 160.0, 170.0},
        {169.0, 177.0, 190.0},
        {183.0, 193.0, 211.0},
        {198.0, 209.0, 231.0},
        {211.0, 224.0, 244.0},
        {224.0, 240.0, 250.0}
    };
    
    [tonecurve setRedControlPoints:[self curveWithPoint:curve atIndex:0]];
    [tonecurve setGreenControlPoints:[self curveWithPoint:curve atIndex:1]];
    [tonecurve setBlueControlPoints:[self curveWithPoint:curve atIndex:2]];
        
    return tonecurve;
}


- (NSArray *)curveWithPoint:(float[16][3])points atIndex:(int)idx {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i < 16; i++) {
        [array addObject:[NSValue valueWithCGPoint:CGPointMake(16.0*i/240.0, points[i][idx]/255.0)]];
    }
    return array;
}

- (GPUImageFilter*)myEffect1 {
    [filter setRedCurve:[NSArray arrayWithObjects:
                       [NSValue valueWithCGPoint:CGPointMake(0, 5)],
                       [NSValue valueWithCGPoint:CGPointMake(127, 133)],
                       [NSValue valueWithCGPoint:CGPointMake(255, 255)], nil]
           greenCurve:[NSArray arrayWithObjects:
                       [NSValue valueWithCGPoint:CGPointMake(0, 70)],
                       [NSValue valueWithCGPoint:CGPointMake(127, 133)],
                       [NSValue valueWithCGPoint:CGPointMake(255, 255)], nil]
            blueCurve:[NSArray arrayWithObjects:
                       [NSValue valueWithCGPoint:CGPointMake(0, 62)],
                       [NSValue valueWithCGPoint:CGPointMake(127, 133)],
                       [NSValue valueWithCGPoint:CGPointMake(255, 255)], nil]];
    filter.gradient = 0.22;
    filter.overlay = 0.58;
//    filter.saturation = 2.0;
//    filter.brightness = 0.0;
    
    return filter;
}

- (GPUImageFilter*)myEffect2 {
    [filter setRedCurve:[NSArray arrayWithObjects:
                         [NSValue valueWithCGPoint:CGPointMake(0, 89)],
                         [NSValue valueWithCGPoint:CGPointMake(127, 120)],
                         [NSValue valueWithCGPoint:CGPointMake(255, 255)], nil]
             greenCurve:[NSArray arrayWithObjects:
                         [NSValue valueWithCGPoint:CGPointMake(0, 0)],
                         [NSValue valueWithCGPoint:CGPointMake(127, 78)],
                         [NSValue valueWithCGPoint:CGPointMake(255, 255)], nil]
              blueCurve:[NSArray arrayWithObjects:
                         [NSValue valueWithCGPoint:CGPointMake(0, 90)],
                         [NSValue valueWithCGPoint:CGPointMake(127, 112)],
                         [NSValue valueWithCGPoint:CGPointMake(255, 255)], nil]];
    filter.gradient = 0.43;
    filter.overlay = 0.72;
//    filter.saturation = 2.0;
//    filter.brightness = 0.0;
    
    return filter;
}

- (GPUImageFilter*)myEffect3 {
    [filter setRedCurve:[NSArray arrayWithObjects:
                         [NSValue valueWithCGPoint:CGPointMake(0, 73)],
                         [NSValue valueWithCGPoint:CGPointMake(127, 184)],
                         [NSValue valueWithCGPoint:CGPointMake(255, 255)], nil]
             greenCurve:[NSArray arrayWithObjects:
                         [NSValue valueWithCGPoint:CGPointMake(0, 69)],
                         [NSValue valueWithCGPoint:CGPointMake(127, 186)],
                         [NSValue valueWithCGPoint:CGPointMake(255, 255)], nil]
              blueCurve:[NSArray arrayWithObjects:
                         [NSValue valueWithCGPoint:CGPointMake(0, 51)],
                         [NSValue valueWithCGPoint:CGPointMake(127, 142)],
                         [NSValue valueWithCGPoint:CGPointMake(255, 255)], nil]];
    filter.gradient = 0.48;
    filter.overlay = 0.61;
//    filter.saturation = 2.0;
//    filter.brightness = -0.05;
    
    return filter;
}

- (GPUImageFilter*)myEffect4 {
    [filter setRedCurve:[NSArray arrayWithObjects:
                         [NSValue valueWithCGPoint:CGPointMake(0, 10)],
                         [NSValue valueWithCGPoint:CGPointMake(127, 99)],
                         [NSValue valueWithCGPoint:CGPointMake(255, 255)], nil]
             greenCurve:[NSArray arrayWithObjects:
                         [NSValue valueWithCGPoint:CGPointMake(0, 33)],
                         [NSValue valueWithCGPoint:CGPointMake(127, 129)],
                         [NSValue valueWithCGPoint:CGPointMake(255, 255)], nil]
              blueCurve:[NSArray arrayWithObjects:
                         [NSValue valueWithCGPoint:CGPointMake(0, 21)],
                         [NSValue valueWithCGPoint:CGPointMake(127, 119)],
                         [NSValue valueWithCGPoint:CGPointMake(255, 255)], nil]];
    filter.gradient = 0.43;
    filter.overlay = 0.72;
//    filter.saturation = 2.0;
//    filter.brightness = 0.0;
    
    return filter;
}

- (GPUImageFilter*)myEffect5 {
    [filter setRedCurve:[NSArray arrayWithObjects:
                         [NSValue valueWithCGPoint:CGPointMake(0, 38)],
                         [NSValue valueWithCGPoint:CGPointMake(127, 133)],
                         [NSValue valueWithCGPoint:CGPointMake(255, 255)], nil]
             greenCurve:[NSArray arrayWithObjects:
                         [NSValue valueWithCGPoint:CGPointMake(0, 52)],
                         [NSValue valueWithCGPoint:CGPointMake(127, 133)],
                         [NSValue valueWithCGPoint:CGPointMake(255, 255)], nil]
              blueCurve:[NSArray arrayWithObjects:
                         [NSValue valueWithCGPoint:CGPointMake(0, 124)],
                         [NSValue valueWithCGPoint:CGPointMake(127, 133)],
                         [NSValue valueWithCGPoint:CGPointMake(255, 255)], nil]];
    filter.gradient = 0.43;
    filter.overlay = 0.72;
//    filter.saturation = 2.0;
//    filter.brightness = 0.0;
    
    return filter;
}


- (GPUImageFilter*)myEffect6 {
    [filter setRedCurve:[NSArray arrayWithObjects:
                         [NSValue valueWithCGPoint:CGPointMake(0, 36)],
                         [NSValue valueWithCGPoint:CGPointMake(102, 132)],
                         [NSValue valueWithCGPoint:CGPointMake(255, 255)], nil]
             greenCurve:[NSArray arrayWithObjects:
                         [NSValue valueWithCGPoint:CGPointMake(0, 44)],
                         [NSValue valueWithCGPoint:CGPointMake(102, 106)],
                         [NSValue valueWithCGPoint:CGPointMake(255, 255)], nil]
              blueCurve:[NSArray arrayWithObjects:
                         [NSValue valueWithCGPoint:CGPointMake(0, 107)],
                         [NSValue valueWithCGPoint:CGPointMake(102, 106)],
                         [NSValue valueWithCGPoint:CGPointMake(255, 255)], nil]];
    filter.gradient = 0.95;
    filter.overlay = 0.75;
//    filter.saturation = 1.5;
//    filter.brightness = 0.0;
    
    return filter;
}


- (GPUImageFilter*)myEffect7 {
    [filter setRedCurve:[NSArray arrayWithObjects:
                         [NSValue valueWithCGPoint:CGPointMake(0, 117)],
                         [NSValue valueWithCGPoint:CGPointMake(140, 133)],
                         [NSValue valueWithCGPoint:CGPointMake(255, 255)], nil]
             greenCurve:[NSArray arrayWithObjects:
                         [NSValue valueWithCGPoint:CGPointMake(0, 66)],
                         [NSValue valueWithCGPoint:CGPointMake(140, 133)],
                         [NSValue valueWithCGPoint:CGPointMake(255, 255)], nil]
              blueCurve:[NSArray arrayWithObjects:
                         [NSValue valueWithCGPoint:CGPointMake(0, 34)],
                         [NSValue valueWithCGPoint:CGPointMake(140, 133)],
                         [NSValue valueWithCGPoint:CGPointMake(255, 255)], nil]];
    filter.gradient = 0.95;
    filter.overlay = 0.70;
//    filter.saturation = 1.5;
//    filter.brightness = 0.0;

    return filter;
}

@end
