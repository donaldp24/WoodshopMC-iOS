//
//  ScanManager.m
//
//  Created by Igor Ishchenko on 12/20/13.
//  Copyright (c) 2013 Igor Ishchenko All rights reserved.
//

#import "ScanManager.h"
#import "GlobalData.h"

static const int kPackageID = 0xDEB93391;

@interface ScanManager () {
    NSDictionary *beforeData;
    NSTimeInterval mLastTakingTime;
}

@property (nonatomic, retain) CBCentralManager *bluetoothCentralManager;

- (void)showAlertWithTitle:(NSString*)title description:(NSString*)description;

@end

@implementation ScanManager

- (void)dealloc {
    [_bluetoothCentralManager setDelegate:nil];
}


- (id)init {
    return [self initWithDelegate:nil];
}

- (id)initWithDelegate:(id<ScanManagerDelegate>)delegate {
    if (self = [super init]) {
        _delegate = delegate;
        _bluetoothCentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        
        NSLog(@"bluetooth - centeral manager inited!");
        
        beforeData = nil;
        mLastTakingTime = -1;
        
    }
    
    return self;
}

- (void)startScan {
    
    NSMutableArray *uuids = [[NSMutableArray alloc] initWithObjects:[CBUUID UUIDWithString:@"9133b9de-5f86-6938-6401-320201040000"], nil];
    [[self bluetoothCentralManager] scanForPeripheralsWithServices:nil
                                                           options:@{CBCentralManagerScanOptionAllowDuplicatesKey: @YES}];
    /*
     [[self bluetoothCentralManager] scanForPeripheralsWithServices:nil
     options:nil];
     */
    
    if ([[self delegate] respondsToSelector:@selector(scanManagerDidStartScanning:)]) {
        [[self delegate] scanManagerDidStartScanning:self];
        NSLog(@"Started scan");
    }
    
}

- (void)stopScan {
    if (self.bluetoothCentralManager == nil)
    {
        NSLog(@"bluetoothCentralManager == nil");
        return;
    }
    [self.bluetoothCentralManager stopScan];
    NSLog(@"Stopped scan");
}

- (void)restartScan {
    [self stopScan];
    [self startScan];
    NSLog(@"Restarted scan");
    
}

#pragma mark - Bluetooth

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
    NSString *stateDescription;
    GlobalData *globalData = [GlobalData sharedData];
    
    switch ([central state]) {
        case CBCentralManagerStateResetting:
            stateDescription = [NSString stringWithFormat:@"CBCentralManagerStateResetting %d ", central.state];
            break;
        case CBCentralManagerStateUnsupported:
            stateDescription = [NSString stringWithFormat:@"CBCentralManagerStateUnsupported %d ", central.state];
            [self showAlertWithTitle:@"Error"
                         description:@"This device does not support Bluetooth low energy."];
            break;
        case CBCentralManagerStateUnauthorized:
            stateDescription = [NSString stringWithFormat:@"CBCentralManagerStateUnauthorized %d ", central.state];
            [self showAlertWithTitle:@"Unauthorized!"
                         description:@"This app is not authorized to use Bluetooth low energy.\n\nAuthorize in Settings > Bluetooth."];
            break;
        case CBCentralManagerStatePoweredOff:
            stateDescription = [NSString stringWithFormat:@"CBCentralManagerStatePoweredOff %d ", central.state];
            [self showAlertWithTitle:@"Powered Off"
                         description:@"Bluetooth is currently powered off.\n\nPower ON the bluetooth in Settings > Bluetooth."];
            break;
        case CBCentralManagerStatePoweredOn:
            stateDescription = [NSString stringWithFormat:@"CBCentralManagerStatePoweredOn %d ", central.state];
            if (globalData.isSaved == YES)
                [self startScan];
            break;
        case CBCentralManagerStateUnknown:
            stateDescription = [NSString stringWithFormat:@"CBCentralManagerStateUnknown %d ", central.state];
            break;
        default:
            stateDescription = [NSString stringWithFormat:@"CBCentralManager Undefined %d ", central.state];
            break;
    }
    
    NSLog(@"centralManagerDidUpdateState:[%@]",stateDescription);
    
#ifdef TESTFLIGHT_ENABLED
    [TestFlight passCheckpoint:[NSString stringWithFormat:@"FloorSmart:centralManagerDidUpdateState:%@",
                                stateDescription]];
#endif
    
}

- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI
{
    NSLog(@"%@",[NSString stringWithFormat:@"FloorSmart:didDiscoverPeripheral:name=[%@]",
                 peripheral.name]);
    
    
    NSString *name = [advertisementData valueForKey:CBAdvertisementDataLocalNameKey];
    NSData *manufacturedData = [advertisementData valueForKey:CBAdvertisementDataManufacturerDataKey];
    NSDictionary *serviceDict = [advertisementData valueForKey:CBAdvertisementDataServiceDataKey];
    NSArray *serviceUUIDsArray = [advertisementData valueForKey:CBAdvertisementDataServiceUUIDsKey];
    NSArray *overflowServiceUUIDsArray = [advertisementData valueForKey:CBAdvertisementDataOverflowServiceUUIDsKey];
    NSNumber *transmitPower = [advertisementData valueForKey:CBAdvertisementDataTxPowerLevelKey];
    
    NSMutableData* dataToParse = nil;
    NSInteger offset = 0;
    NSDictionary *sensorData;
    
    /* for test sensordataparser
     NSArray* uuidsArray = advertisementData[CBAdvertisementDataServiceUUIDsKey];
     manufacturedData = [[uuidsArray firstObject] data];
     */
    
    NSTimeInterval currTime = [[NSDate date] timeIntervalSince1970];
    
    
    if (manufacturedData) {
        
        NSString * dataToParseString = @"";
        for (int ix=0; ix<manufacturedData.length; ix++) {
            unsigned char c;
            [manufacturedData getBytes:&c range:NSMakeRange(ix, 1)];
            dataToParseString = [dataToParseString stringByAppendingFormat:@"%02X ",c];
        }
        NSLog(@"Debug output manufacture data: %@",dataToParseString);
        
        if(![[manufacturedData subdataWithRange:NSMakeRange(0, 4)] isEqualToData:
             [NSData dataWithBytes:&kPackageID length:4]])
        {
            NSLog(@"Third party package was received.");
            [[self delegate] scanManager:self didFindThirdPackage:manufacturedData];
            return;
        }
        
        dataToParse = (NSMutableData*)manufacturedData;
        offset = 0;
        
        
        SensorReadingParser *parser = [[SensorReadingParser alloc] init];
        sensorData = [parser parseData:dataToParse  withOffset:offset];
        
        
    }
    else {
        ///note, that uuid1 is 128-bit uuid that contain first 16 bytes according to the specification: 3-bytes flag, length byte and so on.
        ///uuid2(which is 16-bit uuid) contains last byte of S2T field and battery level byte. This is where specification order is violated.
        ///Last 3 uuids contains full Serial number order.
        NSArray* uuidsArray = advertisementData[CBAdvertisementDataServiceUUIDsKey];
        
        CBUUID* uuid1 = [uuidsArray firstObject];
        
        NSString *outputString = @"";
        for (int ix = 0 ; ix < [uuid1 data].length; ix++) {
            unsigned char c;
            [[uuid1 data] getBytes:&c range:NSMakeRange(ix, 1)];
            outputString = [outputString stringByAppendingFormat:@"%02X ",c];
        }
        NSLog(@"Debug output sensor data(uuid1): %@",outputString);
        
        
        UInt32 packageID = kPackageID;
        ///uuid comes right after flag, length and dataType bytes.
        if([[uuid1 data] length] < 4 || ![[[uuid1 data] subdataWithRange:NSMakeRange(0, 4)] isEqualToData:
                                          [NSData dataWithBytes:&packageID length:4]])
        {
            NSLog(@"Third party package was received.");
            [[self delegate] scanManager:self didFindThirdPackage:[uuid1 data]];
            return;
        }
        
        NSData* firstPackage = [uuid1 data];
        dataToParse = [NSMutableData dataWithData:firstPackage];
        offset = 0;
        
        
        EmulatorReadingParser *parser = [[EmulatorReadingParser alloc] init];
        sensorData = [parser parseData:dataToParse  withOffset:offset];
    }
    
    if ((mLastTakingTime == -1 || currTime - mLastTakingTime >= 5) ||
        [[self delegate] isSameAsBefore:beforeData withData:sensorData] == NO)
    {
        [[self delegate] scanManager:self
                       didFindSensor:sensorData];
        beforeData = sensorData;
        mLastTakingTime = currTime;
    }
    
    
}

- (void)showAlertWithTitle:(NSString *)title description:(NSString *)description {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:description
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    
    [alert performSelectorOnMainThread:@selector(show)
                            withObject:nil
                         waitUntilDone:YES];
}

@end
