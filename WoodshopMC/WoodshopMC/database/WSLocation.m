//
//  FSLocation.m
//  FloorSmart
//
//  Created by Lydia on 12/29/13.
//  Copyright (c) 2013 Tim. All rights reserved.
//

#import "FSLocation.h"

@implementation FSLocation
@synthesize locID = _locID;
@synthesize locName = _locName;

- (id)init
{
    self = [super init];
    if (self) {
        _locID = @"-1";
        _locName = @"";
    }
    return self;
}

@end
