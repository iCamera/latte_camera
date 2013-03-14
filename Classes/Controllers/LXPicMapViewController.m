//
//  luxeysPicMapViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/10/03.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "LXPicMapViewController.h"
#import "LXAppDelegate.h"

@interface LXPicMapViewController ()

@end

@implementation LXPicMapViewController {
    PicturePin *pin;
}

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

- (void)setPicture:(Picture *)picture {
    CLLocationCoordinate2D location;
    location.latitude = [picture.latitude floatValue];
    location.longitude = [picture.longitude floatValue];
    
    pin = [[PicturePin alloc] initWithCoordinate:location];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    [app.tracker sendView:@"Picture Map Screen"];
    
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

@end
