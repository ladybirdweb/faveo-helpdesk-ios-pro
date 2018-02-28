//
//  otherFeatureMenuList.m
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 15/02/18.
//  Copyright © 2018 Ladybird websolutions pvt ltd. All rights reserved.
//

#import "otherFeatureMenuList.h"
#import "otherFeatureMenuListCell.h"

#import "MultipleTicketSelectView.h"
#import "MultipleTicketAssign.h"
#import "MultipleTicketStatusChange.h"
#import "MergeTicketView.h"

@interface otherFeatureMenuList ()<UITableViewDataSource,UITableViewDelegate>
{
     NSArray *questions;
}
@end

@implementation otherFeatureMenuList

- (void)viewDidLoad {
    [super viewDidLoad];
   
    questions=[NSArray arrayWithObjects:@"1. How to select multiple tickets?",@"2. How to assign multiple tickets to agent?",@"3. How to change status of multilple tickets?",@"4. How to merge tickets?", nil];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return questions.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    otherFeatureMenuListCell *cell=[tableView dequeueReusableCellWithIdentifier:@"otherFeatureMenuListCellId"];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"otherFeatureMenuListCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.questionLabel.text=[questions objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.row==0)
    {
        
        MultipleTicketSelectView *td=[self.storyboard instantiateViewControllerWithIdentifier:@"MultipleTicketSelectViewId"];
        [self.navigationController pushViewController:td animated:YES];
        
    }else  if(indexPath.row==1)
    {
        
        MultipleTicketAssign *td=[self.storyboard instantiateViewControllerWithIdentifier:@"MultipleTicketAssignId"];
        [self.navigationController pushViewController:td animated:YES];
        
    } else  if(indexPath.row==2)
    {
        
        MultipleTicketStatusChange *td=[self.storyboard instantiateViewControllerWithIdentifier:@"MultipleTicketStatusChangeId"];
        [self.navigationController pushViewController:td animated:YES];
        
    } if(indexPath.row==3)
    {
        
        MergeTicketView *td=[self.storyboard instantiateViewControllerWithIdentifier:@"MergeTicketViewId"];
        [self.navigationController pushViewController:td animated:YES];
        
    }
}



@end
