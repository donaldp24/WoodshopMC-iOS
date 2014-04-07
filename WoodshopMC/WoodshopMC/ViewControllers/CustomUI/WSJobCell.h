//
//  FSJobCell.h
//  FloorSmart
//
//  Created by Lydia on 12/24/13.
//  Copyright (c) 2013 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSJob.h"

@protocol FSJobCellDelegate;


@interface FSJobCell : UITableViewCell <UITextFieldDelegate>

@property (nonatomic, assign) IBOutlet UILabel *lblJobName;
@property (nonatomic, assign) IBOutlet UITextField *txtJobName;
@property (nonatomic, assign) IBOutlet UIView *viewEdit;
@property (nonatomic, assign) IBOutlet UIView *viewEditing;
@property (nonatomic, assign) IBOutlet UIButton *btnDetail;
@property (nonatomic, assign) IBOutlet UIButton *btnArchive;

@property (nonatomic, strong) FSJob *curJob;

@property (nonatomic, strong) id<FSJobCellDelegate> delegate;

+ (FSJobCell *)sharedCell;

- (IBAction)onEdit:(id)sender;
- (IBAction)onArchive:(id)sender;
- (IBAction)onOK:(id)sender;
- (IBAction)onCancel:(id)sender;
- (IBAction)onDetail:(id)sender;

@end

@protocol FSJobCellDelegate <NSObject>

- (BOOL) didOK:(FSJobCell *)cell;

@end