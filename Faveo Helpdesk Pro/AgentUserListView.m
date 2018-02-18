//
//  AgentUserListView.m
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 17/02/18.
//  Copyright © 2018 Ladybird websolutions pvt ltd. All rights reserved.
//

#import "AgentUserListView.h"
#import "UserAgentListCell.h"
#import "UserAndAgentMenuListCell2.h"

@interface AgentUserListView ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation AgentUserListView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     self.tableview.separatorStyle=UITableViewCellSeparatorStyleNone;
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
    UserAgentListCell *cell=[tableView dequeueReusableCellWithIdentifier:@"UserAgentListCellId"];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"UserAgentListCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    return cell;
    }
    
    UserAndAgentMenuListCell2 *cell=[tableView dequeueReusableCellWithIdentifier:@"UserAndAgentMenuListCell2Id"];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"UserAndAgentMenuListCell2" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    return cell;


}

@end
