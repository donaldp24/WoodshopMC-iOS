//
//  Global.h
//  Kitchen Rush
//
//  Created by Lydia on 12/23/13
//  Copyright (c) 2012 Jonas. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>

#import "GlobalData.h"

#pragma mark - Define MACRO -

#pragma mark - Define Variable -
extern GlobalData *_globalData;

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

#define DATABASE_FILENAME   "WoodshopMC.db"
#define DATE_FORMAT @"yyyy-MM-dd"// HH-mm"
#define US_DATEFORMAT @"MM/dd/yyyy"
#define EU_DATEFORMAT @"dd.MM.yyyy"
#define DATETIME_FORMAT @"yyyy-MM-dd HH:mm:ss"

#define KEYBOARD_HEIGHT     240