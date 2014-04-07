//
//  FSArchiveJobViewController.m
//  FloorSmart
//
//  Created by Lydia on 12/24/13.
//  Copyright (c) 2013 Tim. All rights reserved.
//

#import "FSArchiveJobViewController.h"
#import "FSArchiveCell.h"
#import "DataManager.h"
#import "Global.h"
#import "FSJob.h"
#import "FSMainViewController.h"
#import "FSReportViewController.h"
#import "Defines.h"

@interface FSArchiveJobViewController ()
{
    NSMutableArray *arrJobNames;
    NSInteger arcVSdelete;
    FSJob *curJob;
}
@end

@implementation FSArchiveJobViewController
@synthesize tblArchives, txtTop, delete_alertview;
@synthesize imgAlertBack;

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
    
    delete_alertview.transform = CGAffineTransformMakeScale(0.5f, 0.5f);
    [delete_alertview setHidden:YES];
    [tblArchives setBackgroundColor:[UIColor clearColor]];
    arcVSdelete = -1;
    curJob = [[FSJob alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initTableData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)initTableData
{
    arrJobNames = [[DataManager sharedInstance] getJobs:1 searchField:txtTop.text];
    [tblArchives setContentSize:CGSizeMake(tblArchives.frame.size.width, 60 * [arrJobNames count])];
    [tblArchives reloadData];
    
    if ([arrJobNames count] == 0)
    {
        [self.lblNoResult setHidden:NO];
        
        if (self.txtTop.text == nil || [self.txtTop.text isEqualToString:@""])
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

#pragma mark - textfield delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}   
#pragma mark - UITableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [arrJobNames count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:( UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FSArchiveCell *cell = [tblArchives
                           dequeueReusableCellWithIdentifier:@"FSArchiveCell"];
    
    if(cell == nil)
    {
        cell = [FSArchiveCell sharedCell];
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setDelegate:self];
    [cell setCurJob:[arrJobNames objectAtIndex:indexPath.section]];
    
    return cell;
}

#pragma mark - Cell Delegate
- (void)didUnarchive:(FSArchiveCell *)cell
{
    [CommonMethods playTapSound];
    
    curJob = cell.curJob;
    arcVSdelete = 0;
    [imgAlertBack setImage:[UIImage imageNamed:@"bg_cancelarchive_job"]];
    [self.view bringSubviewToFront:delete_alertview];
    [delete_alertview setHidden:NO];
    [self showAlertAnimation];
}

- (void)didDelete:(FSArchiveCell *)cell
{
    [CommonMethods playTapSound];
    
    arcVSdelete = 1;
    curJob = cell.curJob;
    [imgAlertBack setImage:[UIImage imageNamed:@"bg_delete_job"]];
    [self.view bringSubviewToFront:delete_alertview];
    [delete_alertview setHidden:NO];
    [self showAlertAnimation];
}

- (void)didDetail:(FSArchiveCell *)cell
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
        if (self.jobSelectDelegate != nil)
        {
            [self.jobSelectDelegate jobSelected:cell.curJob];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}

#pragma mark - custom
- (void)showAlertAnimation
{
    [UIView animateWithDuration:0.2f animations:^{
        delete_alertview.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
    }completion:^(BOOL finished){
        [UIView animateWithDuration:0.07f animations:^{
            delete_alertview.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        }completion:nil];
    }];
}

- (void)hideAlertAnimation
{
    [UIView animateWithDuration:0.1f animations:^{
        delete_alertview.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    }completion:^(BOOL finished){
        [delete_alertview setHidden:YES];
    }];
}

#pragma mark - Actions
- (IBAction)onSearch:(id)sender
{
    arrJobNames = [[DataManager sharedInstance] getJobs:1 searchField:txtTop.text];
    [tblArchives reloadData];
}

- (IBAction)onDelete_OK:(id)sender
{
    [CommonMethods playTapSound];
    
    if (arcVSdelete) {
        // check this job is recording now
        GlobalData *globalData = [GlobalData sharedData];
        if (globalData.isSaved && globalData.selectedJobID == curJob.jobID)
        {
            [CommonMethods showAlertUsingTitle:@"" andMessage:@"Recording is for this job now. \nPlease 'Cancel' recording first to delete this job."];
            return;
        }
        
        [[DataManager sharedInstance] deleteJobFromDatabase:curJob];
    } else {
        [curJob setJobArchived:0];
        [[DataManager sharedInstance] updateJobToDatabase:curJob];
    }
    arcVSdelete = -1;
    [self initTableData];
    [self hideAlertAnimation];
}

- (IBAction)onDelete_Cancel:(id)sender
{
    [CommonMethods playTapSound];
    
    arcVSdelete = -1;
//    [curJob clear];
    [self hideAlertAnimation];
}

- (IBAction)onBack:(id)sender
{
    [CommonMethods playTapSound];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onTopChanged:(id)sender
{
    [self onSearch:sender];
}

- (IBAction)onBtnCancel:(id)sender
{
    [CommonMethods playTapSound];
    
    txtTop.text = @"";
    [self onSearch:sender];
    [txtTop resignFirstResponder];
}

@end
