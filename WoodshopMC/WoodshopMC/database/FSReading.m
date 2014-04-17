//
//  FSReading.m
//  FloorSmart
//
//  Created by Lydia on 1/24/14.
//  Copyright (c) 2014 Tim. All rights reserved.
//

#import "FSReading.h"

@implementation FSReading

- (id)init
{
    self = [super init];
    if (self) {
        [self initMembers];
    }
    return self;
}

- (void)initMembers
{
    self.readID = 0;
    self.readLocProductID = 0;
    self.readTimestamp = [[NSDate alloc] init];
    self.readUuid = @"";
    self.readRH = 0;
    self.readConvRH = 0.0;
    self.readTemp = 0;
    self.readConvTemp = 0.0;
    self.readBattery = 0;
    self.readDepth = 0;
    self.readGravity = 0;
    self.readMaterial = 0;
    self.readMC = 0;
}

- (CGFloat)getEmcValue
{
    float T = [FSReading getFTemperature:self.readConvTemp];
    float H = self.readConvRH / 100;
    double W = 330 + 0.452 * T + 0.00415 * T * T;
    double K = 0.791 + 0.000463 * T - 0.000000844 * T * T;
    double KH = K * H;
    double K1 = 6.34 + 0.000775 * T - 0.0000935 * T * T;
    double K2 = 1.09 + 0.0284 * T - 0.0000904 * T * T;
    double M = 1800 / W * (KH / (1 - KH) + ((K1 * KH + 2 * K1 * K2 * K * K * H * H) / (1 + K1 * KH + K1 * K2 * K * K * H * H)));
    
    return M;
}

- (CGFloat)getRealMCValue
{
    if (self.readMaterial == FSMaterialModeWood)
        return (CGFloat)self.readMC / 10.f;
    else
        return (CGFloat)self.readMC;
}

- (NSString *)getDisplayRealMCValue
{
    if (self.readMaterial == FSMaterialModeWood)
        return [NSString stringWithFormat:@"%.1f", [self getRealMCValue]];
    else
        return [NSString stringWithFormat:@"%ld", (long)[self getRealMCValue]];
}

+ (NSString *) getDisplayDepth:(long)depth
{
    if (depth == 1)
        return @"1/4";
    return @"3/4";
}

+ (NSString *) getDisplayMaterial:(long)material
{
    if (material == FSMaterialModeWood)
        return @"Wood";
    else if (material == FSMaterialModeRelative)
        return @"Relative";
    return @"Concrete";
}

+ (CGFloat) getCTemperature:(CGFloat)fTemp
{
    CGFloat ctemp = (fTemp - 32) * 5 / 9.0;
    return ctemp;

}

+ (CGFloat) getFTemperature:(CGFloat)ctemp
{
    CGFloat ftemp = ctemp * 9 / 5 + 32;
    return ftemp;
}

+ (NSString *) getDisplayMC:(CGFloat)mc
{
    return [NSString stringWithFormat:@"%.1f", mc];
}


+ (CGFloat) getMCAvg:(NSMutableArray *)array
{
    CGFloat mcsum = 0;
    for (int i = 0; i < [array count]; i++) {
        FSReading *data = [array objectAtIndex:i];
        mcsum += [data getRealMCValue];

    }
    if ([array count] == 0)
        return 0.0;
    return mcsum / [array count];
}

+ (CGFloat) getMCMax:(NSMutableArray *)array
{
    CGFloat mcmax = 0;
    for (int i = 0; i < [array count]; i++) {
        FSReading *data = [array objectAtIndex:i];
        if (mcmax < [data getRealMCValue])
            mcmax = [data getRealMCValue];

    }
    return mcmax;
}

+ (CGFloat) getMCMin:(NSMutableArray *)array
{
    CGFloat mcmin = 0;
    if ([array count] == 0)
        return mcmin;
    FSReading *data1 = [array objectAtIndex:0];
    mcmin = [data1 getRealMCValue];
    
    for (int i = 0; i < [array count]; i++) {
        FSReading *data = [array objectAtIndex:i];
        if (mcmin > [data getRealMCValue])
            mcmin = [data getRealMCValue];
    }
    return mcmin;
}

+ (CGFloat) getRHAvg:(NSMutableArray *)array
{
    CGFloat rhsum = 0;
    for (int i = 0; i < [array count]; i++) {
        FSReading *data = [array objectAtIndex:i];
        rhsum += data.readConvRH;
    }
    if ([array count] == 0)
        return 0.0;
    return rhsum / [array count];
}

+ (CGFloat) getTempAvg:(NSMutableArray *)array
{
    CGFloat tempsum = 0;
    for (int i = 0; i < [array count]; i++) {
        FSReading *data = [array objectAtIndex:i];
        tempsum += data.readConvTemp;
    }
    if ([array count] == 0)
        return 0.0;
    return tempsum / [array count];
}

+ (CGFloat) getEmcAvg:(NSMutableArray *)array
{
    CGFloat emcsum = 0;
    for (int i = 0; i < [array count]; i++) {
        FSReading *data = [array objectAtIndex:i];
        emcsum += [data getEmcValue];
    }
    if ([array count] == 0)
        return 0.0;
    return emcsum / [array count];
}

@end
