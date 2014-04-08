//
//  FSSettingViewController.h
//  FloorSmart
//
//  Created by Lydia on 12/23/13.
//  Copyright (c) 2013 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSSettingViewController : UIViewController

@property (nonatomic, assign) IBOutlet UIButton *btntempF;
@property (nonatomic, assign) IBOutlet UIButton *btntempC;
@property (nonatomic, assign) IBOutlet UIButton *btnareaFT;
@property (nonatomic, assign) IBOutlet UIButton *btnareaM;
@property (nonatomic, assign) IBOutlet UIButton *btndateUS;
@property (nonatomic, assign) IBOutlet UIButton *btndateEU;
@property (nonatomic, assign) IBOutlet UIView *viewUS;
@property (nonatomic, assign) IBOutlet UILabel *lblUS;
@property (nonatomic, assign) IBOutlet UIView *viewEuro;
@property (nonatomic, assign) IBOutlet UILabel *lblEuro;


- (IBAction)onTempF:(id)sender;
- (IBAction)onTempC:(id)sender;
- (IBAction)onAreaFT:(id)sender;
- (IBAction)onAreaM:(id)sender;
- (IBAction)onDateUS:(id)sender;
- (IBAction)onDateEU:(id)sender;


@end
