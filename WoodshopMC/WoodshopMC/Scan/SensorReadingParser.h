//
//  SensorReadingParser.h
//  WagnerDMiOS
//
//  Created by Igor Ishchenko on 12/20/13.
//
//

#import <Foundation/Foundation.h>


extern NSString * const kSensorDataUuidKey;
extern NSString * const kSensorDataRHKey;
extern NSString * const kSensorDataConvRHKey;
extern NSString * const kSensorDataTemperatureKey;
extern NSString * const kSensorDataConvTempKey;
extern NSString * const kSensorDataBatteryKey;
extern NSString * const kSensorDataDepthKey;
extern NSString * const kSensorDataGravityKey;
extern NSString * const kSensorDataMaterialKey;
extern NSString * const kSensorDataMCKey;
extern NSString * const kSensorDataReadingTimestampKey;


@interface SensorReadingParser : NSObject {
    int kUuidOffset;
    int kRHValueOffset;
    int kTempValueOffset;
    int kBatteryLevelValueOffset;
    int kDepthModeValueOffset;
    int kGravityValueOffset;
    int kMaterialValueOffset;
    int kMCValueOffset;
}

- (NSDictionary*)parseData:(NSData*)manufactureData withOffset:(NSInteger)offset;

@end
