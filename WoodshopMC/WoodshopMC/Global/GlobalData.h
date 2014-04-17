//
//  GlobalData.h
//  Kitchen Rush
//
//  Created by Lydia on 12/23/13
//  Copyright (c) 2012 Jonas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonMethods.h"

@interface GlobalData : NSObject

+ (id) sharedData;

@property (nonatomic) BOOL settingTemp;
@property (nonatomic) BOOL settingArea;
@property (nonatomic, strong) NSString *settingDateFormat;

@property (nonatomic) BOOL isSaved;
@property (nonatomic) long selectedJobID;
@property (nonatomic) long selectedLocID;
@property (nonatomic) long selectedLocProductID;

- (void)loadInitData;

-(BOOL) readBoolEntry:(NSUserDefaults *)config key:(NSString *) key defaults:(BOOL)defaults;
-(float) readFloatEntry:(NSUserDefaults *)config key:(NSString *) key defaults:(float)defaults;
-(int) readIntEntry:(NSUserDefaults *)config key:(NSString *) key defaults:(int)defaults;
-(double) readDoubleEntry:(NSUserDefaults *)config key:(NSString *) key defaults:(double)defaults;
-(NSString *) readEntry:(NSUserDefaults *)config key:(NSString *) key defaults:(NSString *)defaults;

- (NSString *)convertDateToSettingsFormat:(NSString *)originDate;
- (NSString *)convertDateToString:(NSDate *)aDate format:(NSString *)format;
- (NSString *)getCurrentDate:(NSString *)format;
- (NSString *)getCurrentDateAndTime:(NSString *)format;

- (void)saveSelection:(long)selectedJobID selectedLocID:(long)selectedLocID selectedLocProductID:(long)selectedLocProductID;
- (void)resetSavedData;
- (void)startRecording;
- (void)pauseRecording;

- (NSString *)getTempUnit;
+ (CGFloat) sqft2sqm:(CGFloat) sqft;
+ (CGFloat) sqm2sqft:(CGFloat) sqm;



@end
