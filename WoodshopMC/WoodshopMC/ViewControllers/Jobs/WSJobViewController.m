//
//  FSJobViewController.m
//  FloorSmart
//
//  Created by Lydia on 12/23/13.
//  Copyright (c) 2013 Tim. All rights reserved.
//

#import "FSJobViewController.h"
#import "FSPopContentController.h"
#import "FSJobCell.h"
#import "FSJob.h"
#import "DataManager.h"
#import "Global.h"
#import "FSArchiveJobViewController.h"
#import "FSReportViewController.h"
#import "FSMainViewController.h"
#import "FSLocationsViewController.h"
#import "Defines.h"

@interface FSJobViewController ()
{
    NSMutableArray *arrJobNames;
    CGFloat trasnfromHeight;
    FSJob *curJob;
    UITextField *curTextField;
}
@end

@implementation FSJobViewController
@synthesize isEditing = _isEditing;
@synthesize tblJobs, btnFly, viewTopAdd;
@synthesize archive_alertview;

- (id)init {
    self = [super init];
    if (self) {
        //
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];


    [archive_alertview setHidden:YES];
    [tblJobs setBackgroundColor:[UIColor clearColor]];
    trasnfromHeight = 0;
    _isEditing = NO;
    curJob = [[FSJob alloc] init];
    
    curTextField = nil;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.mode == MODE_JOBMANAGEMENT || self.mode == MODE_RECORD)
    {
        [self.viewTopAdd setHidden:NO];
        [self.viewSearch setHidden:YES];
        
        if (self.mode == MODE_RECORD)
        {
            [self.btnFly setHidden:NO];
            [self.btnBack setHidden:NO];
        }
        else
        {
            [self.btnBack setHidden:YES];
            [self.btnFly setHidden:NO];
        }
    }
    else
    {
        [self.viewTopAdd setHidden:YES];
        [self.viewSearch setHidden:NO];
        [self.btnFly setHidden:YES];
        [self.btnBack setHidden:NO];
    }
    [self initTableData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (curTextField != nil)
        [curTextField resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)initTableData
{
    [self initTableDataArray];

    [tblJobs reloadData];
    
    self.isEditing = NO;
    
    if ([arrJobNames count] == 0)
    {
        [self.lblNoResult setHidden:NO];
        if (self.txtEdit.text == nil || [self.txtEdit.text isEqualToString:@""])
        {
            [self.lblNoResult setText:@"No Jobs"];
        }
        else
        {
            [self.lblNoResult setText:@"Searching..."];
        }
    }
    else
    {
        [self.lblNoResult setHidden:YES];
    }
}

- (void)initTableDataArray
{
    if (self.mode == MODE_JOBMANAGEMENT || self.mode == MODE_RECORD)
    {
        arrJobNames = [[DataManager sharedInstance] getJobs:0 searchField:self.txtEdit.text];
    }
    else
    {
        arrJobNames = [[DataManager sharedInstance] getJobs:0 searchField:self.txtSearch.text];
    }
}

#pragma mark - textfield delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    //[self onAdd:textField];
    return YES;
}

- (IBAction)BeginEditing:(UITextField *)sender
{
    curTextField = sender;
}

- (IBAction)EndEditing:(UITextField *)sender
{
    curTextField = nil;
    [sender resignFirstResponder];
}

#pragma mark - UITableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [arrJobNames count];
}
*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrJobNames count];
}

- (CGFloat)tableView:( UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FSJobCell *cell = [tblJobs dequeueReusableCellWithIdentifier:@"FSJobCell"];
    
    if(cell == nil)
    {
        cell = [FSJobCell sharedCell];
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setDelegate:self];
    [cell setCurJob:[arrJobNames objectAtIndex:indexPath.row]];
    
    return cell;
}

#pragma mark - custom
- (void)navigateArchive
{
    FSArchiveJobViewController *vc = [[FSArchiveJobViewController alloc] initWithNibName:@"FSArchiveJobViewController" bundle:nil];
    vc.mode = self.mode;
    vc.jobSelectDelegate = self.jobSelectDelegate;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showAlertAnimation
{
    [UIView animateWithDuration:0.2f animations:^{
        archive_alertview.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
    }completion:^(BOOL finished){
        [UIView animateWithDuration:0.07f animations:^{
            archive_alertview.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        }completion:nil];
    }];
}

- (void)hideAlertAnimation
{
    [UIView animateWithDuration:0.1f animations:^{
        archive_alertview.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    }completion:^(BOOL finished){
        [archive_alertview setHidden:YES];
    }];
}

#pragma mark - Cell Delegate
- (void)didEdit:(FSJobCell *)cell
{
    [CommonMethods playTapSound];
    
    curJob = cell.curJob;
    CGRect selectedCellFrame = [cell.superview convertRect:cell.frame toView:self.view];
    if (selectedCellFrame.origin.y + 60 >= [[UIScreen mainScreen] bounds].size.height - 216) {
        trasnfromHeight = selectedCellFrame.origin.y + 60 - [[UIScreen mainScreen] bounds].size.height + 216;
        [UIView animateWithDuration:0.2f animations:^{
            [tblJobs setFrame:CGRectMake(tblJobs.frame.origin.x, tblJobs.frame.origin.y - trasnfromHeight, tblJobs.frame.size.width, tblJobs.frame.size.height)];
        }];
    } else {
        trasnfromHeight = 0;
    }
}

- (void)didArchive:(FSJobCell *)cell
{
    [CommonMethods playTapSound];
    
    curJob = cell.curJob;
    [self.view bringSubviewToFront:archive_alertview];
    [archive_alertview setHidden:NO];
    [self showAlertAnimation];
}

#pragma mark - Job Cell Delegate

- (BOOL)didOK:(FSJobCell *)cell
{
    [CommonMethods playTapSound];
    
    if ([curJob.jobName isEqualToString:[cell.txtJobName text]])
    {
        //
    }
    else
    {
#if CHECK_JOB_DUPLICATE
        if ([[DataManager sharedInstance] isExistSameJob:cell.txtJobName.text])
        {
            [CommonMethods showAlertUsingTitle:@"" andMessage:[NSString stringWithFormat:@"Job '%@' is already exist", cell.txtJobName.text]];
            return NO;
        }
#endif
        [curJob setJobName:[cell.txtJobName text]];
        [[DataManager sharedInstance] updateJobToDatabase:curJob];
    }
    
    if (trasnfromHeight != 0) {
        [UIView animateWithDuration:0.2f animations:^{
            [tblJobs setFrame:CGRectMake(tblJobs.frame.origin.x, tblJobs.frame.origin.y + trasnfromHeight, tblJobs.frame.size.width, tblJobs.frame.size.height)];
        }];
    }

    [self initTableData];
    
    return YES;
}

- (void)didCancel:(FSJobCell *)cell
{
    [CommonMethods playTapSound];
    
//    [curJob clear];
    if (trasnfromHeight != 0) {
        [UIView animateWithDuration:0.1f animations:^{
            [tblJobs setFrame:CGRectMake(tblJobs.frame.origin.x, tblJobs.frame.origin.y + trasnfromHeight, tblJobs.frame.size.width, tblJobs.frame.size.height)];
        }];
    }
}

- (void)didDetail:(FSJobCell *)cell
{
    [CommonMethods playTapSound];
    
    /*
    FSMainViewController *mainController = [FSMainViewController sharedController];
    UINavigationController *nav =(UINavigationController *)[[mainController viewControllers] objectAtIndex:2];
    FSReportViewController *report = (FSReportViewController *)[[nav viewControllers] objectAtIndex:0];
    [report setCurJob:cell.curJob];
    [mainController selectItem:mainController.btnReports];
     */
    
    if (self.mode == MODE_JOBMANAGEMENT)
    {
        /*
        FSLocationsViewController *vc = [[FSLocationsViewController alloc] initWithNibName:@"FSLocationsViewController" bundle:nil];
        vc.curJob = cell.curJob;
        [self.navigationController pushViewController:vc animated:YES];
         */
        FSMainViewController *mainController = [FSMainViewController sharedController];
        UINavigationController *nav =(UINavigationController *)[[mainController viewControllers] objectAtIndex:2];
        FSReportViewController *report = (FSReportViewController *)[[nav viewControllers] objectAtIndex:0];
        [report setCurJob:cell.curJob];
        [mainController selectItem:mainController.btnReports];
    }
    else
    {
        if (self.jobSelectDelegate)
            [self.jobSelectDelegate jobSelected:cell.curJob];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Actions
- (IBAction)onFly:(id)sender;
{
    [CommonMethods playTapSound];
    
    [self navigateArchive];
}

- (IBAction)onArchive_OK:(id)sender
{
    [CommonMethods playTapSound];
    
    [curJob setJobArchived:1];
    [[DataManager sharedInstance] updateJobToDatabase:curJob];
    [self initTableData];
    [self hideAlertAnimation];
}

- (IBAction)onArchive_Cancel:(id)sender
{
    [CommonMethods playTapSound];
    
//    [curJob clear];
    [self hideAlertAnimation];
}

- (IBAction)onAdd:(id)sender
{
    [CommonMethods playTapSound];
    
    if (self.txtEdit.text == nil || [self.txtEdit.text isEqualToString:@""]) {
        [CommonMethods showAlertUsingTitle:@"" andMessage:@"Please input job name to add!"];
        return;
    }
    
#if CHECK_JOB_DUPLICATE
    if ([[DataManager sharedInstance] isExistSameJob:self.txtEdit.text])
    {
        [CommonMethods showAlertUsingTitle:@"" andMessage:[NSString stringWithFormat:@"Job '%@' is already exist", self.txtEdit.text]];
        return;
    }
#endif
    
    
    FSJob *job = [[FSJob alloc] init];
    job.jobName = self.txtEdit.text;
    job.jobID = [[DataManager sharedInstance] addJobToDatabase:job];
    
    [self.txtEdit resignFirstResponder];
    [self.txtEdit setText:@""];
    
    [self initTableData];
   
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[arrJobNames count] - 1 inSection:0];
    [tblJobs scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
}

- (IBAction)onClose:(id)sender
{
    [CommonMethods playTapSound];
    
    [self.txtEdit setText:@""];
    [self initTableData];
}

- (IBAction)onSearch:(id)sender
{
    [self initTableData];
}

- (IBAction)onBtnBg:(id)sender
{
    //[txtTop resignFirstResponder];
    //if (self.txtEditing)
      //  [self.txtEditing resignFirstResponder];
}

- (IBAction)onBtnCancel:(id)sender
{
    [CommonMethods playTapSound];
    
    [self.txtSearch resignFirstResponder];
    [self.txtSearch setText:@""];
    [self initTableData];
}

- (IBAction)onBtnBack:(id)sender
{
    [CommonMethods playTapSound];
    
    [self.navigationController popViewControllerAnimated:YES];
}


@end


