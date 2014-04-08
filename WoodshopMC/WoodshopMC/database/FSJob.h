//
//  FSJob.h
//  FloorSmart
//
//  Created by Lydia on 12/29/13.
//  Copyright (c) 2013 Tim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSJob : NSObject

@property (nonatomic, readwrite) long jobID;
@property (nonatomic, retain) NSString *jobName;
@property (nonatomic) long jobArchived;

- (void)clear;

@end
