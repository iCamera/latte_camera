//
//  luxeysSideMenuViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/14/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "luxeysSideMenuViewController.h"
#import "luxeysAppDelegate.h"
#import "LatteAPIClient.h"
#import "LXUIRevealController.h"
#import "UIImageView+AFNetworking.h"
#import <QuartzCore/CALayer.h>

@interface luxeysSideMenuViewController ()

@end

@implementation luxeysSideMenuViewController

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
    // Do any additional setup after loading the view from its nib.
    
    self.menuTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.footerImage.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_menu_background.png"]];

    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.imageProfile.bounds];
    self.imageProfile.layer.masksToBounds = NO;
    self.imageProfile.layer.shadowColor = [UIColor blackColor].CGColor;
    self.imageProfile.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    self.imageProfile.layer.shadowOpacity = 1.0f;
    self.imageProfile.layer.shadowRadius = 1.0f;
    self.imageProfile.layer.shadowPath = shadowPath.CGPath;
    
    // Load User Info
    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
    self.labelUsername.text = app.currentUser.name;
    [self.imageProfile setImageWithURL:[NSURL URLWithString:app.currentUser.profilePicture]];
    //[tableView reload];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 5;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	if (nil == cell)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
	}
	
	if (indexPath.row == 0)
	{
		cell.textLabel.text = @"マイページ";
	}
	else if (indexPath.row == 1)
	{
		cell.textLabel.text = @"写真一覧";
	}
	else if (indexPath.row == 2)
	{
		cell.textLabel.text = @"カレンダー";
	}
    else if (indexPath.row == 3)
	{
		cell.textLabel.text = @"友達一覧";
	}
	else if (indexPath.row == 4)
	{
		cell.textLabel.text = @"設定";
	}
    
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.shadowColor = [UIColor blackColor];
    cell.textLabel.shadowOffset = CGSizeMake(0.0, 1.0);

    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_menu.png"]];
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_menu_on.png"]];
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    luxeysAppDelegate* app = (luxeysAppDelegate*)[UIApplication sharedApplication].delegate;
    LXUIRevealController *viewMain = (LXUIRevealController*)app.revealController;

    if (indexPath.row == 3) {
        
        [app.tokenItem resetKeychainItem];
    } else if (indexPath.row == 4) {
        
        UINavigationController *viewNav = (UINavigationController*)viewMain.frontViewController;
        [viewNav.topViewController performSegueWithIdentifier:@"SettingPage" sender:nil];
    }
    [viewMain revealLeft:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setMenuTable:nil];
    [self setFooterImage:nil];
    [self setLabelUsername:nil];
    [self setImageProfile:nil];
    [super viewDidUnload];
}
@end
