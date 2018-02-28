//
//  TicketListMenuTable.m
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 15/02/18.
//  Copyright © 2018 Ladybird websolutions pvt ltd. All rights reserved.
//

#import "TicketListMenuTable.h"
#import "TicketListTableView.h"
#import "AllAboutTicketsInformation.h"
#import "TicketReplayAndInternalNote.h"
#import "TicketSortingAndFilter.h"
#import "TicketStusChange.h"

@interface TicketListMenuTable ()<UITableViewDelegate,UITableViewDataSource>
{
    NSArray *questions;
    NSArray *subHeading;
}
@end

@implementation TicketListMenuTable

- (void)viewDidLoad {
    [super viewDidLoad];
    
    questions=[NSArray arrayWithObjects:@"1. All about tickets",@"2.Ticket Replay and Internal Note",@"3.Ticket sorting and filtration",@"4. Changing status of ticket", nil];
    
    subHeading=[NSArray arrayWithObjects:@"Some information, malliakrjun hanagandi",@"Some information, malliakrjun hanagandi",@"Some information, malliakrjun hanagandi",@"Some information, malliakrjun hanagandi", nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return questions.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    TicketListTableView * cell=[tableView dequeueReusableCellWithIdentifier:@"TicketListTableViewId"];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TicketListTableView" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.headingOneLabel.text=[questions objectAtIndex:indexPath.row];
    cell.headingTwoLabel.text=[subHeading objectAtIndex:indexPath.row];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.row==0)
    {
        AllAboutTicketsInformation *td=[self.storyboard instantiateViewControllerWithIdentifier:@"AllAboutTicketsInformationId"];
        [self.navigationController pushViewController:td animated:YES];
        
    }else if(indexPath.row==1)
    {
        TicketReplayAndInternalNote *td=[self.storyboard instantiateViewControllerWithIdentifier:@"TicketReplayAndInternalNoteId"];
        [self.navigationController pushViewController:td animated:YES];
        
    }else if(indexPath.row==2)
    {
        TicketSortingAndFilter *td=[self.storyboard instantiateViewControllerWithIdentifier:@"TicketSortingAndFilterId"];
        [self.navigationController pushViewController:td animated:YES];
        
    }
    else if(indexPath.row==3)
    {
        TicketStusChange *td=[self.storyboard instantiateViewControllerWithIdentifier:@"TicketStusChangeId"];
        [self.navigationController pushViewController:td animated:YES];
        
    }
    
}


@end
