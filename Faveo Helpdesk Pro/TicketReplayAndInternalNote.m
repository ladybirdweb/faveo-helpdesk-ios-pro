//
//  TicketReplay and Internal Note.m
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 16/02/18.
//  Copyright © 2018 Ladybird websolutions pvt ltd. All rights reserved.
//

#import "TicketReplayAndInternalNote.h"
#import "TicketReplayInternalNoteCell.h"
#import "TicketReplayInternalNoteCell2.h"
#import "TicketReplayInternalNoteCell3.h"


@interface TicketReplayAndInternalNote ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation TicketReplayAndInternalNote

- (void)viewDidLoad {
    [super viewDidLoad];
   self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.section==0){
        TicketReplayInternalNoteCell * cell=[tableView dequeueReusableCellWithIdentifier:@"TicketReplayInternalNoteCellId"];
        
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TicketReplayInternalNoteCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        //    cell.headingOneLabel.text=[questions objectAtIndex:indexPath.row];
        //    cell.headingTwoLabel.text=[subHeading objectAtIndex:indexPath.row];
        return cell;
    }
    else if(indexPath.section==1){
        TicketReplayInternalNoteCell3 * cell=[tableView dequeueReusableCellWithIdentifier:@"TicketReplayInternalNoteCell3Id"];
        
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TicketReplayInternalNoteCell3" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        return cell;
    }
   
        TicketReplayInternalNoteCell2 * cell=[tableView dequeueReusableCellWithIdentifier:@"TicketReplayInternalNoteCell2Id"];
        
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TicketReplayInternalNoteCell2" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        return cell;
  
    
}

@end
