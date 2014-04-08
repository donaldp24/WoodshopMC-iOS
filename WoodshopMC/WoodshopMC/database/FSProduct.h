//
//  FSProduct.h
//  FloorSmart
//
//  Created by Lydia on 12/29/13.
//  Copyright (c) 2013 Tim. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum : long
{
    FSProductTypeFinished,
    FSProductTypeSubfloor
}FSProductType;


@interface FSProduct : NSObject

@property (nonatomic) long productID;
@property (nonatomic, retain) NSString *productName;
@property (nonatomic) long productType;
@property (nonatomic) long productDeleted;

- (void)clear;

+ (NSString *)getDisplayProductType:(long)productType;

@end


@interface FSLocProduct : NSObject

@property (nonatomic) long locProductID;
@property (nonatomic) long locProductLocID;
@property (nonatomic, retain) NSString *locProductName;
@property (nonatomic) long locProductType;
@property (nonatomic) double locProductCoverage;

@end