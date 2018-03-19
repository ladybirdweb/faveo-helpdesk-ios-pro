//
//  UserAndAgentMenuList.m
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 15/02/18.
//  Copyright © 2018 Ladybird websolutions pvt ltd. All rights reserved.
//

#import "UserAndAgentMenuList.h"
#import "UserAndAgentMenuListCell.h"
#import "AgentUserListView.h"
#import "UserAgentFilterView.h"
#import "UserAgentEditProfileView.h"

@interface UserAndAgentMenuList ()<UITableViewDataSource,UITableViewDataSource>
{
     NSArray *questions;
}
@end

@implementation UserAndAgentMenuList

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"User Directory";
     questions=[NSArray arrayWithObjects:@"1. How to see list of all agents and users?",@"2. User or Agent Filter",@"3. Editing the user or agent profiles", nil];
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
    UserAndAgentMenuListCell *cell=[tableView dequeueReusableCellWithIdentifier:@"UserAndAgentMenuListCellId"];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"UserAndAgentMenuListCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.nameLabel.text=[questions objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.row==0)
    {
        AgentUserListView *td=[self.storyboard instantiateViewControllerWithIdentifier:@"AgentUserListViewId"];
       [self.navigationController pushViewController:td animated:YES];
       
    } else if(indexPath.row==1)
    {
        UserAgentFilterView *td=[self.storyboard instantiateViewControllerWithIdentifier:@"UserAgentFilterViewId"];
        [self.navigationController pushViewController:td animated:YES];
        
    }else if(indexPath.row==2)
    {
        UserAgentEditProfileView *td=[self.storyboard instantiateViewControllerWithIdentifier:@"UserAgentEditProfileViewId"];
        [self.navigationController pushViewController:td animated:YES];
        
    }
    
}

@end
