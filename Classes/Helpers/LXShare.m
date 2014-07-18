//
//  LXShare.m
//  Latte camera
//
//  Created by Xuan Dung Bui on 2013/01/18.
//  Copyright (c) 2013年 LUXEYS. All rights reserved.
//

#import "LXShare.h"

#import "LXAppDelegate.h"

#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>
#import <Social/Social.h>
#import <objc/runtime.h>

#define SYSTEM_VERSION_LESS_THAN(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define BLOCK_DONE                      @"BlockDone"
#define BLOCK_CANCELED                  @"BlockCanceled"
#define BLOCK_FAILED                    @"BlockFailed"
#define BLOCK_SAVED                     @"BlockSaved"

typedef enum {
    typeDone = 1,
    typeCanceled,
    typeFailed,
    typeSaved
}typeResult;

@implementation LXShare {
    NSString *text;
    NSData *imageData;
    UIImage *imagePreview;
    NSString *tweetCC;
}

@synthesize text;
@synthesize imagePreview;
@synthesize imageData;
@synthesize url;
@synthesize tweetCC;

// EMAIL
- (void) emailIt
{
    if ([MFMailComposeViewController canSendMail]==YES)
    {
        NSAssert(_controller, @"ViewController must not be nil.");
        
        MFMailComposeViewController* controllerMail = [[MFMailComposeViewController alloc] init];
        controllerMail.mailComposeDelegate = self;

        //[controllerMail setSubject:title];
        
        //Create a string with HTML formatting for the email body
        NSMutableString *emailBody = [[NSMutableString alloc] initWithString:@"<html><body>"];
        //Add some text to it however you want
        if (url)
            [emailBody appendString:[NSString stringWithFormat:@"<p>%@</p>", url]];
        
        //close the HTML formatting
        [emailBody appendString:@"</body></html>"];
        
        [controllerMail setMessageBody:emailBody isHTML:YES];
        
        if (imageData)
        {
            [controllerMail addAttachmentData:imageData mimeType:@"image/png" fileName:@"image"];
        }
        
        if (controllerMail)
            [_controller presentViewController:controllerMail animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", @"Error")
                                                        message:NSLocalizedString(@"Your device must have an email account set up", @"")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"close", @"Close")
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void) tweet
{
    NSAssert(_controller, @"ViewController must not be nil.");
    
    // share to twitter
    // esto lo hago solo si la version del sistema es menor al 6.0
    
    SLComposeViewController *socialComposer = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    
    // IMAGE
    if (imageData != nil)
        [socialComposer addImage:[UIImage imageWithData:imageData]];
    
    // URL
    if (url != nil) {
        [socialComposer addURL:[NSURL URLWithString:url]];
    }
    
    if (text) {
        NSString *message = [NSString stringWithString:text];
        if (message) {
            [socialComposer setInitialText:message];
        }
    }
    
    
    
    // if the message is bigger than 140 characters, then cut the message
    [socialComposer setCompletionHandler:^(SLComposeViewControllerResult result){
        [_controller dismissViewControllerAnimated:YES completion:nil];
        
        switch (result) {
            case SLComposeViewControllerResultCancelled:
                [self completionResult:typeCanceled];
                
                break;
            case SLComposeViewControllerResultDone:
                [self completionResult:typeDone];
                
                break;
            default:
                [self completionResult:typeFailed];
                break;
        }
    }];
    
    [_controller presentViewController:socialComposer animated:YES completion:nil];
    
}

- (void) facebookPost
{
    FBShareDialogParams *params = [[FBShareDialogParams alloc] init];
    params.link = [NSURL URLWithString:url];
    if ([FBDialogs canPresentShareDialogWithParams:params]) {
        [FBDialogs presentShareDialogWithParams:params clientState:nil handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
        }];
    } else {
        [FBWebDialogs presentFeedDialogModallyWithSession:nil parameters:@{@"link": url} handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
            
        }];
    }
}



- (void)inviteFriend {
    if ([MFMailComposeViewController canSendMail]==YES)
    {
        NSAssert(_controller, @"ViewController must not be nil.");
        
        MFMailComposeViewController* controllerMail = [[MFMailComposeViewController alloc] init];
        controllerMail.mailComposeDelegate = self;
        
        
        [controllerMail setSubject:NSLocalizedString(@"mail_invite_subject", @"")];
        
        LXAppDelegate *app = [LXAppDelegate currentDelegate];
        NSString *body;
        if (app.currentUser != nil) {
            body = [NSString stringWithFormat:NSLocalizedString(@"mail_invite_user", @""), app.currentUser.name, app.currentUser.userId.integerValue];
        } else {
            body = [NSString stringWithFormat:NSLocalizedString(@"mail_invite_guest", @"")];
        }
        
        [controllerMail setMessageBody:body isHTML:NO];
        
        
        if (controllerMail)
            [_controller presentViewController:controllerMail animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", @"Error")
                                                        message:NSLocalizedString(@"Your device must have an email account set up", @"")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"close", @"Close")
                                              otherButtonTitles:nil];
        [alert show];
    }
    
}


- (void)mailComposeController:(MFMailComposeViewController*)mailController  didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error;
{
    switch (result)
    {
        case MFMailComposeResultSent:
            [self completionResult:typeDone];
            
            break;
            
        case MFMailComposeResultCancelled:
            [self completionResult:typeCanceled];
            
            break;
            
        case MFMailComposeResultFailed:
            [self completionResult:typeFailed];
            
            break;
            
        case MFMailComposeResultSaved:
            [self completionResult:typeSaved];
            
            break;
            
        default:
            break;
    }
    
    [mailController dismissViewControllerAnimated:YES completion:nil];
}

// Convenience method to perform some action that requires the "publish_actions" permissions.
- (void) performPublishAction:(void (^)(void)) action
{
    // we defer request for permission to post to the moment of post, then we check for the permission
    if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound)
    {
        // if we don't already have the permission, then we request it now
        [FBSession.activeSession requestNewPublishPermissions:[NSArray arrayWithObject:@"publish_actions"]
                                              defaultAudience:FBSessionDefaultAudienceEveryone
                                            completionHandler:^(FBSession *session, NSError *error) {
                                                if (!error)
                                                {
                                                    action();
                                                }
                                                else
                                                {
                                                    [self completionResult:typeCanceled];
                                                }
                                            }];
    }
    else
    {
        action();
    }
    
}

- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI
{
    return [FBSession openActiveSessionWithPublishPermissions:[NSArray arrayWithObject:@"publish_actions"]
                                              defaultAudience:FBSessionDefaultAudienceEveryone
                                                 allowLoginUI:allowLoginUI
                                            completionHandler:^(FBSession *session,
                                                                FBSessionState state,
                                                                NSError *error) {
                                                if (state == FBSessionStateOpen)
                                                {
                                                    [self facebookPost];
                                                }
                                                else
                                                {
                                                    [self completionResult:typeCanceled];
                                                }
                                                
                                                if (error) {
                                                    [LXUtils showFBAuthError:error];
                                                }
                                            }];
    
}

- (void) setCompletionDone:(MyCompletionBlock)blockDone
{
    objc_setAssociatedObject(self, BLOCK_DONE, blockDone, OBJC_ASSOCIATION_COPY);
}

- (void) setCompletionCanceled:(MyCompletionBlock)blockCanceled
{
    objc_setAssociatedObject(self, BLOCK_CANCELED, blockCanceled, OBJC_ASSOCIATION_COPY);
}

- (void) setCompletionFailed:(MyCompletionBlock)blockFailed
{
    objc_setAssociatedObject(self, BLOCK_FAILED, blockFailed, OBJC_ASSOCIATION_COPY);
}

- (void) setCompletionSaved:(MyCompletionBlock)blockSaved
{
    objc_setAssociatedObject(self, BLOCK_SAVED, blockSaved, OBJC_ASSOCIATION_COPY);
}


- (void) completionResult:(typeResult)result
{
    switch (result) {
        case typeDone:
            [self done];
            
            break;
        case typeCanceled:
            [self cancelled];
            
            break;
            
        case typeFailed:
            [self failed];
            
            break;
            
        case typeSaved:
            [self saved];
            
            break;
            
        default:
            [self cancelled];
            
            break;
    }
}

- (void) done
{
    MyCompletionBlock _completionBlock = (MyCompletionBlock)objc_getAssociatedObject(self, BLOCK_DONE);
    if (_completionBlock != nil)
    {
        _completionBlock();
    }
}

- (void) cancelled
{
    MyCompletionBlock _canceledBlock = (MyCompletionBlock)objc_getAssociatedObject(self, BLOCK_CANCELED);
    if (_canceledBlock != nil)
    {
        _canceledBlock();
    }
}

- (void) failed
{
    MyCompletionBlock _completionBlock = (MyCompletionBlock)objc_getAssociatedObject(self, BLOCK_FAILED);
    if (_completionBlock != nil)
    {
        _completionBlock();
    }
}

- (void) saved
{
    MyCompletionBlock _completionBlock = (MyCompletionBlock)objc_getAssociatedObject(self, BLOCK_SAVED);
    if (_completionBlock != nil)
    {
        _completionBlock();
    }
}

@end
