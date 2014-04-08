//
//  FSMainViewController.h
//  FloorSmart
//
//  Created by Lydia on 12/23/13.
//  Copyright (c) 2013 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScanManager.h"
#import "ScanManagerDelegate.h"

@interface FSMainViewController : UITabBarController <ScanManagerDelegate>

@property (nonatomic, retain) ScanManager *scanManager;

@property (nonatomic, assign) IBOutlet UIView *viewForTabbar;
@property (nonatomic, assign) IBOutlet UIButton *btnRecord;
@property (nonatomic, assign) IBOutlet UIButton *btnHome;
@property (nonatomic, assign) IBOutlet UIButton *btnReports;

+ (FSMainViewController *) sharedController;


- (void)selectItem:(UIButton *)btnItem;

- (IBAction)onTabItem:(id)sender;

@end
