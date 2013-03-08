//
//  LXPicCommentViewController.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 3/6/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXPicCommentViewController.h"

#import "LXCellComment.h"
#import "LXAppDelegate.h"
#import "LXMyPageViewController.h"
#import "SideSwipeTableViewCell.h"

@interface LXPicCommentViewController ()

@end

@implementation LXPicCommentViewController {
    UITapGestureRecognizer *gestureTap;
    NSInteger heightHeader;
}

@synthesize viewHeader;
@synthesize growingComment;
@synthesize buttonSend;

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
    growingComment.delegate = self;
    [super viewDidLoad];
        
    gestureTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchBackground:)];
    [self.tableView addGestureRecognizer:gestureTap];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
     self.sideSwipeView = [[UIView alloc] initWithFrame:CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.rowHeight)];
}

- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView {
    buttonSend.enabled = growingTextView.text.length > 0;
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
	CGRect r = viewHeader.frame;
    r.size.height -= diff;
    r.origin.y += diff;
    viewHeader.frame = r;

    [self.tableView beginUpdates];
    self.tableView.tableHeaderView = viewHeader;
    [self.tableView endUpdates];
}


- (void)setComments:(NSMutableArray *)comments {
    _comments = comments;
    [self.tableView reloadData];
}


- (void)toggleLikeComment:(UIButton*)sender {
    LXAppDelegate* app = [LXAppDelegate currentDelegate];
    if (!app.currentUser) {
        sender.enabled = NO;
    }
    Comment *comment = _comments[_comments.count - sender.tag - 1];
    
    comment.isVoted = !comment.isVoted;
    BOOL increase = comment.isVoted;
    sender.selected = comment.isVoted;
    
    comment.voteCount = [NSNumber numberWithInteger:[comment.voteCount integerValue] + (increase?1:-1)];
    
    NSInteger likeCount = [sender.titleLabel.text integerValue];
    NSNumber *num = [NSNumber numberWithInteger:likeCount + (increase?1:-1)];
    [sender setTitle:[num stringValue] forState:UIControlStateNormal];
    
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  @"1", @"vote_type",
                                  nil];
    if (app.currentUser != nil) {
        [param setObject:[app getToken] forKey:@"token"];
    }
    
    
    NSString *url = [NSString stringWithFormat:@"picture/%d/vote_post", [comment.commentId integerValue]];
    [[LatteAPIClient sharedClient] postPath:url
                                 parameters:param
                                    success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                        TFLog(@"Submited like");
                                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", "Error")
                                                                                        message:error.localizedDescription
                                                                                       delegate:nil
                                                                              cancelButtonTitle:NSLocalizedString(@"close", "Close")
                                                                              otherButtonTitles:nil];
                                        [alert show];
                                        TFLog(@"Something went wrong (Vote)");
                                    }];
}

- (BOOL)sendComment {
    if (growingComment.text.length < 3000) {
        // Submit comment
        LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
        NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:
                               [app getToken], @"token",
                               growingComment.text, @"description", nil];
        
        NSString *url = [NSString stringWithFormat:@"picture/%d/comment_post", [_picture.pictureId integerValue]];
        
        [[LatteAPIClient sharedClient] postPath:url
                                     parameters:param
                                        success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                            Comment *comment = [Comment instanceFromDictionary:[JSON objectForKey:@"comment"]];
                                            [_comments addObject:comment];
                                            NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
                                            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationRight];
                                            [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];
                                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                            TFLog(@"Something went wrong (Comment)");
                                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", "Error")
                                                                                            message:error.localizedDescription
                                                                                           delegate:nil
                                                                                  cancelButtonTitle:NSLocalizedString(@"close", "Close")
                                                                                  otherButtonTitles:nil];
                                            [alert show];
                                        }];
        
        growingComment.text = @"";
        buttonSend.enabled = false;
        [growingComment resignFirstResponder];
        return TRUE;
    } else {
        return FALSE;
    }
}

- (void)touchBackground:(id)sender {
    [growingComment resignFirstResponder];
}

- (IBAction)touchSend:(id)sender {
    [self sendComment];
}

- (void)showUser:(UIButton *)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    LXMyPageViewController *viewUserPage = [mainStoryboard instantiateViewControllerWithIdentifier:@"UserPage"];
    Comment *comment = _comments[_comments.count - sender.tag - 1];
    viewUserPage.user = comment.user;
    [self.navigationController pushViewController:viewUserPage animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Comment* comment = _comments[_comments.count - indexPath.row - 1];
        [_comments removeObject:comment];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
        
        NSString *url = [NSString stringWithFormat:@"picture/comment/%d/delete", [comment.commentId integerValue]];
        [[LatteAPIClient sharedClient] postPath:url
                                     parameters:[NSDictionary dictionaryWithObject:[app getToken] forKey:@"token"]
                                        success:nil
                                        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                            [_comments insertObject:comment atIndex:indexPath.row];
                                            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                                        }];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _comments.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LXCellComment* cellComment = [tableView dequeueReusableCellWithIdentifier:@"Comment"];
    
    if (nil == cellComment) {
        cellComment = (LXCellComment*)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                             reuseIdentifier:@"Comment"];
    }
    
    Comment *comment = _comments[_comments.count - indexPath.row - 1];
    
    cellComment.comment = comment;
    
    if (!comment.user.isUnregister) {
        cellComment.buttonUser.tag = indexPath.row;
        cellComment.buttonLike.tag = indexPath.row;
        [cellComment.buttonUser addTarget:self action:@selector(showUser:) forControlEvents:UIControlEventTouchUpInside];
        [cellComment.buttonLike addTarget:self action:@selector(toggleLikeComment:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return cellComment;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Comment *comment = _comments[_comments.count - indexPath.row - 1];
    NSString *strComment = comment.descriptionText;
    CGSize labelSize = [strComment sizeWithFont:[UIFont fontWithName:@"AvenirNextCondensed-Regular" size:11]
                              constrainedToSize:CGSizeMake(255.0f, MAXFLOAT)
                                  lineBreakMode:NSLineBreakByWordWrapping];
    return MAX(labelSize.height + 45, 42);
}

#pragma mark - Table view delegate

@end
