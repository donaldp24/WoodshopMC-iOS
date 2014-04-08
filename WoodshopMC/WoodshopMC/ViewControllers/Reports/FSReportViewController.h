//
//  FSReportViewController.h
//  FloorSmart
//
//  Created by Lydia on 12/23/13.
//  Copyright (c) 2013 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSJob.h"
#import "FSPopView.h"
#import <MessageUI/MessageUI.h>
#import "FSLocation.h"
#import "FSProduct.h"

// define this value not for hiding toolbars/pagebars

#import "ReaderViewController.h"

@interface FSReportViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, MFMailComposeViewControllerDelegate, UIPrintInteractionControllerDelegate, ReaderViewControllerDelegate>

@property (nonatomic, assign) IBOutlet UITableView *tblMain;
@property (nonatomic, assign) IBOutlet UILabel *lblJob;
@property (nonatomic, assign) IBOutlet FSPopView *popView;
@property (nonatomic, strong) FSJob *curJob;
@property (nonatomic, retain) ReaderViewController *pdfReaderViewController;
@property (nonatomic, retain) IBOutlet UILabel *lblNoResults;
@property (nonatomic, retain) IBOutlet UIButton *btnFly;


- (IBAction)onBack:(id)sender;

@end

@interface FSReportListNodeObject : NSObject

@property (nonatomic, retain) FSLocation *loc;
@property (nonatomic, retain) FSLocProduct *locProduct;
@property (nonatomic, retain) NSMutableArray *arrayDates;


@end
