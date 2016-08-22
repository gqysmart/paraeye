//
//  BlueToothViewController.h
//  NJSZGX（new）
//
//  Created by JSJM on 15-9-8.
//  Copyright (c) 2015年 cc. All rights reserved.
//
#import <CoreBluetooth/CoreBluetooth.h>
#import <UIKit/UIKit.h>
#import "TerminalIO.h"
@protocol BlueToothViewDelegate
-(IBAction)btnBlueToothViewClick;
@property (nonatomic, strong) IBOutlet UIView *PopView;
@property (nonatomic, retain) IBOutlet UIView *MainView;
@end
@interface BlueToothViewController : UIViewController
<CBCentralManagerDelegate,CBPeripheralDelegate>
{
    id<BlueToothViewDelegate> myBlueToothViewDelegate;
    CBCentralManager *manager;
    NSMutableArray *LngOLatstr;//读取到的经纬度字符串
}

-(void)connectTimeout;
@property (strong, nonatomic) TIOPeripheral *objCBperipheral;
//@property (nonatomic, strong)  CBPeripheral *objCBperipheral;
@property (strong, nonatomic)   CBCharacteristic *OBJECTcharacteristic ;
@property (nonatomic, assign)  NSMutableArray *dicoveredPeripherals;
@property (nonatomic, assign) id<BlueToothViewDelegate> myBlueToothViewDelegate;
@property (nonatomic, strong) IBOutlet UITableView *DeviceTable;
@property (nonatomic, strong) IBOutlet UILabel *labelState;

@property (nonatomic, strong) IBOutlet UILabel *labelstr;
@property (nonatomic, strong) IBOutlet UILabel *lblgpss;
@property (nonatomic, strong) IBOutlet UILabel *lblLng;
@property (nonatomic, strong) IBOutlet UILabel *lblLngData;
@property (nonatomic, strong) IBOutlet UILabel *lblLat;
@property (nonatomic, strong) IBOutlet UILabel *lblLatData;
@property (nonatomic, strong) IBOutlet UILabel *lblX;
@property (nonatomic, strong) IBOutlet UILabel *lblY;
@property (nonatomic, strong) IBOutlet UIButton *btINFO;
@property (nonatomic, strong) IBOutlet UITextView *GGText;

@property (nonatomic, strong) IBOutlet UIButton *btnRegedit;

- (IBAction)btnCancelNotice:(id)sender;

- (IBAction)BtnLinkselBlueT:(UIButton *)sender ;


-(void)CancelNotice;
//开始订阅
-(void)StartNotice;
//蓝牙状态书写
-(void)BookLog:(NSString *)info;
@end
