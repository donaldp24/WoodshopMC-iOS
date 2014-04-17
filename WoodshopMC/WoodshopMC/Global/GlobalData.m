//
//  GlobalData.m
//  Kitchen Rush
//
//  Created by Lydia on 12/23/13
//  Copyright (c) 2012 Jonas. All rights reserved.
//

#import "GlobalData.h"
#import "Global.h"

#define KEY_ISSAVED     @"isSaved"
#define KEY_SELECTEDJOBID   @"selectedJobID"
#define KEY_SELECTEDLOCID   @"selectedLocID"
#define KEY_SELECTEDLOCPRODUCTID    @"selectedLocProductID"

GlobalData *_globalData = nil;

@implementation GlobalData
@synthesize settingArea = _settingArea;
@synthesize settingDateFormat = _settingDateFormat;
@synthesize settingTemp = _settingTemp;

+(id) sharedData
{
	@synchronized(self)
    {
        if (_globalData == nil)
        {
            _globalData = [[self alloc] init]; // assignment not done here
        }		
	}
	
	return _globalData;
}

//==================================================================================

+(id) allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if (_globalData == nil)
        {
			_globalData = [super allocWithZone:zone];
			
			return _globalData;  
        }
    }
	
    return nil; //on subsequent allocation attempts return nil	
}

//==================================================================================

-(id) init
{
	if ((self = [super init])) {
		// @todo
	}
	
	return self;
}

//==================================================================================

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

-(void) loadInitData
{
    NSUserDefaults *config = [NSUserDefaults standardUserDefaults];
    _settingTemp = [self readBoolEntry:config key:@"temperature" defaults:YES];
    _settingArea = [self readBoolEntry:config key:@"Area" defaults:YES];
    _settingDateFormat = [self readEntry:config key:@"dateformat" defaults:US_DATEFORMAT];
    
    _isSaved = [self readBoolEntry:config key:KEY_ISSAVED defaults:NO];
    _selectedJobID = [self readIntEntry:config key:KEY_SELECTEDJOBID defaults:0];
    _selectedLocID = [self readIntEntry:config key:KEY_SELECTEDLOCID defaults:0];
    _selectedLocProductID = [self readIntEntry:config key:KEY_SELECTEDLOCPRODUCTID defaults:0];
    
#ifdef TESTFLIGHT_ENABLED
    [TestFlight passCheckpoint:@"loadInitData"];
#endif
    
}

- (void)setSettingTemp:(BOOL)settingTemp
{
    _settingTemp = settingTemp;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:settingTemp forKey:@"temperature"];
    [defaults synchronize];
}

- (void)setSettingArea:(BOOL)settingArea
{
    _settingArea = settingArea;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:settingArea forKey:@"Area"];
    [defaults synchronize];
}

- (void)setSettingDateFormat:(NSString *)settingDateFormat
{
    _settingDateFormat = settingDateFormat;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:settingDateFormat forKey:@"dateformat"];
    [defaults synchronize];
}

- (void)saveSelection:(long)selectedJobID selectedLocID:(long)selectedLocID selectedLocProductID:(long)selectedLocProductID
{
    
    _selectedJobID = selectedJobID;
    _selectedLocID = selectedLocID;
    _selectedLocProductID = selectedLocProductID;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setInteger:selectedJobID forKey:KEY_SELECTEDJOBID];
    [defaults setInteger:selectedLocID forKey:KEY_SELECTEDLOCID];
    [defaults setInteger:selectedLocProductID forKey:KEY_SELECTEDLOCPRODUCTID];
    [defaults synchronize];
}

- (void)startRecording
{
    _isSaved = YES;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:_isSaved forKey:KEY_ISSAVED];
    [defaults synchronize];
}

- (void)pauseRecording
{
    _isSaved = NO;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:_isSaved forKey:KEY_ISSAVED];
    [defaults synchronize];
}

- (void)resetSavedData
{
    _isSaved = NO;
    _selectedJobID = 0;
    _selectedLocID = 0;
    _selectedLocProductID = 0;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:_isSaved forKey:KEY_ISSAVED];
    [defaults setInteger:_selectedJobID forKey:KEY_SELECTEDJOBID];
    [defaults setInteger:_selectedLocID forKey:KEY_SELECTEDLOCID];
    [defaults setInteger:_selectedLocProductID forKey:KEY_SELECTEDLOCPRODUCTID];
    [defaults synchronize];
}

#pragma mark - Config Manager -
-(BOOL) readBoolEntry:(NSUserDefaults *)config key:(NSString *) key defaults:(BOOL)defaults
{
    if (key == nil)
        return defaults;
    
    NSString *str = [config objectForKey:key];
    
    if (str == nil) {
        return defaults;
    } else {
        return str.boolValue;
    }
    
    return defaults;
}

-(float) readFloatEntry:(NSUserDefaults *)config key:(NSString *) key defaults:(float)defaults
{
    if (key == nil)
        return defaults;
    
    NSString *str = [config objectForKey:key];
    
    if (str == nil) {
        return defaults;
    } else {
        return str.floatValue;
    }
    
    return defaults;
}

-(int) readIntEntry:(NSUserDefaults *)config key:(NSString *) key defaults:(int)defaults
{
    if (key == nil)
        return defaults;
    
    NSString *str = [config objectForKey:key];
    
    if (str == nil) {
        return defaults;
    } else {
        return str.intValue;
    }
    
    return defaults;
}

-(double) readDoubleEntry:(NSUserDefaults *)config key:(NSString *) key defaults:(double)defaults
{
    if (key == nil)
        return defaults;
    
    NSString *str = [config objectForKey:key];
    
    if (str == nil) {
        return defaults;
    } else {
        return str.doubleValue;
    }
    
    return defaults;
}

-(NSString *) readEntry:(NSUserDefaults *)config key:(NSString *) key defaults:(NSString *)defaults
{
    if (key == nil)
        return defaults;
    
    NSString *str = [config objectForKey:key];
    
    if (str == nil) {
        return defaults;
    } else {
        return str;
    }
    
    return defaults;
}

- (NSString *)convertDateToSettingsFormat:(NSString *)originDate
{
    NSDate *tempDate = [CommonMethods str2date:originDate withFormat:DATE_FORMAT];
    return [CommonMethods date2str:tempDate withFormat:_settingDateFormat];
}

- (NSString *)convertDateToString:(NSDate *)aDate format:(NSString *)format
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    if (!format)
        [formatter setDateFormat:@"MMM dd, yyyy"];
    else
        [formatter setDateFormat:format];
    
    return [formatter stringFromDate:aDate];
}

- (NSString *)getCurrentDate:(NSString *)format
{
    NSDate* date = [NSDate date];
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    if (!format)
        [formatter setDateFormat:@"MMM dd, yyyy"];
    else
        [formatter setDateFormat:format];
    
    return [formatter stringFromDate:date];
}

- (NSString *)getCurrentDateAndTime:(NSString *)format
{
    NSDate* date = [NSDate date];
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    if (!format)
        [formatter setDateFormat:@"MMM dd, yyyy"];
    else
        [formatter setDateFormat:format];
    
    NSString* str = [formatter stringFromDate:date];
    
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    NSString *currentTime = [dateFormatter stringFromDate:today];
    
    NSString *currentDateAndTime = [NSString stringWithFormat:@"%@ %@",str,currentTime];
    return currentDateAndTime;
}


- (NSString *)getTempUnit
{
    if (self.settingTemp == YES)
        return @"F";
    return @"C";
}

+ (CGFloat)sqft2sqm:(CGFloat)sqft
{
    CGFloat sqm = 0.09290304 * sqft;
    return sqm;
}

+ (CGFloat)sqm2sqft:(CGFloat)sqm
{
    CGFloat sqft = sqm / 0.09290304;
    return sqft;
}



@end
