//
//  luxeysTabBarViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/14/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "LXLoginViewController.h"
#import "User.h"
#import "Picture.h"
#import "LXImageCropViewController.h"
#import "LXCanvasViewController.h"
#import "LXMainTabViewController.h"
#import "LXAppDelegate.h"
#import "LXAboutViewController.h"
#import "LXUserPageViewController.h"
#import "LXNavMypageController.h"
#import "LXUploadStatusViewController.h"
#import "LXUploadObject.h"
#import "LXTableConfirmEmailController.h"

@interface LXMainTabViewController ()

@end

@implementation LXMainTabViewController {
    UIView *viewCamera;
    BOOL isFirst;

    UIButton *buttonUploadStatus;
    MBRoundProgressView *hudUpload;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveLoggedIn:)
                                                 name:@"LoggedIn"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveLoggedOut:)
                                                 name:@"LoggedOut"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivePushNotify:)
                                                 name:@"ReceivedPushNotify"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadSuccess:) name:@"LXUploaderSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadProgess:) name:@"LXUploaderProgress" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadStart:) name:@"LXUploaderStart" object:nil];
    
    isFirst = true;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    // Init View
    self.delegate = self;
    
    LXAppDelegate* app = [LXAppDelegate currentDelegate];
    if (app.currentUser != nil) {
        [self setUser];
    } else {
        [self setGuest];
    }
    
    UIScreen *screen = [UIScreen mainScreen];
    
    buttonUploadStatus = [[UIButton alloc] initWithFrame:CGRectMake(280, screen.bounds.size.height-110, 30, 30)];
    [buttonUploadStatus addTarget:self action:@selector(toggleUpload:) forControlEvents:UIControlEventTouchUpInside];
    hudUpload = [[MBRoundProgressView alloc] initWithFrame:buttonUploadStatus.bounds];
    hudUpload.userInteractionEnabled = NO;
    [buttonUploadStatus addSubview:hudUpload];
    [self.view addSubview:buttonUploadStatus];
    buttonUploadStatus.hidden = YES;

    [[UITabBar appearance] setTintColor:[UIColor colorWithRed:35.0/255.0 green:183.0/255.0 blue:223.0/255.00 alpha:1]];
}

- (void)receivePushNotify:(NSNotification*)notify {
    if (self.selectedIndex != 3) {
        NSDictionary *userInfo = notify.object;
        if ([userInfo objectForKey:@"aps"]) {
            NSDictionary *aps = [userInfo objectForKey:@"aps"];
            if ([aps objectForKey:@"badge"]) {
                NSNumber *count = [aps objectForKey:@"badge"];
                UIViewController* notifyView = self.viewControllers[3];
                notifyView.tabBarItem.badgeValue = [count stringValue];
            }
        }
    } else {
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    }
}

- (void)showNotify {
    [[LatteAPIClient sharedClient] GET:@"user/me/unread_announcement"
                                parameters: nil
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       //viewNotify.notifyCount = [[JSON objectForKey:@"announcement_count"] integerValue];
                                   }
                                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       DLog(@"Something went wrong (Announcement count)");
                                   }];
}

- (void)showSetting:(id)sender {
    UIStoryboard* storySetting = [UIStoryboard storyboardWithName:@"Setting" bundle:nil];
    [self presentViewController:[storySetting instantiateInitialViewController] animated:YES completion:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [super viewDidUnload];
}


- (void)setGuest {
    LXNavMypageController *navMypage = self.viewControllers[4];
//    navMypage.tabBarItem.image = [UIImage imageNamed:@"icon_login.png"];    
    UIStoryboard* storyMain = [UIStoryboard storyboardWithName:@"Authentication" bundle:nil];
    UIViewController *viewLogin = [storyMain instantiateViewControllerWithIdentifier:@"Login"];
    
    navMypage.viewControllers = [NSArray arrayWithObject:viewLogin];
}

- (void)setUser {
    LXNavMypageController *navMypage = self.viewControllers[4];
//    navMypage.tabBarItem.image = [UIImage imageNamed:@"icon_mypage.png"];
    UIStoryboard* storyMain = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UIViewController *viewMypage = [storyMain instantiateViewControllerWithIdentifier:@"Home"];
    navMypage.viewControllers = [NSArray arrayWithObject:viewMypage];
}

- (void)receiveLoggedIn:(NSNotification *) notification {
    [self setUser];
    
    // Register for Push Notification
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
}

- (void)receiveLoggedOut:(NSNotification *) notification {
    [self setGuest];
}

- (void)showUser:(NSNotification *)notify {
    self.selectedIndex = 4;
    UINavigationController *nav = (id)self.selectedViewController;
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    LXUserPageViewController *viewUser = [mainStoryboard instantiateViewControllerWithIdentifier:@"UserPage"];
    User *user = notify.object;
    viewUser.user = user;
    [nav pushViewController:viewUser animated:YES];
}


- (void)touchTitle:(id)sender {
    UINavigationController *nav = (UINavigationController*)self.selectedViewController;
    UITableViewController *view = (UITableViewController*)nav.visibleViewController;
    if ([view respondsToSelector:@selector(tableView)]) {
        
        // No animation to prevent too much pageview counter request
        [view.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    }
}

- (void)uploadStart:(NSNotification *) notification {
    buttonUploadStatus.hidden = NO;
}

- (void)uploadSuccess:(NSNotification *) notification {
    LXAppDelegate* app = [LXAppDelegate currentDelegate];
    buttonUploadStatus.hidden = app.uploader.count == 0;
    if (app.uploader.count == 0) {
        self.selectedIndex = 4;
        UINavigationController *navMypage = (UINavigationController*)self.selectedViewController;
        if ([navMypage.viewControllers[0] respondsToSelector:@selector(reloadView)]) {
            [navMypage.viewControllers[0] performSelector:@selector(reloadView)];
        }
    }
}

- (void)uploadProgess:(NSNotification *) notification {
    float percent = 0;
    LXAppDelegate* app = [LXAppDelegate currentDelegate];
    for (LXUploadObject *uploader in app.uploader) {
        percent += uploader.percent;
    }
    hudUpload.progress = percent/app.uploader.count;
}

- (void)toggleUpload:(id)sender {
    [self performSegueWithIdentifier:@"UploadStatus" sender:self];
}

- (void)statusBarOverlayDidRecognizeGesture:(UIGestureRecognizer *)gestureRecognizer {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    UINavigationController *viewConfirm = [mainStoryboard instantiateViewControllerWithIdentifier:@"NavConfirmEmail"];
    [self presentViewController:viewConfirm animated:YES completion:nil];
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if (viewController == tabBarController.viewControllers[2]) {
        UIActionSheet *actionUpload = [[UIActionSheet alloc] initWithTitle:@""
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                     destructiveButtonTitle:nil
                                          otherButtonTitles:NSLocalizedString(@"Camera", @""), NSLocalizedString(@"Photo Library", @""), nil];
        
        [actionUpload showFromTabBar:self.tabBar];
        
        return false;
    }
    
    return true;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    UIStoryboard* storyCamera = [UIStoryboard storyboardWithName:@"Camera" bundle:nil];
    
    if (buttonIndex == 0) {
        
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                  message:@"Device has no camera"
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles: nil];
            
            [myAlertView show];
            
        } else {
            UIImagePickerController *imagePicker = [storyCamera instantiateViewControllerWithIdentifier:@"Picker"];
            
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePicker.delegate = self;
            
            [self presentViewController:imagePicker animated:YES completion:nil];
        }
    } else if (buttonIndex == 1) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.delegate = self;
        
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIStoryboard *storyCamera = [UIStoryboard storyboardWithName:@"Camera" bundle:nil];
    LXImageCropViewController *controllerCrop = [storyCamera instantiateInitialViewController];
    
    UIImage *image =  [info objectForKey:UIImagePickerControllerOriginalImage];
    controllerCrop.sourceImage = image;
    controllerCrop.doneCallback = ^(UIImage *editedImage, BOOL canceled){
        if(!canceled) {
            [picker dismissViewControllerAnimated:NO completion:nil];
            
            UIStoryboard *storyCamera = [UIStoryboard storyboardWithName:@"Camera" bundle:nil];
            LXCanvasViewController *controllerCanvas = [storyCamera instantiateViewControllerWithIdentifier:@"Canvas"];
            controllerCanvas.imageOriginal = editedImage;
            controllerCanvas.info = info;
            [self presentViewController:controllerCanvas animated:NO completion:nil];
        } else {
            [picker popToRootViewControllerAnimated:YES];
            [picker setNavigationBarHidden:NO animated:NO];
        }
    };
    
    [picker setNavigationBarHidden:YES animated:NO];
    [picker pushViewController:controllerCrop animated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}


@end
