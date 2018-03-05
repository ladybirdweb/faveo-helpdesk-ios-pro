//
//  MultipleTicketStatusChange.m
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 19/02/18.
//  Copyright © 2018 Ladybird websolutions pvt ltd. All rights reserved.
//

#import "MultipleTicketStatusChange.h"
#import "MultipleTicketStatusChangeCell.h"

@interface MultipleTicketStatusChange ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation MultipleTicketStatusChange

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"Status Change";
    self.tablview.separatorStyle=UITableViewCellSeparatorStyleNone;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    MultipleTicketStatusChangeCell *cell=[tableView dequeueReusableCellWithIdentifier:@"MultipleTicketStatusChangeCellId"];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MultipleTicketStatusChangeCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    // cell.questionLabel.text=[questions objectAtIndex:indexPath.row];
    
    return cell;
    
}
@end
