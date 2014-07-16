//
//  LXPicDumbTabViewController.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 3/21/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXPicDumbTabViewController.h"
#import "LXCellTag.h"
#import "LXButtonBack.h"
#import "LatteAPIv2Client.h"

typedef enum {
    kTagTableInput,
    kTagTableResult
} TagTable;

@interface LXPicDumbTabViewController ()

@end

@implementation LXPicDumbTabViewController {
    TagTable tableMode;
    AFHTTPRequestOperation *currentRequest;
    NSArray *results;
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
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.tableView registerNib:[UINib nibWithNibName:@"LXCellTag" bundle:nil] forCellReuseIdentifier:@"Tag"];
    
    tableMode = kTagTableInput;
    [self.tableView setEditing:YES animated:YES];
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
    if (tableMode == kTagTableInput) {
        return _tags.count + 1;
    } else {
        return results.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableMode == kTagTableInput) {
        LXCellTag *cell = [tableView dequeueReusableCellWithIdentifier:@"Input" forIndexPath:indexPath];
        [cell.textTag addTarget:self action:@selector(editEnd:) forControlEvents:UIControlEventEditingDidEnd];
        [cell.textTag addTarget:self action:@selector(editBegin:) forControlEvents:UIControlEventEditingDidBegin];
        
        cell.textTag.tag = indexPath.row;
        if (indexPath.row < _tags.count) {
            cell.textTag.text = _tags[indexPath.row];
        } else {
            cell.textTag.text = @"";
        }
        
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Tag" forIndexPath:indexPath];
        cell.textLabel.text = results[indexPath.row][@"label"];
        cell.detailTextLabel.text = [results[indexPath.row][@"picture_count"] stringValue];
        return cell;
    }
}

- (void)editEnd:(UITextField*)textField {
    if (textField.text.length == 0) {
        //        [picture.tags removeObjectAtIndex:textField.tag];
        //        [self.tableView reloadData];
        //        NSArray* indexes = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:textField.tag inSection:0]];
        //        [textField resignFirstResponder];
        //        [self.tableView deleteRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        _tags[textField.tag] = textField.text;
    }
}

- (void)editBegin:(UITextField*)textField {
    if (textField.tag == _tags.count) {
        [_tags addObject:@""];
        NSArray* indexes = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:_tags.count inSection:0]];
        [self.tableView insertRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

// Update the data model according to edit actions delete or insert.
- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_tags removeObjectAtIndex:indexPath.row];
		[aTableView reloadData];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        [_tags addObject:@""];
		[aTableView reloadData];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row < _tags.count;
}

#pragma mark Row reordering
// Determine whether a given row is eligible for reordering or not.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}
// Process the row move. This means updating the data model to correct the item indices.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath
	  toIndexPath:(NSIndexPath *)toIndexPath {
    if (toIndexPath.row < _tags.count && fromIndexPath.row < _tags.count) {
        NSString *item = [_tags objectAtIndex:fromIndexPath.row];
        [_tags removeObject:item];
        [_tags insertObject:item atIndex:toIndexPath.row];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length < 3) {
        tableMode = kTagTableInput;
        [self.tableView setEditing:YES animated:YES];
        [self.tableView reloadData];
    } else {
        [self loadResult:searchText];
    }
}

- (void)loadResult: (NSString*)searchText {
    if (currentRequest && currentRequest.isExecuting)
        [currentRequest cancel];
    
    currentRequest = [[LatteAPIv2Client sharedClient] GET:@"tag/search" parameters:@{@"keyword": _searchBar.text, @"app": @"true"} success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
        [self.tableView setEditing:NO animated:YES];
        tableMode = kTagTableResult;
        results = JSON[@"tags"];
        [self.tableView reloadData];
    } failure:nil];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    tableMode = kTagTableInput;
    [self.tableView setEditing:YES animated:YES];
    [self.tableView reloadData];
    [searchBar resignFirstResponder];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableMode == kTagTableResult) {
        NSString *tag = results[indexPath.row][@"label"];
        if (![_tags containsObject:tag]) {
            [_tags addObject:tag];
        }
    }
    
    _searchBar.text = @"";
    tableMode = kTagTableInput;
    [self.tableView setEditing:YES animated:YES];
    [self.tableView reloadData];
    
}

@end
