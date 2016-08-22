//
//  MyTableViewCell.m
//  MapPrjByWUCL
//
//  Created by JSJM on 14-5-19.
//  Copyright (c) 2014年 cc. All rights reserved.
//

#import "MyTableViewCell.h"
#import "WBAAppDelegate.h"

@implementation MyTableViewCell
@synthesize ServiceName,ServiceOnOff,ServiceOpacity,ServiceInfo;

-(void)setServerName:(NSString *)value
{
    ServiceInfo.text=[[NSString alloc] initWithString:value];
    ServiceName.text=[[value componentsSeparatedByString:@";"] objectAtIndex:0];
    WBAAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    //NSLog(@"%d",appDelegate.mapView.mapLayers.count);
    BOOL Isexit=FALSE;
    for (int i=0;i<appDelegate.mapView.mapLayers.count;i++)
    {
        AGSLayer *lry=[appDelegate.mapView.mapLayers objectAtIndex:i];
       // NSLog(@"%@",lry.name);
        if ([lry.name isEqualToString:ServiceName.text])
        {
            ServiceOnOff.on=TRUE;
            ServiceOpacity.value=lry.opacity;
            Isexit=TRUE;
            break;
        }
    }
    
    if (!Isexit)
    {
        ServiceOnOff.on=FALSE;
        ServiceOpacity.value=0;
        ServiceOpacity.enabled=FALSE;
    }
}

-(IBAction)switchAction:(id)sender
{
    WBAAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    BOOL isButtonOn = [ServiceOnOff isOn];
    NSLog(@"%@",ServiceInfo.text);
    
    if (isButtonOn) {
        //控制图层数量
//        if ([appDelegate.mapView.mapLayers count]>=6) {
//            ServiceOnOff.on=FALSE;
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告"
//                                                            message:@"为了保证地图加载效率，最多只能加载两层数据！\n请先关闭不需要的图层！"
//                                                           delegate:nil
//                                                  cancelButtonTitle:@"确定"
//                                                  otherButtonTitles:nil];
//            [alert show];
//            [alert release];
//            return;
//        }
        
        [self CreatLayerWithinfo:ServiceInfo.text];
        ServiceOpacity.value=1;
        ServiceOpacity.enabled=TRUE;
    }
    else {
        for (int i=0;i<appDelegate.mapView.mapLayers.count;i++)
        {
            AGSLayer *lry=[appDelegate.mapView.mapLayers objectAtIndex:i];
            if ([lry.name isEqualToString:ServiceName.text])
            {
                [appDelegate.mapView removeMapLayer:lry];
                ServiceOpacity.value=0;
                ServiceOpacity.enabled=FALSE;
                lry.opacity=0;
                    break;
            }
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}


//改变使底图始终在管线图层之下
- (void) CreatLayerWithinfo:(NSString *)info
{
	AGSLayer *layer;
    NSString *title=[[info componentsSeparatedByString:@";"] objectAtIndex:0];
    NSString *url=[[info componentsSeparatedByString:@";"] objectAtIndex:1];
    NSString *type=[[info componentsSeparatedByString:@";"] objectAtIndex:2];
     WBAAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	if ([type isEqualToString:@"Tiled"])
    {
        layer = [[AGSTiledMapServiceLayer alloc] initWithURL:[[NSURL alloc] initWithString:url]];
        
        
            [appDelegate.mapView insertMapLayer:layer withName:title atIndex:0];
        return;
        
    }
    else if ([type isEqualToString:@"Dynamic"])
    {
        layer = [[AGSDynamicMapServiceLayer alloc] initWithURL:[[NSURL alloc] initWithString:url]];
        AGSDynamicMapServiceLayer *Dlayer=layer;//设定图像格式为png32防止出现毛边
        Dlayer.imageFormat=AGSImageFormatPNG32;
    }
    else
        layer=[[AGSLayer alloc] init];
    
   
    //[appDelegate.mapView addMapLayer:layer withName:title];
    [appDelegate.mapView insertMapLayer:layer withName:title atIndex:[appDelegate.mapView.mapLayers count]-3];
}


-(IBAction)LayerAlphaValueChanged:(id)sender
{
    WBAAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    //NSLog(@"%d",appDelegate.mapView.mapLayers.count);
    for (int i=0;i<appDelegate.mapView.mapLayers.count;i++)
    {
        AGSLayer *lry=[appDelegate.mapView.mapLayers objectAtIndex:i];
        if ([lry.name isEqualToString:ServiceName.text])
        {
            lry.opacity=ServiceOpacity.value;
            break;
        }
    }
}




- (void)dealloc {
    [super dealloc];
}
@end
