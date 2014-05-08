//
//  JLCBDeviceManager.h
//  CarBeaconSDK
//
//  Created by Shawn Chain on 14-4-25.
//  Copyright (c) 2014年 JoyLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JLCBDevice.h"

typedef void (^JLCBScanHandler)(JLCBDevice* device);

@interface JLCBDeviceManager : NSObject

/*
 * Get the last seen peripheral
 */
-(void)lastConnectedDevice:(JLCBScanHandler) handler;

/*
 * Scan devices
 */
-(void)startScanDevices:(JLCBScanHandler) handler scanTimeoutSeconds:(NSNumber*)timeout;

/*
 * Stop scan
 */
-(void)stopScanDevices;

/*
 * Save connected device
 */
+(void)saveConnectedDevice:(JLCBDevice*)device;
@end
