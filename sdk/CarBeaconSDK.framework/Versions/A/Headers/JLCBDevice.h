//
//  CarBeacon SDK
//
//  Created by Shawn Chain on 14-3-12.
//  Copyright (c) 2014 Shawn Chain. All rights reserved.
//
//  shawn.chain@gmail.com
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "JLCBData.h"

@class JLCBDevice;

////////////////////////////////////////////////////////////////////////////////////////
/*
 * device delegate object
 */
@protocol JLCBDeviceDelegate<NSObject>

@optional
/*
 * device connected
 */
-(void)deviceConnected:(JLCBDevice*)device error:(NSError*)error;

/*
 * device disconnected
 */
-(void)deviceDisconnected:(JLCBDevice*)device error:(NSError*)error;

@end

////////////////////////////////////////////////////////////////////////////////////////
/*
 * CarBeacon Device Class
 */
@interface JLCBDevice : NSObject

/*
 * delegate that handles the connect/disconnect events
 */
@property(assign,nonatomic,readwrite) id<JLCBDeviceDelegate> delegate;

/*
 * the RSSI of connected periperal
 */
@property(readonly) NSNumber* rssi;

/*
 * The name of connected device;
 */
@property(readonly) NSString* name;

/*
 * connect to the device
 */
-(void)connect;

/*
 * disconnect from the bt/serial pass-through service
 */
-(void)disconnect;

/*
 * check if device is connected
 */
-(BOOL)isConnected;
@end

////////////////////////////////////////////////////////////////////////////////////////
/*
 * CarBeacon Device data operations
 */
@interface JLCBDevice(JLCBData)

/*
 * get the engine data, if read success. or null returns
 */
@property (readonly) JLCBEngineData *engineData;

/*
 * get the fuel data. null returns if no data available.
 */
@property (readonly) JLCBFuelData *fuelData;

/*
 * Start update engine data
 */
-(void)startUpdateEngineData:(JLCBEngineDataHandler) handler;

/*
 * Start update engine data, with desiredUpdateFrequency
 */
-(void)startUpdateEngineData:(JLCBEngineDataHandler) handler desiredUpdateFrequency:(JLCBDataUpdateFrequency)desiredUpdateFrequency;

/*
 * Stop update Engine Data
 */
-(void)stopUpdateEngineData;


/*
 * Start update fuel data
 */
-(void)startUpdateFuelData:(JLCBFuelDataHandler) handler;

/*
 * Stop update fuel data
 */
-(void)stopUpdateFuelData;

/*
 * get the device info, if read success. or null returns
 */
@property (readonly) JLCBDeviceInfo *deviceInfo;

/*
 * read device info
 */
-(void)readDeviceInfo:(JLCBDeviceInfoHandler) handler;
@end

