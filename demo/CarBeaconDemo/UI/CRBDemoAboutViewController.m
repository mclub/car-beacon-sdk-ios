//
//  CRBDemoAboutViewController.m
//  CarBeaconDemo
//
//  Created by Shawn Chain on 14-3-14.
//  Copyright (c) 2014年 JoyLabs. All rights reserved.
//

#import "CRBDemoAboutViewController.h"

#import <CarBeaconSDK/JLCarBeaconSDK.h>

#import "MBProgressHUD.h"

@interface CRBDemoAboutViewController ()<UIAlertViewDelegate>
@property(assign,readwrite,nonatomic) IBOutlet UILabel *lblFirmwareName;
@property(assign,readwrite,nonatomic) IBOutlet UILabel *lblFirmwareVersion;
@property(assign,readwrite,nonatomic) IBOutlet UILabel *lblSerialNumber;
@property(assign,readwrite,nonatomic) IBOutlet UILabel *lblManufacturer;

@property(assign,readwrite,nonatomic) IBOutlet UILabel  *lblFastFlash;
@property(assign,readwrite,nonatomic) IBOutlet UISwitch *swFastFlash;
@property(assign,readwrite,nonatomic) IBOutlet UIButton *btnUpdateFirmware;

@property(strong,readwrite,nonatomic) JLCBDeviceInfo    *deviceInfo;

@property(strong,readwrite,nonatomic) MBProgressHUD *hud;

@property(assign,readwrite,nonatomic) BOOL fastMode;

@end

@implementation CRBDemoAboutViewController

- (id)init{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        self = [super initWithNibName:@"CRBDemoAboutViewController_iPad" bundle:nil];
    }else{
        self = [super initWithNibName:@"CRBDemoAboutViewController" bundle:nil];
    }
    
    if(self){
        // custom initialization;
        self.fastMode = YES;
    }
    
    return self;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"Device Info";
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"OK" style:UIBarButtonItemStyleDone target:self action:@selector(closeAction:)];
    self.navigationItem.rightBarButtonItem = doneButton;
    [doneButton release];
    
    // Load firmware info
    self.lblFirmwareVersion.text = @"Unknown";
    self.lblFirmwareName.text = @"Unknown";

    [self.device readDeviceInfo:^(JLCBDeviceInfo *deviceInfo) {
        [self readDeviceInfoComplete:deviceInfo];
    }];
    
    // the progress hud
    self.hud = [[[MBProgressHUD alloc] initWithView:self.navigationController.view] autorelease];
    [self.navigationController.view addSubview:self.hud];
    self.hud.square = YES;
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)closeAction:(id)sender{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration: 1];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.navigationController.view cache:NO];
    [self.navigationController popViewControllerAnimated:NO];
    [UIView commitAnimations];
}

-(IBAction)fastFlashSwitchAction:(id)sender{
    UISwitch *sw = (UISwitch*)sender;
    self.fastMode = sw.on;
    //self.device.firmwareManager.fastMode = sw.on;
}

-(IBAction) updateFirmwareAction:(id)sender{
    // update firmware
    if(!self.device.canUpdateFirmware){
        // ignore;
        return;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"更新固件" message:@"更新开始后，将无法中断，请确保网络连接正常。\r确定要继续吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"更新", nil];
    [alert show];
    [alert autorelease];
}

-(void)dealloc{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    self.device = nil;
    self.hud = nil;
    
    [super dealloc];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1){
        [self downloadFirmware];
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma firmware manager callback

-(void)readDeviceInfoComplete:(JLCBDeviceInfo*) deviceInfo{
    if(deviceInfo){
        self.deviceInfo = deviceInfo;
        NSLog(@"DeviceInfo: %@ %@%@ by %@",deviceInfo.modelNumber, deviceInfo.softwareRev,deviceInfo.firmwareRev, deviceInfo.manufacturerName);
        self.lblFirmwareName.text = deviceInfo.modelNumber;
        self.lblFirmwareVersion.text = [NSString stringWithFormat:@"%@-%@",deviceInfo.softwareRev,deviceInfo.firmwareRev];
        self.lblManufacturer.text = deviceInfo.manufacturerName;
        self.lblSerialNumber.text = deviceInfo.serialNumber;
    }else{
        self.deviceInfo = nil;
        // do nothing for error
        self.lblFirmwareVersion.text = @"N/A";
        self.lblFirmwareName.text = @"N/A";
    }
    
    // Update UI if device supports firmware update.
    if(![self.device canUpdateFirmware]){
        self.lblFastFlash.hidden = YES;
        self.swFastFlash.hidden = YES;
        self.btnUpdateFirmware.hidden = YES;
    }else{
        self.lblFastFlash.hidden = NO;
        self.swFastFlash.hidden = NO;
        self.btnUpdateFirmware.hidden = NO;
    }

}

-(void)downloadFirmware{
    // Show the mbprogress hud
    self.hud.labelText = @"检查固件更新";
    self.hud.detailsLabelText = @"可能需要几分钟";
    self.hud.dimBackground = NO;
    [self.hud show:YES];
    
    [self.device checkFirmwareRelease:^(JLCBFirmwareReleaseInfo *releaseInfo, NSError *error) {
        if(releaseInfo){
            NSLog(@"Found firmware release: %@",releaseInfo.version);
            
            self.hud.labelText = @"正在下载固件";
            
            [self.device downloadFirmwareRelease:releaseInfo completionHandler:^(NSData *data, NSError *error) {
                [self downloadComplete:data error:error];
            } progressHandler:^(int bytesDownloaded, int bytesTotal) {
                // noop
            }];
        }else{
            // no release found, bail out
            [self downloadComplete:nil error:error];
        }
    }];
}

-(void) downloadComplete:(NSData*) data error:(NSError*) error{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if(data == nil){
        if(error){
            NSLog(@"Download error： %@",error);
            self.hud.labelText = @"固件更新失败，请检查网络";
        }else{
            NSLog(@"No update found");
            self.hud.labelText = @"固件已经是最新";
        }
        self.hud.detailsLabelText = error.description;
        [self.hud hide:YES afterDelay:5];
        return;
    }
    
    
    [self.hud hide:NO];
    self.hud.labelText = @"正在更新固件";
    self.hud.mode = MBProgressHUDModeAnnularDeterminate;
    self.hud.dimBackground = YES;
    [self.hud show:NO];
    
    // perform the upgrade now
    [self.device updateFirmwareWithImageData:data
                                 forceUpdate:NO
                                  fastUpdate:self.fastMode
                           completionHandler:^(id data, NSError *error) {
                                      if(error){
                                          NSLog(@"%@",error);
                                          self.hud.labelText = @"固件更新失败";
                                      }else{
                                          self.hud.labelText = @"固件更新完成";
                                          // read device / firmware info
                                          [self.device readDeviceInfo:^(JLCBDeviceInfo *deviceInfo) {
                                              [self readDeviceInfoComplete:deviceInfo];
                                          }];
                                      }
                                      [self.hud hide:YES afterDelay:1];
                            }
                             progressHandler:^(int bytesSent, int bytesTotal) {
                                      //progress update
                                      self.hud.detailsLabelText =[NSString stringWithFormat:@"%d/%d",bytesSent,bytesTotal];
                                      self.hud.progress = (float)bytesSent / (float)bytesTotal;
                            }
     ];
}
@end
