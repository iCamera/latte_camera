//
//  LXImagePickerController.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 4/11/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import "LXImagePickerController.h"
#import "LXCanvasViewController.h"

@interface LXImagePickerController ()

@end

@implementation LXImagePickerController

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
    // Do any additional setup after loading the view.
//    self.delegate = self;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIStoryboard *storyCamera = [UIStoryboard storyboardWithName:@"Camera" bundle:nil];
    LXCanvasViewController *controllerCanvas = [storyCamera instantiateViewControllerWithIdentifier:@"Canvas"];
    
    //controllerCanvas.delegate = self.delegate;
    //        controllerCanvas.imageOriginalPreview = info[UIImagePickerControllerOriginalImage];
    
    //        UIImage *thumbNail = info[UIImagePickerControllerOriginalImage];
    //        CGFloat height = [LXUtils heightFromWidth:70 width:thumbNail.size.height height:thumbNail.size.height];
    
    
    //        controllerCanvas.imageMeta = [NSMutableDictionary dictionaryWithDictionary:info[UIImagePickerControllerMediaMetadata]];
    //        controllerCanvas.imageOriginal = info[UIImagePickerControllerOriginalImage];
    UIImage *image = info[UIImagePickerControllerOriginalImage];
//    controllerCanvas.imageSize = image.size;

    controllerCanvas.info = info;
    
    [picker pushViewController:controllerCanvas animated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
