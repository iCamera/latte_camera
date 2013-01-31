//
//  luxeysPicInfoViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 9/7/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "LXPicInfoViewController.h"

@interface LXPicInfoViewController ()
@end

@implementation LXPicInfoViewController

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
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    [app.tracker sendView:@"Picture Info Screen"];
    
    viewHeader.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_sub_back.png"]];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(0, 32, 320, 10);
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
    
    NSString *url = [NSString stringWithFormat:@"picture/%d", picID];

    [[LatteAPIClient sharedClient] getPath:url
                                      parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                         success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                             picDict = [JSON objectForKey:@"picture"];
                                             pic = [Picture instanceFromDictionary:picDict];
                                             
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
                                             
                                             if (pic.title.length > 0)
                                                 labelTitle.text = pic.title;
                                             
                                             [self.tableView reloadData];
                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             TFLog(@"Something went wrong (PicInfo)");
                                         }];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    if ([self.navigationController.viewControllers[self.navigationController.viewControllers.count-1] isKindOfClass:[LXPicDetailViewController class]]) {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"TabbarHide"
         object:self];
    }
    
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
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
    LXCellDataField *cell = [tableView dequeueReusableCellWithIdentifier:@"Profile"];
    if (indexPath.section == 0)
    {        
        NSString *key = [keyBasic objectAtIndex:indexPath.row];
        if ([key isEqualToString:@"taken_at"]) {
            cell.labelField.text = NSLocalizedString(@"taken_date", @"撮影月日") ;
            cell.labelDetail.text = [LXUtils dateToString:pic.takenAt];
        }
        if ([[keyBasic objectAtIndex:indexPath.row] isEqualToString:@"created_at"]) {
            cell.labelField.text = NSLocalizedString(@"uploaded_date", @"追加月日");
            cell.labelDetail.text = [LXUtils dateToString:pic.createdAt];
        }
        if ([[keyBasic objectAtIndex:indexPath.row] isEqualToString:@"tags"]) {
            cell.labelField.text = NSLocalizedString(@"tags", @"タグ");
            NSArray *tags = [picDict objectForKey:[keyBasic objectAtIndex:indexPath.row]];
            cell.labelDetail.text = [tags componentsJoinedByString:@", "];
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
        return NSLocalizedString(@"exif_info", @"カメラ情報");
    }
    return NSLocalizedString(@"photo_info", @"詳細情報");
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [sections count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, 30)];
    title.font = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:12];
    title.textColor = [UIColor colorWithRed:101.0/255.0 green:90.0/255.0 blue:56.0/255.0 alpha:1];
    title.text = [self tableView:tableView titleForHeaderInSection:section];
    [view addSubview:title];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

@end
