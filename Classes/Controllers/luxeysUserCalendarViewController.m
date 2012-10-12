//
//  luxeysUserCalendarViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/10/05.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "luxeysUserCalendarViewController.h"

@interface luxeysUserCalendarViewController ()

@end

@implementation luxeysUserCalendarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        date = [[NSDate alloc] init];
        NSDateFormatter *formater = [[NSDateFormatter alloc] init];
        [formater setDateFormat:@""];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    luxeysButtonBrown30 *buttonClose = [[luxeysButtonBrown30 alloc] initWithFrame:CGRectMake(250, 400, 60, 30)];
    [buttonClose addTarget:self action:@selector(closeModal) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:buttonClose];
}

- (void)loadCalendar {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{

        
        dispatch_async(dispatch_get_main_queue(), ^{
                                                     [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                 });
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return pics.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    luxeysCellPicCalendar *cellPic;
    if (indexPath.row > 9) {
        cellPic = [collectionView dequeueReusableCellWithReuseIdentifier:@"PicCalendarFat" forIndexPath:indexPath];
    } else{
        cellPic = [collectionView dequeueReusableCellWithReuseIdentifier:@"PicCalendarThin" forIndexPath:indexPath];
    }
    
    cellPic.labelDate.text = [NSString stringWithFormat:@"%d", indexPath.row + 1];
    cellPic.labelBigDate.text = cellPic.labelDate.text;
    return cellPic;
}

- (void)closeModal {
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)setUserID:(NSInteger)aUserID {
    userID = aUserID;
}

@end
