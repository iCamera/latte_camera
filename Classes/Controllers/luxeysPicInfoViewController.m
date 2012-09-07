//
//  luxeysPicInfoViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 9/7/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "luxeysPicInfoViewController.h"
#import "luxeysCellProfile.h"
#import "UIImageView+AFNetworking.h"

@interface luxeysPicInfoViewController () {
    NSDictionary *exif;
    NSArray *keyBasic;
    NSArray *keyExif;
    NSMutableArray *sections;
}
@end

@implementation luxeysPicInfoViewController

@synthesize tableInfo;
@synthesize picture = _picture;
@synthesize labelTitle;
@synthesize imagePic;
@synthesize viewHeader;

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
    [imagePic setImageWithURL:[NSURL URLWithString:[_picture objectForKey:@"url_square"]]];
    
    viewHeader.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_sub_back.png"]];
    
//    CGRect frame = tableInfo.frame;
//    frame.size = tableInfo.contentSize;
//    tableInfo.frame = frame;
//    self.viewScroll.contentSize = CGSizeMake(320, frame.size.height + 50);


    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:imagePic.bounds];
    imagePic.layer.masksToBounds = NO;
    imagePic.layer.shadowColor = [UIColor blackColor].CGColor;
    imagePic.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    imagePic.layer.shadowOpacity = 1.0f;
    imagePic.layer.shadowRadius = 1.0f;
    imagePic.layer.shadowPath = shadowPath.CGPath;
    
    
    labelTitle.text = [_picture objectForKey:@"title"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [tableInfo setNeedsDisplay];
    
    
//    CGRect frame = tableInfo.frame;
//    frame.size = tableInfo.contentSize;
//    tableInfo.frame = frame;
//    self.viewScroll.contentSize = CGSizeMake(320, frame.size.height + 50);
    
//    [viewScroll setNeedsLayout];
    
}

- (void)viewDidUnload
{
    [self setTableInfo:nil];
    [self setLabelTitle:nil];
    [self setImagePic:nil];
    [self setViewHeader:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (IBAction)touchBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setPicture:(NSDictionary *)picture {
    sections = [[NSMutableArray alloc] init];
    _picture = picture;
    
    NSMutableSet *keyBasicSet = [NSMutableSet setWithObjects:@"taken_at", @"created_at", @"tags", nil];
    NSSet *allField = [NSSet setWithArray:[picture allKeys]];
    [keyBasicSet intersectSet:allField];
    keyBasic = [keyBasicSet allObjects];
    [sections addObject:keyBasic];
    exif = [picture objectForKey:@"exif"];
    if (exif.count > 0) {
        [sections addObject:exif];
        keyExif = [exif allKeys];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1)
    {
        return keyExif.count;
    }
    return [keyBasic count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    luxeysCellProfile *cell = [tableView dequeueReusableCellWithIdentifier:@"Profile"];
    if (indexPath.section == 0)
    {        
        cell.labelDetail.text = [_picture objectForKey:[keyBasic objectAtIndex:indexPath.row]];
        if ([[keyBasic objectAtIndex:indexPath.row] isEqualToString:@"taken_at"]) {
            cell.labelField.text = @"撮影月日";
        }
        if ([[keyBasic objectAtIndex:indexPath.row] isEqualToString:@"created_at"]) {
            cell.labelField.text = @"追加月日";
        }
        if ([[keyBasic objectAtIndex:indexPath.row] isEqualToString:@"tags"]) {
            cell.labelField.text = @"タグ";
        }
        if ([[keyBasic objectAtIndex:indexPath.row] isEqualToString:@"taken_at"]) {
            cell.labelField.text = @"撮影月日";
        }
    }
    if (indexPath.section == 1) {
        cell.labelField.text = [keyExif objectAtIndex:indexPath.row];
        cell.labelDetail.text = [exif objectForKey:[keyExif objectAtIndex:indexPath.row]];
    }
    
    return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return @"カメラ情報";
    }
    return @"詳細情報";
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [sections count];
}

@end
