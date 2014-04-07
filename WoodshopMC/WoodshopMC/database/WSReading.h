//
//  FSReading.h
//  FloorSmart
//
//  Created by Lydia on 1/24/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSReading : NSObject

@property (nonatomic) long readID;
@property (nonatomic) long readLocProductID;
@property (nonatomic, retain) NSDate *readTimestamp;
@property (nonatomic, retain) NSString *readUuid;
@property (nonatomic) long readRH; //
@property (nonatomic) double readConvRH; //0-100
@property (nonatomic) long readTemp;
@property (nonatomic) double readConvTemp; //0-130
@property (nonatomic) long readBattery;
@property (nonatomic) long readDepth;
@property (nonatomic) long readGravity;
@property (nonatomic) long readMaterial;
@property (nonatomic) long readMC; //0-1000

- (CGFloat) getEmcValue;

+ (NSString *) getDisplayDepth:(long)depth;
+ (NSString *) getDisplayMaterial:(long)material;
+ (CGFloat) getCTemperature:(CGFloat)ftemp;
+ (CGFloat) getFTemperature:(CGFloat)ctemp;

+ (CGFloat) getMCAvg:(NSMutableArray *)array;
+ (CGFloat) getMCMax:(NSMutableArray *)array;
+ (CGFloat) getMCMin:(NSMutableArray *)array;
+ (CGFloat) getRHAvg:(NSMutableArray *)array;
+ (CGFloat) getTempAvg:(NSMutableArray *)array;
+ (CGFloat) getEmcAvg:(NSMutableArray *)array;

@end

