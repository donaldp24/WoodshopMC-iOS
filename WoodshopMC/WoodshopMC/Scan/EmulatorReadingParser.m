//
//  SensorReadingParser.m
//  WagnerDMiOS
//
//  Created by Igor Ishchenko on 12/20/13.
//
//

#import "EmulatorReadingParser.h"
#import "SensorReadingParser.h"
#import "Global.h"

//NSString * const kSensorDataBatteryKey = @"battery";
//NSString * const kSensorDataRHKey = @"rh";
//NSString * const kSensorDataRHAmbientKey = @"rhAmbient";
//NSString * const kSensorDataTemperatureKey = @"temp";
//NSString * const kSensorDataTemperatureAmbientKey = @"tempAmbient";
//NSString * const kSensorDataReadingTimestampKey = @"readingTimestamp";
//NSString * const kSensorDataSerialNumberKey = @"serial";


@interface EmulatorReadingParser ()

- (float)RHFromBytes:(UInt16)rh;
- (float)temperatureFromBytes:(UInt16)temp;
//- (NSString*)serialNumberFromData:(NSData*)data withOffset:(NSInteger) offset;
- (NSString*)uuidFromData:(NSData*)data withOffset:(NSInteger) offset;

@end

@implementation EmulatorReadingParser

- (id)init {
    self = [super init];
    if (self) {
        [self initOffsets];
    }
    return self;
}

- (void)initOffsets {
    kUuidOffset = 0;
    kRHValueOffset = 4;
    kTempValueOffset = 6;
    kBatteryLevelValueOffset = 8;
    kDepthModeValueOffset = 9;
    kGravityValueOffset = 10;
    kMaterialValueOffset = 11;
    kMCValueOffset = 12;
}

#define EMULATOR_IS_BIGENDIAN
#define CHANGE_ENDIAN(a) ((((a) & 0xFF00) >> 8) + (((a) & 0xFF) << 8))

- (NSDictionary*)parseData:(NSData *)manufactureData withOffset:(NSInteger)offset {

    NSLog(@"EmulatorReadingParser");
    
    int rhValueOffset = kRHValueOffset + offset;
    int tempValueOffset = kTempValueOffset + offset;
    int batteryLevelValueOffset = kBatteryLevelValueOffset + offset;
    int depthModeValueOffset = kDepthModeValueOffset + offset;
    int gravityValueOffset = kGravityValueOffset + offset;
    int materialValueOffset = kMaterialValueOffset + offset;
    int mcValueOffset = kMCValueOffset + offset;
    
    NSMutableDictionary *sensorData = [NSMutableDictionary dictionary];
    
    //NSString* serialNumberString = [self serialNumberFromData:manufactureData withOffset:offset];
    
    NSString *uuidString = [self uuidFromData:manufactureData withOffset:offset];
    
#ifdef EMULATOR_IS_BIGENDIAN
    UInt16 rh = *(UInt16*)[[manufactureData subdataWithRange:NSMakeRange(rhValueOffset, 2)] bytes];
    rh = CHANGE_ENDIAN(rh);
    UInt16 temp = *(UInt16*)[[manufactureData subdataWithRange:NSMakeRange(tempValueOffset, 2)] bytes];
    temp = CHANGE_ENDIAN(temp);
    UInt16 mc = *(UInt16*)[[manufactureData subdataWithRange:NSMakeRange(mcValueOffset, 2)] bytes];
    mc = CHANGE_ENDIAN(mc);
#else
    UInt16 rh = *(UInt16*)[[manufactureData subdataWithRange:NSMakeRange(rhValueOffset, 2)] bytes];
    UInt16 temp = *(UInt16*)[[manufactureData subdataWithRange:NSMakeRange(tempValueOffset, 2)] bytes];
    UInt16 mc = *(UInt16*)[[manufactureData subdataWithRange:NSMakeRange(mcValueOffset, 2)] bytes];
#endif

    
    UInt8 batteryLevel = *(UInt8*)[[manufactureData subdataWithRange:NSMakeRange(batteryLevelValueOffset, 1)] bytes];
    UInt8 depth = *(UInt8*)[[manufactureData subdataWithRange:NSMakeRange(depthModeValueOffset, 1)] bytes];
    UInt8 gravity = *(UInt8*)[[manufactureData subdataWithRange:NSMakeRange(gravityValueOffset, 1)] bytes];
    UInt8 material = *(UInt8*)[[manufactureData subdataWithRange:NSMakeRange(materialValueOffset, 1)] bytes];
    
    NSDateFormatter * dFormatter = [[NSDateFormatter alloc] init];
    [dFormatter setDateFormat:DATETIME_FORMAT];
    NSString * readingTimeStamp = [dFormatter stringFromDate:[NSDate date]];
    
    float convrh = [self RHFromBytes:rh];
    float convtemp = [self temperatureFromBytes:temp];
    
    [sensorData setObject:readingTimeStamp forKey:kSensorDataReadingTimestampKey];
    [sensorData setObject:uuidString forKey:kSensorDataUuidKey];
    [sensorData setObject:[NSNumber numberWithInt:rh] forKey:kSensorDataRHKey];
    [sensorData setObject:[NSNumber numberWithFloat:convrh] forKey:kSensorDataConvRHKey];
    [sensorData setObject:[NSNumber numberWithInt:temp] forKey:kSensorDataTemperatureKey];
    [sensorData setObject:[NSNumber numberWithFloat:convtemp] forKey:kSensorDataConvTempKey];
    [sensorData setObject:[NSNumber numberWithInt:batteryLevel] forKey:kSensorDataBatteryKey];
    [sensorData setObject:[NSNumber numberWithInt:depth] forKey:kSensorDataDepthKey];
    [sensorData setObject:[NSNumber numberWithInt:gravity] forKey:kSensorDataGravityKey];
    [sensorData setObject:[NSNumber numberWithInt:material] forKey:kSensorDataMaterialKey];
    [sensorData setObject:[NSNumber numberWithInt:mc] forKey:kSensorDataMCKey];
    
    // return immutable dictionary
    return [NSDictionary dictionaryWithDictionary:sensorData];
}

- (float)RHFromBytes:(UInt16)rh {
    float convrh = (-6.0f + (125.0f * rh/65536.0f));
    return convrh;
}


- (float)temperatureFromBytes:(UInt16)temp {
    
    float convtemperature = (-46.85f + (175.72f * temp /65536.0f));
    return convtemperature;
}
/*
- (NSString*)serialNumberFromData:(NSData*)data withOffset:(NSInteger) offset {

    NSMutableString* serialNumberString = [NSMutableString string];

    int serialNumberValueOffset = kSerialNumberValueOffset + offset;

    for(int i=0;i<3;++i)
    {
        UInt16 temp;
        [data getBytes:&temp range:NSMakeRange((i*2)+serialNumberValueOffset, 2)];
        [serialNumberString appendString:[NSString stringWithFormat:@"%04X",temp]];
    }
    // return immutable string
    return [NSString stringWithString:serialNumberString];
}
*/
- (NSString*)uuidFromData:(NSData *)data withOffset:(NSInteger)offset {
    
    NSMutableString* uuidString = [NSMutableString string];
    
    int uuidOffset = kUuidOffset + offset;
    
    for(int i=0;i<4;++i)
    {
        UInt8 temp;
        [data getBytes:&temp range:NSMakeRange((i*1)+uuidOffset, 1)];
        [uuidString appendString:[NSString stringWithFormat:@"%02X",temp]];
    }
    // return immutable string
    return [NSString stringWithString:uuidString];
}


@end
