//
//  FSMeasureCell.h
//  FloorSmart
//
//  Created by Lydia on 1/6/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSReading.h"

@interface FSMeasureCell : UITableViewCell

@property (nonatomic, assign) IBOutlet UILabel *lblTime;
@property (nonatomic, assign) IBOutlet UILabel *lblMC;
@property (nonatomic, assign) IBOutlet UILabel *lblEMC;
@property (nonatomic, assign) IBOutlet UILabel *lblRH;
@property (nonatomic, assign) IBOutlet UILabel *lblTemperature;
@property (nonatomic, assign) IBOutlet UIButton *btnDel;

@property (nonatomic, strong) id delegate;
@property (nonatomic, strong) FSReading *curReading;

+ (FSMeasureCell *)sharedCell;

- (IBAction)onDel:(id)sender;

@end
