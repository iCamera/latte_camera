//
//  LXHelpBokehViewController.m
//  Latte camera
//
//  Created by Xuan Dung Bui on 2013/01/25.
//  Copyright (c) 2013年 LUXEYS. All rights reserved.
//

#import "LXHelpBokehViewController.h"

@interface LXHelpBokehViewController ()

@end

@implementation LXHelpBokehViewController

@synthesize viewHelp;
@synthesize viewPopupHelp;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    viewPopupHelp.layer.cornerRadius = 10.0;
    viewPopupHelp.layer.borderWidth = 1.0;
    viewPopupHelp.layer.borderColor = [[UIColor colorWithWhite:1.0 alpha:0.25] CGColor];
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)touchClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
