//
//  LXProfileSettingEditTVC.m
//  Latte camera
//
//  Created by Serkan Unal on 6/19/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import "LXProfileSettingEditTVC.h"
@interface LXProfileSettingEditTVC () {
  NSInteger selectedSection;
  NSInteger selectedValue;
  NSDictionary *section_map;
}

@end

@implementation LXProfileSettingEditTVC
@synthesize textViewHobby;
@synthesize textViewIntroduction;
@synthesize datePickerBirthday;
@synthesize pickerViewNationality;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
  section_map = @{
    @"gender" : [NSNumber numberWithInt:0],
    @"bloodtype" : [NSNumber numberWithInt:3],
    @"birthday" : [NSNumber numberWithInt:8],
    @"introduction" : [NSNumber numberWithInt:10],
    @"hobby" : [NSNumber numberWithInt:12],
    @"nationality" : [NSNumber numberWithInt:14]
    };
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  NSIndexPath *oldIndex = [self.tableView indexPathForSelectedRow];
  [self.tableView cellForRowAtIndexPath:oldIndex].accessoryType = UITableViewCellAccessoryNone;
  [self.tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
  return indexPath;
}


- (void)initSetupwithkind:(NSString *)kind withValue:(NSString *)value {
//keys = [NSArray arrayWithObjects:@"name", @"gender", @"bloodtype", @"birthday", @"current_residence", @"hometown", @"occupation", @"introduction", @"hobby", @"nationality", nil];

  
  selectedValue = value;
  if ([kind  isEqual: @"gender"]) {
    selectedSection = SECTION_GENDER;
  } else if ([kind  isEqual: @"bloodtype"]) {
    selectedSection = SECTION_BLOOD_TYPE;
  } else if ([kind  isEqual: @"birthday"]) {
    selectedSection = SECTION_BIRTHDAY;
  } else if ([kind  isEqual: @"introduction"]) {
    selectedSection = SECTION_INTRODUCTION;
  } else if ([kind  isEqual: @"hobby"]) {
    selectedSection = SECTION_HOBBY;
  } else if ([kind  isEqual: @"nationality"]) {
    selectedSection = SECTION_NATIONALITY;
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [super tableView:tableView
                     cellForRowAtIndexPath:indexPath];
  cell.accessoryType = UITableViewCellAccessoryNone;
  
  NSUInteger section = [indexPath section];
  NSUInteger row = [indexPath row];
  if (!section == selectedSection) {
    
  }
  switch (section)
  {
    case SECTION_GENDER:
      cell.accessoryType = UITableViewCellAccessoryCheckmark;
      break;
      
    case SECTION_BLOOD_TYPE:
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
      break;
    case SECTION_BIRTHDAY:
      break;
    case SECTION_INTRODUCTION:
      break;
    case SECTION_HOBBY:
      break;
    case SECTION_NATIONALITY:
      break;
    default:
      break;
  }
  return cell;
}
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//  [self.tableView reloadData];
//}
/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
