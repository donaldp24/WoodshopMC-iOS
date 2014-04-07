//
//  FSLocSelCell.h
//  FloorSmart
//
//  Created by Donald Pae on 3/11/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XIBTableViewCell.h"


@protocol FSLocSelCellDelegate;

@interface FSLocSelCell : XIBTableViewCell <UITextFieldDelegate>

@property (nonatomic, retain) id <FSLocSelCellDelegate> delegate;
@property (nonatomic, retain) id locData;


@property (nonatomic, assign) IBOutlet UILabel *lblName;
- (IBAction)onBtnAdd:(id)sender;

- (void)setLocData:(id)data;

@end

@protocol FSLocSelCellDelegate <NSObject>

@optional

- (void)onAddSelLoc:(id)sender;
- (NSString *) getLocName:(id)sender;
- (BOOL)onEditFinishedOk:(id)sender;

@end
