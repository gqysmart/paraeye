//
//  TubeStatisticsView.m
//  NJSZGX
//
//  Created by JSJM on 15-8-21.
//  Copyright (c) 2015年 cc. All rights reserved.
//

#import "TubeStatisticsView.h"
#import "MainViewController.h"
#import "WBAAppDelegate.h"
#import "StatisticsCell.h"
#import "DialogController.h"

@interface TubeStatisticsView ()

@end


@implementation TubeStatisticsView
@synthesize myTubeStatisticsDelegate,ClassPick,ResultTable,TextBigclass,TextSmallclass ,ViewOFPick,TextRange,TextSon ,BtnselectValue,Alllayerstrarr,StatisitcsPopView,StatisticResultBox,activityIndicatorView;




int LoadFlag=0;//标识pickview绑定对应数据源
NSMutableData *getteMUtabledData;
DialogController *dia;
NSString *WEPIP;
#define CELL_CONTENT_MARGIN 5.0f   //边距
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
    TextSmallclass.enabled=false;
    TextBigclass.enabled=false;
    TextRange.enabled=false;
    TextSon.enabled=false;
     ClassPick.multipleTouchEnabled=false;
    StatisitcsPopView.hidden=true;
    [activityIndicatorView stopAnimating];//关闭等待进度
    BtnselectValue.tag=21;//初始化pickview内数据源
    
   StatisticResultBox.hidden=true;
    ViewOFPick.hidden=true;
    NSUserDefaults *defal = [NSUserDefaults standardUserDefaults];
	WEPIP = [defal stringForKey:@"WebServiceServiceIP"];

    [self InIlist];
    
}

-(void )viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:true];
    StatisticResultBox.hidden=true;
    ViewOFPick.hidden=true;
    TextSmallclass.text=@"";
    TextBigclass.text=@"";
    TextRange.text=@"";
    TextSon.text=@"";
    BtnselectValue.tag=21;
    StatisitcsPopView.hidden=true;
    [activityIndicatorView stopAnimating];
    LayerNamearr=[[NSMutableArray alloc ]init];
    [self InIlist];
}







- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)btnCloseclick:(UIButton *)sender {
     [self.view removeFromSuperview];
    [myTubeStatisticsDelegate PopView].hidden=true;

   
}

//初始化字符串数组
-(void)InIlist
{
    allstr=@"供电,路灯,交通信号,广告,电车,输电长输,通讯,有线电视,广播,通信长输,原水,自来水,中水,直饮水,输水长输,雨水,污水,合流,天然气,液化气,煤气,输气长输,热水,蒸汽,氢气,氧气,乙炔,乙烯,油料,排渣,输油长输,干线综合,支线综合,缆线综合,道路过路,不明";
            BIGclassName=[[NSMutableArray alloc]init];
    [  BIGclassName addObject:@"电力"];
    [  BIGclassName addObject:@"信息与通信"];
    [  BIGclassName addObject:@"给水"];
    [  BIGclassName addObject:@"排水"];
    [  BIGclassName addObject:@"燃气"];
    [  BIGclassName addObject:@"热力"];
    [  BIGclassName addObject:@"工业管道"];
    [  BIGclassName addObject:@"综合管沟"];
    [  BIGclassName addObject:@"不明"];
    SMALLclassName=[[NSMutableArray  alloc]init];
    [SMALLclassName addObject:@"供电,路灯,交通信号,广告,电车,输电长输"];
    [SMALLclassName addObject:@"通讯,有线电视,广播,通信长输"];
    [SMALLclassName addObject:@"原水,自来水,中水,直饮水,输水长输"];
    [SMALLclassName addObject:@"雨水,污水,合流"];
    [SMALLclassName addObject:@"天然气,液化气,煤气,输气长输"];
    [SMALLclassName addObject:@"热水,蒸汽"];
    [SMALLclassName addObject:@"氢气,氧气,乙炔,乙烯,油料,排渣,输油长输"];
    [SMALLclassName addObject:@"干线综合,支线综合,缆线综合,道路过路"];
    [SMALLclassName addObject:@"不明"];
     
    StatisticsRangeName=[[NSMutableArray alloc]init];
    [  StatisticsRangeName addObject:@"权属单位"];
    [  StatisticsRangeName addObject:@"普查单位"];
    [  StatisticsRangeName addObject:@"道路名称"];
    [  StatisticsRangeName addObject:@"管线材质"];
    [  StatisticsRangeName addObject:@"管线管径"];
    [  StatisticsRangeName addObject:@"建设年代"];
    StatisticsRangeField=[[NSMutableArray alloc]init];
    [  StatisticsRangeField addObject:@"QSDW"];
    [  StatisticsRangeField addObject:@"TCDW"];
    [  StatisticsRangeField addObject:@"SZDL"];
    [  StatisticsRangeField addObject:@"CZ"];
    [  StatisticsRangeField addObject:@"GJ"];
    [  StatisticsRangeField addObject:@"JSND"];

    
    
   
}







-(void)GetSonList:(NSString *)LayerType LayerIndex:(int)Lindex
{
       //第一步，创建url
    
    NSString *Utf8changestr= [@"综合管网查询" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding ];
    NSString *strurl= [NSString stringWithFormat:@"http://%@:6080/arcgis/rest/services/%@/MapServer/%d/query",WEPIP,Utf8changestr,Lindex];
   
    NSURL *url = [NSURL URLWithString:strurl];
    //第二步，创建请求
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url ];
    [request setHTTPMethod:@"POST"];
    //NSString *ClassName= [TextBigclass.text stringByAppendingString:[NSString stringWithFormat: @"_%@",TextSmallclass.text]];
    NSString *str = [NSString stringWithFormat:@"where=%@&outFields=%@&returnGeometry=%@&returnDistinctValues=%@&f=%@",@"1=1",LayerType,@"false",@"true",@"json"];
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
    //NSDictionary  *errordic=[dic objectForKey:@"error"];
    //NSString *errorstr=[errordic objectForKey:@"code"];
    NSArray *errarr=[dic objectForKey:@"error"];
    //NSLog(@"%@",errorstr);
    //判断服务是否开启
    if([errarr count]!=0)
    {
        
        if(dia==nil)
        {
            dia=[[DialogController alloc ]init];
            dia.view.frame=CGRectMake(0,0,1024,768);
        }
        
        dia.info.text=@"统计服务未找到!";
        [[myTubeStatisticsDelegate   MainView] addSubview:dia.view];
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
//                                                        message:@"统计服务未找到!"
//                                                       delegate:nil
//                                              cancelButtonTitle:@"确定"
//                                              otherButtonTitles: nil];
//        
//        [alert show];
//        [alert release];
        TextRange.text=@"";
      StatisitcsPopView.hidden=true;
        [activityIndicatorView stopAnimating];
        return;
        
    }
    
    if(LoadFlag==1)
    {
        NSArray *resultarr=[dic objectForKey:@"features"] ;
        
        if(resultarr.count==0)//当图层下没结果得情况下不让选择
        {
            if(dia==nil)
            {
                dia=[[DialogController alloc ]init];
                dia.view.frame=CGRectMake(0,0,1024,768);
            }
            
            dia.info.text=@"图层内无数据!";
            [[myTubeStatisticsDelegate   MainView] addSubview:dia.view];
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
//                                                            message:@"图层内无数据"
//                                                           delegate:nil
//                                                  cancelButtonTitle:@"确定"
//                                                  otherButtonTitles: nil];
//            
//            [alert show];
//            [alert release];
            
            StatisitcsPopView.hidden=true;
            [activityIndicatorView stopAnimating];
            TextRange.text=@"";
            return;
        }

        
        NSDictionary   *sondic;
        NSLog(@"%@",[resultarr objectAtIndex:0]);
        NSDictionary  *sondic2;
        NSString *comstr=@"";
        NSArray *arr;
        NSString *str;
        
        
        
        
       for(int i=0;i< resultarr.count;i++)
       {
           sondic=[resultarr objectAtIndex:i];
           sondic2=  [sondic objectForKey:@"attributes"];
           str=[sondic2 objectForKey:RangeMark];
           
            NSLog(@"%@",RangeMark);
           

             NSLog(@"%@",str);
           [SonListName addObject:str];
        }
      
        
    }else if(LoadFlag==2)
    {
        NSString *resultSTR=[dic objectForKey:@"Result"] ;
        NSArray *sepArr=  [resultSTR componentsSeparatedByString:@"\""];
        NSLog(@"%d",[sepArr count]);
        NSLog(@"%@",[sepArr objectAtIndex:3]);//获取结果字符串
        NSString *layername=[[[sepArr objectAtIndex:0] componentsSeparatedByString:@"|"] objectAtIndex:0];
        NSArray *linearr=[[sepArr objectAtIndex:3] componentsSeparatedByString:@"#"];
        NSString *comBineStr=@"";
        
        //数量减一因为字符串末尾有＃
        
        for (int s=0; s<linearr.count-1; s++) {
            NSLog(@"%@",[linearr objectAtIndex:s]);
            //comBineStr=[[sepArr objectAtIndex:0] stringByAppendingString:[NSString stringWithFormat:@"%@",[[[linearr objectAtIndex:s]componentsSeparatedByString:@"{"] objectAtIndex:1]]];
            
            comBineStr=[layername stringByAppendingString:[NSString stringWithFormat:@"|%@",[linearr objectAtIndex:s]]];
            NSLog(@"%@",comBineStr);
            [TableDataSource addObject:comBineStr];
            
        }
        [ResultTable reloadData ];
        StatisticResultBox.hidden=false;
        
    }
    
    
    
    StatisitcsPopView.hidden=true;
    [activityIndicatorView stopAnimating];
    
}
//网络请求过程中，出现任何错误（断网，连接超时等）会进入此方法
-(void)connection:(NSURLConnection *)connection
 didFailWithError:(NSError *)error
{
   StatisitcsPopView.hidden=true;
    [activityIndicatorView stopAnimating];
    TextRange.text=@"";
    NSLog(@"%@",[error localizedDescription]);
    if(dia==nil)
    {
        
        dia=[[DialogController alloc ]init];
        dia.view.frame=CGRectMake(0, 0, 1024, 768);
    }
    dia.info.text=@"无法连接到服务器,请检查网络。";
    [[myTubeStatisticsDelegate  MainView] addSubview:dia.view];
}




//结果表单详细代理
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView.tag==1111)
    {
        static NSString *TableSampleIdentifier = @"ReturnCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                                 TableSampleIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc]
                  initWithStyle:UITableViewCellStyleDefault
                  reuseIdentifier:TableSampleIdentifier];
                    }
        
        NSUInteger row = [indexPath row];
        cell.textLabel.font= [UIFont fontWithName:@"Helvetica Neue" size:14];
        cell.textLabel.text =[LayerNamearr objectAtIndex:row];
        return cell;
    }
    else
    {
    static NSString *TableSampleIdentifier = @"StatisticsCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             TableSampleIdentifier];
    if (cell == nil)
    {
        NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:@"StatisticsCell" owner:self options:nil];
        cell = (UITableViewCell *)[nibArray objectAtIndex:0];
        //[nibArray release];
    }
    
    NSUInteger row = [indexPath row];
    cell.textLabel.font= [UIFont fontWithName:@"Helvetica Neue" size:14];
 
    [cell setTextName:[TableDataSource objectAtIndex:row]];
	return cell;
    }
}
//选中行信息
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView.tag==1111)
    {
        return [LayerNamearr count];
    }
    else
    {
    NSLog(@"%d",[TableDataSource count]);
    return [TableDataSource count];
    }
}










//PICKVIEW详细代理
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    switch (BtnselectValue.tag) {
        case 21:
            return 2;
            break;
            
        case 22:
            
            return 1;
            break;
        case 23:
            return 1;
            break;
        default:
            return 2;
            break;
            
    }
    
}




- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    if(pickerView.tag==10)//大小类选择
    {
    if(component ==0)
    {
        
        switch (BtnselectValue.tag) {
            case 22:
                return [SonListName  count];
                break;
            case 21:
                return  [BIGclassName count];
                break;
            case 23:
                return  [StatisticsRangeName count];
                break;
            default:
                return  [BIGclassName count];
                break;
        }
        
        
        
        
    }
    else
    {
        switch (BtnselectValue.tag) {
            case 21:
                return [[[SMALLclassName objectAtIndex:[ClassPick selectedRowInComponent:0]] componentsSeparatedByString:@","] count];
                break;
           
                
        }

        
       
    }
    }
    return 0;
}

- (NSString *)pickerView :(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{

//    if(pickerView.tag==10)//大小类选择
//    {
//    if(component==0)
//    {
//        
//        switch (BtnselectValue.tag) {
//            case 22:
//                 return [SonListName  objectAtIndex:row];
//                break;
//            case 21:
//                return [BIGclassName objectAtIndex:row];
//                break;
//            case 23:
//                return [StatisticsRangeName objectAtIndex:row];
//                break;
//            default:
//                return [BIGclassName objectAtIndex:row];
//                break;
//        }
//        
//        
//
//      
//  
//
//    }
//    else
//    {
//        switch (BtnselectValue.tag) {
//                  case 21:
//                
//                if(row>([[SMALLclassName objectAtIndex:[ClassPick selectedRowInComponent:0]] componentsSeparatedByString:@","].count-1))
//                {
//                    return @"...";
//                }
//                else
//                {
//                
//                 return [[[SMALLclassName objectAtIndex:[ClassPick selectedRowInComponent:0]] componentsSeparatedByString:@","] objectAtIndex:row];
//                }
//                break;
//          
//        }
//
//        
//     
//        
//      
//
//    }
//    }
    return @"";
}




- (void)pickerView:(UIPickerView *)pickerView didSelectRow:
(NSInteger)row inComponent:(NSInteger)component
{
    if(component==0&&BtnselectValue.tag==21)
    {
       
        [ClassPick reloadComponent:1];
        
    }
}

////居中显示
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(12.0f, 0.0f, [pickerView rowSizeForComponent:component].width-12, [pickerView rowSizeForComponent:component].height)] autorelease];
    
    
        if(component==0)
        {
    
            switch (BtnselectValue.tag) {
                case 22:
                    [label setText:[SonListName objectAtIndex:row]];
                                       break;
                case 21:
                     [label setText:[BIGclassName objectAtIndex:row]];
                    
                    break;
                case 23:
                     [label setText:[StatisticsRangeName objectAtIndex:row]];
                   
                    break;
                default:
                    [label setText:[BIGclassName objectAtIndex:row]];
                    break;
            }
    

    
    
    
    
        }
        else
        {
            switch (BtnselectValue.tag) {
                      case 21:
                    if(row>([[SMALLclassName objectAtIndex:[ClassPick selectedRowInComponent:0]] componentsSeparatedByString:@","].count-1))
                    {
                        [label setText:@"   "];
                    }
                    else
                    {
                     [label setText:[[[SMALLclassName objectAtIndex:[ClassPick selectedRowInComponent:0]] componentsSeparatedByString:@","] objectAtIndex:row]];
                    }
                    break;
                    
                    
                }
    
        }
    
    [label setTextAlignment:NSTextAlignmentCenter];
    return label;
}









- (IBAction)selectClassClick:(UIButton *)sender {
    
    switch (sender.tag) {
        case 11:
            BtnselectValue.tag=21;
            break;
         
        case 12:
            if(TextRange.text.length==0)
            {return;}
            BtnselectValue.tag=22;
    
            break;
        case 13:
            if(TextSmallclass.text.length==0)
            {return;}
            BtnselectValue.tag=23;
 
            break;
        default:
            break;
    }
    
   
     [ClassPick reloadAllComponents ];
   ViewOFPick.hidden=false;
}


//确定大小类
- (IBAction)setClassClick:(UIButton *)sender {
    
    switch (sender.tag) {
        case 21:
            //防止滑动过快导致错误
            if([ClassPick selectedRowInComponent:1]>[[SMALLclassName objectAtIndex:[ClassPick selectedRowInComponent:0]]componentsSeparatedByString:@","].count-1)
            {
                
                return;
            }
            
            
            
            TextBigclass.text=[BIGclassName objectAtIndex:[ClassPick selectedRowInComponent:0]];
            TextSmallclass.text=[[[SMALLclassName objectAtIndex:[ClassPick selectedRowInComponent:0]]componentsSeparatedByString:@","] objectAtIndex:[ClassPick selectedRowInComponent:1]];
           
          
            break;
        case 22:
            
           
            
            
            
            TextSon.text=[SonListName objectAtIndex:[ClassPick selectedRowInComponent:0]];
            
            break;
            
        case 23://范围选择
            TextRange  .text=[StatisticsRangeName objectAtIndex:[ClassPick selectedRowInComponent:0]];
             TextSon.text=@"";
            RangeMark =[StatisticsRangeField objectAtIndex:[ClassPick selectedRowInComponent:0]];
            Alllayerstrarr=[allstr componentsSeparatedByString:@","];
            NSLog(@"%d",[Alllayerstrarr count]);
            int valueindex=[Alllayerstrarr indexOfObject:TextSmallclass.text];
            NSLog(@"%d",valueindex);
            if(valueindex!=-1)
            {
                StatisitcsPopView.hidden=false;
                [activityIndicatorView startAnimating];
                LoadFlag=1;
                SonListName=[[NSMutableArray alloc]init];
                [self GetSonList:RangeMark LayerIndex:(valueindex+38)];
            }
             break;

        default:
            break;
    }
    
    
   
    ViewOFPick.hidden=true;
}












/////////统计
- (IBAction)BtnStatistic:(UIButton *)sender {
    
        if(TextRange.text.length!=0)
    {
        TableDataSource=[[NSMutableArray alloc]init];
        LoadFlag=2;//查询标识2
        StatisitcsPopView.hidden=false;
        [activityIndicatorView startAnimating];
        [self GetStatisticsTask:[TextBigclass.text stringByAppendingString:[NSString stringWithFormat:@"_%@",TextSmallclass.text]] Field:RangeMark where:TextSon.text];
        
    }
    
    
    
}








//统计任务
-(void)GetStatisticsTask:(NSString *)GXType Field:(NSString *)field where:(NSString *)wherestr
{
    //第一步，创建url
    if (wherestr.length!=0) {
        
  
        wherestr=[field stringByAppendingString:[NSString stringWithFormat:@"='%@'", wherestr]];
    }
    
    NSString *Utf8changestr= [@"综合管网查询" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding ];
    NSString *strurl= [NSString stringWithFormat:@"http://%@:6080/arcgis/rest/services/%@/MapServer/exts/StatisticsSOEnum/StatiscSOE",WEPIP,Utf8changestr];
    
    NSURL *url = [NSURL URLWithString:strurl];
    //第二步，创建请求
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url ];
    [request setHTTPMethod:@"POST"];
    //NSString *ClassName= [TextBigclass.text stringByAppendingString:[NSString stringWithFormat: @"_%@",TextSmallclass.text]];
    NSString *str = [NSString stringWithFormat:@"GXTypes=%@&LayerType=%@&WhereClause=%@&GroupBy=%@&f=%@",GXType,@"1",wherestr,field,@"json"];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    //第三步，连接服务器
    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    
    
    
    
    if(connection)
    {
        getteMUtabledData =[[NSMutableData data] retain] ;
    }
}






















@end
