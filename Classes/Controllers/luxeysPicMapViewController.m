//
//  luxeysPicMapViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/10/03.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "luxeysPicMapViewController.h"

@interface luxeysPicMapViewController ()

@end

@implementation luxeysPicMapViewController

@synthesize mapPic;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)touchBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)touchApp:(id)sender {
    MKPlacemark *mark = [[MKPlacemark alloc] initWithCoordinate:pin.coordinate addressDictionary:nil];
    [[[MKMapItem alloc] initWithPlacemark:mark] openInMapsWithLaunchOptions:nil];
}

-(void)setPointWithLongitude:(CGFloat)aLongitude andLatitude:(CGFloat)aLatitude {
    CLLocationCoordinate2D location;
    location.latitude = aLatitude;
    location.longitude = aLongitude;
    
    pin = [[PicturePin alloc] initWithCoordinate:location];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(pin.coordinate, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
    
    MKCoordinateRegion adjustedRegion = [mapPic regionThatFits:viewRegion];
    
    [mapPic addAnnotation:pin];
    [mapPic setRegion:adjustedRegion animated:YES];
    [mapPic regionThatFits:adjustedRegion];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    if ([self.navigationController.viewControllers[self.navigationController.viewControllers.count-1] isKindOfClass:[luxeysPicDetailViewController class]]) {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"TabbarHide"
         object:self];
    }
    
    [super viewWillDisappear:animated];
}

@end
