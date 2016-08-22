//
//  MyTableViewCell.h
//  MapPrjByWUCL
//
//  Created by JSJM on 14-5-19.
//  Copyright (c) 2014年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyTableViewCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UILabel *ServiceName;
@property (retain, nonatomic) IBOutlet UILabel *ServiceInfo;
@property (retain, nonatomic) IBOutlet UISwitch *ServiceOnOff;
@property (retain, nonatomic) IBOutlet UISlider *ServiceOpacity;

-(void)setServerName:(NSString *)title;
-(IBAction)switchAction:(id)sender;
-(IBAction)LayerAlphaValueChanged:(id)sender;
@end
