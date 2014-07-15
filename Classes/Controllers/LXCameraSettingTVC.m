//
//  LXCameraSettingTVC.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 7/14/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import "LXCameraSettingTVC.h"

@interface LXCameraSettingTVC ()

@end

@implementation LXCameraSettingTVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"LatteCameraStartUp"]) {
        _switchCamera.on = [defaults boolForKey:@"LatteCameraStartUp"];
    }
    
    if ([defaults objectForKey:@"LatteSaveToAlbum"]) {
        _switchSave.on = [defaults boolForKey:@"LatteSaveToAlbum"];
    } else {
        _switchSave.on = YES;
    }
    
    if ([defaults objectForKey:@"LatteSaveOrigin"]) {
        _switchOrigin.on = [defaults boolForKey:@"LatteSaveOrigin"];
    } else {
        _switchOrigin.on = YES;
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)changeOrigin:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:_switchOrigin.on forKey:@"LatteSaveOrigin"];
    [defaults synchronize];
}

- (IBAction)changeCamera:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:_switchCamera.on forKey:@"LatteCameraStartUp"];
    [defaults synchronize];
}

- (IBAction)changeSave:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:_switchSave.on forKey:@"LatteSaveToAlbum"];
    [defaults synchronize];
}
@end
