//
//  FSFeed.h
//  FloorSmart
//
//  Created by Lydia on 1/3/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSFeed : NSObject

@property (nonatomic, retain) NSString *feedID;
@property (nonatomic) NSInteger feedJobID;
@property (nonatomic) NSInteger feedLocID;
@property (nonatomic) NSInteger feedProcID;
@property (nonatomic, retain) NSString *feedCoverage;
@property (nonatomic) NSInteger feedMode;
@property (nonatomic) NSInteger feedmaterial;
@property (nonatomic) NSInteger feedsg;

@end
