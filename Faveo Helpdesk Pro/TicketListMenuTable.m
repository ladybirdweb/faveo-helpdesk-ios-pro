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
  //  NSArray *images;
}
@end

@implementation TicketListMenuTable

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title=@"Ticket";
    
    questions=[NSArray arrayWithObjects:@"1. All about tickets",@"2. Ticket Replay and Internal Note",@"3. Ticket sorting and filtration",@"4. Changing status of ticket", nil];
    
    subHeading=[NSArray arrayWithObjects:@"Ticket create, edit and view ticket details.",@"How to give reply to ticket, add internal note",@"sorting, filtering a ticket based on some parameters",@"open, close, delete, spam, resolved ..etc", nil];
   // images=[NSArray arrayWithObjects:@"loginHelpSection",@"ticket2",@"userHelpSection",@"otherFeatures", nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return questions.count;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
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
  //  cell.imageView.image = [UIImage imageNamed:[images objectAtIndex:indexPath.row]];
    
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
