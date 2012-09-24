//
//  luxeysPicDetailViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/22/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "luxeysPicDetailViewController.h"

#import "luxeysCellPicture.h"
#import "luxeysCellComment.h"
#import "luxeysAppDelegate.h"
#import "luxeysImageUtils.h"
#import "luxeysUserViewController.h"
#import "luxeysButtonBrown30.h"
#import "luxeysLatteAPIClient.h"
#import "luxeysPicInfoViewController.h"
#import "luxeysLatteAPIClient.h"

@interface luxeysPicDetailViewController () {
    luxeysTableViewCellPicture *cellPicInfo;
    NSMutableArray *comments;
}
@end

@implementation luxeysPicDetailViewController

@synthesize gestureTap;
@synthesize picInfo;
@synthesize viewTextbox;
@synthesize textComment;
@synthesize buttonSend;
@synthesize tablePic;

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
    
    // Do any additional setup after loading the view from its nib.
    luxeysAppDelegate* app = (luxeysAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:) name: UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:) name: UIKeyboardWillHideNotification object:nil];
    
    if (app.currentUser != nil) {
        textComment.enabled = TRUE;
    }

    NSString *url = [NSString stringWithFormat:@"api/picture/%d", [[picInfo objectForKey:@"id"] integerValue]];
    [[luxeysLatteAPIClient sharedClient] getPath:url
                                      parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                         success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                             [cellPicInfo setPicture:[JSON objectForKey:@"picture"] user:[JSON objectForKey:@"user"]];
                                             comments = [NSMutableArray arrayWithArray:[JSON objectForKey:@"comments"]];
                                             [tablePic reloadData];
                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             NSLog(@"Something went wrong (PicInfo)");
                                         }];
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
                                                      width:[[picInfo objectForKey:@"width"] floatValue]
                                                     height:[[picInfo objectForKey:@"height"] floatValue]];
        return newheight + 100;
    } else {
        return 50;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return comments.count + 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        cellPicInfo = [tableView dequeueReusableCellWithIdentifier:@"Picture"];
        
        [cellPicInfo.buttonComment addTarget:self action:@selector(showKeyboard:) forControlEvents:UIControlEventTouchUpInside];
        [cellPicInfo.buttonLike addTarget:self action:@selector(touchLike:) forControlEvents:UIControlEventTouchUpInside];
        
        cellPicInfo.buttonUser.tag = indexPath.row;
        
        [cellPicInfo.buttonUser addTarget:self action:@selector(showUser:) forControlEvents:UIControlEventTouchUpInside];
        [cellPicInfo.buttonInfo addTarget:self action:@selector(showInfo:) forControlEvents:UIControlEventTouchUpInside];
                
        return cellPicInfo;
    } else {
        luxeysTableViewCellComment* cellComment = [tableView dequeueReusableCellWithIdentifier:@"Comment"];

        if (nil == cellComment) {
            cellComment = (luxeysTableViewCellComment*)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:@"Comment"];
                    }
        
        [cellComment setComment:[comments objectAtIndex:indexPath.row-1]];
        cellComment.buttonUser.tag = indexPath.row;
        [cellComment.buttonUser addTarget:self action:@selector(showUser:) forControlEvents:UIControlEventTouchUpInside];
        
        
        return cellComment;
    }
}

- (void)showUser:(UIButton*)button {
    if (button.tag == 0) {
        [self performSegueWithIdentifier:@"UserProfile" sender:[picInfo objectForKey:@"owner"]];
    } else {
        NSArray* arComment = (NSArray*)[picInfo objectForKey:@"comments"];
        NSDictionary *dictComment = [arComment objectAtIndex:button.tag-1];
        
        [self performSegueWithIdentifier:@"UserProfile" sender:[dictComment objectForKey:@"user"]];
    }
}

- (void)showInfo:(id)sender {
    [self performSegueWithIdentifier:@"PictureInfo" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"UserProfile"]) {
        luxeysUserViewController* viewUser = segue.destinationViewController;
        viewUser.dictUser = sender;
    }
    if ([segue.identifier isEqualToString:@"PictureInfo"]) {
        luxeysPicInfoViewController *viewInfo = segue.destinationViewController;
        [viewInfo setPicture:picInfo];
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
    
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
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
        
        NSString *url = [NSString stringWithFormat:@"api/picture/%d/comment_post", [[picInfo objectForKey:@"id"] integerValue]];
        
        [[luxeysLatteAPIClient sharedClient] postPath:url
                                           parameters:param
                                              success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                                  NSDictionary *comment = [JSON objectForKey:@"comment"];
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
    
    NSString *url = [NSString stringWithFormat:@"api/picture/%d/vote_post", [[picInfo objectForKey:@"id"] integerValue]];
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

@end
