//
//  LXCellUpload.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 3/18/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXCellUpload.h"
#import "LXAppDelegate.h"

@implementation LXCellUpload {
    
}

@synthesize imageupload;
@synthesize progressUpload;
@synthesize buttonError;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setUploader:(LXUploadObject *)uploader{
    _uploader = uploader;
    _uploader.delegate = self;
    imageupload.image = uploader.imagePreview;
    progressUpload.progress = uploader.percent;
}

- (IBAction)touchInfo:(id)sender {
    switch (_uploader.uploadState) {
        case kUploadStateSuccess: {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:NSLocalizedString(@"uploaded", @"Uploaded :)")
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"close", "Close")
                                                  otherButtonTitles:nil];
            alert.delegate = self;
            [alert show];
        }
            break;
        case kUploadStateFail:
        {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"cannot_upload", @"")
                                                                     delegate:self
                                                            cancelButtonTitle:NSLocalizedString(@"close", "Close")
                                                       destructiveButtonTitle:NSLocalizedString(@"Abort Uploading", "Abort")
                                                            otherButtonTitles:NSLocalizedString(@"retry_upload", "Retry"), nil];
            LXAppDelegate *app = [LXAppDelegate currentDelegate];
            [actionSheet showFromTabBar:app.viewMainTab.tabBar];
        }
            break;
        case kUploadStateProgress:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:NSLocalizedString(@"uploading", @"Uploading :)")
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"close", "Close")
                                                  otherButtonTitles:nil];
            alert.delegate = self;
            [alert show];
        }
            break;
        default:
            break;
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        // to remove
        [_uploader finishedUpload];
    } else if (buttonIndex == 1) {
        [_uploader upload];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [_uploader upload];
    }
}

- (void)uploader:(LXUploadObject *)upload progress:(float)percent {
    progressUpload.progress = percent;
}

- (void)uploader:(LXUploadObject*)upload success:(id)responseObject {
    
}

- (void)uploader:(LXUploadObject*)upload fail:(NSError*)error {
    
}

@end
