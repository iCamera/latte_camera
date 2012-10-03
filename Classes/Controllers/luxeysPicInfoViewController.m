//
//  luxeysPicInfoViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 9/7/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "luxeysPicInfoViewController.h"

@interface luxeysPicInfoViewController ()
@end

@implementation luxeysPicInfoViewController

@synthesize tableInfo;
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
    
    viewHeader.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_sub_back.png"]];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(0, 40, 320, 10);
    gradient.colors = [NSArray arrayWithObjects:
                       (id)[[UIColor clearColor] CGColor],
                       (id)[[[UIColor blackColor] colorWithAlphaComponent:0.2f] CGColor],
                       nil];
    [viewHeader.layer insertSublayer:gradient atIndex:0];
    

    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:imagePic.bounds];
    imagePic.layer.masksToBounds = NO;
    imagePic.layer.shadowColor = [UIColor blackColor].CGColor;
    imagePic.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    imagePic.layer.shadowOpacity = 1.0f;
    imagePic.layer.shadowRadius = 1.0f;
    imagePic.layer.shadowPath = shadowPath.CGPath;
    
    NSString *url = [NSString stringWithFormat:@"api/picture/%d", picID];

    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
    [[luxeysLatteAPIClient sharedClient] getPath:url
                                      parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                         success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                             picDict = [JSON objectForKey:@"picture"];
                                             pic = [LuxeysPicture instanceFromDictionary:picDict];
                                             
                                             [imagePic setImageWithURL:[NSURL URLWithString:pic.urlSquare]];
                                             
                                             NSMutableSet *keyBasicSet = [NSMutableSet setWithObjects:@"taken_at", @"created_at", @"tags", nil];
                                             NSSet *allField = [NSSet setWithArray:[picDict allKeys]];
                                             [keyBasicSet intersectSet:allField];
                                             keyBasic = [keyBasicSet allObjects];
                                             
                                             sections = [[NSMutableArray alloc] init];
                                             [sections addObject:keyBasic];
                                             exif = [picDict objectForKey:@"exif"];
                                             if (exif.count > 0) {
                                                 [sections addObject:exif];
                                                 keyExif = [exif allKeys];
                                             }
                                             labelTitle.text = pic.title;
                                             
                                             [tableInfo reloadData];
                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             NSLog(@"Something went wrong (PicInfo)");
                                         }];
    
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

- (void)setPictureID:(int)aPicID {
    picID = aPicID;
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
        cell.labelDetail.text = [picDict objectForKey:[keyBasic objectAtIndex:indexPath.row]];
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
