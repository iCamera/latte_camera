//
//  LXShare.m
//  Latte camera
//
//  Created by Xuan Dung Bui on 2013/01/18.
//  Copyright (c) 2013年 LUXEYS. All rights reserved.
//

#import "LXShare.h"

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
        if (text)
            [emailBody appendString:[NSString stringWithFormat:@"<p>%@</p>", text]];
        
        //close the HTML formatting
        [emailBody appendString:@"</body></html>"];
        
        [controllerMail setMessageBody:emailBody isHTML:YES];
        
        if (imageData)
        {
            [controllerMail addAttachmentData:imageData mimeType:@"image/png" fileName:@"image"];
        }
        
        if (controllerMail) [_controller presentModalViewController:controllerMail animated:YES];
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
    
    // TEXT
    if (text != nil)
    {
        // URL AND TWEETCC
        // creo el formato del texto a twittear
        NSString *format    = @"“%@”";
        if (self.tweetCC != nil)
            format          = [format stringByAppendingFormat:@" %@", tweetCC];
        
        
        // TEXT
        NSUInteger idx      = self.text.length;
        // le quito todos los espacios que tenga el texto al principio y al final

        while([text hasPrefix:@" "])
            text = [text substringFromIndex:1];
        while([text hasSuffix:@" "])
        {
            idx       = idx-1;
            text = [text substringToIndex:idx];
        }
        // creo el mensaje
        NSString *message   = [NSString stringWithFormat:format, [NSString stringWithFormat:@"%@…", [text substringToIndex:idx]]];
        
        
        // if the message is bigger than 140 characters, then cut the message
        while (![socialComposer setInitialText:message])
        {
            idx -= 5;
            if (idx > 5)
            {
                message = [NSString stringWithFormat:format, [NSString stringWithFormat:@"%@…", [text substringToIndex:idx]]];
            }
        }
        
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
        
        [_controller presentModalViewController:socialComposer animated:YES];
    }
}

- (void) facebookPost
{
    //share to facebook
    // esto lo hago solo si la version del sistema es menor a la 6.0

        // If the session is open, do the post, if not, try login
        if (FBSession.activeSession.isOpen)
        {
            // if it is available to us, we will post using the native dialog
            BOOL displayedNativeDialog = [FBNativeDialogs presentShareDialogModallyFrom:_controller
                                                                            initialText:text
                                                                                  image:imagePreview
                                                                                    url:nil
                                                                                handler:nil];
            
            // si no presenta caja de dialogo nativo del sistema, presento una propia
            if (!displayedNativeDialog)
            {
                REComposeViewController *composeViewController = [[REComposeViewController alloc] init];
                composeViewController.hasAttachment = YES;
                composeViewController.attachmentImage = imagePreview;
                composeViewController.text = text;
                
                // Service name
                UILabel *titleView          = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 110, 30)];
                titleView.font              = [UIFont boldSystemFontOfSize:17.0];
                titleView.textAlignment     = NSTextAlignmentCenter;
                titleView.backgroundColor   = [UIColor clearColor];
                titleView.textColor         = [UIColor whiteColor];
                titleView.text              = @"Facebook";
                composeViewController.navigationItem.titleView = titleView;

                composeViewController.navigationBar.tintColor = [UIColor colorWithRed:44.0/255.0 green:67.0/255.0 blue:136.0/255.0 alpha:1.0];
                composeViewController.delegate = self;
                
                [_controller presentViewController:composeViewController animated:YES completion:nil];
            }
        }
        else
        {
            [self openSessionWithAllowLoginUI:YES];
        }
}

- (void)composeViewController:(REComposeViewController *)composeViewController didFinishWithResult:(REComposeResult)result {
    switch (result)
    {
        case REComposeResultCancelled:
            [self completionResult:typeCanceled];
            break;
            
        case REComposeResultPosted: {
            [self performPublishAction:^{
                
                // paso los parametros para mandar al feed del usuario
                NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                               imageData, @"source",
                                               composeViewController.text, @"message",
                                               text, @"caption",
                                               nil];
                [FBRequestConnection startWithGraphPath:@"me/photos"
                                             parameters:params
                                             HTTPMethod:@"POST"
                                      completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                          
                                          if (!error)
                                          {
                                              [self completionResult:typeDone];
                                          }
                                          else
                                          {
                                              NSLog(@"ERROR AT 'startWithGraphPath': %@", [error localizedDescription]);
                                              [self completionResult:typeCanceled];
                                          }
                                      }];
            }];
        }
            break;
            
        default:
            break;
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
        [FBSession.activeSession reauthorizeWithPublishPermissions:[NSArray arrayWithObject:@"publish_actions"]
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
                                                if (!error)
                                                {
                                                    [self facebookPost];
                                                }
                                                else
                                                {
                                                    [self completionResult:typeCanceled];
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
