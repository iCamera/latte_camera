//
//  LXProfileSettingTableViewController.h
//  Latte camera
//
//  Created by Serkan Unal on 6/18/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LXProfileSettingTableViewController : UITableViewController <UITextFieldDelegate> {
  NSArray *keys;
  NSArray *genders;
}
@property (strong, nonatomic) IBOutlet UITextField *textUsername;
@property (strong, nonatomic) IBOutlet UITextField *textGender;
@property (strong, nonatomic) IBOutlet UITextField *textBloodType;
//Birthday
@property (strong, nonatomic) IBOutlet UITextField *textBirthday;
@property (strong, nonatomic) IBOutlet UITextField *textCurrentAddress;
@property (strong, nonatomic) IBOutlet UITextField *textHometown;
@property (strong, nonatomic) IBOutlet UITextField *textOccupation;
// Introduciton, Hobby, Nationality.
@property (strong, nonatomic) IBOutlet UITextField *textIntroduction;
@property (strong, nonatomic) IBOutlet UITextField *textHobby;
@property (strong, nonatomic) IBOutlet UITextField *textNationality;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewNationalityFlag;


-(void)updateData;
@end
