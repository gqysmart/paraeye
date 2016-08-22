//
//  CallOutView.m
//  NJSZGX（new）
//
//  Created by JSJM on 15-8-28.
//  Copyright (c) 2015年 cc. All rights reserved.
//

#import "CallOutView.h"
#import "calloutCell.h"

@interface CallOutView ()

@end



@implementation CallOutView
@synthesize myCallOutViewDetagate;

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
    sendATT=[[NSMutableArray alloc]init];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)BingAttributeby:(NSString *)ATTstr
{
    if (!([ATTstr length]==0))
    {
        NSLog(@"%@",ATTstr);
        //没有这个不能刷新，未知
        UILabel *label=[[UILabel alloc] init];
        label.frame=CGRectMake(0,0, 0, 0);
        [self.view addSubview:label];
        NSArray *ar=[ATTstr componentsSeparatedByString:@"$"];
        for (int i=0; i<ar.count; i++) {
            NSLog(@"%@",[ar objectAtIndex:i]);
            [sendATT addObject:[ar objectAtIndex:i] ];
        }
    
    }
}








- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
     NSLog(@"%d",[sendATT count]);
    return   [sendATT count];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Cellcallout = @"calloutCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Cellcallout ];
    
    if (cell == nil)
    {
    NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:@"calloutCell" owner:self options:nil];
            cell = (UITableViewCell *)[nibArray objectAtIndex:0];
        
    }
    
    NSUInteger row = [indexPath row];
    cell.textLabel.font= [UIFont fontWithName:@"Helvetica Neue" size:14];
     [cell setTextName:[sendATT objectAtIndex:row]];
      return cell;//返回cell
}




@end
