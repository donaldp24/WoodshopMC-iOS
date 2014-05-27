//
//  FSLocationsViewController.h
//  FloorSmart
//
//  Created by Donald Pae on 3/11/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSPopView.h"
#import "FSJob.h"
#import "FSLocationCell.h"
#import "FSLocation.h"

#import "GAITrackedViewController.h"

@protocol FSLocationSelectDelegate <NSObject>

- (void)locationSelected:(FSLocation *)loc;

@end

@interface FSLocationsViewController : GAITrackedViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, FSLocationCellDelegate> {
    //
}

@property (nonatomic, strong) FSJob *curJob;
@property (nonatomic, strong) FSLocation *curLoc;
@property (nonatomic, strong) IBOutlet UILabel *lblJobName;

@property (nonatomic) BOOL isEditing;
@property (nonatomic, assign) IBOutlet UITableView *tblLoc;
@property (nonatomic, assign) IBOutlet UITextField *txtAdd;
@property (nonatomic, assign) IBOutlet UIView *archive_alertview;
@property (nonatomic, assign) IBOutlet UILabel *lblNoResult;

@property (nonatomic) int mode;
@property (nonatomic, retain) id<FSLocationSelectDelegate> locationSelectDelegate;

- (IBAction)onAdd:(id)sender;
- (IBAction)onClose:(id)sender;
- (IBAction)onBack:(id)sender;
- (IBAction)onDeleteOk:(id)sender;
- (IBAction)onDeleteCancel:(id)sender;

// FSLocationCellDelegate
- (void)onEditCell:(id)sender;
- (void)onDeleteCell:(id)sender;
- (BOOL)onEditFinishedOk:(id)sender;
- (void)onEditFinishedCancel:(id)sender;
- (BOOL)isEditing:(id)sender;
- (void)onSelectCell:(id)sender;
- (NSString *)getName:(id)sender;


@end
