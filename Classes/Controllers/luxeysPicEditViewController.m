//
//  luxeysPicEditViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/10/11.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "luxeysPicEditViewController.h"

@interface luxeysPicEditViewController ()

@end

@implementation luxeysPicEditViewController

@synthesize imagePic;
@synthesize textDesc;
@synthesize textTitle;
@synthesize gestureTap;

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
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_sub_back.png"]];

    imagePic.layer.borderColor = [[UIColor whiteColor] CGColor];
    imagePic.layer.borderWidth = 2;
    UIBezierPath *shadowPathPic = [UIBezierPath bezierPathWithRect:imagePic.bounds];
    imagePic.layer.masksToBounds = NO;
    imagePic.layer.shadowColor = [UIColor blackColor].CGColor;
    imagePic.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    imagePic.layer.shadowOpacity = 0.5f;
    imagePic.layer.shadowRadius = 1.5f;
    imagePic.layer.shadowPath = shadowPathPic.CGPath;

    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:) name: UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:) name: UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
    [super viewWillAppear:animated];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.section == 1) && (indexPath.row == 1))
    {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"公開"
                                        delegate:self
                               cancelButtonTitle:@"キャンセル"
                          destructiveButtonTitle:nil
                               otherButtonTitles:@"Nomal", @"Tilt Shift", @"Fish Eye", nil];
        [sheet setTag:0];
        sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        [sheet showInView:self.view];
    }
}

- (IBAction)touchPost:(id)sender {
}

- (IBAction)touchBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)touchBackground:(id)sender {
    [textTitle resignFirstResponder];
    [textDesc resignFirstResponder];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    [self.tableView addGestureRecognizer:gestureTap];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [self.tableView removeGestureRecognizer:gestureTap];
}
@end
