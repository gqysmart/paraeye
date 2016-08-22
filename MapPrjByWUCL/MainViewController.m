//
//  MainViewController.m
//  MapPrjByWUCL
//
//  Created by JSJM on 14-5-10.
//  Copyright (c) 2014年 cc. All rights reserved.
//

#import "MainViewController.h"
#import "LayerViewController.h"
#import "WBAAppDelegate.h"
#import "IdentifyViewController.h"
#import "TubeStatisticsView.h"
#import "PolygonQueryViewController.h"
#import "PointStatisticsViewController.h"
#import "BlueToothViewController.h"
#import "BufferQueryController.h"
#import "LSBGetDegress.h"
#import "DialogController.h"
#import <ArcGIS/ArcGIS.h>//GIS
#import "proClass.h"  //真机调试时，使用gps，需使用此方法转换wgs84到bj54坐标系下，同样反注释gps定位方法

@interface MainViewController ()
@end

@implementation MainViewController
@synthesize mapView = _mapView,identifyParams=_identifyParams,identifyTask=_identifyTask,query=_query,queryTask=_queryTask;
@synthesize geometrySeviceTask=_geometrySeviceTask,BufferParameters=_BufferParameters;
@synthesize measureOption,lblValue,PopView;
@synthesize mylocationManager;
@synthesize CalloutTemplate;
@synthesize CameraHelper,CameraView,BtnVirtual,activityIndicatorView;
@synthesize ORIEnvelop=_ORIEnvelop;
@synthesize Qquery,Full,Area,Length,Position,Clear,OArea,OClear,OFull,OLength,OPosition,OQuery,G1,G2,G3,G4,G5,G6,G7;



LayerViewController *LyrViewController;
IdentifyViewController *IdentifyController;
TubeStatisticsView *TubeStatisticsController;
BufferQueryController *BufferQueryViewController;
CircleQueryViewController *CircleQueryController;
PolygonQueryViewController *PolygonQueryController;
PointStatisticsViewController *PointStatisticsController;
BlueToothViewController *BlueToothController;
CameraViewController *CameraController;
DialogController *dia;
WBAAppDelegate *appDelegate;


AGSEnvelope *env;
AGSGraphicsLayer *graphicsLayer;
AGSGraphicsLayer *GPSgraphicsLayer;
AGSSketchGraphicsLayer *sketchLayer;
AGSGraphicsLayer *ATTgraphicsLayer;//属性查询要素高亮图层


NSMutableArray *ServiceArray2;
NSMutableArray *ServiceArray;
int WebType;
NSMutableDictionary *Servicelstattribute;
NSMutableArray *DataSourceValues;
NSString *WebIP;
NSMutableArray *layerarr;//动态图层_图层集合，为nil时默认对全图层选中（信息查询功能）
UIColor *gridLineColor;
AGSGDBGeodatabase *gdb=nil;//初始化矢量离线数据库





- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.mapView=self.mapView;
    appDelegate.BLUETOOTHABLE=false;
    self.mapView.callout.delegate=self;
    NSUserDefaults *defal = [NSUserDefaults standardUserDefaults];
    WebIP = [defal stringForKey:@"WebServiceServiceIP"];
    
    PopView.hidden=true;//遮罩层
    
    
    
    env=[[AGSEnvelope alloc] initWithXmin:108355.439760 ymin:128411.588308 xmax:150688.857760 ymax:156930.497531 spatialReference:self.mapView.spatialReference];
    // env=[[AGSEnvelope alloc] initWithXmin:133377.495569107 ymin:87449.2060136829 xmax:175710.913569277 ymax:110038.053274711 spatialReference:self.mapView.spatialReference];
    
    //  env=[[AGSEnvelope alloc] initWithXmin:128378.38151914049 ymin:148319.75125168345 xmax:129618.25728561192 ymax:148981.34121144906 spatialReference:self.mapView.spatialReference];
    
    WebType=0;
    
    if(appDelegate.NETWORKABLE)
    {
        //gqy test1
        [self GetWebServiceBy:nil];
        //gqy test1 end
    }
    else
    {
        if(dia==nil)
        {
            dia=[[DialogController alloc ]init];
            dia.view.frame=CGRectMake(0,0,1024,768);
        }
        
        dia.info.text=@"未连接服务器，离线模式开启";
        [self.view addSubview:dia.view];
        
    }
    
    
    
    
    [self ControlVisiable:appDelegate.NETWORKABLE];
    [self initLayer];
    
    LyrViewController=[[LayerViewController alloc] init];
    LyrViewController.view.frame=CGRectMake(657, 60, 355, 673);
    LyrViewController.myLayerViewDelegate=self;
    [LyrViewController GetMapSource:Servicelstattribute];
    
    mylocationManager = [[CLLocationManager alloc] init];
    mylocationManager.delegate = self; // send loc updates to myself
    [mylocationManager requestAlwaysAuthorization];
    mylocationManager.distanceFilter = 5;  // 1 kilometer
    mylocationManager.desiredAccuracy = kCLLocationAccuracyBest; //精度
    
    GPSgraphicsLayer = [[[AGSGraphicsLayer alloc] init] autorelease];
    [self.mapView addMapLayer:GPSgraphicsLayer withName:@"position"];
    
    graphicsLayer = [[AGSGraphicsLayer alloc] init];
    [self.mapView addMapLayer:graphicsLayer withName:@"graphicsLayer"];
    
    sketchLayer = [[AGSSketchGraphicsLayer alloc] initWithGeometry:nil];
    [self.mapView addMapLayer:sketchLayer withName:@"Sketch layer"];
    ATTgraphicsLayer=[[AGSGraphicsLayer alloc] init];
    [self.mapView addMapLayer:ATTgraphicsLayer withName:@"ATTlayer"];
    
    self.mapView.minResolution=1;
    self.mapView.maxScale=1;
    gridLineColor=self.mapView.gridLineColor;
    
    [self LinkGDBData];//实例化离线数据库
}



- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    @try {
        [GPSgraphicsLayer removeAllGraphics];
        
        CGPoint pnt;
        pnt.x = newLocation.coordinate.longitude;
        pnt.y = newLocation.coordinate.latitude;
        
//       proClass *progect=[[proClass alloc] init];
//       NSString *str=[progect ConvertWGS84ToNJ92FromL:pnt.x FromB:pnt.y];
//       NSArray *theArray = [str componentsSeparatedByString:@";"];
//       double xvalue=[[theArray objectAtIndex:0] doubleValue];
//        double yvalue=[[theArray objectAtIndex:1] doubleValue];
//       AGSPoint *mappoint =[[AGSPoint alloc] initWithX:xvalue y:yvalue spatialReference:self.mapView.spatialReference ];
        
       AGSPoint *mappoint =[[AGSPoint alloc] initWithX:pnt.x y:pnt.y spatialReference:self.mapView.spatialReference ];
        
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
        
        [GPSgraphicsLayer addGraphic:gra];
        [gra release];
        
//        AGSMutableEnvelope *newEnv =[AGSMutableEnvelope envelopeWithXmin:mappoint.envelope.xmin-1000
//                                                                    ymin:mappoint.envelope.ymin-1000
//                                                                    xmax:mappoint.envelope.xmax+1000
//                                                                    ymax:mappoint.envelope.ymax+1000
//                                                        spatialReference:self.mapView.spatialReference];
        
        //[self.mapView zoomToEnvelope:newEnv animated:YES];
        [self.mapView centerAtPoint:mappoint animated:true];
    }
    @catch (NSException *exception)
    {
        if(dia==nil)
        {
            dia=[[DialogController alloc ]init];
            dia.view.frame=CGRectMake(0,0,1024,768);
        }
        
        dia.info.text=exception.name;
        [self.view addSubview:dia.view];
//        UIAlertView *alert = [[UIAlertView alloc]
//                              initWithTitle:@"提示"
//                              message:exception.name
//                              delegate:self
//                              cancelButtonTitle:nil
//                              otherButtonTitles:@"确定", nil];
//        
//        [alert show];
    }
}












//获得图层集合
-(NSMutableArray *) GetlayerCountArr
{
    
    NSMutableArray *arr=[[NSMutableArray alloc] init ];
    NSString *value=[[[DataSourceValues objectAtIndex:0] componentsSeparatedByString:@"$"] objectAtIndex:1];
    NSString *url2=[[value componentsSeparatedByString:@";"] objectAtIndex:1];
    NSURL* url = [NSURL URLWithString:url2];
   // AGSDynamicMapServiceLayer *layer = [[AGSDynamicMapServiceLayer alloc] initWithURL:[[NSURL alloc] initWithString:url]];
   AGSDynamicMapServiceLayer *layer= [AGSDynamicMapServiceLayer dynamicMapServiceLayerWithURL: url];
   
    NSInteger s=layer.visibleLayers.count;
    NSLog (@"1111");
    NSLog (@"%ld",(long)s);
    [arr addObjectsFromArray:layer.visibleLayers ];
       return arr;
}


- (AGSLayer *) CreatLayerWithUrl:(NSString *)url withType:(NSString *)type
{
	AGSLayer *layer;
	if ([type isEqualToString:@"Tiled"])
    {
        layer = [[AGSTiledMapServiceLayer alloc] initWithURL:[[NSURL alloc] initWithString:url]];
    }
    else if ([type isEqualToString:@"Dynamic"])
    {
        layer = [[AGSDynamicMapServiceLayer alloc] initWithURL:[[NSURL alloc] initWithString:url]];
    }
    else
        layer=[[AGSLayer alloc] init];
    
	return layer;
}



- (void)initLayer
{
    @try
    {
        
        if(appDelegate.NETWORKABLE==false)
        {
         AGSLocalTiledLayer *LocalTileLayer=[AGSLocalTiledLayer localTiledLayerWithName:@"NJbase"];
        [self.mapView addMapLayer:LocalTileLayer withName:@"BaseLayer"];
        AGSLocalTiledLayer *GXTileLayer=[AGSLocalTiledLayer localTiledLayerWithName:@"main"];
        [self.mapView addMapLayer:GXTileLayer withName:@"GXLayer"];
            
        }
        else
        {
            for (int i=DataSourceValues.count-1; i>=0; i--) {
                NSString *value=[[[DataSourceValues objectAtIndex:i] componentsSeparatedByString:@"$"] objectAtIndex:1];
                NSString *title=[[value componentsSeparatedByString:@";"] objectAtIndex:0];
                NSString *url=[[value componentsSeparatedByString:@";"] objectAtIndex:1];
                NSString *type=[[value componentsSeparatedByString:@";"] objectAtIndex:2];
                BOOL visable=[[[value componentsSeparatedByString:@";"] objectAtIndex:3] boolValue];
                if (visable) {
                    AGSLayer *MapLyr = [self CreatLayerWithUrl:url withType:type];
                    MapLyr.visible=visable;
                    MapLyr.maxScale=1;

                    [self.mapView addMapLayer:MapLyr withName:title];
                                   }
            }
        }
        

        [self.mapView zoomToEnvelope:env animated:YES];
        
    }
    @catch (NSException *exception)
    {
        
        if(dia==nil)
        {
            dia=[[DialogController alloc ]init];
            dia.view.frame=CGRectMake(0,0,1024,768);
        }
        
        dia.info.text=exception.name;
        [self.view addSubview:dia.view];

        
//        UIAlertView *alert = [[UIAlertView alloc]
//                              initWithTitle:@"提示"
//                              message:exception.name
//                              delegate:self
//                              cancelButtonTitle:nil
//                              otherButtonTitles:@"确定", nil];
//        
//        [alert show];
    }
}

-(IBAction)MapLayerIndexChangeFrom:(NSString *)name1 To:(NSString *)name2
{
    @try {
        NSLog(@"%@,%@",name1,name2);
        NSString *title=[[name1 componentsSeparatedByString:@";"] objectAtIndex:0];
        NSString *url=[[name1 componentsSeparatedByString:@";"] objectAtIndex:1];
        NSString *type=[[name1 componentsSeparatedByString:@";"] objectAtIndex:2];
        
        AGSLayer *movlry = [self CreatLayerWithUrl:url withType:type];
        movlry.visible=[self.mapView mapLayerForName:title].visible;
    
        int insertnum = 0;
        for (int i=0;i<self.mapView.mapLayers.count;i++)
        {
            AGSLayer *lry=[self.mapView.mapLayers objectAtIndex:i];
            if ([lry.name isEqualToString:name2])
            {
                insertnum=i;
                break;
            }
        }
        NSLog(@"%d",insertnum);
        [self.mapView removeMapLayerWithName:title];
        [self.mapView insertMapLayer:movlry withName:title atIndex:insertnum];
    }
    @catch (NSException *exception)
    {
        
        if(dia==nil)
        {
            dia=[[DialogController alloc ]init];
            dia.view.frame=CGRectMake(0,0,1024,768);
        }
        
        dia.info.text=exception.name;
        [self.view addSubview:dia.view];

//        UIAlertView *alert = [[UIAlertView alloc]
//                              initWithTitle:@"提示"
//                              message:exception.name
//                              delegate:self
//                              cancelButtonTitle:nil
//                              otherButtonTitles:@"确定", nil];
//        
//        [alert show];
    }
}

-(IBAction)ClearALL:(id)sender
{
    [self.mapView.callout dismiss];
   //layerarr=[self GetlayerCountArr];
    [graphicsLayer removeAllGraphics];
    [ATTgraphicsLayer removeAllGraphics];
    [sketchLayer clear];
    lblValue.text=@"";
    measureOption.hidden=TRUE;
    
    if (LyrViewController!=Nil) {
        [LyrViewController.view removeFromSuperview];
    }
    if (IdentifyController!=Nil) {
        [IdentifyController.view removeFromSuperview];
    }
    if(TubeStatisticsController!=nil)
    {
        [TubeStatisticsController.view removeFromSuperview];
    }
    if(BufferQueryViewController!=nil)
    {
        [BufferQueryViewController.view removeFromSuperview];
    }
    if(CircleQueryController!=nil)
    {
        [CircleQueryController.view removeFromSuperview];
    }
    if( PolygonQueryController!=nil)
    {
        [PolygonQueryController.view removeFromSuperview];
    }
//    if( BlueToothController!=nil)
//    {
//        [BlueToothController.view removeFromSuperview];
//    }
    
    self.mapView.touchDelegate = Nil;
}

-(IBAction)btnbackClick:(id)sender
{
   // [self.view removeFromSuperview];
    
  UIWindow *window = appDelegate.window;
    [UIView animateWithDuration:1.0f animations:^{
        window.alpha=0;
        window.frame=CGRectMake(0, window.bounds.size.width, 0, 0);
    }completion:^(BOOL finished){exit(0);}];
    
}

-(IBAction)btnFullMapClick:(id)sender
{
    [self.mapView zoomToEnvelope:env animated:YES];
}








-(IBAction)btnLayerControlClick:(id)sender
{
    if(appDelegate.NETWORKABLE==false)
    {
        if(dia==nil)
        {
            
            dia=[[DialogController alloc ]init];
            dia.view.frame=CGRectMake(0, 0, 1024, 768);
        }
        dia.info.text=@"当前为离线模式，仅可使用离线数据";
        [[self   MainView] addSubview:dia.view];
        return;
    }
    
    [self ClearALL:nil];
    
    if (LyrViewController==Nil) {
        LyrViewController=[[LayerViewController alloc] init];
        LyrViewController.view.frame=CGRectMake(657, 60, 355, 673);
        LyrViewController.myLayerViewDelegate=self;
        [self.view addSubview:LyrViewController.view];
        [LyrViewController GetMapSource:Servicelstattribute];
    }
    else
    {
        LyrViewController.view.frame=CGRectMake(657, 60, 355, 673);
        [self.view addSubview:LyrViewController.view];
    }
}

-(IBAction)btnIdentifyClick:(id)sender
{
    [self ClearALL:nil];
    
    IdentifyController=[[IdentifyViewController alloc] init];
    IdentifyController.view.frame=CGRectMake(657, 60, 355, 673);
    IdentifyController.myIdentifyViewDelegate=self;
    [self.view addSubview:IdentifyController.view];
 
}









-(IBAction)btnLayerViewClick
{
    int movement = 338;
    if (LyrViewController.view.frame.origin.x>800) {
        movement = -338;
    }
    const float movementDuration = 0.3f; // tweak as needed
 
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    LyrViewController.view.frame = CGRectOffset(LyrViewController.view.frame, movement, 0);
    [UIView commitAnimations];
}

-(IBAction)btnIdentifyViewClick
{
    int movement = 338;
    if (IdentifyController.view.frame.origin.x>800) {
        movement = -338;
    }
    const float movementDuration = 0.3f; // tweak as needed
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    IdentifyController.view.frame = CGRectOffset(IdentifyController.view.frame, movement, 0);
    [UIView commitAnimations];
}


-(IBAction)btnBlueToothViewClick
{
    int movement = 338;
    if (BlueToothController.view.frame.origin.x>800) {
        movement = -338;
    }
    const float movementDuration = 0.3f; // tweak as needed
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    BlueToothController.view.frame = CGRectOffset(BlueToothController.view.frame, movement, 0);
    [UIView commitAnimations];
}


-(IBAction)btnPolygonQueryshoworhide
{
    int movement = 338;
    if (PolygonQueryController.view.frame.origin.x>800) {
        movement = -338;
    }
    const float movementDuration = 0.3f; // tweak as needed
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    PolygonQueryController.view.frame = CGRectOffset(PolygonQueryController.view.frame, movement, 0);
    [UIView commitAnimations];
}




-(IBAction)btnTubeStatisticsClick
{
    int movement = 338;
    if (TubeStatisticsController.view.frame.origin.x>800) {
        movement = -338;
    }
    const float movementDuration = 0.3f; // tweak as needed
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    TubeStatisticsController.view.frame = CGRectOffset(TubeStatisticsController.view.frame, movement, 0);
    [UIView commitAnimations];
}


// 缓冲区查询界面
-(IBAction)btnBufferQueryClick
{
    int movement = 338;
    if (BufferQueryViewController.view.frame.origin.x>800) {
        movement = -338;
    }
    const float movementDuration = 0.3f; // tweak as needed
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    BufferQueryViewController.view.frame = CGRectOffset(BufferQueryViewController.view.frame, movement, 0);
    [UIView commitAnimations];
}


//按圆查询界面
-(IBAction)btnCircleQueryhideorshow
{
    int movement = 338;
    if (CircleQueryController.view.frame.origin.x>800) {
        movement = -338;
    }
    const float movementDuration = 0.3f; // tweak as needed
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    CircleQueryController.view.frame = CGRectOffset(CircleQueryController.view.frame, movement, 0);
    [UIView commitAnimations];
}









-(IBAction)btnPositionClick:(UIButton*)sender
{if(appDelegate.BLUETOOTHABLE==true)
    {
       
        [mylocationManager stopUpdatingLocation];
        if (sender.tag==2222) {
            
            [BlueToothController StartNotice];
            sender.tag=3333;
        }else
        {
            [BlueToothController CancelNotice];
            sender.tag=2222;
        }
        
        
        
    }
    else
    {
        sender.tag=2222;
    if(GPSgraphicsLayer.graphics.count!=0)
	{
        [BlueToothController BookLog:@"定位取消"];
        [mylocationManager stopUpdatingLocation];
        
		[GPSgraphicsLayer removeAllGraphics];
	}
	else
	{
        [BlueToothController BookLog:@"没有连接到有效蓝牙设备，启动普通定位"];
		[mylocationManager startUpdatingLocation];
	}
    }
}














//获得服务
-(void)GetWebServiceBy:(NSString*)SearchKey
{
    @try
    {
        NSString *soapMessage;
        if (WebType==0) {
            soapMessage = [NSString stringWithFormat:
                           @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                           "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                           "<soap:Body>"
                           "<GetServiceSource xmlns=\"http://tempuri.org/\"/>"
                           "</soap:Body>"
                           "</soap:Envelope>"];
        }
        else
            return;
        
        NSString *msgLength = [NSString stringWithFormat:@"%d", [soapMessage length]];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/MapPrjWebServicePub/WebService.asmx",WebIP]];
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
        [urlRequest addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [urlRequest addValue: msgLength forHTTPHeaderField:@"Content-Length"];
        //[urlRequest addValue: @"http://tempuri.org/QueryMainInfoByCellID" forHTTPHeaderField:@"SOAPAction"];
        [urlRequest setHTTPMethod:@"POST"];
        [urlRequest setHTTPBody: [soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
        NSURLResponse *reponse;
        NSError *error = nil;
        NSData *responseData =[NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&reponse error:&error];
        
        if(error!=nil)
        {
            appDelegate.NETWORKABLE=false;
            if(dia==nil)
            {
                dia=[[DialogController alloc ]init];
                dia.view.frame=CGRectMake(0,0,1024,768);
            }
            
            dia.info.text=@"当前无网络，自动采用离线模式";
            [self.view addSubview:dia.view];

//            UIAlertView *alert = [[UIAlertView alloc]
//                                  initWithTitle:@"提示"
//                                  message:[error description]
//                                  delegate:self
//                                  cancelButtonTitle:nil
//                                  otherButtonTitles:@"确定", nil];
//            [alert show];
        }
        else
        {
            appDelegate.NETWORKABLE=true;

            if(responseData)
            {
                NSXMLParser *myParser=[[NSXMLParser alloc]initWithData:responseData];
                [myParser setDelegate:self];
                [myParser parse];
            }
        }
    }
    @catch (NSException *exception)
    {
          appDelegate.NETWORKABLE=false;
        if(dia==nil)
        {
            dia=[[DialogController alloc ]init];
            dia.view.frame=CGRectMake(0,0,1024,768);
        }
        
        dia.info.text=exception.name;
        [self.view addSubview:dia.view];
//        UIAlertView *alert = [[UIAlertView alloc]
//                              initWithTitle:@"提示"
//                              message:exception.name
//                              delegate:self
//                              cancelButtonTitle:nil
//                              otherButtonTitles:@"确定", nil];
//        [alert show];
    }
}


-(void)parserDidStartDocument:(NSXMLParser *)parser
{
    if (WebType==0) {
        DataSourceValues=[[NSMutableArray alloc]init];
    }
}

//长度测量
-(IBAction)btnJLMeasureClick:(id)sender
{
    [sketchLayer clear];
    lblValue.text=@"";
    appDelegate. identifyFlag=true;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToGeomChanged:) name:AGSSketchGraphicsLayerGeometryDidChangeNotification object:nil];//GeometryChanged时调用
   	
    self.mapView.touchDelegate = sketchLayer;
	sketchLayer.geometry = [[AGSMutablePolyline alloc] initWithSpatialReference:self.mapView.spatialReference];
	
	AGSSimpleLineSymbol *LineSymbol =[AGSSimpleLineSymbol simpleLineSymbol];
	LineSymbol.color=[[UIColor redColor] colorWithAlphaComponent:0.60];
	LineSymbol.width=11;
    
    AGSCompositeSymbol *Symbol=[[AGSCompositeSymbol alloc]init];
    [Symbol addSymbol:LineSymbol];
    
	AGSSimpleMarkerSymbol *MarkerSymbol =[AGSSimpleMarkerSymbol simpleMarkerSymbol];
	MarkerSymbol.color=[[UIColor blueColor] colorWithAlphaComponent:0.80];
	MarkerSymbol.size=CGSizeMake(16, 16);
	
	sketchLayer.vertexSymbol=MarkerSymbol;
	sketchLayer.mainSymbol=Symbol;
}










//面积测量
-(IBAction)btnMJMeasureClick:(id)sender
{
    [sketchLayer clear];
    lblValue.text=@"";
    appDelegate. identifyFlag=true;

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToGeomChanged:) name:AGSSketchGraphicsLayerGeometryDidChangeNotification object:nil];//GeometryChanged时调用
	self.mapView.touchDelegate = sketchLayer;
	sketchLayer.geometry = [[AGSMutablePolygon alloc] initWithSpatialReference:self.mapView.spatialReference];
	AGSSimpleFillSymbol *FillSymbol = [AGSSimpleFillSymbol simpleFillSymbol];
	FillSymbol.color = [[UIColor redColor] colorWithAlphaComponent:0.40];
	FillSymbol.outline.color = [UIColor whiteColor];
	FillSymbol.outline.width=0;
	AGSSimpleMarkerSymbol *MarkerSymbol =[AGSSimpleMarkerSymbol simpleMarkerSymbol];
	MarkerSymbol.color=[[UIColor blueColor] colorWithAlphaComponent:0.80];
	MarkerSymbol.size=CGSizeMake(16, 16);
	AGSCompositeSymbol *Symbol=[[AGSCompositeSymbol alloc]init];
	[Symbol addSymbol:FillSymbol];
	sketchLayer.vertexSymbol=MarkerSymbol;
	sketchLayer.mainSymbol=Symbol;
}







//地图绘制反馈
- (void)respondToGeomChanged: (NSNotification*) notification
{
	if (![sketchLayer.geometry isEmpty])
	{
      
        if(  appDelegate.identifyFlag==true)
        {
        if (measureOption.hidden==TRUE) {
            measureOption.hidden=FALSE;
        }
        }
        else
        {
            measureOption.hidden=true;
        }
        
		AGSGeometry *geom =sketchLayer.geometry;
		AGSGeometryEngine *myGeoEngine=[[AGSGeometryEngine alloc]init];
		AGSGeometry *geochange=[myGeoEngine projectGeometry:geom toSpatialReference:self.mapView.spatialReference];

        
        
        
        
        
		//图形为line计算长度
		if([geochange isKindOfClass:[AGSPolyline class]]){
			
			double length=[myGeoEngine lengthOfGeometry:(geochange)];
			if (length != 0) {
		              
                                 NSLog(@"length=%0.3f",fabs(length));
                    if (fabs(length)<100000) {
                        lblValue.text = [[NSString stringWithFormat:@"%0.3f", fabs(length)] stringByAppendingFormat: @" 米"];
                    }
                    else
                    {
                        lblValue.text = [[NSString stringWithFormat:@"%0.3f", fabs(length)/1000] stringByAppendingFormat: @" 公里"];
                    }
                    
              
			 		
		}
        }
        //
		
        //图形为polygon面积计算
		if([geochange isKindOfClass:[AGSPolygon class]]){
			double area=[myGeoEngine areaOfGeometry:(geochange)];
			if (area != 0) {
				NSLog(@"area=%0.3f",fabs(area));
                if (fabs(area)<1000*1000) {
                    lblValue.text = [[NSString stringWithFormat:@"%0.3f", fabs(area)] stringByAppendingFormat: @" 平方米"];
                }
                else
                {
                    lblValue.text = [[NSString stringWithFormat:@"%0.3f", fabs(area)/1000000] stringByAppendingFormat: @" 平方公里"];
                }
            }
			
		}
        //
        
        
       
        
	}
	
}




-(void)queryTask:(AGSQueryTask *)queryTask operation:(NSOperation *)op didExecuteWithFeatureSetResult:(AGSFeatureSet *)featureSet
{
    NSLog(@"%d",featureSet.features.count);
    //featureSet.features.
  NSLog(@"%d",  [featureSet.fields count]);
}

-(void)queryTask:(AGSQueryTask *)queryTask operation:(NSOperation *)op didFailWithError:(NSError *)error
{
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
//                                                    message:[error localizedDescription]
//                                                   delegate:nil
//                                         cancelButtonTitle:@"确定"
//                                          otherButtonTitles: nil];
//    alert.tag=1111;
//    [alert show];
//    [alert release];
}














-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
}

- (void)identifyTask:(AGSIdentifyTask *)identifyTask operation:(NSOperation *)op didExecuteWithIdentifyResults:(NSArray *)results
{
    [graphicsLayer removeAllGraphics];
    
    if ([results count] > 0)
    {
         IdentifyController.ServiceFieldarray=[[NSMutableArray alloc] init];
               [IdentifyController.ServiceFieldarray addObject:@"管线代码"];
        
               AGSGraphic *gra=((AGSIdentifyResult*)[results objectAtIndex:0]).feature;
        if (AGSGeometryTypeForGeometry(gra.geometry)==AGSGeometryTypePoint)
            {
            AGSPictureMarkerSymbol *PointSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"pushpin.png"];
            CGPoint pnt;
            pnt.x = 10;
            pnt.y = 10;
            PointSymbol.offset=pnt;
            gra.symbol=PointSymbol;
                [IdentifyController.ServiceFieldarray addObject:@"地面高程"];
                [IdentifyController.ServiceFieldarray addObject:@"特征点"];
                [IdentifyController.ServiceFieldarray addObject:@"附属物"];
                [IdentifyController.ServiceFieldarray addObject:@"所在道路"];
                [IdentifyController.ServiceFieldarray addObject:@"SSQY"];
                [IdentifyController.ServiceFieldarray addObject:@"权属单位"];
                [IdentifyController.ServiceFieldarray addObject:@"探测单位"];
                [IdentifyController.ServiceFieldarray addObject:@"探测日期"];
                [IdentifyController.ServiceFieldarray addObject:@"井盖材质"];
                [IdentifyController.ServiceFieldarray addObject:@"井盖直径"];
                [IdentifyController.ServiceFieldarray addObject:@"井盖长"];
                [IdentifyController.ServiceFieldarray addObject:@"井盖宽"];
                [IdentifyController.ServiceFieldarray addObject:@"井盖形状"];
                [IdentifyController.ServiceFieldarray addObject:@"检修井材质"];
                [IdentifyController.ServiceFieldarray addObject:@"井脖深"];
                [IdentifyController.ServiceFieldarray addObject:@"井室直径"];
//            [IdentifyController.ServiceFieldarray addObject:@"X坐标"];
//            [IdentifyController.ServiceFieldarray addObject:@"Y坐标"];
//            [IdentifyController.ServiceFieldarray addObject:@"井深"];
//            [IdentifyController.ServiceFieldarray addObject:@"井盖材质"];
//            [IdentifyController.ServiceFieldarray addObject:@"所在道路"];
            }
        else if (AGSGeometryTypeForGeometry(gra.geometry)==AGSGeometryTypePolyline) {
            AGSSimpleFillSymbol *LineSymbol = [AGSSimpleFillSymbol simpleFillSymbol];
            LineSymbol.color = [UIColor clearColor];
            LineSymbol.outline.color = [[UIColor purpleColor] colorWithAlphaComponent:0.80];
            LineSymbol.outline.style = AGSSimpleLineSymbolStyleSolid;
            LineSymbol.outline.width = 8;
            gra.symbol=LineSymbol;
            
            [IdentifyController.ServiceFieldarray addObject:@"材质"];
            [IdentifyController.ServiceFieldarray addObject:@"管径"];
            [IdentifyController.ServiceFieldarray addObject:@"所在道路"];
            [IdentifyController.ServiceFieldarray addObject:@"SSQY"];
            [IdentifyController.ServiceFieldarray addObject:@"权属单位"];
            [IdentifyController.ServiceFieldarray addObject:@"建设年代"];
            [IdentifyController.ServiceFieldarray addObject:@"电压值"];
            [IdentifyController.ServiceFieldarray addObject:@"压力"];
            [IdentifyController.ServiceFieldarray addObject:@"总孔数"];
            [IdentifyController.ServiceFieldarray addObject:@"占用孔数"];
            [IdentifyController.ServiceFieldarray addObject:@"电缆条数"];
            [IdentifyController.ServiceFieldarray addObject:@"起点高程"];
            [IdentifyController.ServiceFieldarray addObject:@"终点高程"];
            [IdentifyController.ServiceFieldarray addObject:@"起点埋深"];
            [IdentifyController.ServiceFieldarray addObject:@"终点埋深"];
            [IdentifyController.ServiceFieldarray addObject:@"埋设类型"];
            [IdentifyController.ServiceFieldarray addObject:@"探测单位"];
            [IdentifyController.ServiceFieldarray addObject:@"探测日期"];
           

//            [IdentifyController.ServiceFieldarray addObject:@"材质"];
//            [IdentifyController.ServiceFieldarray addObject:@"管径"];
//            [IdentifyController.ServiceFieldarray addObject:@"起点埋深"];
//            [IdentifyController.ServiceFieldarray addObject:@"终点埋深"];
//            [IdentifyController.ServiceFieldarray addObject:@"建设年代"];
//            [IdentifyController.ServiceFieldarray addObject:@"所在道路"];
//            [IdentifyController.ServiceFieldarray addObject:@"权属单位"];
           
           
        }
        else if (AGSGeometryTypeForGeometry(gra.geometry)==AGSGeometryTypePolygon) {
            AGSSimpleFillSymbol *FillSymbol = [AGSSimpleFillSymbol simpleFillSymbol];
            FillSymbol.style = AGSSimpleFillSymbolStyleCross;
            FillSymbol.color = [[UIColor blackColor] colorWithAlphaComponent:0.80];
            FillSymbol.outline.color = [[UIColor blueColor] colorWithAlphaComponent:0.80];
            FillSymbol.outline.style = AGSSimpleLineSymbolStyleSolid;
            FillSymbol.outline.width = 2;
            
            gra.symbol=FillSymbol;
        }
        
        [graphicsLayer addGraphic:gra];
        
        if (IdentifyController!=Nil) {
            [IdentifyController BingData:gra.allAttributes];
        }
        
        [activityIndicatorView stopAnimating];
         PopView.hidden=true;
    }
    else
    {
        if (IdentifyController!=Nil) {
            [IdentifyController BingData:nil];
        }
        [activityIndicatorView stopAnimating];
         PopView.hidden=true;
        
        
        if(dia==nil)
        {
        
        dia=[[DialogController alloc ]init];
        dia.view.frame=CGRectMake(0, 0, 1024, 768);
        }
        dia.info.text=@"没有选中可查询的对象";
        [self.view addSubview:dia.view];
        
//        
//        UIAlertView *alert = [[UIAlertView alloc]
//                              initWithTitle:@"提示"
//                              message:@"没有选中可查询的对象!"
//                              delegate:self
//                              cancelButtonTitle:nil
//                              otherButtonTitles:@"确定", nil];
//        [alert show];
        
    }
}


- (void)mapView:(AGSMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint graphics:(NSDictionary *)graphics
{
    @try
    {
        if(appDelegate.NETWORKABLE==false)
        {
        NSLog(@"X:%f Y:%f",mappoint.envelope.xmax,mappoint.envelope.ymax);
            AGSEnvelope *enve=[[AGSEnvelope alloc]initWithXmin:mappoint.envelope.xmin-0.5 ymin:mappoint.envelope.ymin-0.5 xmax:mappoint.envelope.xmax+0.5 ymax:mappoint.envelope.ymax+0.5 spatialReference:self.mapView.spatialReference];
            [self searchInfo:enve gdbfile:gdb];
            
        }
        else
        {
        PopView.hidden=false;
        [activityIndicatorView startAnimating];

        
        self.identifyParams.geometry = mappoint;
        //execute the task
        [self.identifyTask executeWithParameters:self.identifyParams];
        }
       
    }
    @catch (NSException *exception)
    {
        
        if(dia==nil)
        {
            dia=[[DialogController alloc ]init];
            dia.view.frame=CGRectMake(0,0,1024,768);
        }
        
        dia.info.text=exception.name;
        [self.view addSubview:dia.view];
//        UIAlertView *alert = [[UIAlertView alloc]
//                              initWithTitle:@"提示"
//                              message:exception.name
//                              delegate:self
//                              cancelButtonTitle:nil
//                              otherButtonTitles:@"确定", nil];
//        [alert show];
    }
}



-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{

    if (WebType==0) {
        [DataSourceValues addObject:string];
    }
}

-(void)parserDidEndDocument:(NSXMLParser *)parser
{
    if (WebType==0) {
        if ([DataSourceValues count]>0)
        {
             Servicelstattribute=[[NSMutableDictionary alloc] init];
            for (NSString *item in DataSourceValues) {
                 NSArray *array = [item componentsSeparatedByString:@"$"];
                  NSLog(@"%@",[array objectAtIndex:0]);
                  NSLog(@"%@",[array objectAtIndex:1]);
                if ([[Servicelstattribute allKeys] containsObject:[array objectAtIndex:0]]) {
                    [[Servicelstattribute objectForKey:[array objectAtIndex:0]] addObject:[array objectAtIndex:1]];
                }
                else{
                    NSLog(@"%@",[array objectAtIndex:0]);
                    ServiceArray = [[NSMutableArray alloc] init];
                    [ServiceArray addObject:[array objectAtIndex:1]];
                    [Servicelstattribute setValue:ServiceArray forKey:[array objectAtIndex:0]];
                }
            }
        }
    }
}

-(void)IdentifyBegion:(NSString *)URL LayerID:(int)identifylayer
{
    
    //create identify task
    self.identifyTask =
    [AGSIdentifyTask identifyTaskWithURL:[NSURL URLWithString:URL]];
    //create identify parameters
    self.identifyParams = [[AGSIdentifyParameters alloc] init];
    //the layer we want is layer ‘5’ (from the map service doc)
    //self.identifyParams.l.layerIds = layerarr;//[NSArray arrayWithObjects:[NSNumber numberWithInt:identifylayer], nil];
    self.identifyParams.tolerance =5;
    self.identifyParams.size = self.mapView.bounds.size;
    self.identifyParams.mapEnvelope = self.mapView.visibleArea.envelope;
    self.identifyParams.returnGeometry = YES;
    self.identifyParams.layerOption = AGSIdentifyParametersLayerOptionAll;
    self.identifyParams.spatialReference = self.mapView.spatialReference;
    self.identifyTask.delegate = self;
    self.mapView.touchDelegate = self;
}

- (void)identifyTask:(AGSIdentifyTask *)identifyTask operation:(NSOperation *)op didFailWithError:(NSError *)error {
    
    
    if(dia==nil)
    {
        dia=[[DialogController alloc ]init];
        dia.view.frame=CGRectMake(0,0,1024,768);
    }
    
    dia.info.text=[error localizedDescription];
    [self.view addSubview:dia.view];
    
    [self ClearALL:nil];
    PopView.hidden=true;
    [activityIndicatorView stopAnimating];
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
//                                                    message:[error localizedDescription]
//                                                   delegate:nil
//                                          cancelButtonTitle:@"OK"
//                                          otherButtonTitles:nil];
//    [alert show];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}






//按圆查询
- (IBAction)btnCircleQueryClick:(UIButton *)sender {
    
    
    
    
    
    [self ClearALL:nil];
    if (CircleQueryController   ==nil) {
        
       CircleQueryController=[[CircleQueryViewController alloc] init];
        CircleQueryController.view.frame=CGRectMake(657, 60, 355, 673);
        CircleQueryController.myCircleQueryDelegate=self;
        [self.view addSubview:CircleQueryController.view];
        
    }
    else
    {
        CircleQueryController.view.frame=CGRectMake(657, 60, 355, 673);
        [self.view addSubview:CircleQueryController.view];
        
    }
    
    
    
//    
//    [self ClearALL:nil];//取消绘制状态
//    
//    
////预先绘制直线，获取第二点后构圆
//    [sketchLayer clear];
//    lblValue.text=@"";
//    
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToGeomChanged:) name:AGSSketchGraphicsLayerGeometryDidChangeNotification object:nil];//GeometryChanged时调用
//   	
//    self.mapView.touchDelegate = sketchLayer;
//	sketchLayer.geometry = [[AGSMutablePolyline alloc] initWithSpatialReference:self.mapView.spatialReference];
//	
//	AGSSimpleLineSymbol *LineSymbol =[AGSSimpleLineSymbol simpleLineSymbol];
//	LineSymbol.color=[[UIColor redColor] colorWithAlphaComponent:0.60];
//	LineSymbol.width=6;
//    
//    AGSCompositeSymbol *Symbol=[[AGSCompositeSymbol alloc]init];
//    [Symbol addSymbol:LineSymbol];
//    
//	AGSSimpleMarkerSymbol *MarkerSymbol =[AGSSimpleMarkerSymbol simpleMarkerSymbol];
//	MarkerSymbol.color=[[UIColor brownColor] colorWithAlphaComponent:0.80];
//	MarkerSymbol.size=CGSizeMake(10, 10);
//	sketchLayer.vertexSymbol=MarkerSymbol;
//	sketchLayer.mainSymbol=Symbol;
//    isDrawRange=true;
//
   
}





//按范围查询－－缓冲区查询
- (IBAction)btnRangeQueryClick:(UIButton *)sender {
    
    
    [self ClearALL:nil];
    if (BufferQueryViewController   ==nil) {
        
        BufferQueryViewController=[[BufferQueryController alloc] init];
        BufferQueryViewController.view.frame=CGRectMake(657, 60, 355, 673);
      BufferQueryViewController.myBufferQueryDelegate=self;
        [self.view addSubview:BufferQueryViewController.view];
      
    }
    else
    {
        BufferQueryViewController.view.frame=CGRectMake(657, 60, 355, 673);
        [self.view addSubview:BufferQueryViewController.view];
        
    }
    
}
















- (IBAction)btnTubePointAnalystClick:(UIButton *)sender {
    [self ClearALL:nil];
    
    [self    callPointStatisticsWindow];
    PopView.hidden=false;
   }
//呼出管点统计窗口
-(void)callPointStatisticsWindow
{
    if (PointStatisticsController==nil) {
        
        PointStatisticsController=[[PointStatisticsViewController alloc] init];
        PointStatisticsController.view.frame=CGRectMake(200,200,640,310)   ;
        PointStatisticsController.myPointStatisticsDelegate=self;
        [self.view addSubview:PointStatisticsController.view];
    }
    else
    {
        PointStatisticsController.view.frame=CGRectMake(200,200,640,310)   ;
        
        [self.view addSubview:PointStatisticsController.view];
    }
}

//呼出管线统计窗口
-(void)callStatisticsWindow
{
    if (TubeStatisticsController==nil) {
        
    TubeStatisticsController=[[TubeStatisticsView alloc] init];
    TubeStatisticsController.view.frame=CGRectMake(200,200,640,310)   ;
    TubeStatisticsController.myTubeStatisticsDelegate=self;
    [self.view addSubview:TubeStatisticsController.view];
    }
    else
    {
        TubeStatisticsController.view.frame=CGRectMake(200,200,640,310)   ;

        [self.view addSubview:TubeStatisticsController.view];
    }
}

//管线分析
- (IBAction)btnTubeLineAnalystClick:(UIButton *)sender {
    [self ClearALL:nil];
    
    
    [self callStatisticsWindow];
    PopView.hidden=false;
}

- (IBAction)btnBlueteethGPSClick:(UIButton *)sender {
    
    
    
    [self ClearALL:nil];
    if (BlueToothController   ==nil) {
        
        BlueToothController=[[BlueToothViewController alloc] init];
        BlueToothController.view.frame=CGRectMake(657, 60, 355, 673);
        BlueToothController.myBlueToothViewDelegate=self;
        [self.view addSubview:BlueToothController.view];
        
    }
    else
    {
        BlueToothController.view.frame=CGRectMake(657, 60, 355, 673);
        [self.view addSubview:BlueToothController.view];
        
    }

    
    
//    NSString* str;
//    str=[[[[NSString stringWithFormat:@"%lf\n", self.mapView.visibleArea.envelope.xmin] stringByAppendingString:[NSString stringWithFormat:@"%lf\n", self.mapView.visibleArea.envelope.xmax]] stringByAppendingString:[NSString stringWithFormat:@"%lf\n", self.mapView.visibleArea.envelope.ymin]] stringByAppendingString:
//         [NSString stringWithFormat:@"%lf\n", self.mapView.visibleArea.envelope.ymax]];
//    
//    
//    
//    UIAlertView *aler=[[UIAlertView alloc] initWithTitle:@"beaty" message:str delegate:Nil cancelButtonTitle:@"beast" otherButtonTitles: nil];
//    [aler show  ];
}



- (IBAction)btnPolygonQueryClick:(UIButton *)sender {
     [self ClearALL:nil];
    if (PolygonQueryController ==Nil) {
        PolygonQueryController=[[PolygonQueryViewController alloc] init];
       PolygonQueryController.view.frame=CGRectMake(657, 60, 355, 673);
        PolygonQueryController.myPolygonQueryDelegate=self;
        [self.view addSubview:PolygonQueryController.view];
    }
    else
    {
        PolygonQueryController.view.frame=CGRectMake(657, 60, 355, 673);
        PolygonQueryController.myPolygonQueryDelegate=self;
        [self.view addSubview:PolygonQueryController.view];
    }



}

   




//////////////////测试感应器



- (IBAction)btnCallSensor:(UIButton *)sender {
    
   
    if ( CameraController ==Nil) {
        CameraController=[[ CameraViewController alloc] init];
         //CameraController.view.frame=CGRectMake(657, 60, 355, 673);
         CameraController.myCameraViewDelegate=self;
        [self.view addSubview: CameraController.view];
    }
    else
    {
        //CameraController.view.frame=CGRectMake(657, 60, 355, 673);
        CameraController.myCameraViewDelegate=self;
        [self.view addSubview: CameraController.view];
    }

}




///////////////照相机

- (IBAction)btnCallCamera:(UIButton *)sender {
    [self OpenCameraView];
   }


///////////////方向旋转
- (IBAction)BTnRotation:(UIButton *)sender {
//    if(GPSgraphicsLayer.graphicsCount>0)
//    {
    
    
    [self OpenCameraView];
   [self OpenAttitudeSensor];
//    }
//    else
//    {
//        if(dia==nil)
//        {
//            dia=[[DialogController alloc ]init];
//            dia.view.frame=CGRectMake(0,0,1024,768);
//        }
//        
//        dia.info.text=@"请先进行定位";
//        [self.view addSubview:dia.view];
//    }
   }

bool isSensorStop=false;

//打开照相机界面
-(void)OpenCameraView
{
    if(CameraHelper==nil)
    {
      
       // self.ORIEnvelop=self.mapView.visibleArea.envelope;
        isSensorStop=false;//标记传感器开始旋转
        AGSPoint *Apoint=[[AGSPoint alloc] initWithX:(self.mapView.visibleArea.envelope.xmax-self.mapView.visibleArea.envelope.xmin)/2+self.mapView.visibleArea.envelope.xmin y:(self.mapView.visibleArea.envelope.ymax-self.mapView.visibleArea.envelope.ymin)/2+self.mapView.visibleArea.envelope.ymin spatialReference:self.mapView.spatialReference];
        
        
        NSLog(@"%f~~~%f",Apoint.x,Apoint.y);
        AGSMutableEnvelope *newEnv =[AGSMutableEnvelope envelopeWithXmin:Apoint.envelope.xmin-2
                                                                    ymin:Apoint.envelope.ymin-2
                                                                    xmax:Apoint.envelope.xmax+2
                                                                    ymax:Apoint.envelope.ymax+2
                                                        spatialReference:self.mapView.spatialReference];
        
        [self.mapView zoomToEnvelope:newEnv animated:YES];

  
        //换按钮背景图片
        [BtnVirtual setImage:[UIImage imageNamed:@"Virtualoff.png"] forState:UIControlStateNormal];
        //去除网格
        self.mapView.gridLineColor=[UIColor clearColor];
        
        
        CameraHelper = [[CameraImageHelper alloc]init];
        
        // 开始实时取景
        [CameraHelper startRunning];
        [CameraHelper embedPreviewInView:  CameraView];
        [CameraHelper changePreviewOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
        self.mapView.alpha=0.5;
    }
    else
    {
        isSensorStop=true;//标记传感器停止旋转
        self.mapView.gridLineColor=gridLineColor;
        //换按钮背景图片
       
        [BtnVirtual setImage:[UIImage imageNamed:@"Virtual.png"] forState:UIControlStateNormal];
        [CameraHelper stopRunning];
        CameraHelper=nil;
        self.mapView.alpha=1;
        
       
          }

}

//打开虚拟现实模拟
-(void)OpenAttitudeSensor
{
    double Minx,Miny,Maxx,Maxy;
    Minx=self.mapView.visibleArea.envelope.xmin;
    Miny=self.mapView.visibleArea.envelope.ymin;
    Maxx=self.mapView.visibleArea.envelope.xmax;
    Maxy=self.mapView.visibleArea.envelope.ymax;
    if(moM==nil)
    {
      //  measureOption.hidden=false;
        
        

        
        moM=[[CMMotionManager alloc]init];
        [LSBGetDegress getDegressByGravity:^(CMDeviceMotion  *latestDeviceMotion, NSError *error)
         {
             //[sender setTitle:[NSString stringWithFormat:@"%f",latestDeviceMotion.attitude.yaw] forState: UIControlStateNormal];
             
             
             if( isSensorStop==true) //由于具有滞后性，所以设置一个全局开关，防止延后使图不能回到初始位置
             {
                 self.mapView.rotationAngle=0;
             }
             else
             {
             self.mapView.rotationAngle=-latestDeviceMotion.attitude.yaw*60 ;
             NSLog(@"%f", latestDeviceMotion.attitude.yaw);
             }
             
             
          // self.mapView.rotationAngle= -( atan2(latestDeviceMotion.gravity.x, latestDeviceMotion.gravity.y)-M_PI)*60;
             
             
             
             
             
            // lblValue.text=[NSString stringWithFormat:@"%f", latestDeviceMotion.attitude.roll];
             
             //重新定义地图范围

//             AGSMutableEnvelope *newEnv=nil;
//             if(latestDeviceMotion.attitude.yaw<2.25&latestDeviceMotion.attitude.yaw>=0.75)
//             {
//                 newEnv =[AGSMutableEnvelope envelopeWithXmin:          Minx+latestDeviceMotion.attitude.roll*5
//                                                         ymin:Miny
//                                                         xmax:Maxx+latestDeviceMotion.attitude.roll*5
//                                                         ymax:Maxy
//                                             spatialReference:self.mapView.spatialReference];
//             }
//             else if(latestDeviceMotion.attitude.yaw>=-0.75&latestDeviceMotion.attitude.yaw<0.75)
//             {
//                 newEnv =[AGSMutableEnvelope envelopeWithXmin:          Minx
//                                                         ymin:Miny-latestDeviceMotion.attitude.roll*5
//                                                         xmax:Maxx
//                                                         ymax:Maxy-latestDeviceMotion.attitude.roll*5
//                                             spatialReference:self.mapView.spatialReference];
//             }
//             else if(abs(latestDeviceMotion.attitude.yaw)>=2.25&abs(latestDeviceMotion.attitude.yaw)<3)
//             {
//                 newEnv =[AGSMutableEnvelope envelopeWithXmin:          Minx
//                                                         ymin:Miny+latestDeviceMotion.attitude.roll*5
//                                                         xmax:Maxx
//                                                         ymax:Maxy+latestDeviceMotion.attitude.roll*5
//                                             spatialReference:self.mapView.spatialReference];
//
//             }
//             else if(latestDeviceMotion.attitude.yaw>=-2.25&latestDeviceMotion.attitude.yaw<-0.75)
//             {
//                 newEnv =[AGSMutableEnvelope envelopeWithXmin:Minx-latestDeviceMotion.attitude.roll*5
//                                                         ymin:Miny
//                                                         xmax:Maxx-latestDeviceMotion.attitude.roll*5
//                                                         ymax:Maxy
//                                             spatialReference:self.mapView.spatialReference];
//             }
//         
//             
//             
//             [self.mapView zoomToEnvelope:newEnv animated:YES];
             
             
         }M:moM];
        
    }
    else
    {
        [moM stopDeviceMotionUpdates];
        moM=nil;
        
       
    }

}








-(void)LinkGDBData
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    
    NSFileManager * fm = [NSFileManager defaultManager];
    NSError *err;
    NSArray  *arr = [fm contentsOfDirectoryAtPath:docDir error:&err ];
    NSString *GDBpath=@"";
    for (int i=0; i<arr.count; i++) {
        if([[arr objectAtIndex:i] isEqualToString:@"gxdata0827.geodatabase"])
        {
            NSLog(@"%@",[arr objectAtIndex:i]);
            GDBpath=[docDir  stringByAppendingString:[NSString stringWithFormat:@"/%@",[arr objectAtIndex:i]]];
            NSLog(@"%@",GDBpath);
            break;
        }
    }
     gdb = [[AGSGDBGeodatabase alloc]initWithPath:GDBpath error:&err];
   

}

static NSMutableArray *OffLineFeaturearr;
int runindex=0;

-(void)searchInfo:(AGSEnvelope *)envelop gdbfile: (AGSGDBGeodatabase *)gdb
{
    
    if(gdb!=nil)
    {
        runindex=0;
        OffLineFeaturearr=[[NSMutableArray alloc]init];
        AGSGDBFeatureTable *localFeatureTable;
        
        
        AGSQuery *mAgsQuery;
        mAgsQuery=[AGSQuery query];
        mAgsQuery.geometry=envelop;
        mAgsQuery.spatialRelationship=AGSSpatialRelationshipIntersects;        mAgsQuery.outFields=[NSArray arrayWithObjects:@"*", nil];
        mAgsQuery.returnGeometry =false;
        for (int s=0; s<[gdb featureTables].count; s++) {
           
            localFeatureTable = [[gdb featureTables] objectAtIndex:s];

            [localFeatureTable queryResultsWithParameters:mAgsQuery completion:^(NSArray *arr,NSError *err)
            {
                runindex++;
                                 if(err!=nil)
                                 {
                                     NSLog(@"%@",err.description);
                                     return ;
                }
                                 if(arr.count!=0)
                                {
                                    AGSGDBFeature *gdbfeature;
                                    for (int q=0; q<arr.count; q++) {
                                        
                                        //查到的数据存入数组
                                        
                                        gdbfeature=[arr objectAtIndex:q];
                                        [OffLineFeaturearr  addObject:gdbfeature];                                       NSLog(@"%@ %@", localFeatureTable.tableName,[arr objectAtIndex:q]);
                                    }
                                 
                                    NSLog(@"%d",arr.count);
                                }
                                else
                                {
                                    //NSLog(@"Failed");
                                }
                

                //检索完毕，开始绑定结果数据
                if(runindex==[gdb featureTables].count)
                {
                    if(OffLineFeaturearr.count==0)
                    {
                        OffLineFeaturearr=nil;
                    }
                    [IdentifyController BingFeature:OffLineFeaturearr];
                }

                
            }];

            
            
            
        }
      
        
           }
    else
    {
        NSLog(@"Cannot Load GeoDatabase");
    }
}



//控制界面显示
-(void)ControlVisiable:(bool)yesorno
{
    
    
    if (yesorno) {
        OArea.hidden=true;
        OClear.hidden=true;
        OFull.hidden=true;
        OLength.hidden=true;
        OPosition.hidden=true;
        OQuery.hidden=true;
        
        [G7 setImage:[UIImage imageNamed:@"blueteethGPS.png"] forState:UIControlStateNormal];
        
        
    }else
    {
        G1.hidden=true;
         G2.hidden=true;
         G3.hidden=true;
         G4.hidden=true;
         G5.hidden=true;
         G6.hidden=true;
        
        Qquery.hidden=true;
        Full.hidden=true;
        Clear.hidden=true;
        Position.hidden=true;
        Length.hidden=true;
        Area.hidden=true;
        [G7 setImage:[UIImage imageNamed:@"Oblue.png"] forState:UIControlStateNormal];
    }
}









@end
