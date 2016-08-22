//
//  CircleQueryViewController.h
//  NJSZGX（new）
//
//  Created by JSJM on 15-8-31.
//  Copyright (c) 2015年 cc. All rights reserved.
//


#import <UIKit/UIKit.h>

@protocol CircleQueryDelegate
-(IBAction)btnCircleQueryhideorshow;
@property (nonatomic, retain) IBOutlet UIView *PopView;
@property (nonatomic, retain) IBOutlet UIView *MainView;
@property (nonatomic,strong) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@end
@interface CircleQueryViewController : UIViewController
<UITableViewDelegate, UITableViewDataSource>
{
    id<CircleQueryDelegate> myCircleQueryDelegate;
    NSMutableArray *BigName;
    NSMutableArray *SmallName;
    NSMutableArray *AllName;
    NSMutableArray *attGotton;//从服务器端获取的值
    NSMutableArray *Tablelist;//存储表单显示结果
     NSMutableArray *Objectlist;//存储表单对象代码显示结果
    NSString *FormatPointstr;
}


@property (nonatomic,assign) id<CircleQueryDelegate> myCircleQueryDelegate;




@property (nonatomic, retain) IBOutlet UILabel *BufferlblValue;
@property (nonatomic, retain) IBOutlet UITextField *Bufferdistance;
@property (nonatomic, retain) IBOutlet UIPickerView *Bufferpicklist;

@property (nonatomic, retain) IBOutlet UIView *BoxPick;
@property (nonatomic, retain) IBOutlet UITextField *textBigClass;
@property (nonatomic, retain) IBOutlet UITextField *textSmallClass;
@property (nonatomic, retain) IBOutlet UIButton *btqueryBuffer;
@property (nonatomic, retain) IBOutlet UIButton *btnSmallclass;
@property (nonatomic, retain) IBOutlet UIButton *btnBigclass;
@property (nonatomic, retain) IBOutlet UITableView *tbResultview;
@property (nonatomic, retain) IBOutlet UIButton *btnCreatBuffer;
@property (nonatomic, retain) IBOutlet UIButton *btnDrawBuffer;
@property (nonatomic, retain) IBOutlet UIView *ResultView;
@property (nonatomic, retain) IBOutlet UISegmentedControl *Segment;
@property (nonatomic, retain) IBOutlet UISegmentedControl *Selmode;
@property (nonatomic, retain) IBOutlet UILabel *CURleaf;

@property (nonatomic, retain) IBOutlet UILabel *ALLleaf;

@property (nonatomic, retain) IBOutlet UIButton *btnPreleaf;
@property (nonatomic, retain) IBOutlet UIButton *btnNextleaf;
@property (nonatomic, retain) IBOutlet UIView *PopViewSon;

- (IBAction)BtnBigclass:(UIButton *)sender ;
- (IBAction)BtnCreateBuffer:(UIButton *)sender;
- (IBAction)BtnSmallclass:(UIButton *)sender;
- (IBAction)BtnDrawBuffer:(UIButton *)sender;
- (IBAction)btnbufferquery:(UIButton *)sender ;



@end
