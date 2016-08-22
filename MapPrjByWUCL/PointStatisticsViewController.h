//
//  PointStatisticsViewController.h
//  NJSZGX（new）
//
//  Created by JSJM on 15-9-7.
//  Copyright (c) 2015年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol PointStatisticsDelegate

@property (nonatomic, retain) IBOutlet UIView *PopView;
@property (nonatomic, retain) IBOutlet UIView *MainView;
@end

@interface PointStatisticsViewController : UIViewController
<UITableViewDelegate, UITableViewDataSource>
{
    id<PointStatisticsDelegate> myPointStatisticsDelegate;
    
    NSMutableArray *BIGclassName;
    NSMutableArray *SMALLclassName;
    NSMutableArray *StatisticsRangeName;//统计范围
    NSMutableArray *StatisticsRangeField;//统计范围
    NSMutableArray *SonListName;//子项集合
    NSString *allstr;
    NSString *RangeMark;
    NSMutableArray *TableDataSource;
}
@property (nonatomic,assign) id<PointStatisticsDelegate> myPointStatisticsDelegate;
@property (nonatomic, retain) IBOutlet UIPickerView *ClassPick;
@property (nonatomic, retain) IBOutlet UITableView *ResultTable;
@property (nonatomic, retain) IBOutlet UITextField *TextBigclass;
@property (nonatomic, retain) IBOutlet UITextField *TextSmallclass;
@property (nonatomic,strong) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@property (nonatomic, retain) IBOutlet UIButton *BtnselectValue;
@property (nonatomic, retain) IBOutlet UITextField *TextRange;
@property (nonatomic, retain) IBOutlet UITextField *TextSon;
@property (nonatomic, retain) IBOutlet UIView *ViewOFPick;
@property (nonatomic,strong) IBOutlet NSArray  *Alllayerstrarr;
@property (nonatomic,strong) IBOutlet UIView  *StatisitcsPopView;
@property (nonatomic,strong) IBOutlet UIView *StatisticResultBox;
- (IBAction)BtnStatistic:(UIButton *)sender ;
- (IBAction)setClassClick:(UIButton *)sender ;
- (IBAction)selectClassClick:(UIButton *)sender;
@end

