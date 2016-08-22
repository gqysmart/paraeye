//
//  IdentifyViewController.m
//  MapPrjByWUCL
//
//  Created by JSJM on 14-5-21.
//  Copyright (c) 2014年 cc. All rights reserved.
//

#import "IdentifyViewController.h"
#import "DialogController.h"
#import "WBAAppDelegate.h"
@interface IdentifyViewController ()

@end

@implementation IdentifyViewController
@synthesize myIdentifyViewDelegate;
@synthesize SerarchTip,ServiceFieldarray,featureTableView,FeaListTable;
#define CELL_CONTENT_MARGIN 5.0f   //边距

//UIAlertView *AutoAlert;
UITableView *ResultTable;
//NSMutableArray *ServiceFieldarray;
NSMutableArray *SearchSourceValues;
int identifyWebType;
NSDictionary *graAttDic;
DialogController *dia;
WBAAppDelegate *appDelegate;
int Featureselectindex=-1;//选中要素的表格索引
AGSGraphicsLayer  *graphicslayer;



NSString *WebIP;

- (void)viewDidLoad
{
    [super viewDidLoad];
       appDelegate=[[UIApplication sharedApplication] delegate];
   graphicslayer = [[AGSGraphicsLayer alloc] init];
    graphicslayer=[appDelegate.mapView mapLayerForName:@"graphicsLayer"];
    
    
    NSUserDefaults *defal = [NSUserDefaults standardUserDefaults];
	WebIP = [defal stringForKey:@"WebServiceServiceIP"];
    
    FeaListTable.hidden=true;
    featureTableView.tag=3838;
    
    
    ResultTable = [[UITableView alloc] initWithFrame: CGRectMake(40, 110, 310, 500) style:UITableViewStyleGrouped];
    
    
    UIImageView *imageview = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 500)] autorelease];
    [imageview setImage:[UIImage imageNamed:@"panelbj.png"]];
    [imageview setAlpha:1];
    [ResultTable setBackgroundView:imageview];
    
     ResultTable.hidden=TRUE;
   
    [ResultTable setDelegate:self];
    [ResultTable setDataSource:self];
    ResultTable.sectionHeaderHeight=25;
    [self.view insertSubview:ResultTable  belowSubview:FeaListTable];
    CGPoint p = ResultTable.center;
    if(appDelegate.NETWORKABLE==false)
    {
    p.y+=50;
   ResultTable.center=p;
    }
    else
    {
        p.y-=50;
        ResultTable.center=p;
         [self GetWebServiceBy:nil];
    }
    
   
   //初始化服务选择框，选择默认服务
    //ServiceView.hidden = TRUE;
    //int index = [Servicepick selectedRowInComponent:0];
  
    
   

    
   }
//显示时注册查询事件
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:true];
    [self UserTipShow];
    [myIdentifyViewDelegate IdentifyBegion:[[[SearchSourceValues objectAtIndex:0] componentsSeparatedByString:@";"] objectAtIndex:1] LayerID: 0 ];//[[[[SearchSourceValues objectAtIndex:0] componentsSeparatedByString:@";"] objectAtIndex:2] integerValue]];
    identifyWebType=1;
 //[self GetWebServiceBy:nil];

}



- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [SearchSourceValues count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [[[SearchSourceValues objectAtIndex:row] componentsSeparatedByString:@";"] objectAtIndex:0];
}


-(IBAction)btnPanelClick:(id)sender
{
    [myIdentifyViewDelegate btnIdentifyViewClick];
}

-(void)UserTipShow
{
    SerarchTip.hidden=FALSE;
    [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(CloseTip:) userInfo:nil repeats:NO];
}

-(void) CloseTip:(NSTimer *)timer
{
    SerarchTip.hidden=TRUE;
}

-(void)GetWebServiceBy:(NSString*)SearchKey
{
    @try
    {
        NSString *soapMessage;
        if (identifyWebType==0) {
            soapMessage = [NSString stringWithFormat:
                           @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                           "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                           "<soap:Body>"
                           "<GetSearchList xmlns=\"http://tempuri.org/\"/>"
                           "</soap:Body>"
                           "</soap:Envelope>"];
        }
        else if (identifyWebType==1) {
            NSArray *tmp=[SearchKey componentsSeparatedByString:@";"];
            soapMessage = [NSString stringWithFormat:
                           @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                           "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                           "<soap:Body>"
                           "<GetSearchFields xmlns=\"http://tempuri.org/\">"
                           "<SERVICENAME>%@</SERVICENAME>"
                           "<LAYERID>%@</LAYERID>"
                           "</GetSearchFields>"
                           "</soap:Body>"
                           "</soap:Envelope>",[tmp objectAtIndex:0],[tmp objectAtIndex:1]];
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
        NSData *responseData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&reponse error:&error];
        
        if(error)
        {
            appDelegate.NETWORKABLE=false;
            if(dia==nil)
            {
                
                dia=[[DialogController alloc ]init];
                dia.view.frame=CGRectMake(0, 0, 1024, 768);
            }
            dia.info.text=@"无法连接到服务器,请检查网络。";
      [[myIdentifyViewDelegate    MainView] addSubview:dia.view];

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
       
        if(dia==nil)
        {
            
            dia=[[DialogController alloc ]init];
            dia.view.frame=CGRectMake(0, 0, 1024, 768);
        }
        dia.info.text=@"无法连接到服务器,请检查网络。";
        [[myIdentifyViewDelegate MainView] addSubview:dia.view];
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
          if (identifyWebType==0) {
              SearchSourceValues=[[NSMutableArray alloc]init];

    }
    else if(identifyWebType==1){
          }
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    
    if (identifyWebType==0) {
        [SearchSourceValues addObject:string];
    }
    else if(identifyWebType==1){
        [ServiceFieldarray addObject:string];
    }
}

-(void)parserDidEndDocument:(NSXMLParser *)parser
{
    if (identifyWebType==0) {
       
    }
    else if(identifyWebType==1){
        
    }
}

-(void)BingData:(NSDictionary *)ATT
{
    if (ATT==nil) {
        ResultTable.hidden=TRUE;
    }
    else{
        graAttDic=[[NSDictionary alloc] initWithDictionary:ATT];
        NSLog(@"%@",graAttDic);
        ResultTable.hidden=FALSE;
        [ResultTable reloadData];
    }
}


-(void)BingFeature:(NSMutableArray *)Featurearr
{
    if (Featurearr==nil) {
        
        FeaListTable.hidden=true;
       ResultTable.hidden=true;
        [graphicslayer removeAllGraphics];
    }
    else{
        layerCollectionarr=[[NSMutableArray alloc ]init];
        GDBfeaturearr=[[NSMutableArray alloc ]init];//初始化
        GDBfeaturearr=Featurearr;
        NSDictionary *feaATTdic;
        AGSGDBFeature *fea;
        NSString *combinestr;
        for (int i=0; i<Featurearr.count; i++) {
            fea=[Featurearr objectAtIndex:i];
            feaATTdic=fea.allAttributes;
            
            combinestr=  [ [self CheckFeatureBelong: [feaATTdic objectForKey:@"GXDM"]] stringByAppendingString:[NSString stringWithFormat:@"$%@",[feaATTdic objectForKey:@"OBJECTID"]]];
            NSLog(@"%@",combinestr);
            [layerCollectionarr addObject:combinestr];
            
        }
        NSLog(@"%@",fea.allAttributes);
        fea= [Featurearr objectAtIndex:0];
        
        Featureselectindex =0;
        //默认先选中第一栏
        [self MarkSelectData:0];
      
        
        
      
        //graAttDic=[[NSDictionary alloc] initWithDictionary:ATT];
         FeaListTable.hidden=false;
        [featureTableView reloadData];
        [ featureTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]  animated:YES scrollPosition:UITableViewScrollPositionNone];
       
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(appDelegate.NETWORKABLE==false)
    {
        if(tableView.tag==3838)
        {
             Featureselectindex=indexPath.row    ;
            
            [self MarkSelectData:Featureselectindex];
        }
        else
        {
            
            [ResultTable deselectRowAtIndexPath:[ResultTable indexPathForSelectedRow] animated:YES];
        }
        
        
        
    }
    else
    {
         [ResultTable deselectRowAtIndexPath:[ResultTable indexPathForSelectedRow] animated:YES];
    }
   
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 25;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(appDelegate.NETWORKABLE ==false)
    {
        if (tableView.tag==3838)
        {
            return 1;
        }
        else
        {
            return [ServiceFieldarray count] ;
        }
        
    }
    else
    {
        return [ServiceFieldarray count];
    }
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(appDelegate.NETWORKABLE==false)
    {
        if(tableView.tag==3838)
        {
            static NSString *TableSampleIdentifier = @"LayerINFOCell";
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                                     TableSampleIdentifier];
            if (cell == nil)
            {
                NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:@"LayerINFOCell" owner:self options:nil];
                cell = (UITableViewCell *)[nibArray objectAtIndex:0];
                //[nibArray release];
            }
            
            NSUInteger row = [indexPath row];
            cell.textLabel.font= [UIFont fontWithName:@"Helvetica Neue" size:14];
            
            [cell setTextName:[layerCollectionarr objectAtIndex:row]];
            return cell;

        }
        else//结果表格
        {
            static NSString *CellIdentifier = @"Cell";
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
            }
            
             NSString *key= [[[ServiceFieldarray objectAtIndex:indexPath.section] componentsSeparatedByString:@"$"] objectAtIndex:0];
            NSString *keyfield= [[[ServiceFieldarray objectAtIndex:indexPath.section] componentsSeparatedByString:@"$"] objectAtIndex:1];
            
            NSLog(@"%@",key);
            AGSGDBFeature *fea=[GDBfeaturearr objectAtIndex:Featureselectindex];
            NSString *value=[fea.allAttributes objectForKey:keyfield];
            NSLog(@"%@",value);
            
            
            if([key isEqualToString:@"管线代码"])//转换所属管线名称
            {
                value=  [self CheckFeatureBelong:value];
                cell.textLabel.text=value;
            }
            //if([value isEqualToString:@"Null"])
            //{
              //  cell.textLabel.text =@"";
            //}
            else
            {
                if([key isEqualToString:@"起点埋深"]|| [key isEqualToString:@"终点埋深"]||[key isEqualToString:@"地面高程"]||[key isEqualToString:@"起点高程"]||[key isEqualToString:@"井脖深"]||[key isEqualToString:@"终点高程"])
                {
                    double dd=[value doubleValue];
                    cell.textLabel.text=[NSString stringWithFormat:@"%@ %@",[NSString stringWithFormat:@"%.3f",dd],@"米"];
                }else if([key isEqualToString:@"总孔数"]||[key isEqualToString:@"占用孔数"]||[key isEqualToString:@"电缆条数"])
                {
                double ss=[value doubleValue];
                    cell.textLabel.text=[NSString stringWithFormat:@"%.0f",ss];
                    
                }
                else if([key isEqualToString:@"井盖直径"]||[key isEqualToString:@"井盖长"]||[key isEqualToString:@"井盖宽"]||[key isEqualToString:@"井室直径"])
                {
                    double ss=[value doubleValue];
                    cell.textLabel.text=[NSString stringWithFormat:@"%.0f",ss];
                }
                else if([key isEqualToString:@"电压值"]||[key isEqualToString:@"压力"])
                {
                    double ss=[value doubleValue];
                    cell.textLabel.text=[NSString stringWithFormat:@"%.2f",ss];
                }
                
                else if([key isEqualToString:@"探测日期"])
                {
                    NSDateFormatter *dateF=[[NSDateFormatter alloc] init];
                    [dateF setDateFormat:@"yyyy-MM-dd"];
                    cell.textLabel.text= [dateF stringFromDate:(NSDate *)value];
                }
                else if([key isEqualToString:@"管径"])
                {
                    cell.textLabel.text=[NSString stringWithFormat:@"%@毫米",value];
                    
                }
                else if([key isEqualToString:@"埋设类型"])
                {
                     double ss=[value doubleValue];
                    NSString *Typestr=[NSString stringWithFormat:@"%.0f",ss];
                    if ([Typestr isEqualToString:@"0"]) {
                        cell.textLabel.text=@"直埋";
                    }
                    else if([Typestr isEqualToString:@"1"]) {
                        cell.textLabel.text=@"矩形管沟";
                        
                    }
                    else if([Typestr isEqualToString:@"2"]) {
                        cell.textLabel.text=@"拱形管沟";
                    }
                    else if([Typestr isEqualToString:@"3"]) {
                        cell.textLabel.text=@"管块";
                    }
                    else if([Typestr isEqualToString:@"4"]) {
                        cell.textLabel.text=@"管埋";
                    }
                    else if([Typestr isEqualToString:@"5"]) {
                        cell.textLabel.text=@"架空";
                    }
                    else if([Typestr isEqualToString:@"6"]) {
                        cell.textLabel.text=@"井内连线";
                    }
                    else if([Typestr isEqualToString:@"7"]) {
                        cell.textLabel.text=@"顶管";
                    }
                    else
                    {
                        cell.textLabel.text=@" ";
                    }

                    
                }
                else
                {
                    cell.textLabel.text=value;
                }
                
            }
            cell.textLabel.font=[UIFont fontWithName:@"Helvetica Neue" size:15];
            [cell.textLabel setNumberOfLines:10];
            return cell;

        }
    }
    else
    {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSString *key= [ServiceFieldarray objectAtIndex:indexPath.section]; //[[graAttDic allKeys] objectAtIndex:indexPath.section];
    NSLog(@"%@",key);
    NSString *value=[graAttDic  objectForKey:key];
    NSLog(@"%@",value);
   
    
    if([key isEqualToString:@"管线代码"])//转换所属管线名称
    {
        value=  [self CheckFeatureBelong:value];
    }
    if([value isEqualToString:@"Null"])
    {
        cell.textLabel.text =@"";
    }
    else
    {
    if([key isEqualToString:@"起点埋深"]|| [key isEqualToString:@"终点埋深"]||[key isEqualToString:@"井深"])
    {
        double dd=[value doubleValue];
        cell.textLabel.text=[NSString stringWithFormat:@"%@ %@",[NSString stringWithFormat:@"%.3f",dd],@"米"];
    }
    else if( [key isEqualToString:@"埋设类型"])
    {
        if ([value isEqualToString:@"0"]) {
            cell.textLabel.text=@"直埋";
        }
         else if([value isEqualToString:@"1"]) {
             cell.textLabel.text=@"矩形管沟";

         }
         else if([value isEqualToString:@"2"]) {
             cell.textLabel.text=@"拱形管沟";
         }
         else if([value isEqualToString:@"3"]) {
             cell.textLabel.text=@"管块";
         }
         else if([value isEqualToString:@"4"]) {
             cell.textLabel.text=@"管埋";
         }
         else if([value isEqualToString:@"5"]) {
             cell.textLabel.text=@"架空";
         }
         else if([value isEqualToString:@"6"]) {
             cell.textLabel.text=@"井内连线";
         }
         else if([value isEqualToString:@"7"]) {
             cell.textLabel.text=@"顶管";
         }
        else
        {
        cell.textLabel.text=@" ";
        }
       
        
        

    }
    
    else
    {
        cell.textLabel.text=value;
    }
        
    }
    cell.textLabel.font=[UIFont fontWithName:@"Helvetica Neue" size:15];
    [cell.textLabel setNumberOfLines:10];
    return cell;
    }

}


//// NSString值为Unicode格式的字符串编码(如\u7E8C)转换成中文
////unicode编码以\u开头
//+ (NSString *)replaceUnicode:(NSString *)unicodeStr
//{
//    NSString *tempStr1 = [unicodeStrstringByReplacingOccurrencesOfString:@"\\u"withString:@"\\U"];
//    NSString *tempStr2 = [tempStr1stringByReplacingOccurrencesOfString:@"\""withString:@"\\\""];
//    NSString *tempStr3 = [[@"\""stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
//    NSData *tempData = [tempStr3dataUsingEncoding:NSUTF8StringEncoding];
//    NSString* returnStr = [NSPropertyListSerializationpropertyListFromData:tempData
//    return returnStr;
//
//}



-(NSString *)CheckFeatureBelong:(NSString *)value
{
    NSString *val=@"";
    NSArray *nsa=@[@"JS_SYG",@"JS_SSG",@"JS_ZSG",@"JS_ZYS",@"JS_SCS",@"JS_QTX",@"PS_YSG"
                   ,@"PS_WSG",@"PS_HSG",@"PS_QTX",@"RQ_TRQ",@"RQ_YHQ",@"RQ_MQG",@"RQ_RCS"
                   ,@"RQ_QTX",@"DL_GDX",@"DL_LDX",@"DL_JTX",@"DL_GGX",@"DL_DCX",@"DL_DCS"
                   ,@"XX_TXX",@"XX_YXX",@"XX_GBX",@"XX_XCS",@"RL_RSG",@"RL_ZQG",@"BM"
                   ,@"GY",@"ZH"];
    
    switch ([nsa indexOfObject:value]) {
        case 0:
            val=@"原水管线";
            break;
        case 1:
            val=@"自来水管线";
            break;
        case 2:val=@"中水管线";
            break;
        case 3:val=@"直饮水管线";
            break;
        case 4:val=@"输水长输管线";
            break;
        case 5:val=@"给水其它管线";
            break;
        case 6:val=@"雨水管线";
            break;
        case 7:val=@"污水管线";
            break;
        case 8:val=@"合流管线";
            break;
        case 9:val=@"排水其它管线";
            break;
        case 10:val=@"天然气管线";
            break;
        case 11:val=@"液化气管线";
            break;
       case 12:val=@"煤气管线";
            break;
        case 13:val=@"输气长输管线";
            break;
        case 14:val=@"燃气其它管线";
            break;
        case 15:val=@"供电管线";
            break;
        case 16:val=@"路灯管线";
            break;
        case 17:val=@"交通信号管线";
            break;
        case 18:val=@"广告管线";
            break;
        case 19:val=@"电车管线";
            break;
        case 20:val=@"输电长输管线";
            break;
        case 21:val=@"通讯管线";
            break;
        case 22:val=@"有线电视管线";
            break;
        case 23:val=@"广播管线";
            break;
        case 24:val=@"通信长输管线";
            break;
        case 25:val=@"热水管线";
            break;
        case 26:val=@"蒸汽管线";
            break;
        case 27:val=@"不明管线";
            break;
        case 28:val=@"工业管道";
            break;
        case 29:val=@"综合管沟";
            break;
        default:val=value;
            break;
    }
    
    
    return val;
}






- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (appDelegate.NETWORKABLE==false) {
    if(tableView.tag==3838)
    {
        return layerCollectionarr.count;
    }
        else
        {
            return 1;
        }
        
    }
    else
    {
    return 1;
    }
}



- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(appDelegate.NETWORKABLE==false)
    {
        return @"";
    }
    else
    {
         return [ServiceFieldarray objectAtIndex:section];
    }
   
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(appDelegate.NETWORKABLE==false)
    {
        if(tableView.tag==3838)
        {
             return nil;
        }
        else
        {
            UIView* myView = [[[UIView alloc] init] autorelease];
            //myView.backgroundColor = [UIColor colorWithRed:0.10 green:0.68 blue:0.94 alpha:0.7];
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 200, 20)];
            titleLabel.textColor=[UIColor whiteColor];
            titleLabel.backgroundColor = [UIColor clearColor];
            NSString *fieldname=[[[ServiceFieldarray objectAtIndex:section] componentsSeparatedByString:@"$"]objectAtIndex:0];
          
            if([fieldname isEqualToString:@"管线代码"])
            {
                titleLabel.text=@"所属管线";
            }
            else
            {
                titleLabel.text=fieldname;
            }
            titleLabel.font=[UIFont fontWithName:@"Helvetica Neue" size:15];
            [myView addSubview:titleLabel];
            NSLog(@"%@",titleLabel.text);
            [titleLabel release];
            return myView;
        }
       
    }
    else
    {
    UIView* myView = [[[UIView alloc] init] autorelease];
    //myView.backgroundColor = [UIColor colorWithRed:0.10 green:0.68 blue:0.94 alpha:0.7];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 200, 20)];
    titleLabel.textColor=[UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    NSString *fieldname=[ServiceFieldarray objectAtIndex:section];
    if([fieldname isEqualToString:@"SSQY"])
    {
        titleLabel.text=@"所属区域";
    }
    else if([fieldname isEqualToString:@"管线代码"])
    {
        titleLabel.text=@"所属管线";
    }
    else
    {
        titleLabel.text=fieldname;
    }
    titleLabel.font=[UIFont fontWithName:@"Helvetica Neue" size:15];
    [myView addSubview:titleLabel];
    NSLog(@"%@",titleLabel.text);
    [titleLabel release];
    return myView;
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



//选中后符号化数据
-(void)MarkSelectData:(int)selindex
{
    [graphicslayer removeAllGraphics];
    AGSGDBFeature *fea= [GDBfeaturearr objectAtIndex:selindex];
    ServiceFieldarray=[[NSMutableArray alloc]    init    ];
    AGSGraphic *gra=[[AGSGraphic alloc]init];
    gra.geometry=fea.geometry;
    if(AGSGeometryTypeForGeometry(fea.geometry)==AGSGeometryTypePoint)
    {
                AGSPictureMarkerSymbol *PointSymbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"pushpin.png"];
        CGPoint pnt;
        pnt.x = 10;
        pnt.y = 10;
        PointSymbol.offset=pnt;
        gra.symbol=PointSymbol;
        
       
//        [ServiceFieldarray addObject:@"所属区域$SSQY"];
//        [ServiceFieldarray addObject:@"X坐标$XZB"];
//        [ServiceFieldarray addObject:@"Y坐标$YZB"];
//        [ServiceFieldarray addObject:@"井深$JS"];
//        [ServiceFieldarray addObject:@"井盖材质$JGCZ"];
//        [ServiceFieldarray addObject:@"所在道路$SZDL"];
    }
    if(AGSGeometryTypeForGeometry(fea.geometry)==AGSGeometryTypePolyline)
    {
        AGSSimpleFillSymbol *LineSymbol = [AGSSimpleFillSymbol simpleFillSymbol];
        LineSymbol.color = [UIColor clearColor];
        LineSymbol.outline.color = [[UIColor purpleColor] colorWithAlphaComponent:0.80];
        LineSymbol.outline.style = AGSSimpleLineSymbolStyleSolid;
        LineSymbol.outline.width = 8;
        gra.symbol=LineSymbol;
        [ServiceFieldarray addObject:@"管线代码$GXDM"];
       
        [ServiceFieldarray addObject:@"材质$CZ"];
        [ServiceFieldarray addObject:@"管径$GJ"];
        [ServiceFieldarray addObject:@"所在道路$SZDL"];
         [ServiceFieldarray addObject:@"所属区域$SSQY"];
        [ServiceFieldarray addObject:@"权属单位$QSDW"];
        [ServiceFieldarray addObject:@"建设年代$JSND"];
        [ServiceFieldarray addObject:@"电压值$DYZ"];
        [ServiceFieldarray addObject:@"压力$YL"];
        [ServiceFieldarray addObject:@"总孔数$ZKS"];
        [ServiceFieldarray addObject:@"占用孔数$ZYKS"];
        [ServiceFieldarray addObject:@"电缆条数$DLTS"];
        [ServiceFieldarray addObject:@"起点高程$QDGC"];
        [ServiceFieldarray addObject:@"终点高程$ZDGC"];
        [ServiceFieldarray addObject:@"起点埋深$QDMS"];
        [ServiceFieldarray addObject:@"终点埋深$ZDMS"];
        [ServiceFieldarray addObject:@"埋设类型$MSLX"];
        [ServiceFieldarray addObject:@"探测单位$TCDW"];
        [ServiceFieldarray addObject:@"探测日期$TCRQ"];
       
//        [ServiceFieldarray addObject:@"材质$CZ"];
//        [ServiceFieldarray addObject:@"管径$GJ"];
//        [ServiceFieldarray addObject:@"起点埋深$QDMS"];
//        [ServiceFieldarray addObject:@"终点埋深$ZDMS"];
//        [ServiceFieldarray addObject:@"建设年代$JSND"];
//        [ServiceFieldarray addObject:@"所在道路$SZDL"];
//        [ServiceFieldarray addObject:@"权属单位$QSDW"];
    }
    
    [graphicslayer addGraphic:gra ];
    
    ResultTable.hidden=false;
    [ResultTable reloadData];
    

    
}














@end
