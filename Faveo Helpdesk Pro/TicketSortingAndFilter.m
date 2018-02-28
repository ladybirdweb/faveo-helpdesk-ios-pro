//
//  Ticket Sorting and Filter.m
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 16/02/18.
//  Copyright © 2018 Ladybird websolutions pvt ltd. All rights reserved.
//

#import "TicketSortingAndFilter.h"
#import "TicketSortingFikterCell.h"
#import "FIlterAndSort2.h"



@interface TicketSortingAndFilter ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation TicketSortingAndFilter

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tablview.separatorStyle=UITableViewCellSeparatorStyleNone;
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
    
     if(indexPath.section==0){
        TicketSortingFikterCell * cell=[tableView dequeueReusableCellWithIdentifier:@"TicketSortingFikterCellId"];
        
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TicketSortingFikterCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        //    cell.headingOneLabel.text=[questions objectAtIndex:indexPath.row];
        //    cell.headingTwoLabel.text=[subHeading objectAtIndex:indexPath.row];
        return cell;
    }

    FIlterAndSort2 * cell=[tableView dequeueReusableCellWithIdentifier:@"FIlterAndSort2Id"];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FIlterAndSort2" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    //    cell.headingOneLabel.text=[questions objectAtIndex:indexPath.row];
    //    cell.headingTwoLabel.text=[subHeading objectAtIndex:indexPath.row];
    return cell;
    
}

@end
