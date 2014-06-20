//
//  LXProfileSettingEditTVC.h
//  Latte camera
//
//  Created by Serkan Unal on 6/19/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LXProfileSettingEditTVC : UITableViewController <UITextViewDelegate, UIPickerViewDelegate>
@property (strong, nonatomic) IBOutlet UIDatePicker *datePickerBirthday;
@property (strong, nonatomic) IBOutlet UITextView *textViewIntroduction;
@property (strong, nonatomic) IBOutlet UITextView *textViewHobby;
@property (strong, nonatomic) IBOutlet UIPickerView *pickerViewNationality;

//,UIDatePickerDelegate,  UITextViewDelegate, UIPickerViewDelegate
- (void)initSetupwithkind:(NSString *)kind withValue:(NSString *)value;
@end

static const int SECTION_GENDER = 0;
static const int SECTION_BLOOD_TYPE = 1;
static const int SECTION_BIRTHDAY = 2;
static const int SECTION_INTRODUCTION = 3;
static const int SECTION_HOBBY = 4;
static const int SECTION_NATIONALITY = 5;
