//
//  TicketStusChange.m
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 17/02/18.
//  Copyright © 2018 Ladybird websolutions pvt ltd. All rights reserved.
//

#import "TicketStusChange.h"
#import "TicketStusChangeCell.h"

@interface TicketStusChange ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation TicketStusChange

- (void)viewDidLoad {
    [super viewDidLoad];
    
     self.tableview.separatorStyle=UITableViewCellSeparatorStyleNone;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
//    if(indexPath.section==0){
        TicketStusChangeCell * cell=[tableView dequeueReusableCellWithIdentifier:@"TicketStusChangeCellId"];

        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TicketStusChangeCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        //    cell.headingOneLabel.text=[questions objectAtIndex:indexPath.row];
        //    cell.headingTwoLabel.text=[subHeading objectAtIndex:indexPath.row];
        return cell;
//    }
//
//    FIlterAndSort2 * cell=[tableView dequeueReusableCellWithIdentifier:@"FIlterAndSort2Id"];
//
//    if (cell == nil)
//    {
//        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FIlterAndSort2" owner:self options:nil];
//        cell = [nib objectAtIndex:0];
//    }
//    //    cell.headingOneLabel.text=[questions objectAtIndex:indexPath.row];
//    //    cell.headingTwoLabel.text=[subHeading objectAtIndex:indexPath.row];
//    return cell;
   
}


@end
