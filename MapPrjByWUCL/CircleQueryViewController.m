//
//  CircleQueryViewController.m
//  NJSZGX（new）
//
//  Created by JSJM on 15-8-31.
//  Copyright (c) 2015年 cc. All rights reserved.
//

#import "CircleQueryViewController.h"
#import "WBAAppDelegate.h"
#import "MainViewController.h"
#import "CallOutView.h"
#import "DialogController.h"
@interface CircleQueryViewController ()

@end

@implementation CircleQueryViewController
@synthesize myCircleQueryDelegate;
@synthesize BufferlblValue,Bufferdistance,Bufferpicklist,BoxPick,textBigClass,textSmallClass,btqueryBuffer,btnSmallclass,btnBigclass ,tbResultview,btnCreatBuffer ,ResultView,CURleaf,ALLleaf,btnNextleaf,Selmode,btnPreleaf,Segment,btnDrawBuffer,PopViewSon;
AGSSketchGraphicsLayer *sklayer;
AGSGraphicsLayer *graphicsLayer;
WBAAppDelegate *appDelegate;
AGSGraphicsLayer *ATTgraLayer;
AGSGraphicsLayer *GPSgraLayer;
DialogController *dia;



NSString *postLayernamestr;
NSString *WEPIP;


NSMutableArray *compareDIC;

NSData *gettedData;
NSMutableData *getteMUtabledData;
AGSMutableMultipoint  *Mpoint2=nil;
int Queryflag;//查询旗标，标识查询进度（2次）
int Typeflag;//TYPE选择旗标
bool isDrawRange2=false;//标识是否在绘制圆形；
int  numDrawPoint2=1;//标识绘制了第几个点,默认为1
AGSMutablePoint *centerPoint;//标识绘制圆中心点；



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
    
    [self INIpickArray];//初始化数组
    //getteMUtabledData=[[NSMutableData alloc]init];
    
    // Do any additional setup after loading the view from its nib.
    
    NSUserDefaults *defal = [NSUserDefaults standardUserDefaults];
	WEPIP = [defal stringForKey:@"WebServiceServiceIP"];
    Segment.selectedSegmentIndex=0;
    NSLog(@"%d",[BigName count] );
    BoxPick.hidden=true;
    btqueryBuffer.enabled=false;
    btnSmallclass.enabled=false;
    btnBigclass.enabled=false;
    Segment.hidden=true;//隐藏选择器
    //tbResultview.hidden=true;//隐藏结果表单
    ResultView.hidden=true;
    
    PopViewSon.hidden=true;
    
    
    
    centerPoint=nil;
    // WBAAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate = [[UIApplication sharedApplication] delegate];
    sklayer=(AGSSketchGraphicsLayer *) [appDelegate.mapView mapLayerForName:@"Sketch layer"];
    graphicsLayer=(AGSGraphicsLayer *) [appDelegate.mapView mapLayerForName:@"graphicsLayer"];
    ATTgraLayer=(AGSGraphicsLayer *) [appDelegate.mapView mapLayerForName:@"ATTlayer"];
    GPSgraLayer=(AGSGraphicsLayer *) [appDelegate.mapView mapLayerForName:@"position"];
    
}
-(void)viewDidAppear:(BOOL)animated  //控制显示
{
    [super viewDidAppear:true];
    [sklayer clear];//取消绘制状态
    appDelegate.mapView.touchDelegate=nil;
    [ATTgraLayer removeAllGraphics];
    [graphicsLayer removeAllGraphics];
    BoxPick.hidden=true;
    [self controlHidden:false];
    btnSmallclass.enabled=false;
    btnBigclass.enabled=false;
    btqueryBuffer.enabled=false;
    btnCreatBuffer.enabled=true;
    ResultView.hidden=true;
    textBigClass.text=@"";
    textSmallClass.text=@"";
    BufferlblValue.text=@"";
    Bufferdistance.text=@"0";
    Selmode.selectedSegmentIndex=0;
    btnCreatBuffer.hidden=true;
    btnDrawBuffer.hidden=false;
    Bufferdistance.enabled=false;
        centerPoint=nil;//初始化中心点
    isDrawRange2=false;//默认关闭圆绘制
    
}

///////////////////////防止查询同步／／／／／／
-(void)controlHidden:(BOOL)enable
{
    btnNextleaf.enabled=enable;
    btnPreleaf.enabled=enable;
    btnCreatBuffer.enabled=enable;
    btqueryBuffer.enabled=enable;
    Selmode.selectedSegmentIndex=0;
}

- (IBAction)BtnDrawBuffer:(UIButton *)sender {
    
    
    [self ResetResult];
    [ATTgraLayer removeAllGraphics];
    [sklayer clear];
    [graphicsLayer removeAllGraphics];
    Bufferdistance.text=@"0";
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(CirclerespondToGeomChanged:) name:AGSSketchGraphicsLayerGeometryDidChangeNotification object:nil];//GeometryChanged时调用
   	
    appDelegate.mapView.touchDelegate = sklayer;
	sklayer.geometry = [[AGSMutablePolyline alloc] initWithSpatialReference:appDelegate.mapView.spatialReference];
	
	AGSSimpleLineSymbol *LineSymbol =[AGSSimpleLineSymbol simpleLineSymbol];
	LineSymbol.color=[[UIColor redColor] colorWithAlphaComponent:0.60];
	LineSymbol.width=11;
    
    AGSCompositeSymbol *Symbol=[[AGSCompositeSymbol alloc]init];
    [Symbol addSymbol:LineSymbol];
    
	AGSSimpleMarkerSymbol *MarkerSymbol =[AGSSimpleMarkerSymbol simpleMarkerSymbol];
	MarkerSymbol.color=[[UIColor blueColor] colorWithAlphaComponent:0.80];
	MarkerSymbol.size=CGSizeMake(16, 16);
	
	sklayer.vertexSymbol=MarkerSymbol;
	sklayer.mainSymbol=Symbol;
    isDrawRange2=true;
    numDrawPoint2=1;
    centerPoint=nil;
    
    //NSLog(@"%@",sklayer.name);
}


- (void)CirclerespondToGeomChanged: (NSNotification*) notification
{
	if (![sklayer.geometry isEmpty])
	{
        
        
		AGSGeometry *geom =sklayer.geometry;
		AGSGeometryEngine *myGeoEngine=[[AGSGeometryEngine alloc]init];
		AGSGeometry *geochange=[myGeoEngine projectGeometry:geom toSpatialReference:appDelegate.mapView.spatialReference];
        
        //图形为line计算长度
		if([geochange isKindOfClass:[AGSPolyline class]]){
			
			double length=[myGeoEngine lengthOfGeometry:(geochange)];
			if (length != 0) {
                
                //绘制圆形查询，当绘制第二个点得时候实行绘制
                if(isDrawRange2)
                {
                    if(numDrawPoint2==2)
                    {
                       
                          [sklayer clear];//取消绘制状态
                            appDelegate.mapView.touchDelegate=nil;
                            [self getCircle: centerPoint Radius:length];//创建圆形
                            //重置参数
                           
                            numDrawPoint2=1;
                        
                            
                            NSLog(@"%f",length) ;
                            NSLog(@"length=%0.3f",fabs(length));
                            Bufferdistance.text =[NSString stringWithFormat:@"%0.3f", fabs(length)]  ;
                       
                       PopViewSon.hidden=false;
                         [myCircleQueryDelegate PopView].hidden=PopViewSon.hidden;
                        [[myCircleQueryDelegate activityIndicatorView] startAnimating];
                            [self GetBufferServiceBy:[self GetGeometryStr:centerPoint]];
                            
                        
                    }
                }
               
                //
			}
            else
            {
                if(isDrawRange2)
                {
                    if(numDrawPoint2==1)
                    {
                        if(centerPoint==nil)
                        {
                            centerPoint=[[AGSMutablePoint alloc] init];
                            centerPoint=[[AGSMutablePoint alloc] initWithX:geochange.envelope.xmax y:geochange.envelope.ymax spatialReference:appDelegate.mapView.spatialReference ];
                            numDrawPoint2++;
                        }
                    }
                }
                
            }
            
            
		}
        
    }
}

//绘制圆形
-(AGSGeometry *)getCircle:(AGSMutablePoint *)center Radius:(double)radius
{
    
    AGSMutablePolygon *circle=[[AGSMutablePolygon alloc]init];
    AGSMutableMultipoint *mutiPoint= [self GetPoints:center Radius:radius];
    [circle addRingToPolygon];
    for (int i=0; i<mutiPoint.numPoints; i++)
    {
        //circle ad
        //[circle numRings]
        [circle addPoint:[mutiPoint pointAtIndex:i] toRing:0];
        // [circle addPointToRing:[mutiPoint  pointAtIndex:i]];
    }
    AGSGraphic *gra=[[AGSGraphic alloc] init];
    circle.spatialReference=appDelegate.mapView.spatialReference;
    gra.geometry=circle;
    
    AGSSimpleFillSymbol *FillSymbol = [AGSSimpleFillSymbol simpleFillSymbol];
    FillSymbol.style = AGSSimpleFillSymbolStyleCross;
    FillSymbol.color = [[UIColor blackColor] colorWithAlphaComponent:0.80];
    FillSymbol.outline.color = [[UIColor blueColor] colorWithAlphaComponent:0.80];
    FillSymbol.outline.style = AGSSimpleLineSymbolStyleSolid;
    FillSymbol.outline.width = 2;
    gra.symbol=FillSymbol;
    [graphicsLayer removeAllGraphics];
    [graphicsLayer addGraphic:gra];
    return  circle;
}

//获得点集
-(AGSMutableMultipoint *)GetPoints:(AGSMutablePoint *)center Radius:(double)radius
{
    double sinresult;
    double cosresult;
    double x;
    double y;
    AGSPoint *point;
    AGSMutableMultipoint *mutablePoints;
    mutablePoints=[[AGSMutableMultipoint alloc] init];
    
    for (int i=0; i<50; i++) {
        sinresult= sin(M_PI*2*i/50);
        cosresult=cos(M_PI*2*i/50);
        x=center.x+radius*sinresult;
        y=center.y+radius*cosresult;
        point=[[AGSPoint alloc] initWithX:x y:y spatialReference:appDelegate.mapView.spatialReference ];
        [mutablePoints addPoint:point];
    }
    int s=  mutablePoints.numPoints;
    NSLog(@"%d",s);
    return mutablePoints;
}







//初始化数组
-(void)INIpickArray
{
    BigName=[[NSMutableArray alloc]init];
    
    [BigName addObject:@"电力"];
    [BigName addObject:@"信息与通信"];
    [BigName addObject:@"给水"];
    [BigName addObject:@"排水"];
    [BigName addObject:@"燃气"];
    [BigName addObject:@"热力"];
    [BigName addObject:@"工业管道"];
    [BigName addObject:@"综合管沟"];
    [BigName addObject:@"不明"];
    //BigName=[NSArray  arrayWithObjects:@"电力",@"信息与通信",@"给水",@"排水",@"燃气",@"热力",@"工业管道",@"不明",nil];
    NSLog(@"%@",[BigName objectAtIndex:0] );
    
    
    compareDIC=[[NSMutableArray alloc]init   ];
    [compareDIC addObject:@"供电管线点|0,供电管线线|0,供电井室线|0,广告管线线|0,广告管线点|0,广告井室线|0,电车管线线|0,电车管线点|0,电车井室线|0,路灯管线线|0,路灯管线点|0,路灯井室线|0,输电长输管线点|0,输电长输井室线|0,输电长输管线线|0"];
    [compareDIC addObject:@"广播管线点|0,广播井室线|0,广播管线线|0,有线电视管线点|0,有线电视管线线|0,有线电视井室线|42,通信长输管线线|0,通信长输管线点|0,通信长输井室线|0,通讯井室线|0,通讯管线点|0,通讯管线线|0"];
    [compareDIC addObject:@"中水井室线|0,中水管线线|0,中水管线点|0,原水井室线|0,原水管线点|0,原水管线线|0,直饮水管线点|0,直饮水管线线|0,直饮水井室线|0,自来水井室线|0,自来水管线线|0,自来水管线点|0,输水长输管线点|0,输水长输管线线|0,输水长输井室线|0"];
    [compareDIC addObject:@"合流管线点|0,合流管线线|0,合流井室线|0,污水管线线|0,污水管线点|0,污水井室线|0,雨水管线点|0,雨水管线线|0,雨水井室线|0"];
    [compareDIC addObject:@"天然气管线点|0,天然气管线线|0,天然气井室线|0,液化气管线点|0,液化气管线线|0,液化气井室线|0,煤气管线线|0,煤气管线点|0,煤气井室线|0,输气长输管线线|0,输气长输管线点|0,输气长输井室线|0"];
    [compareDIC addObject:@"蒸汽管线线|0,蒸汽井室线|0,蒸汽管线点|0,热水管线线|0,热水井室线|0,热水管线点|0"];
    [compareDIC addObject:@"乙炔管线点|0,乙炔管线线|0,乙炔井室线|0,乙烯管线点|0,乙烯管线线|0,乙烯井室线|0,排渣管线点|0,排渣井室线|0,排渣管线线|0,氢气井室线|0,氢气管线线|0,氢气管线点|0,氧气管线线|0,氧气井室线|0,氧气管线点|0,油料井室线|0,油料管线点|0,油料管线线|0,输油长输管线线|0,输油长输管线点|0,输油长输井室线|0"];
    [compareDIC addObject:@"干线综合管沟点|0,干线综合管沟线|0,支线综合管沟线|0,支线综合管沟点|0,缆线综合管沟点|0,缆线综合管沟线|0"];
    [compareDIC addObject:@"不明管线线|0,不明井室线|0,不明管线点|0"];
    
    
    postLayernamestr=@"电力_供电|电力_路灯|电力_交通信号|电力_广告|电力_电车|电力_输电长输|信息与通信_通讯|信息与通信_有线电视|信息与通信_广播|信息与通信_通信长输|给水_原水|给水_自来水|给水_中水|给水_直饮水|给水_输水长输|排水_雨水|排水_污水|排水_合流|燃气_天然气|燃气_液化气|燃气_煤气|燃气_输气长输|热力_蒸汽|热力_热水|工业管道_氢气|工业管道_氧气|工业管道_乙炔|工业管道_乙烯|工业管道_油料|工业管道_排渣|工业管道_输油长输|综合管沟_干线综合|综合管沟_支线综合|综合管沟_缆线综合|综合管沟_道路过路|不明_不明";
}


//初始化状态查询
-(void)ResetResult
{
    textBigClass.text=@"";
    textSmallClass.text=@"";
    if(BoxPick.hidden==false)
    {
        BoxPick.hidden=true;
    }
    
    
    btqueryBuffer.enabled=false;
    btnSmallclass.enabled=false;
    btnBigclass.enabled =false;
    // tbResultview.hidden=true;//隐藏结果表单
    ResultView.hidden=true;
}


- (IBAction)BtnCreateBuffer:(UIButton *)sender {
    
    
    [Bufferdistance resignFirstResponder];
    
    if(GPSgraLayer.graphicsCount==0)
    {
        if(dia==nil)
        {
            dia=[[DialogController alloc ]init];
            dia.view.frame=CGRectMake(0,0,1024,768);
        }
        
        dia.info.text=@"请先进行定位!";
        [[myCircleQueryDelegate   MainView] addSubview:dia.view];
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
//                                                        message:@"请先进行定位"
//                                                       delegate:nil
//                                              cancelButtonTitle:@"确定"
//                                              otherButtonTitles: nil];
//        
//        [alert show];
//        [alert release];
        return;
    }
    //初始化
    btnCreatBuffer.enabled=false;
    centerPoint=Nil;
    [graphicsLayer removeAllGraphics];
    [ATTgraLayer removeAllGraphics];
    [sklayer clear];
    BoxPick.hidden=true;
    ResultView.hidden=true;
    textBigClass.text=@"";
    textSmallClass .text=@"";
    btnBigclass.enabled=false;
    btnSmallclass.enabled=false;
    
    AGSGraphic *gra= [GPSgraLayer.graphics objectAtIndex:0];
    
    AGSGeometry *geo=gra.geometry;
    centerPoint=(AGSMutablePoint *)geo;
//    centerPoint=[[AGSMutablePoint alloc] initWithX:geo.envelope.xmin+(geo.envelope.xmax-geo.envelope.xmin)/2 y:geo.envelope.ymin+(geo.envelope.ymax-geo.envelope.ymin)/2 spatialReference:appDelegate.mapView.spatialReference];
    
   // Bufferdistance.text=[NSString stringWithFormat:@"%f  ,%f",geo.envelope.xmax,geo.envelope.ymax];
  //  return;
    PopViewSon.hidden=false;
     [myCircleQueryDelegate PopView].hidden=PopViewSon.hidden;
    [[myCircleQueryDelegate activityIndicatorView] startAnimating];
 [self     GetBufferServiceBy:[self GetGeometryStr:centerPoint]];
    
    [self getCircle:centerPoint Radius:[Bufferdistance.text doubleValue]];
   
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//选择大类
- (IBAction)BtnBigclass:(UIButton *)sender {
    btqueryBuffer.enabled=false;//重置查询按钮
    //tbResultview.hidden=true;//重置查询结果
    ResultView.hidden =true;
    BoxPick.hidden=false;
    Typeflag=0;
    [Bufferpicklist reloadAllComponents];
    
}



//选择小类
- (IBAction)BtnSmallclass:(UIButton *)sender {
    if(SmallName==nil)
    {
        return;
    }
    ResultView.hidden=true;//结果框隐藏，防止改变页码时非法操作
    BoxPick.hidden=false;
    Typeflag=1;
    [Bufferpicklist reloadAllComponents];
}




//控制绘制模式
- (IBAction)segModelchanged:(UISegmentedControl *)sender {
    
    [graphicsLayer removeAllGraphics];
    BoxPick.hidden=true;
    btnSmallclass.enabled=false;
    btnBigclass.enabled=false;
    ResultView.hidden=true;
    btqueryBuffer.enabled=false;
    textSmallClass.text=@"";
    textBigClass.text=@"";
    
    if(sender.selectedSegmentIndex==0)
    {
        Bufferdistance.enabled=false;
        btnDrawBuffer.hidden=false;
        btnCreatBuffer.hidden=true;
        Bufferdistance.text=@"0";
        
    }
    else
    {
        Bufferdistance.enabled=true;
        btnDrawBuffer.hidden=true;
        btnCreatBuffer.hidden=false;
        Bufferdistance.text=@"200";
    }
}


//控制窗体隐藏与显示
- (IBAction)btnCircleQueryCall:(UIButton *)sender {
    [myCircleQueryDelegate btnCircleQueryhideorshow];
    
}


//选择器
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    //  NSLog(@"%@",[BigName objectAtIndex:0] );
    if(Typeflag==0)
    {
        return [BigName count];
    }
    else
    {
        return [SmallName count];
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if(Typeflag==0)
    {
        return [BigName objectAtIndex:row];
    }
    else
    {
        return [SmallName objectAtIndex:row ];
    }
}



//选择大类小类项
- (IBAction)selectType:(UIButton *)sender {
    
    NSInteger selindex= [Bufferpicklist selectedRowInComponent:0];
    
    if(Typeflag==0)
    {
        textSmallClass.text=@"";
        btnSmallclass.enabled=true;
        textBigClass.text= [BigName objectAtIndex:selindex];
        //初始化小类显示
        SmallName =[[NSMutableArray alloc]init];
        
        
        NSString *checkstr=  [compareDIC objectAtIndex:selindex];
        NSString *fitstr=@"";
        NSRange range;
        for (int i=0;i<AllName.count;i++)
        {
            fitstr = [[[AllName objectAtIndex:i] componentsSeparatedByString:@"|"] objectAtIndex:0];
            range=[checkstr rangeOfString:fitstr];
            if(range.location!=NSNotFound)
            {
                [SmallName addObject:[AllName objectAtIndex:i]];
            }
            
        }
        if([SmallName   count]==0)
        {
            return;
        }
    }
    else
    {
        //textSmallClass.text=[SmallName objectAtIndex:selindex];
        
        // double sumcount= [[[[SmallName objectAtIndex:selindex] componentsSeparatedByString:@"|"] objectAtIndex:1] doubleValue];
        
        //改变小类显示，显示为（总数）
        NSArray *s=[[SmallName objectAtIndex:selindex] componentsSeparatedByString:@"|"];
        NSString *bt=@"";
        NSString  *smName= [s objectAtIndex:0];
        NSString *leafs=[s objectAtIndex:1];
        bt=[[[[bt stringByAppendingString:smName] stringByAppendingString:@"("] stringByAppendingString:leafs]
            stringByAppendingString:@")"];
        textSmallClass.text=bt;
        double sumcount=[leafs doubleValue];
        if(sumcount>7)
        {
        int leafcount=(sumcount/7.0 +0.5) ;
        ALLleaf.text = [NSString stringWithFormat:@"%d",leafcount];
        }
        else
        {
             ALLleaf.text = @"1";
        }
        btqueryBuffer.enabled=true;
    }
    BoxPick.hidden=true;
}












//查询结果图层内要素数量
-(void)GetBufferServiceBy:(NSString *)GEOMETRYstr
{
    Queryflag=0;
    //第一步，创建url
    
    NSString *Utf8changestr= [@"综合管网查询" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding ];
    NSString *strurl= [NSString stringWithFormat:@"http://%@:6080/arcgis/rest/services/%@/MapServer/exts/GXQuery/GX_CountQuery",WEPIP,Utf8changestr];
    //strurl=@"http://10.10.31.6:6080/arcgis/rest/services/综合管网查询/MapServer/exts/GXQuery/GX_OnePageQuery";
    NSURL *url = [NSURL URLWithString:strurl];
    //第二步，创建请求
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url ];
    [request setHTTPMethod:@"POST"];
    NSString *str = [NSString stringWithFormat:@"GXTypes=%@&GeometryWKT=%@&BufferRadius=%@&f=%@",postLayernamestr,GEOMETRYstr,Bufferdistance.text,@"json"];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    //第三步，连接服务器
    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    
    
    
    
    if(connection)
    {
        getteMUtabledData =[[NSMutableData data] retain] ;
    }
}








//接收到服务器回应的时候调用此方法
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    //[getteMUtabledData setLength:0];
    
    
    
    NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
    NSLog(@"%@",[res  allHeaderFields]);
    
    
}
//接收到服务器传输数据的时候调用，此方法根据数据大小执行若干次
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSString *responseResult = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@",responseResult);
    [getteMUtabledData appendData:data];
}

//数据传完之后调用此方法
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    NSString *receiveStr = [[NSString alloc]initWithData:getteMUtabledData encoding:NSUTF8StringEncoding];
    
    
    
    
    NSData *jsonData=[receiveStr dataUsingEncoding:NSUTF8StringEncoding ];
    NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
    NSArray  *errorstr=[dic objectForKey:@"error"];
    

    
    //判断服务是否开启
    if(errorstr.count!=0 )
    {
        
        if(dia==nil)
        {
            dia=[[DialogController alloc ]init];
            dia.view.frame=CGRectMake(0,0,1024,768);
        }
        
        dia.info.text=@"查询服务未找到!";
        [[myCircleQueryDelegate   MainView] addSubview:dia.view];
        
        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
//                                                        message:@"查询服务未找到!"
//                                                       delegate:nil
//                                              cancelButtonTitle:@"确定"
//                                              otherButtonTitles: nil];
//        
//        [alert show];
//        [alert release];
        btnCreatBuffer.enabled=true;
        btnDrawBuffer.enabled=true;
       
     
        btnNextleaf.enabled=true;
        btnPreleaf.enabled =true;
 PopViewSon.hidden=true;
         [myCircleQueryDelegate PopView].hidden=PopViewSon.hidden;
        [[myCircleQueryDelegate activityIndicatorView] stopAnimating];
        return;
           }
    
    
    
    if(Queryflag==0)
    {
        
        // SmallName=[[NSMutableArray alloc] init ];
        AllName=[[NSMutableArray alloc] init ];
        NSString *regionstr=[dic objectForKey:@"Result"];//管点数量
        NSArray *arr=[regionstr componentsSeparatedByString:@","];
        NSString *real=@"";
        for(int i=0;i<arr.count;i++)
        {
            
            real= [[[arr objectAtIndex:i] componentsSeparatedByString:@"|"]
                   objectAtIndex:1];
            if(![real isEqualToString:@"0"])
            {
                //[SmallName addObject:[arr objectAtIndex:i]];
                
                if(![real isEqualToString:@"-1"])
                {
                    
                    [AllName addObject:[arr objectAtIndex:i]];
                }
            }
            
            //
        }
        NSString *message=@"";
        if([AllName count]==0)
        {
            message=@"圆形区域内未查找到数据!";
            NSLog(@"%@",[arr objectAtIndex:0]);
            
            if(dia==nil)
            {
                dia=[[DialogController alloc ]init];
                dia.view.frame=CGRectMake(0,0,1024,768);
            }
            
            dia.info.text=message;
            [[myCircleQueryDelegate   MainView] addSubview:dia.view];
            
            
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
//                                                            message:message
//                                                           delegate:nil
//                                                  cancelButtonTitle:@"确定"
//                                                  otherButtonTitles: nil];
//            
//            [alert show];
//            [alert release];
        }
        else
        {
            btnBigclass.enabled=true;
        }
        
        
       
      
          }
    else
    {
        NSString *regionstr2=[dic objectForKey:@"Result"];//管点数量
        NSLog(@"%@",regionstr2);
        NSString *sep=[[regionstr2 componentsSeparatedByString:@"=\""]objectAtIndex:1];;
        NSArray *featurearr=[sep componentsSeparatedByString:@"#"];
        NSString *att=@"";
        NSArray *attarr=[[NSArray alloc]init ];
        NSString *strpart;
        Tablelist=[[NSMutableArray alloc]init ];
        Objectlist =[[NSMutableArray alloc]init];
        attGotton=[[NSMutableArray alloc]init ];
        
        //字段之间用"$"隔开，与返回的geometry之间用｜隔开
        for(int i=0;i<featurearr.count-1;i++)
        {
            attarr=[[featurearr objectAtIndex:i] componentsSeparatedByString:@"|"];
            switch (Segment.selectedSegmentIndex) {
                case 0:
                    strpart= [NSString stringWithFormat:@"地面高程:%@$特征点:%@$附属物:%@$所在道路:%@$所属区域:%@$权属单位:%@$探测单位:%@$探测日期:%@$井盖材质:%@$井盖直径:%@$井盖长:%@$井盖宽:%@$井盖形状:%@$检修井材质:%@$井脖深:%@$井室直径:%@|%@",[attarr objectAtIndex:1],[attarr objectAtIndex:2],[attarr objectAtIndex:3],[attarr objectAtIndex:4],[attarr objectAtIndex:5],[attarr objectAtIndex:6],[attarr objectAtIndex:7],[attarr objectAtIndex:8],[attarr objectAtIndex:9],[attarr objectAtIndex:10],[attarr objectAtIndex:11],[attarr objectAtIndex:12],[attarr objectAtIndex:13],[attarr objectAtIndex:14],[attarr objectAtIndex:15],[attarr objectAtIndex:16],[attarr objectAtIndex:17]];
                    att =[att stringByAppendingString: strpart];
                    break;
                case 1:
                    strpart= [NSString stringWithFormat:@"材质:%@$管径:%@$所在道路:%@$所属区域:%@$权属单位:%@$建设年代:%@$电压值:%@$压力:%@$总孔数:%@$占用孔数:%@$电缆条数:%@$起点高程:%@$终点高程:%@$起点埋深:%@$终点埋深:%@$埋设类型:%@$探测单位:%@$探测日期:%@|%@",[attarr objectAtIndex:1],[attarr objectAtIndex:2],[attarr objectAtIndex:3],[attarr objectAtIndex:4],[attarr objectAtIndex:5],[attarr objectAtIndex:6],[attarr objectAtIndex:7],[attarr objectAtIndex:8],[attarr objectAtIndex:9],[attarr objectAtIndex:10],[attarr objectAtIndex:11],[attarr objectAtIndex:12],[attarr objectAtIndex:13],[attarr objectAtIndex:14],[attarr objectAtIndex:15],[attarr objectAtIndex:16],[attarr objectAtIndex:17],[attarr objectAtIndex:18],[attarr objectAtIndex:19]];
                    att =[att stringByAppendingString: strpart ];
                    break;
                case 2:
                    strpart=[NSString stringWithFormat:@"所属区域:%@$线形:%@$起点点号:%@$终点点号:%@|%@",[attarr objectAtIndex:1],[attarr objectAtIndex:2],[attarr objectAtIndex:3],[attarr objectAtIndex:4],[attarr objectAtIndex:5]];
                    att =[att stringByAppendingString:  strpart];
                    break;
            }
            [attGotton addObject:strpart];
            
            
            [Objectlist addObject:[NSString stringWithFormat:@"对象代码: %@",[attarr objectAtIndex:0]]];
            
            [Tablelist addObject:[[strpart componentsSeparatedByString:@"|"] objectAtIndex:0]];
            //
        }

        
        //////////////////需另外判断是否进行参数初始化／／／
        //初始化结果表单
        [tbResultview reloadData];

        
        ResultView.hidden=false ;//显示结果表单
        
        [self controlHidden:true];

    }
     PopViewSon.hidden=true;
     [myCircleQueryDelegate PopView].hidden=PopViewSon.hidden;
    [[myCircleQueryDelegate activityIndicatorView] stopAnimating];
     Selmode.enabled=true;
    btnDrawBuffer.enabled=true;
    btnCreatBuffer.enabled=true;
    
    //   NSLog(@"%@",regionstr);
    // NSLog(@"%@",receiveStr);
}
//网络请求过程中，出现任何错误（断网，连接超时等）会进入此方法
-(void)connection:(NSURLConnection *)connection
 didFailWithError:(NSError *)error
{
     PopViewSon.hidden=true;
     [myCircleQueryDelegate PopView].hidden=PopViewSon.hidden;
    [[myCircleQueryDelegate activityIndicatorView] stopAnimating];
    btnDrawBuffer.enabled=true;
    btnCreatBuffer.enabled=true;
    BoxPick.hidden=true;
    ResultView.hidden=true;
    btqueryBuffer.enabled=false;
    textBigClass.text=@"";
    textSmallClass.text=@"";
    btnCreatBuffer.enabled=true;
    btnBigclass.enabled=false;
    btnSmallclass.enabled=false;
    
    NSLog(@"%@",[error localizedDescription]);
    if(dia==nil)
    {
        
        dia=[[DialogController alloc ]init];
        dia.view.frame=CGRectMake(0, 0, 1024, 768);
    }
    dia.info.text=@"无法连接到服务器,请检查网络。";
     [[myCircleQueryDelegate   MainView] addSubview:dia.view];
}












-(void)GetBufferServiceResult:(NSString *)GEOMETRYstr
{
    Queryflag=1;
    //第一步，创建url
    NSLog(@"%@",Bufferdistance.text);
    NSLog(@"%@",GEOMETRYstr);
    NSString *Utf8changestr= [@"综合管网查询" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding ];
    NSString *strurl= [NSString stringWithFormat:@"http://%@:6080/arcgis/rest/services/%@/MapServer/exts/GXQuery/GX_OnePageQuery" ,WEPIP,Utf8changestr];
    //strurl=@"http://10.10.31.6:6080/arcgis/rest/services/综合管网查询/MapServer/exts/GXQuery/GX_OnePageQuery";
    NSURL *url = [NSURL URLWithString:strurl];
    //第二步，创建请求
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url ];
    [request setHTTPMethod:@"POST"];
    NSString *str =@"";
    
    //由原来从服务器得到的"|"转换为"("
    //NSString  *bs= [[textSmallClass.text componentsSeparatedByString:@"|"] objectAtIndex:0];
    NSString  *bs= [[textSmallClass.text componentsSeparatedByString:@"("] objectAtIndex:0];
    // hasprefix判断字符串是否开头包含
    // hassuffix判断字符串是否结尾包含
    
    
    if([bs hasSuffix:@"井室线"] )
    {
        Segment.selectedSegmentIndex=2;
    }
    else if([bs hasSuffix:@"管线点"])
    {
        Segment.selectedSegmentIndex=0;
    }
    else if([bs hasSuffix:@"管线线"])
    {
        Segment.selectedSegmentIndex=1;
    }
    NSString *sendleaf=[CURleaf.text stringByAppendingString:@"|7"];
    
    switch ( Segment.selectedSegmentIndex) {
            //管点
        case 0:
            str = [NSString stringWithFormat:@"GXName=%@&OutFields=%@&GeometryWKT=%@&BufferRadius=%@&PageNowAndSize=%@&f=%@&OutGeometry=%@",bs,@"OBJECTID,DMGC,TZD,FSW,SZDL,SSQY,QSDW,TCDW,TCRQ,JGCZ,JGZJ,JGC,JGK,JGXZ,JXJCZ,JBS,JSZJ",GEOMETRYstr,Bufferdistance.text,sendleaf,@"json",@"T"];
            break;
            //管线
        case 1:
            str = [NSString stringWithFormat:@"GXName=%@&OutFields=%@&GeometryWKT=%@&BufferRadius=%@&PageNowAndSize=%@&f=%@&OutGeometry=%@",bs,@"OBJECTID,CZ,GJ,SZDL,SSQY,QSDW,JSND,DYZ,YL,ZKS,ZYKS,DLTS,QDGC,ZDGC,QDMS,ZDMS,MSLX,TCDW,TCRQ",GEOMETRYstr,Bufferdistance.text,sendleaf,@"json",@"T"];
            
            break;
            //井室线
        case 2:
            str = [NSString stringWithFormat:@"GXName=%@&OutFields=%@&GeometryWKT=%@&BufferRadius=%@&PageNowAndSize=%@&f=%@&OutGeometry=%@",bs,@"OBJECTID,SSQY,XX,QDDH,ZDDH",GEOMETRYstr,Bufferdistance.text,sendleaf,@"json",@"T"];
            break;
        default:
            break;
    }

    
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    //第三步，连接服务器
    NSURLConnection *connection2 = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    
    
    
    
    if(connection2)
    {
        getteMUtabledData =[[NSMutableData data] retain] ;
    }
}






- (IBAction)btnbufferquery:(UIButton *)sender {
    CURleaf.text=@"1";//初始化当前页码为1
    btqueryBuffer.enabled=false;
   
    btnDrawBuffer.enabled=false;
    btnCreatBuffer.enabled=false;
  PopViewSon.hidden=false;
     [myCircleQueryDelegate PopView].hidden=PopViewSon.hidden;
    [[myCircleQueryDelegate activityIndicatorView] startAnimating];
    [self     GetBufferServiceResult:[self GetGeometryStr:centerPoint]];
}







//生成表单数据
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *TableSampleIdentifier = @"TableSampleIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             TableSampleIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:TableSampleIdentifier];
    }
    
    NSUInteger row = [indexPath row];
    cell.textLabel.font= [UIFont fontWithName:@"Helvetica Neue" size:14];
    //cell.textLabel.text = [[[Tablelist objectAtIndex:row] componentsSeparatedByString:@"$"] objectAtIndex:0];
    cell.textLabel.text=[Objectlist objectAtIndex:row];
	return cell;
}


//选中行信息
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [ATTgraLayer  removeAllGraphics];
    NSString *geostr=  [[[attGotton objectAtIndex:[indexPath row]] componentsSeparatedByString:@"|"] objectAtIndex:1];
    AGSMutableMultipoint    *resultGEO=[self TransGeometry:geostr];
    
    [self MakeSymbol:resultGEO index:[indexPath row]];
    //    NSString *rowString = [Tablelist objectAtIndex:[indexPath row]];
    //    UIAlertView * alter = [[UIAlertView alloc] initWithTitle:@"要素属性" message:rowString delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    //    [alter show];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [Tablelist count];
}

//点击列表定位到点  加载callout显示属性小窗
-(void)MakeSymbol:(AGSMutableMultipoint *)resultG index:(int)rowindex
{
    AGSGraphic *gra=[[AGSGraphic alloc]init ];
    CGPoint offsetsize;
    offsetsize.x = 0;
    offsetsize.y = 0;
    AGSPoint *midPoint=[[AGSPoint alloc]init]; //获取范围的中心点，显示气泡
    if([resultG numPoints]>1) //线
    {
        
        AGSMutablePolyline *pLine=[[AGSMutablePolyline alloc]init];
        [pLine addPathToPolyline];
        for (int j=0;j<[resultG numPoints]; j++) {
            [pLine addPoint:[resultG pointAtIndex:j] toPath:0 ];
            
        }
        
        midPoint=[[AGSPoint alloc]initWithX:pLine.envelope.xmin+  (pLine.envelope.xmax-pLine.envelope.xmin)/2 y:pLine.envelope.ymin+  (pLine.envelope.ymax-pLine.envelope.ymin)/2 spatialReference:appDelegate.mapView.spatialReference];
        
        gra.geometry=pLine;
        AGSSimpleFillSymbol *LineSymbol = [AGSSimpleFillSymbol simpleFillSymbol];
        LineSymbol.color = [UIColor clearColor];
        LineSymbol.outline.color = [[UIColor purpleColor] colorWithAlphaComponent:0.80];
        LineSymbol.outline.style = AGSSimpleLineSymbolStyleSolid;
        LineSymbol.outline.width = 8;
        gra.symbol=LineSymbol;
        [ATTgraLayer addGraphic:gra];
        
    }
    else   //点
    {
        midPoint=[resultG pointAtIndex:0];
        gra.geometry= midPoint;
        //        AGSPictureMarkerSymbol *pt;
        //        pt=[AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"pushpin.png"];
        //
        //        pt.offset=offsetsize;
        //        gra.symbol=pt;
        //        [ATTgraLayer addGraphic:gra];
    }
    CallOutView*v=[[CallOutView alloc]init];
    [v BingAttributeby:[Tablelist objectAtIndex:rowindex]];
    
    appDelegate.mapView.callout.customView=v.view;
    
    
    appDelegate.mapView.callout.leaderPositionFlags=AGSCalloutLeaderPositionRight;

    [appDelegate.mapView.callout showCalloutAt:midPoint screenOffset:offsetsize animated:true];
    AGSMutableEnvelope *newEnv =[AGSMutableEnvelope envelopeWithXmin:gra.geometry.envelope.xmin-4
                                                                ymin:gra.geometry.envelope.ymin-4
                                                                xmax:gra.geometry.envelope.xmax+6
                                                                ymax:gra.geometry.envelope.ymax+6
                                                    spatialReference:appDelegate.mapView.spatialReference];
    
    [appDelegate.mapView zoomToEnvelope:newEnv animated:YES];
    
    
    
    
    
    
    
}


///////////////////////////解析服务器回传geometry

-(AGSMutableMultipoint *)TransGeometry:(NSString *)geometryStr
{
    AGSMutableMultipoint   *Pointsarr=[[AGSMutableMultipoint alloc] init];
    NSString *sep1= [[[[geometryStr componentsSeparatedByString:@"("] objectAtIndex:1] componentsSeparatedByString:@")"]objectAtIndex:0];
    NSLog(@"%@",geometryStr);
    NSLog(@"%@",sep1);
    //点
    if ( [geometryStr hasPrefix:@"POINT  ("])
    {
        
        
        double Pointx=[[[sep1  componentsSeparatedByString:@" "]objectAtIndex:1] doubleValue];
        double  Pointy=[[[sep1 componentsSeparatedByString:@" "]objectAtIndex:2] doubleValue];
        
        [Pointsarr addPoint:[[AGSPoint alloc] initWithX:Pointx y:Pointy spatialReference:appDelegate.mapView.spatialReference]];
        
    }
    //线
    if([geometryStr hasPrefix:@"LINESTRING  ("])
    {
        double Px=0;
        double Py=0;
        NSArray *sep2= [sep1 componentsSeparatedByString:@","];
        for (int i=0; i<sep2.count; i++) {
            Px= [[[[sep2 objectAtIndex:i] componentsSeparatedByString:@" "]objectAtIndex:1] doubleValue];
            Py= [[[[sep2 objectAtIndex:i] componentsSeparatedByString:@" "]objectAtIndex:2] doubleValue];
            [Pointsarr addPoint:[[AGSPoint alloc] initWithX:Px y:Py spatialReference:appDelegate.mapView.spatialReference]];
            NSLog(@"%f",Px);
        }
        
        
    }
    return Pointsarr;
}



//////////////////////////////翻页/////////////////////////////

- (IBAction)btnNextleaf:(UIButton *)sender {
    if(![CURleaf.text isEqualToString:ALLleaf.text])
    {
         PopViewSon.hidden=false;
         [myCircleQueryDelegate PopView].hidden=PopViewSon.hidden;
        [[myCircleQueryDelegate activityIndicatorView] startAnimating];
        CURleaf.text=[NSString stringWithFormat:@"%d",[CURleaf.text intValue]+1];
        [self controlHidden:false];
        [self     GetBufferServiceResult:[self GetGeometryStr:centerPoint]];
    }
}

- (IBAction)btnPreleaf:(UIButton *)sender {
    if(![CURleaf.text isEqualToString:@"1"])
    {
         PopViewSon.hidden=false;
         [myCircleQueryDelegate PopView].hidden=PopViewSon.hidden;
        [[myCircleQueryDelegate activityIndicatorView]startAnimating];
        CURleaf.text=[NSString stringWithFormat:@"%d",[CURleaf.text intValue]-1];
        [self controlHidden:false];
        [self     GetBufferServiceResult:[self GetGeometryStr:centerPoint]];
    }

}


//获取圆心坐标字符串
-(NSString *)GetGeometryStr:(AGSPoint *)MidPoint
{
    
     NSString *all=@"";
    
        all=[[all stringByAppendingString:[NSString stringWithFormat:@"%f ",   MidPoint.x]] stringByAppendingString:[NSString stringWithFormat:@"%f",   MidPoint.y]];
    return [NSString  stringWithFormat:@"POINT (%@)",all] ;
}




@end
