//
//  luxeysPicDetailViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/22/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "luxeysPicDetailViewController.h"

@interface luxeysPicDetailViewController ()
@end

@implementation luxeysPicDetailViewController

@synthesize gestureTap;
@synthesize viewTextbox;
@synthesize textComment;
@synthesize buttonSend;
@synthesize tablePic;
@synthesize constraintCommentView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        loaded = FALSE;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Style
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:viewTextbox.bounds];
    viewTextbox.layer.masksToBounds = NO;
    viewTextbox.layer.shadowColor = [UIColor blackColor].CGColor;
    viewTextbox.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    viewTextbox.layer.shadowOpacity = 0.5f;
    viewTextbox.layer.shadowRadius = 2.5f;
    viewTextbox.layer.shadowPath = shadowPath.CGPath;
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    textComment.leftView = paddingView;
    textComment.leftViewMode = UITextFieldViewModeAlways;
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:) name: UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:) name: UIKeyboardWillHideNotification object:nil];
    
    refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tablePic.bounds.size.height, self.view.frame.size.width, self.tablePic.bounds.size.height)];
    refreshHeaderView.delegate = self;
    [self.tablePic addSubview:refreshHeaderView];

    CGRect frameTable = self.view.bounds;
    CGRect frameComment = viewTextbox.frame;
    frameTable.size.height -= 44+viewTextbox.frame.size.height;
    tablePic.frame = frameTable;
    
    frameComment.origin.y = self.view.bounds.size.height-frameComment.size.height-44;
    viewTextbox.frame = frameComment;
    
    [self reloadView];
}

- (void)reloadView {
    luxeysAppDelegate* app = (luxeysAppDelegate*)[[UIApplication sharedApplication] delegate];
    if (app.currentUser != nil) {
        textComment.enabled = TRUE;
    }
    
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
    NSString *url = [NSString stringWithFormat:@"api/picture/%d", picID];
    [[luxeysLatteAPIClient sharedClient] getPath:url
                                      parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                         success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                             user = [LuxeysUser instanceFromDictionary:[JSON objectForKey:@"user"]];
                                             pic = [LuxeysPicture instanceFromDictionary:[JSON objectForKey:@"picture"]];
                                             comments = [LuxeysComment mutableArrayFromDictionary:JSON withKey:@"comments"];
                                             
                                             [self doneLoadingTableViewData];
                                             loaded = TRUE;

                                             [tablePic reloadData];

                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                     [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                 });
                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             NSLog(@"Something went wrong (PicDetail)");
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                     [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                 });
                                         }];
    });
    
}

- (void)viewDidUnload
{
    [self setViewTextbox:nil];
    [self setTextComment:nil];
    [self setButtonSend:nil];
    [self setGestureTap:nil];
    [self setTablePic:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"TabbarHide"
     object:self];
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"TabbarShow"
     object:self];
    
    [super viewWillDisappear:animated];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        float newheight = [luxeysImageUtils heightFromWidth:300
                                                      width:[pic.width floatValue]
                                                     height:[pic.height floatValue]];
        return newheight + 100;
    } else {
        LuxeysComment *comment = [comments objectAtIndex:indexPath.row-1];
        NSString *strComment = comment.descriptionText;
        CGSize labelSize = [strComment sizeWithFont:[UIFont systemFontOfSize:11]
                                  constrainedToSize:CGSizeMake(255.0f, MAXFLOAT)
                                      lineBreakMode:NSLineBreakByWordWrapping];
        return MAX(labelSize.height + 33, 50);
    }
}

- (void)setPictureID:(int)aPicID {
    picID = aPicID;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (loaded)
        return comments.count + 1;
    return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        cellPicInfo = [tableView dequeueReusableCellWithIdentifier:@"Picture"];
        
        [cellPicInfo setPicture:pic user:user];
        
        [cellPicInfo.buttonComment addTarget:self action:@selector(showKeyboard:) forControlEvents:UIControlEventTouchUpInside];
        [cellPicInfo.buttonLike addTarget:self action:@selector(touchLike:) forControlEvents:UIControlEventTouchUpInside];
        
        cellPicInfo.buttonUser.tag = [user.userId longValue];
        
        [cellPicInfo.buttonUser addTarget:self action:@selector(showUser:) forControlEvents:UIControlEventTouchUpInside];
        [cellPicInfo.buttonInfo addTarget:self action:@selector(showInfo:) forControlEvents:UIControlEventTouchUpInside];
        [cellPicInfo.buttonMap addTarget:self action:@selector(showMap:) forControlEvents:UIControlEventTouchUpInside];
                
        return cellPicInfo;
    } else {
        luxeysTableViewCellComment* cellComment = [tableView dequeueReusableCellWithIdentifier:@"Comment"];

        if (nil == cellComment) {
            cellComment = (luxeysTableViewCellComment*)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:@"Comment"];
                    }
        
        LuxeysComment *comment = [comments objectAtIndex:indexPath.row-1];
        [cellComment setComment:comment];
        
        cellComment.buttonUser.tag = [comment.user.userId longValue];
        [cellComment.buttonUser addTarget:self action:@selector(showUser:) forControlEvents:UIControlEventTouchUpInside];
        
        
        return cellComment;
    }
}

- (void)showUser:(UIButton*)button {
    [self performSegueWithIdentifier:@"UserProfile" sender:button];
}

- (void)showInfo:(id)sender {
    [self performSegueWithIdentifier:@"PictureInfo" sender:self];
}

- (void)showMap:(id)sender {
    [self performSegueWithIdentifier:@"PictureMap" sender:self];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UIButton *)button {
    if ([segue.identifier isEqualToString:@"UserProfile"]) {
        luxeysUserViewController* viewUser = segue.destinationViewController;
        [viewUser setUserID:button.tag];
    }
    if ([segue.identifier isEqualToString:@"PictureInfo"]) {
        luxeysPicInfoViewController *viewInfo = segue.destinationViewController;
        [viewInfo setPictureID:picID];
    }
    if ([segue.identifier isEqualToString:@"PictureMap"]) {
        luxeysPicMapViewController *viewMap = segue.destinationViewController;
        [viewMap setPointWithLongitude:[pic.longitude floatValue] andLatitude:[pic.latitude floatValue]];
    }

}

- (void)showKeyboard:(id)sender {
    [textComment becomeFirstResponder];
}


- (void)keyboardWillShow:(NSNotification *)notification
{
    
    [self.tablePic addGestureRecognizer:gestureTap];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    
    // Step 1: Get the size of the keyboard.
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;

    
    // Step 2: Adjust the bottom content inset of your scroll view by the keyboard height.
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
    tablePic.contentInset = contentInsets;
    tablePic.scrollIndicatorInsets = contentInsets;
    
    
 
    viewTextbox.frame = CGRectMake(0,
                                   self.view.frame.size.height-keyboardSize.height-viewTextbox.frame.size.height,
                                   viewTextbox.frame.size.width,
                                   viewTextbox.frame.size.height);
    
    
    CGPoint scrollPoint = CGPointMake(0.0, tablePic.contentOffset.y + keyboardSize.height);
    [tablePic setContentOffset:scrollPoint];
    
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [self.tablePic removeGestureRecognizer:gestureTap];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    tablePic.contentInset = contentInsets;
    tablePic.scrollIndicatorInsets = contentInsets;

    viewTextbox.frame = CGRectMake(0,
                                   self.view.frame.size.height-viewTextbox.frame.size.height,
                                   viewTextbox.frame.size.width,
                                   viewTextbox.frame.size.height);
    
//    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
//    CGPoint scrollPoint = CGPointMake(0.0, tablePic.contentOffset.y - keyboardSize.height);
//    [tablePic setContentOffset:scrollPoint];
        
    [UIView commitAnimations];
}

- (BOOL)sendComment {
    if (textComment.text.length < 3000) {
        // Submit comment
        luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
        NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:
                               [app getToken], @"token",
                               textComment.text, @"description", nil];
        
        NSString *url = [NSString stringWithFormat:@"api/picture/%d/comment_post", picID];
        
        [[luxeysLatteAPIClient sharedClient] postPath:url
                                           parameters:param
                                              success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                                  LuxeysComment *comment = [LuxeysComment instanceFromDictionary:[JSON objectForKey:@"comment"]];
                                                  [comments addObject:comment];
                                                  NSIndexPath *path = [NSIndexPath indexPathForRow:comments.count inSection:0];
                                                  [tablePic insertRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationRight];
                                                  [tablePic scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];
                                              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                  NSLog(@"Something went wrong (Comment)");
                                              }];

        textComment.text = @"";
        [self.textComment resignFirstResponder];
        return TRUE;
    } else {
        return FALSE;
    }
}

- (IBAction)touchBackground:(id)sender {
    [self.textComment resignFirstResponder];
}

- (IBAction)touchBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)changeText:(id)sender {
    buttonSend.enabled = textComment.text.length > 0;
}

- (IBAction)touchSend:(id)sender {
    [self sendComment];
}

- (void)touchLike:(id)sender {
    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:
                           [app getToken], @"token",
                           @"1", @"vote_type",
                           nil];
    
    NSString *url = [NSString stringWithFormat:@"api/picture/%d/vote_post", picID];
    [[luxeysLatteAPIClient sharedClient] postPath:url
                                       parameters:param
                                          success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                              cellPicInfo.buttonLike.enabled = NO;
                                              NSNumber *vote_count = [NSNumber numberWithInt:[cellPicInfo.labelLike.text integerValue] + 1 ];
                                              cellPicInfo.labelLike.text = [vote_count stringValue];
                                          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                              NSLog(@"Something went wrong (Vote)");
                                          }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [self sendComment];
}

- (void)reloadTableViewDataSource{
    reloading = YES;
}

- (void)doneLoadingTableViewData{
    reloading = NO;
    [refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tablePic];
}

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    [self reloadTableViewDataSource];
    
    [self reloadView];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    
    return reloading; // should return if data source model is reloading
    
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    
    return [NSDate date]; // should return date data source was last changed
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}


@end
