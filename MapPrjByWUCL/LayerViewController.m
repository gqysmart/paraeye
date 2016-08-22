//
//  LayerViewController.m
//  MapPrjByWUCL
//
//  Created by JSJM on 14-5-19.
//  Copyright (c) 2014年 cc. All rights reserved.
//

#import "LayerViewController.h"
#import "MyTableViewCell.h"
#import "QuartzCore/QuartzCore.h"

@interface LayerViewController ()

@end

@implementation LayerViewController
@synthesize myLayerViewDelegate;

UITableView *DataTable;


NSMutableDictionary *Servicelstattribute;
NSInteger *intt;//控制图层标签顺序； 管线在第一
NSInteger *intt2;
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    DataTable = [[UITableView alloc] initWithFrame:CGRectMake(35, 0, 320, 673) style:UITableViewStyleGrouped];
    UIImageView *imageview = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 673)] autorelease];
    [imageview setImage:[UIImage imageNamed:@"panelbj.png"]];
    [DataTable setBackgroundView:imageview];
    [DataTable setDelegate:self];
    [DataTable setDataSource:self];
    [self.view addSubview:DataTable];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:true];
    intt=0;
    intt2=0;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [Servicelstattribute count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [DataTable deselectRowAtIndexPath:[DataTable indexPathForSelectedRow] animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[Servicelstattribute allKeys] objectAtIndex:section];
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(IBAction)btnPanelControlClick:(id)sender
{
    [myLayerViewDelegate btnLayerViewClick];
}

-(void)GetMapSource:(NSMutableDictionary *)_Servicelstattribute
{
   // [Servicelstattribute removeAllObjects];
  Servicelstattribute=_Servicelstattribute;

//   NSMutableArray *ServiceArray = [[NSMutableArray alloc] init];
//    [ServiceArray addObject:[[_Servicelstattribute objectForKey:[[_Servicelstattribute allKeys] objectAtIndex:1]] objectAtIndex:1]];
//    [Servicelstattribute setValue:ServiceArray forKey:[[_Servicelstattribute allKeys] objectAtIndex:1]];
//    	
//    
//    [ServiceArray addObject:[[_Servicelstattribute objectForKey:[[_Servicelstattribute allKeys] objectAtIndex:0]] objectAtIndex:1]];
//    [Servicelstattribute setValue:ServiceArray forKey:[[_Servicelstattribute allKeys] objectAtIndex:0]];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[Servicelstattribute allValues] objectAtIndex:section] count];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MyTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier ];
    
    if (cell == nil)
    {
        NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:@"MyTableViewCell" owner:self options:nil];
        cell = (UITableViewCell *)[nibArray objectAtIndex:0];
    }
    
//    NSString *key=[[Servicelstattribute allKeys] objectAtIndex:indexPath.section];
//    NSString *value=[[Servicelstattribute objectForKey:key] objectAtIndex:indexPath.row];
    NSLog(@"%d",indexPath.section);
    NSLog(@"%d",indexPath.row);
    NSString *key;
    NSString *value;
    if(intt==0)
    {
        
        key=[[Servicelstattribute allKeys] objectAtIndex:1];
       value=[[Servicelstattribute objectForKey:key] objectAtIndex:0];
        intt=intt+1;
    }
    else
    {
        
        key=[[Servicelstattribute allKeys] objectAtIndex:0];
        value=[[Servicelstattribute objectForKey:key] objectAtIndex:0];
    }
    
    
    
    [cell setServerName:value];
    return cell;//返回cell
}


- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    if (sourceIndexPath != destinationIndexPath) {
        NSString *ssection = [Servicelstattribute.allKeys objectAtIndex:sourceIndexPath.section];
        NSString *srow =[NSString stringWithString:[[Servicelstattribute objectForKey:ssection] objectAtIndex:sourceIndexPath.row]];
        [[Servicelstattribute objectForKey:ssection] removeObjectAtIndex:sourceIndexPath.row];
        //        NSLog(@"%@",ssection);
        //        NSLog(@"%@",srow);
        
        NSString *tsection = [Servicelstattribute.allKeys objectAtIndex:destinationIndexPath.section];
        NSString *trow = [[Servicelstattribute objectForKey:tsection] objectAtIndex:destinationIndexPath.row];
        //        NSLog(@"%@",tsection);
        //        NSLog(@"%@",trow);
        if ([[Servicelstattribute objectForKey:tsection] count]==0)
            [[Servicelstattribute objectForKey:tsection] addObject:srow];
        else
            [[Servicelstattribute objectForKey:tsection] insertObject:srow atIndex:destinationIndexPath.row];
        [myLayerViewDelegate MapLayerIndexChangeFrom:srow To:[[trow componentsSeparatedByString:@";"] objectAtIndex:0]];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* myView = [[[UIView alloc] init] autorelease];
    //myView.backgroundColor = [UIColor colorWithRed:0.10 green:0.68 blue:0.94 alpha:0.7];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 300, 30)];
    titleLabel.textColor=[UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    if(intt2==0)
    {
         titleLabel.text=[[Servicelstattribute allKeys] objectAtIndex:1];
        intt2=intt2+1;
    }
    else
    {
        titleLabel.text=[[Servicelstattribute allKeys] objectAtIndex:0];

    }
        titleLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:20];
    [myView addSubview:titleLabel];
    [titleLabel release];
    return myView;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
