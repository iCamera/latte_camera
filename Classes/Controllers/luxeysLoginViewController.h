//
//  luxeysLoginViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 8/7/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KeychainItemWrapper;

@protocol UserLoginDelegate <NSObject>
-(void)userLoggedIn;
@end

@interface luxeysLoginViewController : UIViewController
{
    KeychainItemWrapper *keychainItemWrapper;
    id <UserLoginDelegate> delegate;
}

@property (nonatomic, retain) KeychainItemWrapper *keychainItemWrapper;

@property (strong, nonatomic) IBOutlet UITextField *textPass;
@property (strong, nonatomic) IBOutlet UITextField *textUser;

- (IBAction)registerClick:(id)sender;
- (IBAction)singleTap:(id)sender;
- (IBAction)goBack:(id)sender;
- (IBAction)login:(id)sender;

@property(nonatomic,retain)id delegate;

@end
