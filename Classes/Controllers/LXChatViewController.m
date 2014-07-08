//
//  LXChatViewController.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 6/18/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import "LXChatViewController.h"
#import "LatteAPIv2Client.h"
#import "LXTagDiscussionViewController.h"

@interface LXChatViewController () {
    NSMutableArray *conversations;
}

@end

@implementation LXChatViewController

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
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    LatteAPIv2Client *api2 = [LatteAPIv2Client sharedClient];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateConversation:) name:@"update_conversation" object:nil];
    
    [api2 GET:@"message/recent" parameters:nil success:^(AFHTTPRequestOperation *operation, NSMutableArray *JSON) {
        conversations = JSON;
        [self.tableView reloadData];
    } failure:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return conversations.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Conversation" forIndexPath:indexPath];
    
    NSDictionary *conversation = conversations[indexPath.row];
    cell.textLabel.text = conversation[@"title"];
    cell.detailTextLabel.text = conversation[@"preview"];
    cell.tag = indexPath.row;
    // Configure the cell...
    
    return cell;
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
        NSDictionary *conversation = conversations[indexPath.row];
        
        NSString *url = [NSString stringWithFormat:@"message/%@", conversation[@"hash"]];
        
        LatteAPIv2Client *api2 = [LatteAPIv2Client sharedClient];
        [api2 DELETE:url parameters:nil success:nil failure:nil];
        
        [conversations removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)updateConversation:(NSNotification *)notification {
    NSDictionary *rawConversation = notification.object;
    
    for (NSInteger idx = 0; idx < conversations.count; idx++) {
        if ([rawConversation[@"hash"] isEqualToString:conversations[idx][@"hash"]]) {
            conversations[idx] = rawConversation;
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    LXTagDiscussionViewController *viewConversation = segue.destinationViewController;
    UITableViewCell *cell = sender;
    NSDictionary* conversation = conversations[cell.tag];
    viewConversation.navigationItem.title = conversation[@"title"];
    viewConversation.conversationHash = conversation[@"hash"];
}

@end
