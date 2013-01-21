//
//  LXNavigationController.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/10/11.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "LXNavigationController.h"

@interface LXNavigationController ()

@end

@implementation LXNavigationController

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
	// Do any additional setup after loading the view.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self.parentViewController action:@selector(showAbout:)];
    tap.delegate = self;
    [self.navigationBar addGestureRecognizer:tap];
//    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] ini]
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return (![[[touch view] class] isSubclassOfClass:[UIControl class]]);
}
@end
