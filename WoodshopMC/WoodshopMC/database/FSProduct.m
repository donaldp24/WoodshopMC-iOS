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

- (id)init
{
    self = [super init];
    if (self) {
        _productID = 0;
        _productName = @"";
    }
    return self;
}


- (void)clear
{
    _productID = 0;
    _productName = @"";
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
        _locProductCoverage = 0.0;
    }
    return self;
}

@end