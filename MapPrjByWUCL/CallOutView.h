//
//  CallOutView.h
//  NJSZGX（new）
//
//  Created by JSJM on 15-8-28.
//  Copyright (c) 2015年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CallOutViewDelegate


@end

@interface CallOutView : UIViewController
<UITableViewDelegate, UITableViewDataSource>
{
    id<CallOutViewDelegate> myCallOutViewDetegate;
    NSMutableArray  *sendATT;
    
}

@property (nonatomic, assign) id<CallOutViewDelegate> myCallOutViewDetagate;

@property (nonatomic, retain) IBOutlet UITextView *textV;
-(void)BingAttributeby:(NSString *)ATTstr;
@end
