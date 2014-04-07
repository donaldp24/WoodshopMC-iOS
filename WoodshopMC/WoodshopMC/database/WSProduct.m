//
//  FSProduct.m
//  FloorSmart
//
//  Created by Lydia on 12/29/13.
//  Copyright (c) 2013 Tim. All rights reserved.
//

#import "FSProduct.h"

@implementation FSProduct
@synthesize productID = _productID;
@synthesize productName = _productName;
@synthesize productType = _productType;
@synthesize productDeleted = _productDeleted;

- (id)init
{
    self = [super init];
    if (self) {
        _productID = 0;
        _productName = @"";
        _productType = FSProductTypeFinished;
        _productDeleted = 0;
    }
    return self;
}


- (void)clear
{
    _productID = 0;
    _productName = @"";
    _productType = FSProductTypeFinished;
    _productDeleted = 0;
}

+ (NSString *)getDisplayProductType:(long)productType
{
    return (productType == FSProductTypeFinished) ? @"Finished" : @"Subfloor";
}

@end

@implementation FSLocProduct
- (id) init
{
    self = [super init];
    if (self) {
        _locProductID = 0;
        _locProductLocID = 0;
        _locProductName = @"";
        _locProductType = FSProductTypeFinished;
        _locProductCoverage = 0.0;
    }
    return self;
}

@end