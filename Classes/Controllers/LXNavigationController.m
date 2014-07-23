//
//  LXNavigationController.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 3/19/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXNavigationController.h"
#import "LXAppDelegate.h"

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
    
    //self.delegate = app.viewMainTab;
    self.delegate = self;
	// Do any additional setup after loading the view.
    [self.view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)]];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognized:)];
    tap.cancelsTouchesInView = NO;
    [self.navigationBar addGestureRecognizer:tap];
}

- (void)panGestureRecognized:(UIPanGestureRecognizer *)sender
{
    // Dismiss keyboard (optional)
    //
    [self.view endEditing:YES];
    [self.frostedViewController.view endEditing:YES];
    
    // Present the view controller
    //
    [self.frostedViewController panGestureRecognized:sender];
}

- (void)tapGestureRecognized:(UIPanGestureRecognizer *)sender
{
    [self scrollToTop];
}

- (void)scrollToTop {
    if ([self.topViewController respondsToSelector:@selector(tableView)]) {
        UITableViewController *view = (UITableViewController*)self.topViewController;
        // No animation to prevent too much pageview counter request
        [view.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    }
    
    if ([self.topViewController respondsToSelector:@selector(collectionView)]) {
        UICollectionViewController *view = (UICollectionViewController*)self.topViewController;
        // No animation to prevent too much pageview counter request
        [view.collectionView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    }
}



- (void)popViewController {
    [self popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
