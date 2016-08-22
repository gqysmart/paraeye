//
//  TubeStatisticsView.h
//  NJSZGX
//
//  Created by JSJM on 15-8-21.
//  Copyright (c) 2015年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol TubeStatisticsDelegate
-(IBAction)btnTubeStatisticsClick;
@property (nonatomic, retain) IBOutlet UIView *PopView;
@property (nonatomic, retain) IBOutlet UIView *MainView;
@end

@interface TubeStatisticsView : UIViewController
<UITableViewDelegate, UITableViewDataSource>
{
    id<TubeStatisticsDelegate> myTubeStatisticsDelegate;
    NSMutableArray *LayerNamearr;//存储统计图层的数组
    NSMutableArray *BIGclassName;
    NSMutableArray *SMALLclassName;
     NSMutableArray *StatisticsRangeName;//统计范围
     NSMutableArray *StatisticsRangeField;//统计范围
    NSMutableArray *SonListName;//子项集合
    NSString *allstr;
    NSString *RangeMark;
    NSMutableArray *TableDataSource;
}

@property (nonatomic,assign) id<TubeStatisticsDelegate> myTubeStatisticsDelegate;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, retain) IBOutlet UIPickerView *ClassPick;
@property (nonatomic, retain) IBOutlet UITableView *ResultTable;
@property (nonatomic, retain) IBOutlet UITextField *TextBigclass;
@property (nonatomic, retain) IBOutlet UITextField *TextSmallclass;
@property (nonatomic, retain) IBOutlet UIButton *BtnselectValue;
@property (nonatomic, retain) IBOutlet UITextField *TextRange;
@property (nonatomic, retain) IBOutlet UITextField *TextSon;
@property (nonatomic, retain) IBOutlet UIView *ViewOFPick;
@property (nonatomic,strong) IBOutlet NSArray  *Alllayerstrarr;
@property (nonatomic,strong) IBOutlet UIView  *StatisitcsPopView;
@property (nonatomic,strong) IBOutlet UIView *StatisticResultBox;



@end
