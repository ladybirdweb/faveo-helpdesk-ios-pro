//
//  MultipleTicketSelectView.m
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 19/02/18.
//  Copyright © 2018 Ladybird websolutions pvt ltd. All rights reserved.
//

#import "MultipleTicketSelectView.h"
#import "MultipleTicketSelectViewCell.h"

@interface MultipleTicketSelectView ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation MultipleTicketSelectView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"Multiple Ticket Select";
     self.tablview.separatorStyle=UITableViewCellSeparatorStyleNone;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MultipleTicketSelectViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"MultipleTicketSelectViewCellId"];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MultipleTicketSelectViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
   // cell.questionLabel.text=[questions objectAtIndex:indexPath.row];
    
    return cell;
}
@end
