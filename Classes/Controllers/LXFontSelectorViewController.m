//
//  LXFontSelectorViewController.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 5/17/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXFontSelectorViewController.h"
#import "LXCellFont.h"

@interface LXFontSelectorViewController () {
    NSMutableArray *fonts;
}

@end

@implementation LXFontSelectorViewController

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
    
    // List all fonts on iPhone
    fonts = [[NSMutableArray alloc] init];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"fonts" ofType:@"plist"];
    NSArray *arrayFonts = [NSArray arrayWithContentsOfFile:path];
    
    for (NSString *fontName in arrayFonts) {
        [fonts addObject:fontName];
    }

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return fonts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Font";
    LXCellFont *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    //cell.labelSample.text =
    cell.labelSample.font = [UIFont fontWithName:fonts[indexPath.row][@"font"] size:22];
    cell.labelSample.text = _label.text;
    cell.labelFontName.text = fonts[indexPath.row][@"title"];
    
    return cell;
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat fontSize = _label.font.pointSize;
    _label.font = [UIFont fontWithName:fonts[indexPath.row][@"font"] size:fontSize];
    
    CGSize textSize = [_label.text
                       sizeWithFont:_label.font
                       constrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                       lineBreakMode:UILineBreakModeWordWrap];
    CGRect frame = _label.bounds;
    frame.size = textSize;
    _label.bounds = frame;
    
    [self dismissModalViewControllerAnimated:YES];
}

@end
