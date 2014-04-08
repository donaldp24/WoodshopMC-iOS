//
//  FSRecordViewController.h
//  FloorSmart
//
//  Created by Lydia on 12/23/13.
//  Copyright (c) 2013 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSJobViewController.h"
#import "FSLocationsViewController.h"
#import "FSProductViewController.h"
#import "FSLocProductViewController.h"
#import "FSCurReadingsViewController.h"
#import "FSSelectViewController.h"

@interface FSRecordViewController : UIViewController <UITextFieldDelegate, FSJobSelectDelegate, FSLocationSelectDelegate, FSLocProductSelectDelegate> {
    
    FSJob *selectedJob;
    FSLocation *selectedLocation;
    FSProduct *selectedProduct;
    FSLocProduct *selectedLocProduct;
    
    FSLocation *defaultLocation;
    FSProduct *defaultProduct;
    
    UITextField *curTextField;
    FSCurReadingsViewController *readingVC;
    
    FSSelectViewController  *jobSelector;
    
    BOOL isPrevSqureFoot;
}

@property (nonatomic, retain) IBOutlet UILabel *lblJob;
@property (nonatomic, retain) IBOutlet UILabel *lblLocation;
@property (nonatomic, retain) IBOutlet UILabel *lblProduct;
@property (nonatomic, retain) IBOutlet UITextField *txtCoverage;

@property (nonatomic, strong) IBOutlet UILabel *lblHintJob;
@property (nonatomic, strong) IBOutlet UILabel *lblHintLocation;
@property (nonatomic, strong) IBOutlet UILabel *lblHintProduct;

@property (nonatomic, retain) IBOutlet UILabel *lblUnitFt;
@property (nonatomic, retain) IBOutlet UILabel *lblUnitM;

@property (nonatomic, retain) IBOutlet UIButton *btnSave;
@property (nonatomic, retain) IBOutlet UIButton *btnCancel;
@property (nonatomic, retain) IBOutlet UIButton *btnSummary;

@property (nonatomic, strong) IBOutlet UIButton *btnBg;

// actions
- (IBAction)onSelJob:(id)sender;
- (IBAction)onSelLocation:(id)sender;
- (IBAction)onSelProduct:(id)sender;

- (IBAction)onJobClick:(id)sender;
- (IBAction)onLocationClick:(id)sender;
- (IBAction)onProductClick:(id)sender;

- (void) showSummary;
- (void) hideSummary;

// delegate methods
- (void)jobSelected:(FSJob *)job;
- (void)locationSelected:(FSLocation *)loc;
- (void)locationAdded:(FSLocation *)loc;
- (void)locProductSelected:(FSLocProduct *)locProduct;
- (void)productSelected:(FSProduct *)product;

// button actions
- (IBAction)onSaveClicked:(id)sender;
- (IBAction)onCancelClicked:(id)sender;
- (IBAction)onSummaryClicked:(id)sender;

- (BOOL)isSelectable;
- (void)showAlertForNotSelectable;

// text delegates
- (IBAction)BeginEditing:(UITextField *)sender;
- (IBAction)EndEditing:(UITextField *)sender;
- (IBAction)onBgClicked:(id)sender;

// save incoming data
- (void)saveNewData:(NSDictionary *)data;
- (void)showReadingView;
@end
