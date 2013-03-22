//
//  LXTagViewController.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 3/13/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXTagViewController.h"
#import "LXAppDelegate.h"
#import "LatteAPIClient.h"
#import "LXCellGrid.h"
#import "LXGalleryViewController.h"
#import "LXButtonBack.h"
#import "LXUtils.h"
#import "Picture.h"

@interface LXTagViewController ()

@end

@implementation LXTagViewController {
    NSArray *pictures;
}

@synthesize viewHeader;
@synthesize labelTag;
@synthesize activityLoad;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [LXUtils globalShadow:viewHeader];
    viewHeader.layer.cornerRadius = 5.0;
    labelTag.text = _keyword;
    
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_sub_back.png"]];

    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:
                           [app getToken], @"token", nil];
    
    NSString *url = [NSString stringWithFormat:@"picture/tag/%@", _keyword];
    
    [[LatteAPIClient sharedClient] getPath:url
                                 parameters:param
                                    success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {

                                        pictures = [Picture mutableArrayFromDictionary:JSON withKey:@"pictures"];
                                        [self.tableView reloadData];
                                        [activityLoad stopAnimating];
                                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        TFLog(@"Something went wrong Tag");
                                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", "Error")
                                                                                        message:error.localizedDescription
                                                                                       delegate:nil
                                                                              cancelButtonTitle:NSLocalizedString(@"close", "Close")
                                                                              otherButtonTitles:nil];
                                        [alert show];
                                        [activityLoad stopAnimating];
                                    }];
    UIBarButtonItem *navLeftItem = self.navigationItem.leftBarButtonItem;
    LXButtonBack *buttonBack = (LXButtonBack*)navLeftItem.customView;
    [buttonBack addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return pictures.count/3 + (pictures.count%3>0?1:0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Grid";
    LXCellGrid *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.viewController = self;
    [cell setPictures:pictures forRow:indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 104 + (indexPath.row==0?3:0);
}

- (void)showPic:(UIButton*)sender {
    UIStoryboard *storyGallery = [UIStoryboard storyboardWithName:@"Gallery"
                                                           bundle:nil];
    UINavigationController *navGalerry = [storyGallery instantiateInitialViewController];
    LXGalleryViewController *viewGallery = navGalerry.viewControllers[0];
    viewGallery.delegate = self;
    
    viewGallery.picture = pictures[sender.tag];
    
    [self presentViewController:navGalerry animated:YES completion:nil];
}

- (NSDictionary *)pictureAfterPicture:(Picture *)picture {
        NSUInteger current = [pictures indexOfObject:picture];
        if (current == pictures.count-1) {
            return nil;
        }
        Picture *picNext = pictures[current+1];
        NSDictionary *ret = [NSDictionary dictionaryWithObjectsAndKeys:
                             picNext, @"picture",
                             nil];
        return ret;
}

- (NSDictionary *)pictureBeforePicture:(Picture *)picture {
    NSUInteger current = [pictures indexOfObject:picture];
    if (current == 0) {
        return nil;
    }
    Picture *picPrev = pictures[current-1];
    NSDictionary *ret = [NSDictionary dictionaryWithObjectsAndKeys:
                         picPrev, @"picture",
                         nil];
    return ret;
}

@end
