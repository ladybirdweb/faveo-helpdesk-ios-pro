//
//  AllAboutTicketsInformation.m
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 16/02/18.
//  Copyright © 2018 Ladybird websolutions pvt ltd. All rights reserved.
//

#import "AllAboutTicketsInformation.h"
#import "AllAboutTicketCell.h"
#import "AllAboutTicketCell2.h"
#import "AllAboutTicketCell3.h"
#import "AllAboutTicketCell1.h"
#import "AllAboutTicketCell4.h"
#import "AllAboutTicketCell5.h"
#import "AllAboutTicketCell6.h"

@interface AllAboutTicketsInformation ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation AllAboutTicketsInformation

- (void)viewDidLoad {
    [super viewDidLoad];
   self.title=@"All About Tickets";
    self.tableVIew.separatorStyle=UITableViewCellSeparatorStyleNone;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 7;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if(indexPath.section==0){
       AllAboutTicketCell * cell=[tableView dequeueReusableCellWithIdentifier:@"AllAboutTicketCellId"];

        if (cell == nil)
           {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AllAboutTicketCell" owner:self options:nil];
               cell = [nib objectAtIndex:0];
            }
        //    cell.headingOneLabel.text=[questions objectAtIndex:indexPath.row];
        //    cell.headingTwoLabel.text=[subHeading objectAtIndex:indexPath.row];
        return cell;
    }
    else if(indexPath.section==1){
        AllAboutTicketCell1 * cell=[tableView dequeueReusableCellWithIdentifier:@"AllAboutTicketCell1Id"];
        
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AllAboutTicketCell1" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        return cell;
    }
    else if(indexPath.section==2){
        AllAboutTicketCell2 * cell=[tableView dequeueReusableCellWithIdentifier:@"AllAboutTicketCell2Id"];
        
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AllAboutTicketCell2" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
    
        return cell;
    }
    else if(indexPath.section==3){
        AllAboutTicketCell3 * cell=[tableView dequeueReusableCellWithIdentifier:@"AllAboutTicketCell3Id"];
        
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AllAboutTicketCell3" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        return cell;
    }
    else if(indexPath.section==4){
        AllAboutTicketCell4 * cell=[tableView dequeueReusableCellWithIdentifier:@"AllAboutTicketCell4Id"];
        
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AllAboutTicketCell4" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        return cell;
    }
    else if(indexPath.section==5){
        AllAboutTicketCell5 * cell=[tableView dequeueReusableCellWithIdentifier:@"AllAboutTicketCell5Id"];
        
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AllAboutTicketCell5" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        return cell;
    }
    
        AllAboutTicketCell6 * cell=[tableView dequeueReusableCellWithIdentifier:@"AllAboutTicketCell6Id"];
        
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AllAboutTicketCell6" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        return cell;
   
}
@end
