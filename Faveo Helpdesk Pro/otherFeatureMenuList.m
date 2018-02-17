//
//  otherFeatureMenuList.m
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 15/02/18.
//  Copyright © 2018 Ladybird websolutions pvt ltd. All rights reserved.
//

#import "otherFeatureMenuList.h"
#import "otherFeatureMenuListCell.h"

@interface otherFeatureMenuList ()<UITableViewDataSource,UITableViewDelegate>
{
     NSArray *questions;
}
@end

@implementation otherFeatureMenuList

- (void)viewDidLoad {
    [super viewDidLoad];
   
    questions=[NSArray arrayWithObjects:@"1. All about tickets",@"2.Ticket Replay and Internal Note",@"3.Ticket sorting and filtration",@"4.Multple Ticket Selection Feature", nil];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return questions.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    otherFeatureMenuListCell *cell=[tableView dequeueReusableCellWithIdentifier:@"otherFeatureMenuListCellId"];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"otherFeatureMenuListCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.questionLabel.text=[questions objectAtIndex:indexPath.row];
    
    return cell;
}




@end
