//
//  FSLocationsViewController.m
//  FloorSmart
//
//  Created by Donald Pae on 3/11/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import "FSLocationsViewController.h"
#import "FSLocation.h"
#import "DataManager.h"
#import "Defines.h"
#import "GlobalData.h"

@interface FSLocationsViewController () {
    NSMutableArray *arrLoc;
    NSMutableArray *arrMainLoc;
    CGFloat trasnfromHeight;
}
@end

@implementation FSLocationsViewController

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
    // Do any additional setup after loading the view from its nib.
    
    arrLoc = [[DataManager sharedInstance] getLocations:self.curJob.jobID];
    
    [self.tblLoc setDataSource:self];
    [self.tblLoc setDelegate:self];
    [self.tblLoc setBackgroundColor:[UIColor clearColor]];
    
    trasnfromHeight = 0;
    
    self.archive_alertview.transform = CGAffineTransformMakeScale(0.5f, 0.5f);
    [self.archive_alertview setHidden:YES];
    
    [self.lblJobName setText:self.curJob.jobName];
    
    FSLocation *defaultLoc = [[FSLocation alloc] init];
    defaultLoc.locID = 0;
    defaultLoc.locJobID = self.curJob.jobID;
    defaultLoc.locName = @"Default";
    self.curLoc = defaultLoc;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.screenName = @"Location Screen";
    
    [self initTableData];
}

- (void)initTableData
{
    arrLoc = [[DataManager sharedInstance] getLocations:self.curJob.jobID];
    [self.tblLoc reloadData];
    self.isEditing = NO;
    if ([arrLoc count] == 0)
    {
        [self.lblNoResult setHidden:NO];
    }
    else
        [self.lblNoResult setHidden:YES];
}

- (void)initTableDataArray
{
    arrLoc = [[DataManager sharedInstance] getLocations:self.curJob.jobID];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - actions

- (IBAction)onAdd:(id)sender
{
    [CommonMethods playTapSound];
    
    NSString *locationName = self.txtAdd.text;
    if (locationName == nil || [locationName isEqualToString:@""]) {
        [CommonMethods showAlertUsingTitle:@"" andMessage:@"Please input location name to add!"];
        return;
    }
    
#if CHECK_LOC_DUPLICATE
    if ([[DataManager sharedInstance] isExistSameLocation:self.curJob.jobID locName:self.txtAdd.text])
    {
        [CommonMethods showAlertUsingTitle:@"" andMessage:[NSString stringWithFormat:@"Location '%@' is already exist in this Job", self.txtAdd.text]];
        return;
    }
#endif
    
    FSLocation *loc = [[FSLocation alloc] init];
    loc.locID = 0;
    loc.locJobID = self.curJob.jobID;
    loc.locName = locationName;
        
    loc.locID = [[DataManager sharedInstance] addLocationToDatabase:loc];
    if (loc.locID != 0)
    {
        [self initTableData];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[arrLoc count] - 1 inSection:0];
        [self.tblLoc scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
    
    [self.txtAdd resignFirstResponder];
    self.txtAdd.text = @"";
}

- (IBAction)onClose:(id)sender
{
    [CommonMethods playTapSound];
    
    [self.txtAdd resignFirstResponder];
    [self.txtAdd setText:@""];
}

- (IBAction)onBack:(id)sender
{
    [CommonMethods playTapSound];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onDeleteOk:(id)sender
{
    [CommonMethods playTapSound];
    
    // check whether this location is using for recording
    GlobalData *globalData = [GlobalData sharedData];
    if (globalData.isSaved && globalData.selectedLocID == self.curLoc.locID)
    {
        [CommonMethods showAlertUsingTitle:@"" andMessage:@"Recording is for this Location,\nPlease 'Cancel' recording first to delete this location."];
        return;
    }
    
    [[DataManager sharedInstance] deleteLocFromDatabase:self.curLoc];
    [self initTableData];
    [self hideAlertAnimation];
}

- (IBAction)onDeleteCancel:(id)sender
{
    [CommonMethods playTapSound];
    
    [self hideAlertAnimation];
}


- (void)showAlertAnimation
{
    [UIView animateWithDuration:0.2f animations:^{
        self.archive_alertview.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
    }completion:^(BOOL finished){
        [UIView animateWithDuration:0.07f animations:^{
            self.archive_alertview.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        }completion:nil];
    }];
}

- (void)hideAlertAnimation
{
    [UIView animateWithDuration:0.1f animations:^{
        self.archive_alertview.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    }completion:^(BOOL finished){
        [self.archive_alertview setHidden:YES];
    }];
}

#pragma mark - UITableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tblLoc)
        return [arrLoc count];
    else
        return [arrMainLoc count];
}

- (CGFloat)tableView:( UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tblLoc)
        return 60.0f;
    else
        return 40.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    FSLocationCell *cell = [self.tblLoc dequeueReusableCellWithIdentifier:@"FSLocationCell"];
    
    if(cell == nil)
    {
        cell = (FSLocationCell *)[FSLocationCell cellFromNibNamed:@"FSLocationCell"];
        [cell setIdentifier:@"FSLocationCell"];
    }
    cell.delegate = self;
    [cell setData:[arrLoc objectAtIndex:indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - textfield delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    //[self onAdd:textField];
    return YES;
}

#pragma mark - FSCellDelegate
- (void)onEditCell:(id)sender
{
    [CommonMethods playTapSound];
    
    FSLocationCell *cell = (FSLocationCell *)sender;
    _curLoc = (FSLocation *)cell.data;
    CGRect selectedCellFrame = [cell.superview convertRect:cell.frame toView:self.view];
    if (selectedCellFrame.origin.y + 60 >= [[UIScreen mainScreen] bounds].size.height - 216) {
        trasnfromHeight = selectedCellFrame.origin.y + 60 - [[UIScreen mainScreen] bounds].size.height + 216;
        [UIView animateWithDuration:0.2f animations:^{
            [self.tblLoc setFrame:CGRectMake(self.tblLoc.frame.origin.x, self.tblLoc.frame.origin.y - trasnfromHeight, self.tblLoc.frame.size.width, self.tblLoc.frame.size.height)];
        }];
    } else {
        trasnfromHeight = 0;
    }
    
    self.isEditing = YES;

}

- (void)onDeleteCell:(id)sender
{
    [CommonMethods playTapSound];
    
    FSLocationCell *cell = (FSLocationCell *)sender;
    self.curLoc = cell.data;
    [self.view bringSubviewToFront:self.archive_alertview];
    [self.archive_alertview setHidden:NO];
    [self showAlertAnimation];
}

- (BOOL)onEditFinishedOk:(id)sender
{
    [CommonMethods playTapSound];
    
    self.isEditing = NO;
    
    FSLocationCell *cell = (FSLocationCell *)sender;
    if ([self.curLoc.locName isEqualToString:cell.txtName.text])
    {
        //
    }
    else
    {
#if CHECK_LOC_DUPLICATE
        if ([[DataManager sharedInstance] isExistSameLocation:self.curJob.jobID locName:cell.txtName.text])
        {
            [CommonMethods showAlertUsingTitle:@"" andMessage:[NSString stringWithFormat:@"Location '%@' is already exist in this Job", cell.txtName.text]];
            return NO;
        }
#endif
        [self.curLoc setLocName:[cell.txtName text]];
        [[DataManager sharedInstance] updateLocToDatabase:self.curLoc];
    }
    if (trasnfromHeight != 0) {
        [UIView animateWithDuration:0.2f animations:^{
            [self.tblLoc setFrame:CGRectMake(self.tblLoc.frame.origin.x, self.tblLoc.frame.origin.y + trasnfromHeight, self.tblLoc.frame.size.width, self.tblLoc.frame.size.height)];
        }];
    }
    [self initTableData];
    return YES;
}

- (void)onEditFinishedCancel:(id)sender
{
    [CommonMethods playTapSound];
    
    self.isEditing = NO;
    
    if (trasnfromHeight != 0) {
        [UIView animateWithDuration:0.1f animations:^{
            [self.tblLoc setFrame:CGRectMake(self.tblLoc.frame.origin.x, self.tblLoc.frame.origin.y + trasnfromHeight, self.tblLoc.frame.size.width, self.tblLoc.frame.size.height)];
        }];
    }
}

- (BOOL)isEditing:(id)sender
{
    return self.isEditing;
}

- (void)onSelectCell:(id)sender
{
    
    [CommonMethods playTapSound];
    
    if (self.mode == MODE_RECORD)
    {
        FSLocationCell *cell = (FSLocationCell *)sender;
        FSLocation *loc = (FSLocation *)cell.data;
        if (self.locationSelectDelegate != nil)
            [self.locationSelectDelegate locationSelected:loc];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (NSString *)getName:(id)sender
{
    FSLocationCell *cell = (FSLocationCell *)sender;
    FSLocation *loc = (FSLocation *)cell.data;
    return loc.locName;
}


@end
