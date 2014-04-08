//
//  FSJob.m
//  FloorSmart
//
//  Created by Lydia on 12/29/13.
//  Copyright (c) 2013 Tim. All rights reserved.
//

#import "FSJob.h"

@implementation FSJob
@synthesize jobID = _jobID;
@synthesize jobName = _jobName;
@synthesize jobArchived = _jobArchived;

- (id)init
{
    self = [super init];
    if (self) {
        _jobID = 0;
        _jobName = @"";
        _jobArchived = 0;
    }
    return self;
}

- (void)clear
{
    _jobID = 0;
    _jobName = @"";
    _jobArchived = 0;
}

@end
