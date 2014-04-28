//
//  FSReportViewController.m
//  FloorSmart
//
//  Created by Lydia on 12/23/13.
//  Copyright (c) 2013 Tim. All rights reserved.
//

#import "FSReportViewController.h"
#import "FSMainViewController.h"
#import "DataManager.h"
#import "Global.h"
#import "FSReportHeaderView.h"
#import "FSReportCell.h"
#import "FSCurReadingsViewController.h"
#import "FSReportHelper.h"
#import "ReaderDocument.h"

@interface FSReportViewController ()
{
    NSMutableArray *arrayJob;
    FSReportHelper *reportHelper;
}

@end

@implementation FSReportViewController
@synthesize lblJob, popView;
@synthesize curJob = _curJob;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        arrayJob = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [popView setArrContents:[NSArray arrayWithObjects:@"Email Report", @"Print Report", nil]];
    [popView setDelegate:self];
    CGRect popFrame = popView.frame;
    popFrame.size.height = 0;
    [popView setFrame:popFrame];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    arrayJob = [[NSMutableArray alloc] init];
    self.lblJob.text = @"";
    
    if (self.curJob != nil)
    {
        self.lblJob.text = self.curJob.jobName;
        
        NSMutableArray *arrayLocation = [[DataManager sharedInstance] getLocations:self.curJob.jobID containDefault:YES];
    
        for (int i = 0; i < [arrayLocation count]; i++) {
            FSLocation *loc = [arrayLocation objectAtIndex:i];
            
            NSMutableArray *arrayLocProduct = [[DataManager sharedInstance] getLocProducts:loc searchField:@"" containDefault:YES];
            
            for (int j = 0; j < [arrayLocProduct count]; j++) {
                FSLocProduct *locProduct = (FSLocProduct *)[arrayLocProduct objectAtIndex:j];
                NSMutableArray *arrayReadingDates = [[DataManager sharedInstance] getAllReadingDates:locProduct.locProductID];
                NSMutableArray *arrayReadingDatesHasData = [[NSMutableArray alloc] init];
                for (int k = 0; k < [arrayReadingDates count]; k++) {
                    NSDate *date = [arrayReadingDates objectAtIndex:k];
                    if ([[DataManager sharedInstance] getReadingsCount:locProduct.locProductID withDate:date] > 0)
                    {
                        [arrayReadingDatesHasData addObject:date];
                    }
                }
                if ([arrayReadingDatesHasData count] > 0)

                {
                    FSReportListNodeObject *node = [[FSReportListNodeObject alloc] init];
                    node.loc = loc;
                    node.locProduct = locProduct;
                    node.arrayDates = arrayReadingDates;
                    [arrayJob addObject:node];
                }
            }
        }
    }
    [self.tblMain reloadData];
    
    if ([arrayJob count] == 0)
    {
        self.lblNoResults.hidden = NO;
        self.btnFly.hidden = YES;
    }
    else
    {
        self.lblNoResults.hidden = YES;
        self.btnFly.hidden = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];    
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
    return [arrayJob count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section < [arrayJob count])
    {
        FSReportListNodeObject *node = [arrayJob objectAtIndex:section];
        return [node.arrayDates count];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [FSReportHeaderView getViewHeight];
}

- (CGFloat)tableView:( UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0f;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section >= [arrayJob count])
        return nil;
    FSReportListNodeObject *node = [arrayJob objectAtIndex:section];
    FSReportHeaderView *view = [FSReportHeaderView reportHeaderView:node.loc locProduct:node.locProduct];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section >= [arrayJob count])
        return nil;
    
    FSReportListNodeObject *node = [arrayJob objectAtIndex:indexPath.section];
    NSMutableArray *arrayDates = node.arrayDates;
    if (indexPath.row >= [arrayDates count])
        return nil;
    /*
    UITableViewCell *cell = [self.tblMain dequeueReusableCellWithIdentifier:@"UITableViewCellIdentifier"];
    
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCellIdentifier"];
    }
    
    [cell.textLabel setTextColor:lblJob.textColor];
    [cell.textLabel setFont:[UIFont systemFontOfSize:13]];
    
    
    NSDate *date = [arrayDates objectAtIndex:indexPath.row];
    GlobalData *globalData = [GlobalData sharedData];
    [cell.textLabel setText:[CommonMethods date2str:date withFormat:globalData.settingDateFormat]];
     */
    
    FSReportCell *cell = [self.tblMain dequeueReusableCellWithIdentifier:@"FSReportCell"];
    
    if(cell == nil)
    {
        cell = [FSReportCell sharedCell];
    }
    NSDate *date = [arrayDates objectAtIndex:indexPath.row];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setDelegate:self];
    [cell setCurDate:date];
    cell.loc = node.loc;
    cell.locProduct = node.locProduct;
    
    return cell;
}

#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - MFMailComposeViewControllerDelegate mothods
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    if ((result == MFMailComposeResultFailed) && (error != NULL)) {
        [CommonMethods showAlertUsingTitle:@"Error" andMessage:@"Can't send mail"];
    } else if (result == MFMailComposeResultSent) {
        [CommonMethods showAlertUsingTitle:@"Info" andMessage:@"Message Sent"];
    }
    
    [controller dismissViewControllerAnimated:YES completion:^(void){
        
    }];
}

#pragma mark - PopView Delegate
- (void)didPopUpItem
{
    
    [UIView animateWithDuration:0.1f animations:^{
        CGRect popFrame = popView.frame;
        popFrame.size.height = 0.0f;
        [popView setFrame:popFrame];
    }completion:^(BOOL finished){
        [popView setHidden:YES];
        switch (popView.selectedNum) {
            case 0:
                [self sendEmail];
                break;
            case 1:
                [self print];
                break;
            default:
                break;
        }
    }];
}

#pragma mark - UIPrinterInteractionDelegate
//- (UIPrintPaper *)printInteractionController:(UIPrintInteractionController *)pic
//                                 choosePaper:(NSArray *)paperList {
//    CGSize pageSize = [self pageSizeForDocumentType:self.document.type];
//    return [UIPrintPaper bestPaperForPageSize:pageSize
//                          withPapersFromArray:paperList];
//}

#pragma mark - Custom Functions
- (void)sendEmail
{
    if(![MFMailComposeViewController canSendMail])
    {
        [CommonMethods showAlertUsingTitle:@"No Mail Accounts" andMessage:@"You don't have a Mail account configured, please configure to send email."];
        return;
    }
    
    // create an MFMailComposeViewController for sending an e-mail
    MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
    
    // set controller's delegate to this objects
    controller.mailComposeDelegate = self;
    
    [controller setSubject:@"FloorSmart Job Overview"];
    
    [controller setMessageBody:[self getEmailBody] isHTML:YES];
    
    // show the MFMailComposeViewController
    controller.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.navigationController presentViewController:controller animated:YES completion:nil];
}

- (NSString *)getEmailBody
{
    /*//
    NSString *locName = [(FSLocation *)[[DataManager sharedInstance] getLocationFromID:[_curFeed feedLocID]] locName];
    NSString *procName = [(FSProduct *)[[DataManager sharedInstance] getProductFromID:[_curFeed feedProcID]] productName];
    NSString *feedMode = @"";
    switch (_curFeed.feedMode) {
        case 0:
            feedMode = @"";
            break;
        case 1:
            feedMode = @"1/4\"";
            break;
        case 2:
            feedMode = @"3/4\"";
            break;
        default:
            break;
    }
    NSString *feedMaterial = @"";
    switch (_curFeed.feedmaterial) {
        case 0:
            feedMaterial = @"";
            break;
        case 1:
            feedMaterial = @"normal";
            break;
        case 2:
            feedMaterial = @"relative";
            break;
        case 3:
            feedMaterial = @"concrete";
            break;
        default:
            break;
    }
    NSString *feedSG = [NSString stringWithFormat:@"%.2f", (float)[_curFeed feedsg] / 100];
    NSString *feedReadings = [NSString stringWithFormat:@"%d", (int)[[DataManager sharedInstance] getReadingsCount:[_curFeed feedID]]];
    
    NSString *embedHTML = [NSString stringWithFormat:@"%@%@%@", @"<html><head></head><body><p>", [NSString stringWithFormat:@"Job Name : %@\n Location : %@</p><p>Product : %@</p><p>Coverage : %@</p><p>Mode : %@</p><p>Material : %@</p><p>S.G : %@</p><p>Readings : %@", [_curJob jobName], locName, procName, [_curFeed feedCoverage], feedMode, feedMaterial, feedSG, feedReadings], @"</p></body></html>"];
    
    return embedHTML;
     */
    return @"";
}

- (void)print
{
#if false
    UIPrintInteractionController *pic = [UIPrintInteractionController sharedPrintController];
    pic.delegate = self;
    
    UIPrintInfo *printInfo = [UIPrintInfo printInfo];
    printInfo.outputType = UIPrintInfoOutputGeneral;
    printInfo.jobName = @"JobOverViewPrint";
    pic.printInfo = printInfo;
    
    UIMarkupTextPrintFormatter *htmlFormatter = [[UIMarkupTextPrintFormatter alloc]
                                                 initWithMarkupText:[self getEmailBody]];
    htmlFormatter.startPage = 0;
    htmlFormatter.contentInsets = UIEdgeInsetsMake(72.0, 72.0, 72.0, 72.0); // 1 inch margins
    pic.printFormatter = htmlFormatter;
    pic.showsPageRange = YES;
    
    void (^completionHandler)(UIPrintInteractionController *, BOOL, NSError *) =
    ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
        if (!completed && error) {
            NSLog(@"Printing could not complete because of error: %@", error);
        }
    };

    [pic presentAnimated:YES completionHandler:completionHandler];
#else

    if (reportHelper == nil)
        reportHelper = [[FSReportHelper alloc] init];
    NSString *pdfFullPath = [reportHelper generateReportForJob:self.curJob];
    
    if (pdfFullPath == nil)
        return;
    
    if([[NSFileManager defaultManager] fileExistsAtPath:pdfFullPath]) {
        ReaderDocument *document = [ReaderDocument withDocumentFilePath:pdfFullPath password:nil];
        
        if (document) {
            ReaderViewController *readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document];
            readerViewController.delegate = self;
            readerViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            readerViewController.modalPresentationStyle = UIModalPresentationFullScreen;
            self.pdfReaderViewController = readerViewController;
            [self presentViewController:self.pdfReaderViewController animated:YES completion:nil];
        }
    }
#endif
}

- (IBAction)onBack:(id)sender
{
    FSMainViewController *mainController = [FSMainViewController sharedController];
    [mainController selectItem:mainController.btnHome];
}

- (IBAction)onFly:(id)sender
{
#if false
    if (popView.hidden) {
        [popView setHidden:NO];
        [UIView animateWithDuration:0.1f animations:^{
            CGRect popFrame = popView.frame;
            popFrame.size.height = 60.0f;
            [popView setFrame:popFrame];
        }completion:nil];
    } else {
        [UIView animateWithDuration:0.1f animations:^{
            CGRect popFrame = popView.frame;
            popFrame.size.height = 0.0f;
            [popView setFrame:popFrame];
        }completion:^(BOOL finished){
            [popView setHidden:YES];
            
        }];
    }
#else
    
    [self print];
#endif
    
}

- (void)didDisclosure:(FSReportCell *)cell
{
    FSCurReadingsViewController *vc = [[FSCurReadingsViewController alloc] init];
    vc.curDate = cell.curDate;
    vc.curLocProduct = cell.locProduct;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - ReaderViewControllerDelegate
- (void)dismissReaderViewController:(ReaderViewController *)viewController {
    
    if (viewController) {
        [viewController dismissViewControllerAnimated:YES completion:nil];
    }
}

@end

@implementation FSReportListNodeObject


@end
