//
//  MergeTicketView.m
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 19/02/18.
//  Copyright © 2018 Ladybird websolutions pvt ltd. All rights reserved.
//

#import "MergeTicketView.h"
#import "MultipleTicketAssignCell.h"

@interface MergeTicketView ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation MergeTicketView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title=@"Ticket Status Change";
     self.tablview.separatorStyle=UITableViewCellSeparatorStyleNone;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MultipleTicketAssignCell *cell=[tableView dequeueReusableCellWithIdentifier:@"MultipleTicketAssignCellId"];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MultipleTicketAssignCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    // cell.questionLabel.text=[questions objectAtIndex:indexPath.row];
    
    return cell;
}

@end
