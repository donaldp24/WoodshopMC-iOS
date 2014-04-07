//
//  DataManager.h
//  iHelp
//
//  Created by Lydia on 1/14/14.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSJob.h"
#import "FSLocation.h"
#import "FSProduct.h"
#import "FSLocation.h"
#import "FSFeed.h"
#import "FSReading.h"
#define FMD_DEFAULT_LOCATIONNAME    @"Default"
#define FMD_DEFAULT_PRODUCTNAME     @"Default"

@class FMDatabase;

@interface DataManager : NSObject {

    FMDatabase *_database;
    NSString *databasePath;
}

+ (id)sharedInstance;

// job
- (NSMutableArray *)getAllJobs;
- (NSMutableArray *)getJobs:(long)archiveFlag searchField:(NSString *)searchField;
- (BOOL)isExistSameJob:(NSString *)jobName;
- (FSJob *)getJobFromID:(long)jobID;
- (int)addJobToDatabase:(FSJob *)job;
- (void)updateJobToDatabase:(FSJob *)job;
- (void)deleteJobFromDatabase:(FSJob *)job;

// location
- (NSMutableArray *)getLocations:(long)jobID;
- (NSMutableArray *)getLocations:(long)jobID containDefault:(BOOL) isContain;
- (BOOL)isExistSameLocation:(long)jobID locName:(NSString *)locName;
- (FSLocation *)getLocation:(long)jobID locName:(NSString *)locName;
- (FSLocation *)getLocationFromID:(long)locID;
- (int)addLocationToDatabase:(FSLocation *)loc;
- (void)updateLocToDatabase:(FSLocation *)loc;
- (void)deleteLocFromDatabase:(FSLocation *)loc;
- (FSLocation *)getDefaultLocationOfJob:(long)jobID;
- (NSMutableArray *)getAllDistinctLocations;

// product
- (NSMutableArray *)getAllProducts;
- (NSMutableArray *)getProducts:(NSString *)searchField;
- (BOOL)isExistSameProduct:(NSString *)productName productType:(long)productType;
//- (NSMutableArray *)getProducts:(NSMutableArray *)arrFeeds;
//- (NSMutableArray *)getFeedProducts:(NSString *)jobID loc:(NSInteger)locID;
- (FSProduct *)getProductFromID:(long)procID;
- (int)addProductToDatabase:(FSProduct *)product;
- (void)updateProductToDatabase:(FSProduct *)product;
- (void)deleteProductFromDatabase:(FSProduct *)product;
- (FSProduct *)getProductWithLocProduct:(FSLocProduct *)locProduct;

// products for specific location
- (NSMutableArray *)getLocProducts:(FSLocation *)loc searchField:(NSString *)searchField;
- (NSMutableArray *)getLocProducts:(FSLocation *)loc searchField:(NSString *)searchField containDefault:(BOOL) isContain;
- (BOOL)isExistSameLocProduct:(long)locID locProductName:(NSString *)locProductName locProductType:(long)locProductType;
- (FSLocProduct *)getLocProductWithID:(long)locProductID;
- (FSLocProduct *)getDefaultLocProductOfLocation:(FSLocation *)loc;
- (FSLocProduct *)getLocProductWithProduct:(FSProduct *)product locID:(long)locID;
- (int)addLocProductToDatabaseWithProduct:(FSProduct *)product locID:(long)locID coverage:(double)coverage;
- (int)addLocProductToDatabase:(FSLocProduct *)locProduct;
- (BOOL)updateLocProductToDatabase:(FSLocProduct *)locProduct;
- (BOOL)deleteLocProductFromDatabase:(FSLocProduct *)locProduct;


- (NSMutableArray *)getCurReadings:(long)locProductID;
- (NSMutableArray *)getAllReadingDates:(long)locProductID;
- (NSMutableArray *)getReadings:(long)locProductID withDate:(NSDate *)date;
- (NSInteger)getReadingsCount:(long)locProductID;
- (int)addReadingToDatabase:(FSReading *)reading;
- (BOOL)updateReadingToDatabase:(FSReading *)reading;
- (BOOL)deleteReadingFromDatabase:(FSReading *)reading;

@end
