//
//  BufferQueryController.h
//  NJSZGX
//
//  Created by JSJM on 15-8-26.
//  Copyright (c) 2015年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIDialogWindow.h"
@protocol BufferQueryDelegate
-(IBAction)btnBufferQueryClick;
@property (nonatomic, strong) IBOutlet UIView *PopView;
@property (nonatomic, strong) IBOutlet UIView *MainView;
@property (nonatomic,strong) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property bool identifyFlag;

@end
@interface BufferQueryController : UIViewController
<UITableViewDelegate, UITableViewDataSource>
{
 id<BufferQueryDelegate> myBufferQueryDelegate;
  NSMutableArray *BigName;
    NSMutableArray *SmallName;
    NSMutableArray *AllName;
    NSMutableArray *attGotton;//从服务器端获取的值
    NSMutableArray *Tablelist;//存储表单显示结果
    NSMutableArray *Objectlist;//存储结果编号显示结果
    NSString *FormatPointstr;
}

@property (nonatomic,assign) id<BufferQueryDelegate> myBufferQueryDelegate;


- (IBAction)btnBufferQueryClick:(UIButton *)sender;
- (IBAction)BtnDrawBuffer:(UIButton *)sender;
- (IBAction)BtnCreateBuffer:(UIButton *)sender ;

@property (nonatomic, retain) IBOutlet UIView *PopViewSon;
@property (nonatomic, retain) IBOutlet UILabel *BufferlblValue;
@property (nonatomic, retain) IBOutlet UITextField *Bufferdistance;
@property (nonatomic, retain) IBOutlet UIPickerView *Bufferpicklist;
@property (nonatomic, retain) IBOutlet UISegmentedControl *Segment;
@property (nonatomic, retain) IBOutlet UIView *BoxPick;
@property (nonatomic, retain) IBOutlet UITextField *textBigClass;
@property (nonatomic, retain) IBOutlet UITextField *textSmallClass;
@property (nonatomic, retain) IBOutlet UIButton *btqueryBuffer;
@property (nonatomic, retain) IBOutlet UIButton *btnSmallclass;
@property (nonatomic, retain) IBOutlet UIButton *btnBigclass;
@property (nonatomic, retain) IBOutlet UITableView *tbResultview;
@property (nonatomic, retain) IBOutlet UIButton *btnCreatBuffer;
@property (nonatomic, retain) IBOutlet UIView *ResultView;
@property (nonatomic, retain) IBOutlet UILabel *CURleaf;
@property (nonatomic, retain) IBOutlet UILabel *ALLleaf;
@property (nonatomic, retain) IBOutlet UIButton *btnPreleaf;
@property (nonatomic, retain) IBOutlet UIButton *btnNextleaf;
- (IBAction)BtnBigclass:(UIButton *)sender ;
- (IBAction)BtnSmallclass:(UIButton *)sender;






@end