//
//  FSReportCell.h
//  FloorSmart
//
//  Created by iOS Developer on 2/28/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataManager.h"

@interface FSReportCell : UITableViewCell

@property (nonatomic, assign) IBOutlet UILabel *lblReadingDate;
@property (nonatomic, assign) IBOutlet UIButton *btnDisclosure;

@property (nonatomic, retain) FSLocation *loc;
@property (nonatomic, retain) FSLocProduct *locProduct;
@property (nonatomic, strong) NSDate *curDate;
@property (nonatomic) BOOL isOpened;

@property (nonatomic, strong) id delegate;

+ (FSReportCell *)sharedCell;

- (IBAction)onDisclosre:(id)sender;

@end
