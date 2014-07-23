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
#import "LXUploadStatusViewController.h"
#import "LXUploadObject.h"
#import "LXTableConfirmEmailController.h"
#import "MZFormSheetSegue.h"
#import "LXNotifySideViewController.h"
#import "LXNavigationController.h"
#import "UAProgressView.h"

@interface LXMainTabViewController ()

@end

@implementation LXMainTabViewController {
    UIView *viewCamera;
    BOOL isFirst;

    UAProgressView *hudUpload;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadSuccess:) name:@"LXUploaderSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadProgess:) name:@"LXUploaderProgress" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadStart:) name:@"LXUploaderStart" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userUpdate:) name:@"user_update" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive:) name:@"BecomeActive" object:nil];
    
    isFirst = true;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    // Init View
    self.delegate = self;
    
    UIScreen *screen = [UIScreen mainScreen];
    
    hudUpload = [[UAProgressView alloc] initWithFrame:CGRectMake(280, screen.bounds.size.height-110, 30, 30)];
    hudUpload.tintColor = [UIColor colorWithRed:35.0/255.0 green:183.0/255.0 blue:223.0/255.00 alpha:1];

    __weak __typeof(self)weakSelf = self;
    [hudUpload setDidSelectBlock:^(UAProgressView *progressView) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf toggleUpload:strongSelf];
    }];

    hudUpload.hidden = YES;
    [self.view addSubview:hudUpload];
    

    [[UITabBar appearance] setTintColor:[UIColor colorWithRed:35.0/255.0 green:183.0/255.0 blue:223.0/255.00 alpha:1]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    isFirst = false;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if ([defaults boolForKey:@"LatteCameraStartUp"]) {
        if (isFirst) {
            [self startCamera];
        }
        
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


- (void)receiveLoggedIn:(NSNotification *) notification {
    // Register for Push Notification
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
}

- (void)receiveLoggedOut:(NSNotification *) notification {
    self.selectedIndex = 0;
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
    hudUpload.hidden = NO;
}

- (void)uploadSuccess:(NSNotification *) notification {
    LXAppDelegate* app = [LXAppDelegate currentDelegate];
    hudUpload.hidden = app.uploader.count == 0;
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

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if (self.viewControllers.count == 0)
        return false;
    
    LXAppDelegate* app = [LXAppDelegate currentDelegate];
    if (!app.currentUser) {
        if ((viewController == tabBarController.viewControllers[3]) || (viewController == tabBarController.viewControllers[4])) {
            UIStoryboard *storyAuth = [UIStoryboard storyboardWithName:@"Authentication" bundle:nil];
            [self presentViewController:[storyAuth instantiateInitialViewController] animated:YES completion:nil];
            return false;
        }
    }
    
    if (viewController == tabBarController.viewControllers[2]) {
        UIActionSheet *actionUpload = [[UIActionSheet alloc] initWithTitle:@""
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                     destructiveButtonTitle:nil
                                          otherButtonTitles:NSLocalizedString(@"Camera", @""), NSLocalizedString(@"Photo Library", @""), nil];
        
        [actionUpload showFromTabBar:self.tabBar];
        
        return false;
    } else if (tabBarController.selectedViewController == viewController) {
        LXNavigationController *navTab = (LXNavigationController*)viewController;
        if (navTab.topViewController == navTab.viewControllers[0]) {
            [navTab scrollToTop];
        }
    }
    
    return true;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    if (viewController == tabBarController.viewControllers[3]) {
        viewController.tabBarItem.badgeValue = nil;
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    }
}

- (void)startCamera {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
        
    } else {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
        imagePicker.delegate = self;
        
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self startCamera];
    } else if (buttonIndex == 1) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.delegate = self;
        
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image =  [info objectForKey:UIImagePickerControllerOriginalImage];
    
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        BOOL save;
        if ([defaults objectForKey:@"LatteSaveOrigin"]) {
            save = [defaults boolForKey:@"LatteSaveOrigin"];
        } else {
            save = YES;
        }
        
        if (save) {
            [LXUtils saveImageRefToLib:image.CGImage metadata:[info objectForKey:UIImagePickerControllerMediaMetadata]];
        }
    }
    
    UIStoryboard *storyCamera = [UIStoryboard storyboardWithName:@"Camera" bundle:nil];
    LXImageCropViewController *controllerCrop = [storyCamera instantiateInitialViewController];
    
    controllerCrop.sourceImage = image;
    controllerCrop.doneCallback = ^(UIImage *editedImage, BOOL canceled){
        if(!canceled) {
            UIStoryboard *storyCamera = [UIStoryboard storyboardWithName:@"Camera" bundle:nil];
            LXCanvasViewController *controllerCanvas = [storyCamera instantiateViewControllerWithIdentifier:@"Canvas"];
            controllerCanvas.imageOriginal = editedImage;
            if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
                controllerCanvas.info = [info objectForKey:UIImagePickerControllerMediaMetadata];
                [picker pushViewController:controllerCanvas animated:YES];
            } else {

                NSURL *assetURL = [info objectForKey:UIImagePickerControllerReferenceURL];
                
                ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                [library assetForURL:assetURL
                         resultBlock:^(ALAsset *asset)  {
                             controllerCanvas.info = asset.defaultRepresentation.metadata;
                             [picker pushViewController:controllerCanvas animated:YES];
                         }
                        failureBlock:^(NSError *error) {
                        }];
            }
        } else {
            [picker popViewControllerAnimated:YES];
            [picker setNavigationBarHidden:NO animated:YES];
        }
    };
    
    [picker setNavigationBarHidden:YES animated:YES];
    [picker pushViewController:controllerCrop animated:YES];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"UploadStatus"]) {
        MZFormSheetSegue *sheet = (MZFormSheetSegue*)segue;
        sheet.formSheetController.cornerRadius = 0;
        sheet.formSheetController.shouldDismissOnBackgroundViewTap = YES;
    }
}

- (void)userUpdate:(NSNotification *)notification {
    NSDictionary *rawUser = notification.object;
    if (rawUser[@"notification_count"]) {
        LXAppDelegate* app = [LXAppDelegate currentDelegate];
        if (app.currentUser) {
            if ([app.currentUser.userId integerValue] == [rawUser[@"id"] integerValue]) {
                UINavigationController* notifyNav = self.viewControllers[3];
                
                if (self.selectedIndex != 3) {
                    NSInteger notifyCount = [rawUser[@"notification_count"] integerValue];
                    if (notifyCount > 0) {
                        notifyNav.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld", (long)notifyCount];
                    } else {
                        notifyNav.tabBarItem.badgeValue = nil;
                    }
                    [UIApplication sharedApplication].applicationIconBadgeNumber = notifyCount;
                } else {
                    LXNotifySideViewController *viewNotify = notifyNav.viewControllers[0];
                    [viewNotify reloadView];
                    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
                }
            }
        }
    }
}

- (void)becomeActive:(NSNotification *) notification {
    if (self.selectedIndex != 3) {
        [[LatteAPIClient sharedClient] GET:@"user/me/unread_notify" parameters: nil success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
            NSInteger count = [JSON[@"notify_count"] integerValue];
            UIViewController *viewNotify = self.viewControllers[3];
            if (count > 0) {
                viewNotify.tabBarItem.badgeValue = [JSON[@"notify_count"] stringValue];
            } else {
                viewNotify.tabBarItem.badgeValue = nil;
            }
            [UIApplication sharedApplication].applicationIconBadgeNumber = count;
            
        } failure: nil];
    }
}

@end
