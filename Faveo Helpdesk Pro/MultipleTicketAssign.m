//
//  MultipleTicketAssign.m
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 19/02/18.
//  Copyright © 2018 Ladybird websolutions pvt ltd. All rights reserved.
//

#import "MultipleTicketAssign.h"
#import "MergeTicketViewCell.h"
#import "MergeTicketViewCell2.h"

@interface MultipleTicketAssign ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation MultipleTicketAssign

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.title=@"Multiple Ticket Assign";
     self.tableview.separatorStyle=UITableViewCellSeparatorStyleNone;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0)
    {
        
    MergeTicketViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"MergeTicketViewCellId"];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MergeTicketViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    // cell.questionLabel.text=[questions objectAtIndex:indexPath.row];
    
    return cell;
    }
    
    MergeTicketViewCell2 *cell=[tableView dequeueReusableCellWithIdentifier:@"MergeTicketViewCell2Id"];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MergeTicketViewCell2" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    return cell;
    
}

@end
