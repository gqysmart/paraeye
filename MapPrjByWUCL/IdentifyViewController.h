//
//  IdentifyViewController.h
//  MapPrjByWUCL
//
//  Created by JSJM on 14-5-21.
//  Copyright (c) 2014年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol IdentifyViewDelegate
-(IBAction)btnIdentifyViewClick;
-(void)IdentifyBegion:(NSString *)URL LayerID:(int)identifylayer;
@property (nonatomic, strong) IBOutlet UIView *PopView;
@property (nonatomic, strong) IBOutlet UIView *MainView;
@end
@interface IdentifyViewController : UIViewController
<NSXMLParserDelegate,
UITableViewDelegate,
UITableViewDataSource>
{
    id<IdentifyViewDelegate> myIdentifyViewDelegate;
    NSMutableArray *layerCollectionarr;//存储找到的管线概要
    NSMutableArray *GDBfeaturearr;//存储找到的数据的所有信息
    
    
}
@property (nonatomic, assign) id<IdentifyViewDelegate> myIdentifyViewDelegate;
@property (nonatomic, strong) IBOutlet UIView *FeaListTable;
@property (nonatomic, strong) IBOutlet UITableView *featureTableView;
@property (nonatomic, strong) IBOutlet UILabel *SerarchTip;

@property  (nonatomic, strong) IBOutlet NSMutableArray *ServiceFieldarray;


-(IBAction)btnPanelClick:(id)sender;
-(void)BingData:(NSDictionary *)ATT;
-(void)BingFeature:(NSMutableArray *)Featurearr;
@end
