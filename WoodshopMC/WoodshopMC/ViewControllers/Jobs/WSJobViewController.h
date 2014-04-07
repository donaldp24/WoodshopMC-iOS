//
//  FSJobViewController.h
//  FloorSmart
//
//  Created by Lydia on 12/23/13.
//  Copyright (c) 2013 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSJob.h"
#import "FSJobCell.h"

@protocol FSJobSelectDelegate <NSObject>

- (void)jobSelected:(FSJob *)job;

@end

@interface FSJobViewController : UIViewController <UITableViewDelegate, UITextFieldDelegate, FSJobCellDelegate>

@property (nonatomic) BOOL isEditing;

@property (nonatomic, assign) IBOutlet UITableView *tblJobs;

@property (nonatomic, assign) IBOutlet UIButton *btnFly;
@property (nonatomic, assign) IBOutlet UIButton *btnBack;
@property (nonatomic, assign) IBOutlet UIView *viewTopAdd;
@property (nonatomic, assign) IBOutlet UIView *viewSearch;
@property (nonatomic, assign) IBOutlet UITextField *txtEdit;
@property (nonatomic, assign) IBOutlet UITextField *txtSearch;
@property (nonatomic, assign) IBOutlet UIView *archive_alertview;
@property (nonatomic, assign) IBOutlet UILabel *lblNoResult;

@property (nonatomic) int mode;
@property (nonatomic, retain) id<FSJobSelectDelegate> jobSelectDelegate;


- (IBAction)onAdd:(id)sender;
- (IBAction)onClose:(id)sender;
- (IBAction)onSearch:(id)sender;
- (IBAction)onBtnBg:(id)sender;
- (IBAction)onBtnCancel:(id)sender;
- (IBAction)onBtnBack:(id)sender;

- (IBAction)BeginEditing:(UITextField *)sender;
- (IBAction)EndEditing:(UITextField *)sender;


@end
