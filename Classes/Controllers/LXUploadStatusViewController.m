//
//  LXUploadStatusViewController.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 7/2/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXUploadStatusViewController.h"
#import "LXCellUpload.h"
#import "LXAppDelegate.h"

@interface LXUploadStatusViewController ()

@end

@implementation LXUploadStatusViewController

@synthesize tableUpload;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadSuccess:) name:@"LXUploaderSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadStart:) name:@"LXUploaderStart" object:nil];
	// Do any additional setup after loading the view.
}

- (void)uploadStart:(NSNotification *) notification {
    [tableUpload reloadData];
}

- (void)uploadSuccess:(NSNotification *) notification {
    [tableUpload reloadData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LXAppDelegate *app = [LXAppDelegate currentDelegate];
    LXCellUpload* cellUpload = [tableView dequeueReusableCellWithIdentifier:@"Upload"];
    cellUpload.uploader = app.uploader[indexPath.row];
    return cellUpload;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    LXAppDelegate *app = [LXAppDelegate currentDelegate];
    return app.uploader.count;

}

- (IBAction)touchBackground:(id)sender {
    [UIView animateWithDuration:kGlobalAnimationSpeed animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        self.view.hidden = true;
    }];
}


- (void)viewDidUnload {
    [self setTableUpload:nil];
    [super viewDidUnload];
}
@end
