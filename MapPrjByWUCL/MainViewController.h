//
//  MainViewController.h
//  MapPrjByWUCL
//
//  Created by JSJM on 14-5-10.
//  Copyright (c) 2014年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>
#import "LayerViewController.h"
#import "IdentifyViewController.h"
#import "TubeStatisticsView.h"
#import "BufferQueryController.h"
#import "CircleQueryViewController.h"
#import "PolygonQueryViewController.h"
#import "PointStatisticsViewController.h"
#import "BlueToothViewController.h"
#import "CameraViewController.h"
#import "CameraImageHelper.h"

@interface MainViewController : UIViewController
<NSXMLParserDelegate
,AGSIdentifyTaskDelegate  //要素识别
,AGSQueryTaskDelegate     //信息查询
,AGSMapViewTouchDelegate
,AGSGeometryServiceTaskDelegate
,CLLocationManagerDelegate
,LayerViewDelegate
,IdentifyViewDelegate
,TubeStatisticsDelegate
,UIAlertViewDelegate
,BufferQueryDelegate
,CircleQueryDelegate
,PolygonQueryDelegate
,PointStatisticsDelegate
,BlueToothViewDelegate
,CameraViewDelegate
,AGSCalloutDelegate
>
{
    AGSMapView *_mapView;
    AGSIdentifyTask *_identifyTask;
    AGSIdentifyParameters *_identifyParams;
      AGSQueryTask *_queryTask;
    AGSQuery *_query;
    CLLocationManager *mylocationManager;
    AGSCalloutTemplate *_CalloutTemplate;
    CMMotionManager *moM;
   
}

@property (nonatomic,copy) AGSEnvelope *ORIEnvelop;//记录正北方向，防止过度旋转


@property (nonatomic, retain) IBOutlet UIView *MainView;
//@property   bool  identifyFlag;

@property(retain,nonatomic) CameraImageHelper *CameraHelper;
@property (nonatomic, strong) IBOutlet AGSMapView *mapView;
@property (nonatomic, strong) IBOutlet AGSIdentifyTask *identifyTask;
@property (nonatomic, strong) IBOutlet AGSIdentifyParameters *identifyParams;
@property (nonatomic,strong) IBOutlet AGSQueryTask *queryTask;
@property (nonatomic,strong) IBOutlet AGSQuery *query;
@property (nonatomic,strong) IBOutlet AGSGeometryServiceTask *geometrySeviceTask;
@property (nonatomic,strong) IBOutlet AGSBufferParameters *BufferParameters;
@property (nonatomic,strong) IBOutlet AGSCalloutTemplate *CalloutTemplate;

@property (nonatomic,strong) IBOutlet UIActivityIndicatorView *activityIndicatorView;//旋转等待ui
@property (nonatomic, retain) CLLocationManager *mylocationManager;

@property (nonatomic, retain) IBOutlet UIView *measureOption;
@property (nonatomic, retain) IBOutlet UILabel *lblValue;
@property (nonatomic, retain) IBOutlet UIButton *BtnVirtual;
@property (nonatomic, retain) IBOutlet UIView *PopView;
@property (nonatomic, retain) IBOutlet UIView *CameraView;



@property (nonatomic, retain) IBOutlet UIButton *OQuery;
@property (nonatomic, retain) IBOutlet UIButton *OFull;
@property (nonatomic, retain) IBOutlet UIButton *OArea;
@property (nonatomic, retain) IBOutlet UIButton *OLength;
@property (nonatomic, retain) IBOutlet UIButton *OPosition;
@property (nonatomic, retain) IBOutlet UIButton *OClear;


@property (nonatomic, retain) IBOutlet UIButton *Qquery;
@property (nonatomic, retain) IBOutlet UIButton *Full;
@property (nonatomic, retain) IBOutlet UIButton *Area;
@property (nonatomic, retain) IBOutlet UIButton *Length;
@property (nonatomic, retain) IBOutlet UIButton *Position;
@property (nonatomic, retain) IBOutlet UIButton *Clear;


@property (nonatomic, retain) IBOutlet UIButton *G1;
@property (nonatomic, retain) IBOutlet UIButton *G2;
@property (nonatomic, retain) IBOutlet UIButton *G3;
@property (nonatomic, retain) IBOutlet UIButton *G4;
@property (nonatomic, retain) IBOutlet UIButton *G5;
@property (nonatomic, retain) IBOutlet UIButton *G6;
@property (nonatomic, retain) IBOutlet UIButton *G7;


-(IBAction)btnPositionClick:(UIButton*)sender;
-(IBAction)btnJLMeasureClick:(id)sender;

-(IBAction)btnMJMeasureClick:(id)sender;
-(IBAction)ClearALL:(id)sender;
-(IBAction)btnbackClick:(id)sender;
-(IBAction)btnFullMapClick:(id)sender;
-(IBAction)btnIdentifyClick:(id)sender;
-(IBAction)btnLayerControlClick:(id)sender;
-(IBAction)btnCircleQueryClick:(UIButton *)sender;
-(IBAction)btnRangeQueryClick:(UIButton *)sender;
-(IBAction)btnTubePointAnalystClick:(UIButton *)sender;
-(IBAction)btnTubeLineAnalystClick:(UIButton *)sender;
-(IBAction)btnBlueteethGPSClick:(UIButton *)sender;
@end
