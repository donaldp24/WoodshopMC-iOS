//
//  SensorReadingParser.m
//  WagnerDMiOS
//
//  Created by Igor Ishchenko on 12/20/13.
//
//

#import "SensorReadingParser.h"
#import "Global.h"


NSString * const kSensorDataUuidKey = @"uuid";
NSString * const kSensorDataRHKey = @"rh";
NSString * const kSensorDataConvRHKey = @"convrh";
NSString * const kSensorDataTemperatureKey = @"temp";
NSString * const kSensorDataConvTempKey = @"convtemp";
NSString * const kSensorDataBatteryKey = @"battery";
NSString * const kSensorDataDepthKey = @"depth";
NSString * const kSensorDataGravityKey = @"gravity";
NSString * const kSensorDataMaterialKey = @"material";
NSString * const kSensorDataMCKey = @"mc";
NSString * const kSensorDataReadingTimestampKey = @"timestamp";


@interface SensorReadingParser ()

- (float)RHFromBytes:(int)rh;
- (float)temperatureFromBytes:(int)temp;
//- (NSString*)serialNumberFromData:(NSData*)data withOffset:(NSInteger) offset;

@end

@implementation SensorReadingParser

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


#define CHANGE_ENDIAN(a) ((((a) & 0xFF00) >> 8) + (((a) & 0xFF) << 8))

- (NSDictionary*)parseData:(NSData *)manufactureData withOffset:(NSInteger)offset {

    NSLog(@"SensorReadingParser");
    
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
    
    UInt16 rh = *(UInt16*)[[manufactureData subdataWithRange:NSMakeRange(rhValueOffset, 2)] bytes];
    rh = CHANGE_ENDIAN(rh);
    UInt16 temp = *(UInt16*)[[manufactureData subdataWithRange:NSMakeRange(tempValueOffset, 2)] bytes];
    temp = CHANGE_ENDIAN(temp);
    UInt16 mc = *(UInt16*)[[manufactureData subdataWithRange:NSMakeRange(mcValueOffset, 2)] bytes];
    mc = CHANGE_ENDIAN(mc);

    
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
    
    NSLog(@"SensorReadingParser parsing result ; RH:%hu(%.2f), Temp:%hu(%.2f), BT:%hhu, D:%hhu, SG:%hhu, MT:%hhu, MC:%hu", rh, convrh, temp, convtemp, batteryLevel, depth, gravity, material, mc);
    
    // return immutable dictionary
    return [NSDictionary dictionaryWithDictionary:sensorData];
}

- (float)RHFromBytes:(int)rh {
    // There is a problem with this method and the temperature method;
    // The value calculated should be to 0.1 precision, so the calculation and return value
    // should be a floating point (float) value, and when displayed on screen the
    // value should be something like 72.4, etc...
    // as it is, since you are casting to a UInt16 value, the "tenths" place gets rounded to nearest "ones" unit
    // with no 0.1 precision (i.e. precision = 0 in your case, but should equal 1
    
    // bytes need to be swapped
    /*
    if(CFByteOrderGetCurrent() == CFByteOrderLittleEndian) {
        rh = CFSwapInt16BigToHost(rh);
    }
     */
    float convrh = (-6.0f + (125.0f * rh / 65536.0f));
    //  rh = (UInt16)roundf(-6.0f + (125.0f * (rh/256 + (rh & 0xff) * 256) / 65536.0f));
    return convrh;
}

- (float)temperatureFromBytes:(int)temp {
    float temperature = temp;
    // bytes need to be swapped
    /*
    if(CFByteOrderGetCurrent() == CFByteOrderLittleEndian) {
        temperature = CFSwapInt16BigToHost(temperature);
    }
     */
    temperature = (-46.85f + (175.72f * temperature / 65536.0f));  // celsius
    //temperature = temperature * 1.8f + 32.0f;  // convert to fahrenheit
    return temperature;
}

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
@end
