//
//  luxeysPicDetailViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/22/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "luxeysPicDetailViewController.h"

#import "luxeysTableViewCellPicture.h"
#import "luxeysTableViewCellComment.h"
#import "luxeysAppDelegate.h"
#import "luxeysImageUtils.h"
#import "luxeysUserViewController.h"
#import "luxeysButtonBrown30.h"
#import "luxeysLatteAPIClient.h"

@interface luxeysPicDetailViewController ()

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
    return [[picInfo objectForKey:@"comments"] count] + 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        luxeysTableViewCellPicture* cellPicInfo = [tableView dequeueReusableCellWithIdentifier:@"Picture"];
        
        if (nil == cellPicInfo) {
            cellPicInfo = (luxeysTableViewCellPicture*)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                                              reuseIdentifier:@"Picture"];
        }
        
        [cellPicInfo setPicture:picInfo];
        
        [cellPicInfo.buttonComment addTarget:self action:@selector(showKeyboard:) forControlEvents:UIControlEventTouchUpInside];
        
        cellPicInfo.buttonUser.tag = indexPath.row;
        [cellPicInfo.buttonUser addTarget:self action:@selector(showUser:) forControlEvents:UIControlEventTouchUpInside];
        
        luxeysAppDelegate* app = (luxeysAppDelegate*)[[UIApplication sharedApplication] delegate];
        if (app.currentUser != nil) {
            cellPicInfo.buttonLike.enabled = TRUE;
            cellPicInfo.buttonComment.enabled = TRUE;
        }
        
        return cellPicInfo;
    } else {
        luxeysTableViewCellComment* cellComment = [tableView dequeueReusableCellWithIdentifier:@"Comment"];

        if (nil == cellComment) {
            cellComment = (luxeysTableViewCellComment*)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:@"Comment"];
                    }
        
        
        NSArray* arComment = (NSArray*)[picInfo objectForKey:@"comments"];
        [cellComment setComment:[arComment objectAtIndex:indexPath.row-1]];
        cellComment.buttonUser.tag = indexPath.row;
        [cellComment.buttonUser addTarget:self action:@selector(showUser:) forControlEvents:UIControlEventTouchUpInside];
        
        
        return cellComment;
    }
}

- (void)showUser:(UIButton*)button {
    UIStoryboard* storyUser = [UIStoryboard storyboardWithName:@"UserStoryboard" bundle:nil];
    luxeysUserViewController* viewUser = (luxeysUserViewController*)[storyUser instantiateInitialViewController];
    
    if (button.tag == 0) {
        viewUser.dictUser = [picInfo objectForKey:@"owner"];
    } else {
        NSArray* arComment = (NSArray*)[picInfo objectForKey:@"comments"];
        NSDictionary *dictComment = [arComment objectAtIndex:button.tag-1];
        viewUser.dictUser = [dictComment objectForKey:@"user"];
    }
    [self.navigationController pushViewController:viewUser animated:YES];
    
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
    luxeysAppDelegate* app = (luxeysAppDelegate*)[[UIApplication sharedApplication] delegate]; 
    if (textComment.text.length < 3000) {
        textComment.text = @"";
        [self.textComment resignFirstResponder];
        NSDictionary *dictComment = [NSDictionary dictionaryWithObjectsAndKeys:
                                     textComment.text, @"description",
                                     app.currentUser, @"user",
                                     nil];
        
        luxeysTableViewCellComment* cellComment = [tablePic dequeueReusableCellWithIdentifier:@"Comment"];
        [cellComment setComment:dictComment];
        cellComment.buttonUser.tag = 0;
//        [tablePic add
        //[cellComment.buttonUser addTarget:self action:@selector(showUser:) forControlEvents:UIControlEventTouchUpInside];
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [self sendComment];
}

@end
