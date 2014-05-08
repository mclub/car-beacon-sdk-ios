//
//  CRBDemoMainViewController.m
//  CarBeaconDemo
//
//  Created by Shawn Chain on 14-3-12.
//  Copyright (c) 2014年 JoyLabs. All rights reserved.
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


#import "CRBDemoMainViewController.h"

#import "GaugeView.h"
#import "MBProgressHUD.h"
#import <CarBeaconSDK/JLCarBeaconSDK.h>

#import "CRBDemoAboutViewController.h"
#import "CRBDemoScanViewController.h"

#define CONNECT_TITLE @"连接设备"

#define DISCONNECT_TITLE @"断开连接"

@interface CRBDemoMainViewController ()<JLCBDeviceDelegate>

@property(strong,readwrite,nonatomic) IBOutlet GaugeView *meterView;
@property(strong,readwrite,nonatomic) MBProgressHUD *progressHud;
@property(strong,readwrite,nonatomic) JLCBDevice *carDevice;
@property(strong,readwrite,nonatomic) JLCBDeviceManager *carDeviceManager;

//@property(strong) NSTimer *refreshDataTimer;

@property(assign) IBOutlet UITextField *txtFuel;
@property(assign) IBOutlet UITextField *txtFuelRate;
@property(assign) IBOutlet UITextField *txtCoolant;
@property(assign) IBOutlet UITextField *txtSpeed;
@property(assign) IBOutlet UITextField *txtEngineLoad;

@end

@implementation CRBDemoMainViewController

//////////////////////////////////////////////////////////////////////////
#pragma mark - lifecycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.carDeviceManager = [[JLCBDeviceManager alloc] init];
        
        // notification from the scan view
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scanDeviceCompleteHandler:) name:@"JLCBDevice_Found" object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // add connect/disconnect buttons
    UIBarButtonItem *connectButton = [[[UIBarButtonItem alloc] initWithTitle:CONNECT_TITLE style:(UIBarButtonItemStyleDone) target:self action:@selector(connectAction:)] autorelease];
    self.navigationItem.rightBarButtonItem = connectButton;
    
    UIBarButtonItem *resetButton = [[[UIBarButtonItem alloc] initWithTitle:@"查找设备" style:(UIBarButtonItemStylePlain) target:self action:@selector(scanAction:)] autorelease];
    self.navigationItem.leftBarButtonItem = resetButton;
    
    [self setupGauge];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.meterView = nil;
    self.progressHud = nil;
    self.carDevice = nil;
    self.carDeviceManager = nil;
    
    [super dealloc];
}

//////////////////////////////////////////////////////////////////////////
#pragma mark - actions

-(IBAction)connectAction:(id)sender{
    // if no device remembered, perform the scan
    if(!self.carDevice){
        // no device associated yet, perform a scan
        [self.carDeviceManager lastConnectedDevice:^(JLCBDevice *device) {
            if(device){
                self.carDevice = device;
                // perform the connect
                [self connectAction:nil];
            }else{
                // perform the scan operation
                [self scanAction:nil];
            }
        }];
        return;
    }
    
    // do connect
    if(self.navigationItem.rightBarButtonItem.tag ==0){
        // do connect;
        [self connectDevice];
    }else if(self.navigationItem.rightBarButtonItem.tag ==1){
        // do disconnect;
        [self disconnectDevice];
    }
}

-(IBAction)scanAction:(id)sender{
    //[self.navigationController presentViewController:scan animated:YES completion:nil];
    
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration: 1];
//    [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.navigationController.view cache:YES];
    CRBDemoScanViewController *scan = [[CRBDemoScanViewController alloc] init];
    [self.navigationController pushViewController:scan animated:YES];
    [scan release];
//    [UIView commitAnimations];
}

-(void) scanDeviceCompleteHandler:(NSNotification*)notif{
    JLCBDevice *d = (JLCBDevice*)notif.object;
    if(d){
        NSLog(@"device found %@",notif.object);
        // perform the connect
        self.carDevice = d;
        d.delegate = self;
        [self connectDevice];
    }
}

-(IBAction) testAction:(id)sender{
    if(_meterView.value == 0.1f){
        [_meterView setValue:8000.0 animated:YES duration:1.75];
    }else{
        [_meterView setValue:0.1f animated:YES duration:1.75];
    }
}

-(IBAction) infoAction:(id)sender{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration: 1];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:YES];
    CRBDemoAboutViewController *c = [[CRBDemoAboutViewController alloc] init];
    c.device = self.carDevice;
    [self.navigationController pushViewController:c animated:NO];
    [c release];
    [UIView commitAnimations];
}

//////////////////////////////////////////////////////////////////////////
#pragma mark - device delegate methods
-(void) deviceConnected:(JLCBDevice *)device error:(NSError *)error{
    if(error){
        [self.progressHud hide:NO];
        UIAlertView *alert = nil;
        if(error.code == kJLCBErrorCodePowerOff){
            alert = [[UIAlertView alloc] initWithTitle:@"蓝牙未开启" message:@"您需要打开蓝牙设备来连接" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"重试", nil];
        }else{
            alert = [[UIAlertView alloc] initWithTitle:@"连接失败" message:@"请检查CarBeacon硬件设备" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"重试", nil];
        }
        [alert show];
        [alert autorelease];
        
        // restore the connect button state
        self.navigationItem.rightBarButtonItem.title = CONNECT_TITLE;
        self.navigationItem.rightBarButtonItem.tag = 0;
    }else{
        // we're connected
        // hide the hud
        [self.progressHud hide:YES];
        // start read engine data
        [device startUpdateEngineData:^(JLCBEngineData *engineData) {
            // update guage
            [self updateGaugeWithEngineData:engineData fuelData:nil];
        }
               desiredUpdateFrequency:JLCBDataUpdateFrequency_BEST];
        
        [device startUpdateFuelData:^(JLCBFuelData *fuelData) {
           [self updateGaugeWithEngineData:nil fuelData:fuelData];
        }];
    }
}

-(void) deviceDisconnected:(JLCBDevice *)device error:(NSError *)error{
    //[self.refreshDataTimer invalidate];
    
    // hide HUD anyway
    if(!_progressHud.isHidden){
        [self.progressHud hide:NO];
    }
    
    // disconnect callback;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"蓝牙连接已断开" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    [alert autorelease];
    
    [self resetUI];
}

/////////////////////////////////////////////////////////////////
#pragma mark - alert delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1){
        [self connectDevice];
    }
}

////////////////////////////////////////////////////////////////////////////
#pragma mark - internals

-(void) resetUI{
    // reset meters
    [self.meterView setValue:0 animated:YES duration:1.75];
    _txtEngineLoad.text = nil;
    _txtCoolant.text = nil;
    _txtFuel.text = nil;
    _txtFuelRate.text = nil;    
    _txtSpeed.text = nil;
    [self.meterView setValue:0 animated:YES duration:1.75];
    
    // reset connect button
    self.navigationItem.rightBarButtonItem.tag = 0;
    self.navigationItem.rightBarButtonItem.title = CONNECT_TITLE;
}


-(void) connectDevice{
    self.navigationItem.rightBarButtonItem.tag = 1;
    self.navigationItem.rightBarButtonItem.title = DISCONNECT_TITLE;
    // show progress hud
    if(!_progressHud){
        self.progressHud = [[[MBProgressHUD alloc] initWithView:self.view] autorelease];
        //_progressHud.mode = MBProgressHUDModeText;
        _progressHud.minShowTime = 1;
        _progressHud.color = [UIColor grayColor];
        _progressHud.yOffset = -100.f;
        [self.view addSubview:_progressHud];
    }
    _progressHud.labelText = @"正在连接设备";
    [_progressHud show:YES];
    
    [self.carDevice connect];
}

-(void) disconnectDevice{
    self.navigationItem.rightBarButtonItem.tag = 0;
    self.navigationItem.rightBarButtonItem.title = CONNECT_TITLE;
    _progressHud.labelText = @"正在断开";
    [_progressHud show:YES];
    
    [self.carDevice disconnect];
}

// Timer routine
//-(void)refreshDataTimerProc:(NSTimer*)timer{
//    [_carDevice startReadEngineData:^(JLCBEngineData *engineData) {
//        // update guage
//        [self updateGauge:engineData];
//    }];
//}

-(void)setupGauge{
    if(!_meterView)
        return;
    
    GaugeView *g = _meterView;
    g.startAngle = 3.0 * M_PI / 4.0;
    g.maxNumber = 8000.0;
	g.textLabel.text = @"RPM";
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        g.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-BoldItalic" size:36.0];
    }else{
        g.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-BoldItalic" size:18.0];
    }
	
	g.minorTickLength = 15.0;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        g.lineWidth = 5.0;
        g.needle.width = 8.0;
        g.tickLength = 38.0;        
    }else{
        g.lineWidth = 2.5;
        g.needle.width = 4.0;
        g.tickLength = 38.0;
    }
    
	g.textLabel.textColor = [UIColor colorWithRed:0.7 green:1.0 blue:1.0 alpha:1.0];
    g.backgroundColor = [UIColor blackColor];
    

    [g setValue:0.01 animated:NO];
}

static void bubble_sort(float *list, int length){
    for (int i = 0; i < length; i++) {
        for (int j = length - 1; j > i; j--) {
            if (list[j] < list[j-1]) {
                float tmp = list[j-1];
                list[j-1] =  list[j];
                list[j] = tmp;
            }
        }
    }
}

static float apply_filter(float input){
    static float valueWindow[3] = {0,0,0};
    static int valueWindowIdx = 0;
    valueWindow[valueWindowIdx++] = input;
    if(valueWindowIdx == 3) valueWindowIdx = 0;
    bubble_sort(valueWindow,3);
    float value = valueWindow[1];
    return value;
}

/*
 * Load data
 */
-(void)updateGaugeWithEngineData:(JLCBEngineData*)engineData fuelData:(JLCBFuelData*)fuelData{
    
    if(engineData){
        _txtCoolant.text = [NSString stringWithFormat:@"%3.0f",engineData.coolantTemperature];
        _txtSpeed.text = [NSString stringWithFormat:@"%3.0f",engineData.vehicleSpeed];
        _txtEngineLoad.text = [NSString stringWithFormat:@"%3.0f",engineData.engineLoad];
        [self.meterView setValue:apply_filter(engineData.rpm) animated:YES duration:0.25];
    }
    if(fuelData){
        _txtFuel.text = [NSString stringWithFormat:@"%3.0f",fuelData.fuelLevel];
        _txtFuelRate.text = [NSString stringWithFormat:@"%3.1f",fuelData.fuelRate > 0 ?fuelData.fuelRate:fuelData.estimatedFuelRate];
    }
}

@end
