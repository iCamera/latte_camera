//
//  LXFollowingTagTVC.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 7/10/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import "LXFollowingTagTVC.h"
#import "LatteAPIv2Client.h"
#import "LXTagHome.h"
#import "LXButtonOrange.h"
#import "LXSearchViewController.h"
#import "LXAppDelegate.h"

@interface LXFollowingTagTVC ()

@end

typedef enum {
    kTagFollowing,
    kTagSearch
} TagData;

@implementation LXFollowingTagTVC {
    NSMutableArray *tags;
    NSMutableArray *results;
    AFHTTPRequestOperation *currentRequest;
    BOOL loadEnded;
    BOOL loading;
    TagData tagData;
}

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
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"LXCellTag" bundle:nil] forCellReuseIdentifier:@"Tag"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    loadEnded = false;
    
    LatteAPIv2Client *api2 = [LatteAPIv2Client sharedClient];
    
    [_activityLoad startAnimating];
    [api2 GET:@"tag/following" parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
        tags = JSON[@"tags"];
        loadEnded = true;
        tagData = kTagFollowing;
        [self.tableView reloadData];
        
        /*
        if (tags.count == 0) {
            [_activityLoad startAnimating];
            
            currentRequest = [[LatteAPIv2Client sharedClient] GET:@"picture/get_tag_cloud"
                                                       parameters:@{@"type": @"popular"}
                                                          success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                                              results = [JSON objectForKey:@"tags"];
                                                              tagData = kTagSearch;
                                                              [self.tableView reloadData];
                                                              [_activityLoad stopAnimating];
                                                          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                              [_activityLoad stopAnimating];
                                                          }];
            
        }*/
        
        [_activityLoad stopAnimating];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_activityLoad stopAnimating];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tagData == kTagSearch) {
        return results.count;
    } else {
        return tags.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tagData == kTagSearch) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Tag" forIndexPath:indexPath];
        cell.textLabel.text = results[indexPath.row][@"term"];
        cell.detailTextLabel.text = [results[indexPath.row][@"count"] stringValue];
        if ([tags containsObject:results[indexPath.row][@"term"]]) {
            cell.imageView.image = [UIImage imageNamed:@"icon36-tag-blue.png"];
        } else {
            cell.imageView.image = [UIImage imageNamed:@"icon36-tag-brown.png"];
        }
        
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Tag" forIndexPath:indexPath];
        
        cell.textLabel.text = tags[indexPath.row];
        cell.detailTextLabel.text = @"";
        cell.imageView.image = [UIImage imageNamed:@"icon36-tag-blue.png"];
        
        return cell;
    }
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        LatteAPIv2Client *api2 = [LatteAPIv2Client sharedClient];
        [api2 POST:@"tag/unfollow" parameters:@{@"tag": tags[indexPath.row]} success:nil failure:nil];
        
        [tags removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [_searchBar resignFirstResponder];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    LXTagHome *viewTag = [mainStoryboard instantiateViewControllerWithIdentifier:@"TagHome"];
    if (tagData == kTagSearch) {
        viewTag.tag = results[indexPath.row][@"term"];
    } else {
        viewTag.tag = tags[indexPath.row];
    }
    
    [self.navigationController pushViewController:viewTag animated:YES];
    
}


- (void)loadTagSearch {
    [_activityLoad startAnimating];
    if (loading)
        [currentRequest cancel];
    
    loading = YES;
    currentRequest = [[LatteAPIv2Client sharedClient] GET:@"tag/search" parameters:@{@"keyword": _searchBar.text, @"app": @"true"} success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
        
        results = [[NSMutableArray alloc] init];
        for (NSDictionary *tag in JSON[@"tags"]) {
            [results addObject:@{@"term": tag[@"label"], @"count": tag[@"picture_count"]}];
        }
        
        tagData = kTagSearch;
        [self.tableView reloadData];
        [_activityLoad stopAnimating];
        loading = NO;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_activityLoad stopAnimating];
        loading = NO;
    }];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length > 0) {
        [self loadTagSearch];
        self.navigationItem.rightBarButtonItem = nil;
        [self.tableView setEditing:NO animated:NO];
    } else {
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
        tagData = kTagFollowing;
        [self.tableView reloadData];
    }

}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}


- (void)searchTag:(id)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UIViewController *viewSearch = [mainStoryboard instantiateViewControllerWithIdentifier:@"Search"];
    viewSearch.navigationItem.leftBarButtonItem = nil;
    viewSearch.navigationItem.rightBarButtonItem = nil;
    [self.navigationController pushViewController:viewSearch animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (tags.count == 0 && loadEnded) {
        UIView *emptyView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 200)];
        UIImageView *emptyImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nopict.png"]];
        emptyImage.center = emptyView.center;
        [emptyView addSubview:emptyImage];
        
        LXButtonOrange *buttonFind = [[LXButtonOrange alloc] initWithFrame:CGRectMake(20, 150, 280, 35)];
        buttonFind.titleLabel.font = [UIFont fontWithName:@"Futura-CondensedMedium" size:16];
        [buttonFind setTitle:NSLocalizedString(@"find_tag", @"") forState:UIControlStateNormal];
        [buttonFind addTarget:self action:@selector(searchTag:) forControlEvents:UIControlEventTouchUpInside];
        [emptyView addSubview:buttonFind];
        
        return emptyView;
    }
    return nil;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (tags.count == 0 && loadEnded)
        return 200;
    return 0;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
