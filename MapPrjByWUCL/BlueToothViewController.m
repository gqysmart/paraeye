//
//  BlueToothViewController.m
//  NJSZGX（new）
//
//  Created by JSJM on 15-9-8.
//  Copyright (c) 2015年 cc. All rights reserved.
//

#import "BlueToothViewController.h"
#import "WBAAppDelegate.h"
#import "proClass.h"
#import "DialogController.h"
#import "TIOPeripheral.h"
@interface BlueToothViewController ()<TIOPeripheralDelegate>

@end

@implementation BlueToothViewController
@synthesize myBlueToothViewDelegate,DeviceTable,labelState,labelstr,objCBperipheral,GGText,lblLat,lblLatData,lblLng,lblLngData,lblX,lblY,btINFO,lblgpss,OBJECTcharacteristic,btnRegedit;

bool isConnected=false;
bool hasFind=false;//是否截取到gps信息



NSString *s1=@"!!!";
NSTimer *connectTimer;
NSMutableArray  *BlueTootharr;

AGSGraphicsLayer *GPSgraLayer;
WBAAppDelegate *appDelegate;
DialogController *dia;

int selDevieindex=-1;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    appDelegate = [[UIApplication sharedApplication] delegate];
    GPSgraLayer=(AGSGraphicsLayer *)   [appDelegate.mapView mapLayerForName:@"position"];
    
    [TIOManager sharedInstance].delegate = self;//初始化
    //GGText.layoutManager.allowsNonContiguousLayout = NO;
}



-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:true];
    manager = [[CBCentralManager alloc]  initWithDelegate:self queue:nil];
    selDevieindex=-1;
    _dicoveredPeripherals=[[NSMutableArray alloc ]init];
    BlueTootharr=[[NSMutableArray alloc ]init];
    selDevieindex=-1;//重置当前选择行索引
    [DeviceTable reloadData];
    labelstr.text=@"搜索状态：";
    objCBperipheral=nil;
    OBJECTcharacteristic=nil;
    lblX.text=@"X坐标:";
    lblY.text=@"Y坐标:";
    GGText.text=@"实时状态:";
    lblLng.text=@"经度:";
    lblLngData.text=@"";
    lblLat.text=@"纬度:";
    lblLatData.text=@"";
    lblgpss.text=@"GPS状态:";
    // GGText.hidden=true;
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:true];
    // [ self disConnect];
    //    GGText.text=@"实时状态:";
    //    lblLng.text=@"Lng:";
    //    lblLngData.text=@"";
    //    lblLat.text=@"Lat:";
    //    lblLatData.text=@"";
}

//主动断开设备
-(void)disConnect
{
    
    if (objCBperipheral != nil)
    {
        
        [  DeviceTable deselectRowAtIndexPath:[NSIndexPath indexPathForRow:selDevieindex inSection:0] animated:true];
        selDevieindex=-1;
        NSLog(@"disConnect ");
        [self BookLog:@"蓝牙已断开"];
        [self.objCBperipheral cancelConnection];
        //  [manager cancelPeripheralConnection:objCBperipheral];
        objCBperipheral=nil;
        OBJECTcharacteristic=nil;
        appDelegate.BLUETOOTHABLE=false;
        hasFind=false;
        LngOLatstr=nil;
    }
    
}



- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    
    
    
    if(peripheral.name!=nil)
    {
        
        if(![_dicoveredPeripherals containsObject:peripheral])
        {
            [ BlueTootharr addObject:[peripheral.name stringByAppendingString:[NSString stringWithFormat:@"    强度：%@", RSSI]]];
            [_dicoveredPeripherals addObject:peripheral];
            [DeviceTable reloadData];
        }
        
    }
    NSLog(@"%@",peripheral);
    NSLog(@"%@",advertisementData);
    NSLog(@"RSSI: %@\n",RSSI);
    
}

- (IBAction)BtnsearchBlue:(UIButton *)sender {
    if( isConnected==true)
    {
        [self disConnect];
        objCBperipheral=nil;
        OBJECTcharacteristic=nil;
        GGText.text=@"实时状态:";
        
        
        
        _dicoveredPeripherals=[[NSMutableArray alloc ]init];
        
        BlueTootharr=[[NSMutableArray alloc]init    ];
        selDevieindex=-1;//重置选中设备索引
        
        [DeviceTable reloadData];
        [self startScan];
    }
    else
    {
        
        [self stopScan];
        
    }
    
}

#pragma mark - Start/Stop Scan methods
/*
 Request CBCentralManager to scan for health thermometer peripherals using service UUID 0x1809
 */
- (void)startScan
{
    
    // NSDictionary * options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:false], CBCentralManagerScanOptionAllowDuplicatesKey, nil];
    [[TIOManager sharedInstance] startScan];
    // [manager scanForPeripheralsWithServices:nil options:nil];
    [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(connectTimeout) userInfo:@"" repeats:NO];
    labelstr.text=@"搜索状态：扫描中。。。";
    [self BookLog:@"搜索状态：扫描中。。。"];
}


-(void)connectTimeout
{
    [self stopScan];
    NSLog(@"搜索结束");
    
    [self BookLog:@"搜索结束"];
}

-(void)searchServiceTimeout
{
    
    NSLog(@"搜索服务结束");
    //labelstr.text=@"搜索状态：扫描结束";
    [self BookLog:@"搜索服务结束"];
}


/*
 Request CBCentralManager to stop scanning for health thermometer peripherals
 */
- (void)stopScan
{
    // [manager stopScan];
    [[TIOManager sharedInstance] stopScan];
}


-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    isConnected= [self isLECapableHardware:central];
}


#pragma mark - LE Capable Platform/Hardware check
/*
 Uses CBCentralManager to check whether the current platform/hardware supports Bluetooth LE. An alert is raised if Bluetooth LE is not enabled or is not supported.
 */
- (BOOL) isLECapableHardware:(CBCentralManager *)central
{
    NSString * state = nil;
    
    switch ([central state])
    {
        case CBCentralManagerStateUnsupported:
            state = @"设备不支持蓝牙功能";
            break;
        case CBCentralManagerStateUnauthorized:
            state = @"App未获得蓝牙授权";
            break;
        case CBCentralManagerStatePoweredOff:
            state = @"蓝牙未开启";
            break;
        case CBCentralManagerStatePoweredOn:
            state = @"蓝牙已开启";
            labelState.text=[NSString stringWithFormat:@"蓝牙状态: %@", state];
            [self BookLog:@"蓝牙状态:蓝牙已开启"];
            return true;
        case CBCentralManagerStateUnknown:
        default:
            return FALSE;
            
    }
    
    NSLog(@"蓝牙状态: %@", state);
    [self BookLog:[NSString stringWithFormat: @"蓝牙状态:%@",state ]];
    
    
    labelState.text=[NSString stringWithFormat:@"蓝牙状态: %@", state];
    return FALSE;
}

//连接蓝牙


- (IBAction)BtnLinkselBlueT:(UIButton *)sender {
    
    NSArray *peripherals = [TIOManager sharedInstance].peripherals;
    
    
    if(peripherals.count<1)
    {
        labelstr.text=@"搜索状态：未检测到设备";
        [self BookLog:@"搜索状态：未检测到设备"];
        return;
    }
    
    // [self  disConnect];//预先切断蓝牙连接
    if(selDevieindex==-1)
    {
        [ DeviceTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]  animated:YES scrollPosition:UITableViewScrollPositionNone];
        selDevieindex=0;
    }
    lblLat.text=@"纬度:";
    lblLng.text=@"经度:";
    lblLatData.text=@"";
    lblLngData.text=@"";
    lblgpss.text=@"GPS状态:";
    btnRegedit.enabled=true;
    self.objCBperipheral =[peripherals objectAtIndex:selDevieindex];
    self.objCBperipheral.delegate=self;
    [self.objCBperipheral connect];
    
    //[manager connectPeripheral:[_dicoveredPeripherals objectAtIndex:selDevieindex] options:nil];
    NSLog(@"connect peripheral");
    [self BookLog:@"正在尝试连接设备蓝牙"];
    
    //开一个定时器监控连接超时的情况
    [NSTimer scheduledTimerWithTimeInterval:20.0f target:self selector:@selector(searchServiceTimeout) userInfo:@"" repeats:NO];
    
    
}


//连接成功后访问其服务
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    if (!peripheral) {
        return;
    }
    
    [self stopScan];
    objCBperipheral=peripheral;
    [objCBperipheral setDelegate:self];
    NSLog(@"peripheral did connect");
    [self BookLog:@"已成功连接设备蓝牙"];
    NSLog(@"%@",peripheral);
    [peripheral discoverServices:nil];
    
    
}

//锁定服务后检索其内容
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSLog(@"Discovered Services");
    NSArray *services = nil;
    
    if (peripheral != objCBperipheral) {
        NSLog(@"Wrong Peripheral.\n");
        return ;
    }
    
    
    
    
    
    
    if (error != nil) {
        NSLog(@"Error %@\n", error);
        return ;
    }
    
    services = [peripheral services];
    if (!services || ![services count]) {
        NSLog(@"No Services");
        return ;
    }
    
    for (CBService *service in services) {
        if([service.UUID isEqual:[CBUUID UUIDWithString:@"1800"]])
        {
            NSLog(@"service:%@",service.UUID);
            [peripheral discoverCharacteristics:nil forService:service];
        }
        if([service.UUID isEqual:[CBUUID UUIDWithString:@"180a"]])
        {
            NSLog(@"service:%@",service.UUID);
            [peripheral discoverCharacteristics:nil forService:service];
        }
        //        if([service.UUID isEqual:[CBUUID UUIDWithString:@"53544d54-4552-494f-5345-525631303030"]])
        //        {
        //            NSLog(@"service:%@",service.UUID);
        //             [self BookLog:@"成功找到GPS服务"];
        //            [peripheral discoverCharacteristics:nil forService:service];
        //        }
        if([service.UUID isEqual:[CBUUID UUIDWithString:@"FFE0"]])
        {
            NSLog(@"service:%@",service.UUID);
            [self BookLog:@"成功找到GPS服务"];
            [peripheral discoverCharacteristics:nil forService:service];
        }
    }
    
}

//返回的蓝牙特征值通知通过代理实现
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    
    @try {
        
        //    if (objCBperipheral.state==CBPeripheralStateDisconnected) {
        //        [self BookLog:@"设备意外断开,请重新连接"];
        //        return;
        //    }
        
        //    for (CBCharacteristic * characteristic in service.characteristics) {
        //
        //       NSLog(@"Discovered write characteristics:%@ for service: %@  属性代码: %d",characteristic.UUID, service.UUID,characteristic.properties);
        //     // [objCBperipheral readValueForCharacteristic:characteristic];
        //       // [objCBperipheral setNotifyValue:YES forCharacteristic:characteristic];
        //    }
        if ( [service.UUID isEqual:[CBUUID UUIDWithString:@"1800"]] )
        {
            for (CBCharacteristic *characteristic in service.characteristics)
            {
                /* Read device name */
                if([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2a01"]])
                {
                    [objCBperipheral readValueForCharacteristic:characteristic];
                    NSLog(@"Found a Device Name Characteristic - Read Apperance name");
                }
            }
        }
        
        
        if ( [service.UUID isEqual:[CBUUID UUIDWithString:@"180a"]] )
        {
            for (CBCharacteristic *characteristic in service.characteristics)
            {
                /* Read device name */
                if([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2a50"]])
                {
                    [objCBperipheral readValueForCharacteristic:characteristic];
                    NSLog(@"Found a Device Name Characteristic - Read  DeviceInformation");
                }
            }
        }
        
        
        if ( [service.UUID isEqual:[CBUUID UUIDWithString:@"FFE0"]] )
        {
            for (CBCharacteristic *characteristic in service.characteristics)
            {
                appDelegate.BLUETOOTHABLE=true;//已经获取到
                ///* Read device name */
                if([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFE1"]])
                {
                    // [objCBperipheral setNotifyValue:true forCharacteristic:characteristic];
                    OBJECTcharacteristic=characteristic;
                    labelstr.text=@"搜索状态:已获取到gps服务";
                    [self BookLog:@"已获取GPS广播服务特征，可以开始蓝牙定位"];
                    //NSLog(@"Found a Device Name Characteristic - UnKnowService");
                    break;
                    
                }
                
                
                
                
                NSLog(@"UUID:%@",characteristic.UUID);
                
            }
        }
        
        
    }
    @catch (NSException *exception) {
        [self BookLog:@"未知错误，请检查设备是否连接正常"];
    }
    
    
    
    
    
    
    
    
    
    if(OBJECTcharacteristic==nil)
    {
        appDelegate.BLUETOOTHABLE=false;
        [self BookLog:@"设备未提供GPS服务"];
        labelstr.text=@"搜索状态:设备未提供gps服务";
    }
    
}


/*
 Invoked upon completion of a -[readValueForCharacteristic:] request or on the reception of a notification/indication.
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    @try {
        
        //    if (objCBperipheral.state==CBPeripheralStateDisconnected) {
        //        [self BookLog:@"设备意外断开,请重新连接"];
        //        return;
        //    }
        
        if (error)
        {
            NSLog(@"Error updating value for characteristic %@ error: %@", characteristic.UUID, [error localizedDescription]);
            return;
        }else
            
            
            
        /* Value for device name received */
            if([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2a01"]])
            {
                NSString  *deviceName = [[[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding] autorelease];
                NSLog(@"Apperance value = %@", deviceName);
            }else
                
                
            /* Value for device name received */
                if([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2a50"]])
                {
                    NSString  *deviceName = [[[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding] autorelease];
                    NSLog(@"Apperance value = %@", deviceName);
                }
        
        
        
        // if([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"53544f55 41525449 4e202056 30303031"]])
                else{
                    
                    NSString  *deviceName = [[[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding] autorelease];
                    
                    
                    
                    
                    if([deviceName hasPrefix:@"$GPGGA"])
                    {
                        
                        if (LngOLatstr!=nil) {
                            NSString *str=@"";
                            for (int i=0; i<LngOLatstr.count; i++) {
                                str =[str stringByAppendingString:[LngOLatstr objectAtIndex:i]];
                            }
                            
                            NSLog(@"%@",str);
                            NSArray *strarr=    [str componentsSeparatedByString:@","];
                            if(strarr.count>1)
                            {
                                CGPoint pnt;
                                
                                //获取的数字格式为ddmm.mmmmmm 经度dddmm.mmmmmm需做转换
                                double mm=0;
                                double dd=0;
                                if (![[strarr objectAtIndex:4] isEqualToString:@""]) {
                                    mm= [[[strarr objectAtIndex:4] substringFromIndex:3] doubleValue]/60;
                                    dd=[[[strarr objectAtIndex:4] substringToIndex:3]doubleValue];
                                }
                                
                                
                                
                                
                                pnt.x= dd+mm ;
                                
                                mm=0;
                                dd=0;
                                if (![[strarr objectAtIndex:2] isEqualToString:@""]) {
                                    mm= [[[strarr objectAtIndex:2] substringFromIndex:2] doubleValue]/60;
                                    dd=[[[strarr objectAtIndex:2] substringToIndex:2]doubleValue];
                                    
                                }
                                
                                pnt.y= dd+mm ;
                                
                                
                                NSLog(@"%f",pnt.x);
                                NSLog(@"%f",pnt.y);
                                [self LocateAdvanceGPS:pnt];//精准定位
                                
                                
                                
                                lblLatData.text= [NSString stringWithFormat:@"%f",[[strarr objectAtIndex:2] doubleValue]/100 ];
                                lblLat.text= [NSString stringWithFormat:@"纬度:%@",[strarr objectAtIndex:3] ] ;
                                lblLng.text=[NSString stringWithFormat:@"经度:%@",[strarr objectAtIndex:5] ] ;
                                lblLngData.text=[NSString stringWithFormat:@"%f",[[strarr objectAtIndex:4] doubleValue]/100 ];
                                NSString *gpsstate=@"";
                                switch ([[strarr objectAtIndex:6] intValue]) {
                                    case 0:
                                        gpsstate=@"未定位";
                                        break;
                                    case 1:
                                        gpsstate=@"单点定位";
                                        break;
                                    case 2:
                                        gpsstate=@"差分定位";
                                        break;
                                    case 3:
                                        gpsstate=@"PPS解";
                                        break;
                                    case 4:
                                        gpsstate=@"固定解";
                                        break;
                                    case 5:
                                        gpsstate=@"浮点解";
                                        break;
                                    case 6:
                                        gpsstate=@"估计值";
                                        break;
                                    case 7:
                                        gpsstate=@"手工输入模式";
                                        break;
                                    case 8:
                                        gpsstate=@"模拟模式";
                                        break;
                                    case 9:
                                        gpsstate=@"WAAS差分";
                                        break;
                                        
                                    default:
                                        break;
                                }
                                lblgpss.text=[NSString stringWithFormat:@"GPS状态:%@",gpsstate];
                                [self BookLog:@"正在传输GPS定位数据"];
                            }
                        }
                        
                        
                        LngOLatstr=[[NSMutableArray alloc]init];
                        [LngOLatstr addObject:deviceName];
                        // GGText.text= [[GGText.text stringByAppendingString:@"\n"] stringByAppendingString:deviceName];
                        hasFind=true;
                        
                    }else if(hasFind==true)
                    {
                        [LngOLatstr addObject:deviceName];
                    }
                    else
                    {
                        [self BookLog:@"未获取GPS定位数据"];
                    }
                    
                    NSLog(@"Unknow value = %@", deviceName);
                }
        NSLog(@"Done");
        
    }
    @catch (NSException *exception) {
        [self BookLog:@"未知错误，请检查设备是否连接正常"];
    }
    
    
    
}


-(void)LocateAdvanceGPS:(CGPoint )pnt
{
    
    @try {
        
        
        
        [GPSgraLayer removeAllGraphics];
        
        
        //        double  mm= [[@"11844.1294" substringFromIndex:3] doubleValue]/60;
        //        NSLog(@"%@",[@"11844.1294" substringFromIndex:3]);
        //        double dd=[[@"11844.1294" substringToIndex:3]doubleValue];
        //        NSLog(@"%@",[@"11844.1294" substringToIndex:3]);
        //
        //        pnt.x= dd+mm ;
        //        mm= [[@"3159.46325" substringFromIndex:2] doubleValue]/60;
        //         NSLog(@"%@",[@"3159.46325" substringFromIndex:2]);
        //        dd=[[@"3159.46325" substringToIndex:2]doubleValue];
        //         NSLog(@"%@",[@"3159.46325" substringToIndex:2]);
        //        pnt.y= dd+mm ;
        //        NSLog(@"%f",pnt.x);
        //        NSLog(@"%f",pnt.y);
        
//        proClass *progect=[[proClass alloc] init];
//        NSString *str=[progect ConvertWGS84ToNJ92FromL:pnt.x FromB:pnt.y];
//        NSArray *theArray = [str componentsSeparatedByString:@";"];
//        double xvalue=[[theArray objectAtIndex:0] doubleValue];
//        double yvalue=[[theArray objectAtIndex:1] doubleValue];
//        AGSPoint *mappoint =[[AGSPoint alloc] initWithX:xvalue y:yvalue spatialReference:appDelegate.mapView.spatialReference ];
         AGSPoint *mappoint =[[AGSPoint alloc] initWithX:pnt.x y:pnt.y spatialReference:appDelegate.mapView.spatialReference ];
        
        lblX.text=[@"X坐标:" stringByAppendingString:[NSString stringWithFormat:@"%f",mappoint.envelope.xmin]] ;
        lblY.text=[@"Y坐标:" stringByAppendingString:[NSString stringWithFormat:@"%f",mappoint.envelope.ymin]];
        
        
        
        AGSPictureMarkerSymbol *pt;
        pt=[AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"GpsDisplay.png"];
        CGSize size;
        size.width=50;
        size.height=50;
        pt.size=size;
        CGPoint offsetsize;
        offsetsize.x = 0;
        offsetsize.y = 0;
        pt.offset=offsetsize;
        
        AGSGraphic *gra = [[AGSGraphic alloc] init];
        gra.geometry=mappoint;
        gra.symbol=pt;
        
        [GPSgraLayer addGraphic:gra];
        [gra release];
        
        //        AGSMutableEnvelope *newEnv =[AGSMutableEnvelope envelopeWithXmin:mappoint.envelope.xmin-200
        //                                                                    ymin:mappoint.envelope.ymin-200
        //                                                                    xmax:mappoint.envelope.xmax+200
        //                                                                    ymax:mappoint.envelope.ymax+200
        //                                                        spatialReference:appDelegate.mapView.spatialReference];
        //
        //        [appDelegate.mapView zoomToEnvelope:newEnv animated:YES];
        [appDelegate.mapView centerAtPoint:mappoint animated:true];
        
    }
    @catch (NSException *exception)
    {
        if(dia==nil)
        {
            dia=[[DialogController alloc ]init];
            dia.view.frame=CGRectMake(0,0,1024,768);
        }
        
        dia.info.text=exception.name;
        [[myBlueToothViewDelegate   MainView] addSubview:dia.view];
        //                UIAlertView *alert = [[UIAlertView alloc]
        //                                      initWithTitle:@"提示"
        //                                      message:exception.name
        //                                      delegate:self
        //                                      cancelButtonTitle:nil
        //                                      otherButtonTitles:@"确定", nil];
        //
        //                [alert show];
    }
}









//断开蓝牙
- (IBAction)btnCancelNotice:(id)sender {
  //  [self disConnect];
    
    [self.objCBperipheral cancelConnection];
    labelstr.text=@"已断开蓝牙连接";
    [GPSgraLayer removeAllGraphics];
}

//取消订阅
-(void)CancelNotice
{
    if(objCBperipheral!=nil&&OBJECTcharacteristic!=nil)
    {
        [objCBperipheral setNotifyValue:NO forCharacteristic:OBJECTcharacteristic];
        hasFind=false;
        LngOLatstr=nil;
        [self BookLog:@"已停止获取GPS定位数据"];
    }
}
//开始订阅
-(void)StartNotice
{
    if(objCBperipheral!=nil&&OBJECTcharacteristic!=nil)
    {
        hasFind=false;
        LngOLatstr=nil;
        [objCBperipheral setNotifyValue:YES forCharacteristic:OBJECTcharacteristic];
        
        [self BookLog:@"开始获取GPS定位数据"];
        
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)btnShowOrHide:(UIButton *)sender {
    
    [myBlueToothViewDelegate btnBlueToothViewClick   ];
}







//结果表单详细代理
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *TableSampleIdentifier = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             TableSampleIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:TableSampleIdentifier];
    }
    
    NSUInteger row = [indexPath row];
    cell.textLabel.font= [UIFont fontWithName:@"Helvetica Neue" size:14];
    //cell.textLabel.text=[BlueTootharr objectAtIndex:row];
    TIOPeripheral *peripheral = [self peripheralAtSection:indexPath.section];
    cell.textLabel.text = peripheral.name;
    
    
    return cell;
}
//选中行信息
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    selDevieindex=indexPath.row ;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //NSLog(@"%d",[BlueTootharr count]);
    //return [BlueTootharr count];
    
    
    NSInteger numberOfPeripherals = [TIOManager sharedInstance].peripherals.count;
    return numberOfPeripherals;
    
}



//log信息
-(void)BookLog:(NSString *)info
{
    
    GGText.text=[GGText.text stringByAppendingString:[NSString stringWithFormat:@"\n %@",info] ];
    GGText.selectedRange=NSMakeRange(GGText.text.length, 0);
    int g=GGText.text. length;
    [GGText setSelectedRange:NSMakeRange(g, 0)];
    //    GGText.scrollsToTop=false;
    //    [GGText scrollRectToVisible:CGRectMake(0,  GGText.contentSize.height-25,  GGText.contentSize.width, 100 ) animated:true];
    
}



- (IBAction)btnINFO:(UIButton *)sender {
    
   
    
    
    if(GGText.hidden==true)
    {
        GGText.hidden=false;
    }
    else
    {
        GGText.hidden=true;
    }
}

- (IBAction)btnRegisterDevice:(id)sender {
    
    
    if (!self.objCBperipheral.isConnected) {
        if(dia==nil)
        {
            dia=[[DialogController alloc ]init];
            dia.view.frame=CGRectMake(0,0,1024,768);
        }
        
        dia.info.text=@"请先连接设备！";
        [[myBlueToothViewDelegate   MainView] addSubview:dia.view];
        return;
    }
    //写入激活数据
    NSData *data =  [@"$FCMDA,100,de08e89cdcdfa104e8c1a412533f5e9081e63d9fe679be47c5faeab09dcd0493192059a45c699231455a9aedba2001a94ab2cea60b01251b36c0f6e063b33a78$FCMDA,100,*FF" dataUsingEncoding:
                     NSWindowsCP1252StringEncoding];
    for (int i=0;i<4;i++) {
        [self.objCBperipheral   writeUARTData:data];
    }
    ((UIButton *)sender).enabled=false;
    
}


#pragma mark - Internal methods

- (TIOPeripheral	*)peripheralAtSection:(NSInteger)section
{
    NSArray *peripherals = [TIOManager sharedInstance].peripherals;
    if (section >= peripherals.count)
    {
        
        return nil;
    }
    
    return ([peripherals objectAtIndex:section]);
}


//新蓝牙连接方式代理
- (void)tioManager:(TIOManager *)manager didDiscoverPeripheral:(TIOPeripheral *)peripheral
{
    
    // overrule default behaviour: peripheral shall be saved only after having been connected
    peripheral.shallBeSaved = NO;
    
    [DeviceTable reloadData];
}

#pragma mark - TIOPeripheralDelegate implementation
///////////////////////回传代理
- (void)tioPeripheral:(TIOPeripheral *)peripheral didReceiveUARTData:(NSData *)data
{
    
    @try {
         // [self BookLog:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
    NSString *deviceName=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if([deviceName hasPrefix:@"$GPGGA"])
    {
        
        if (LngOLatstr!=nil) {
            NSString *str=@"";
            for (int i=0; i<LngOLatstr.count; i++) {
                str =[str stringByAppendingString:[LngOLatstr objectAtIndex:i]];
            }
            
            NSLog(@"%@",str);
            NSArray *strarr=    [str componentsSeparatedByString:@","];
            if(strarr.count>1)
            {
                CGPoint pnt;
                
                //获取的数字格式为ddmm.mmmmmm 经度dddmm.mmmmmm需做转换
                double mm=0;
                double dd=0;
                if (![[strarr objectAtIndex:4] isEqualToString:@""]) {
                    mm= [[[strarr objectAtIndex:4] substringFromIndex:3] doubleValue]/60;
                    dd=[[[strarr objectAtIndex:4] substringToIndex:3]doubleValue];
                }
                
                
                
                
                pnt.x= dd+mm ;
                
                mm=0;
                dd=0;
                if (![[strarr objectAtIndex:2] isEqualToString:@""]) {
                    mm= [[[strarr objectAtIndex:2] substringFromIndex:2] doubleValue]/60;
                    dd=[[[strarr objectAtIndex:2] substringToIndex:2]doubleValue];
                    
                }
                
                pnt.y= dd+mm ;
                
                
                NSLog(@"%f",pnt.x);
                NSLog(@"%f",pnt.y);
                [self LocateAdvanceGPS:pnt];//精准定位
                
                
                
                lblLatData.text= [NSString stringWithFormat:@"%f",[[strarr objectAtIndex:2] doubleValue]/100 ];
                lblLat.text= [NSString stringWithFormat:@"纬度:%@",[strarr objectAtIndex:3] ] ;
                lblLng.text=[NSString stringWithFormat:@"经度:%@",[strarr objectAtIndex:5] ] ;
                lblLngData.text=[NSString stringWithFormat:@"%f",[[strarr objectAtIndex:4] doubleValue]/100 ];
                NSString *gpsstate=@"";
                switch ([[strarr objectAtIndex:6] intValue]) {
                    case 0:
                        gpsstate=@"未定位";
                        break;
                    case 1:
                        gpsstate=@"单点定位";
                        break;
                    case 2:
                        gpsstate=@"差分定位";
                        break;
                    case 3:
                        gpsstate=@"PPS解";
                        break;
                    case 4:
                        gpsstate=@"固定解";
                        break;
                    case 5:
                        gpsstate=@"浮点解";
                        break;
                    case 6:
                        gpsstate=@"估计值";
                        break;
                    case 7:
                        gpsstate=@"手工输入模式";
                        break;
                    case 8:
                        gpsstate=@"模拟模式";
                        break;
                    case 9:
                        gpsstate=@"WAAS差分";
                        break;
                        
                    default:
                        break;
                }
                lblgpss.text=[NSString stringWithFormat:@"GPS状态:%@",gpsstate];
                [self BookLog:@"正在传输GPS定位数据"];
            }
        }
        
        
        LngOLatstr=[[NSMutableArray alloc]init];
        [LngOLatstr addObject:deviceName];
        // GGText.text= [[GGText.text stringByAppendingString:@"\n"] stringByAppendingString:deviceName];
        hasFind=true;
        
    }else if(hasFind==true)
    {
        [LngOLatstr addObject:deviceName];
    }
    else
    {
        [self BookLog:@"未获取GPS定位数据"];
    }
    
    NSLog(@"Unknow value = %@", deviceName);
 
    
    
    NSLog(@"Done");

}
@catch (NSException *exception) {
    [self BookLog:@"设备未激活，请先进行激活操作"];
}






}






@end
