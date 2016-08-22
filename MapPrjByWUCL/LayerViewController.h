//
//  LayerViewController.h
//  MapPrjByWUCL
//
//  Created by JSJM on 14-5-19.
//  Copyright (c) 2014年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyTableViewCell.h"
@protocol LayerViewDelegate
-(IBAction)btnLayerViewClick;
-(IBAction)MapLayerIndexChangeFrom:(NSString *)name1 To:(NSString *)name2;
@end
@interface LayerViewController : UIViewController
<UITableViewDelegate, UITableViewDataSource>
{
    id<LayerViewDelegate> myLayerViewDelegate;
}
@property (nonatomic, assign) id<LayerViewDelegate> myLayerViewDelegate;

-(IBAction)btnPanelControlClick:(id)sender;
-(void)GetMapSource:(NSMutableDictionary *)_Servicelstattribute;
@end
