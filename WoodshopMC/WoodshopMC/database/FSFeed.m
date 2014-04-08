//
//  FSFeed.m
//  FloorSmart
//
//  Created by Lydia on 1/3/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import "FSFeed.h"

@implementation FSFeed
@synthesize feedID = _feedID;
@synthesize feedJobID = _feedJobID;
@synthesize feedLocID = _feedLocID;
@synthesize feedProcID = _feedProcID;
@synthesize feedCoverage = _feedCoverage;
@synthesize feedmaterial = _feedmaterial;
@synthesize feedMode = _feedMode;
@synthesize feedsg = _feedsg;

- (id)init
{
    self = [super init];
    if (self) {
        _feedID = @"-1";
        _feedJobID = -1;
        _feedLocID = -1;
        _feedProcID = -1;
        _feedCoverage = @"";
        _feedMode = 0;
        _feedmaterial = 0;
        _feedsg = 0;
    }
    return self;
}

@end
