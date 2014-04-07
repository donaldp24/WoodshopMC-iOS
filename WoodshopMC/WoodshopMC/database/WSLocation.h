//
//  FSLocation.h
//  FloorSmart
//
//  Created by Lydia on 12/29/13.
//  Copyright (c) 2013 Tim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSLocation : NSObject

@property (nonatomic, readwrite) long locID;
@property (nonatomic, readwrite) long locJobID;
@property (nonatomic, retain) NSString *locName;

@end
