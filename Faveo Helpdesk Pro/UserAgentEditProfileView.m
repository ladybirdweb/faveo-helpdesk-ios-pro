//
//  UserAgentEditProfileView.m
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 17/02/18.
//  Copyright © 2018 Ladybird websolutions pvt ltd. All rights reserved.
//

#import "UserAgentEditProfileView.h"
#import "UserAgentEditCell.h"

@interface UserAgentEditProfileView ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation UserAgentEditProfileView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tablview.separatorStyle=UITableViewCellSeparatorStyleNone;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserAgentEditCell *cell=[tableView dequeueReusableCellWithIdentifier:@"UserAgentEditCellId"];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"UserAgentEditCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    //   cell.nameLabel.text=[questions objectAtIndex:indexPath.row];
    
    return cell;
}

@end
