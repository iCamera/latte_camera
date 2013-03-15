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
//#import "SideSwipeTableViewCell.h"
#import "LXCommentControllViewController.h"
#import "LXButtonBack.h"

@interface LXPicCommentViewController ()

@end

@implementation LXPicCommentViewController {
    UITapGestureRecognizer *gestureTap;
    NSInteger heightHeader;
}

@synthesize viewHeader;
@synthesize growingComment;
@synthesize buttonSend;
@synthesize activityLoad;

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
    
    
    growingComment.layer.borderWidth = 1;
    growingComment.layer.borderColor = [UIColor grayColor].CGColor;
    growingComment.layer.cornerRadius = 5;
    growingComment.layer.masksToBounds = YES;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Component"
                                                             bundle:nil];
    UIViewController *viewCommentControl = [mainStoryboard instantiateViewControllerWithIdentifier:@"Comment"];
    viewCommentControl.view.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.rowHeight);
    
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    
    if (app.currentUser != nil) {
        // Edit Swipe
        UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedHorizontal)];
        swipe.direction = UISwipeGestureRecognizerDirectionRight | UISwipeGestureRecognizerDirectionLeft;
        [self.tableView addGestureRecognizer:swipe];
        
    } else {
        self.tableView.tableHeaderView = nil;
    }
    
//    self.sideSwipeView = viewCommentControl.view;
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:) name: UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:) name: UIKeyboardWillHideNotification object:nil];
    
    UIBarButtonItem *navLeftItem = self.navigationItem.leftBarButtonItem;
    LXButtonBack *buttonBack = (LXButtonBack*)navLeftItem.customView;
    [buttonBack addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    [self.tableView addGestureRecognizer:gestureTap];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [self.tableView removeGestureRecognizer:gestureTap];
}

- (void)swipedHorizontal {
    [self.tableView setEditing:!self.tableView.editing animated:YES];
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
    [activityLoad stopAnimating];
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
    LXCellComment* cellComment = [tableView dequeueReusableCellWithIdentifier:@"Comment" forIndexPath:indexPath];
        
    Comment *comment = _comments[_comments.count - indexPath.row - 1];
    
    cellComment.comment = comment;
    
    if (!comment.user.isUnregister) {
        cellComment.buttonUser.tag = indexPath.row;
        cellComment.buttonLike.tag = indexPath.row;
        [cellComment.buttonUser addTarget:self action:@selector(showUser:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return cellComment;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Comment *comment = _comments[_comments.count - indexPath.row - 1];
    NSString *strComment = comment.descriptionText;
    CGSize labelSize = [strComment sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12]
                              constrainedToSize:CGSizeMake(255.0f, MAXFLOAT)
                                  lineBreakMode:NSLineBreakByWordWrapping];
    return MAX(labelSize.height + 45, 42);
}

#pragma mark - Table view delegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    Comment* comment = _comments[_comments.count - indexPath.row - 1];
    return ([comment.user.userId integerValue] == [app.currentUser.userId integerValue]) || _picture.isOwner;
}

@end
