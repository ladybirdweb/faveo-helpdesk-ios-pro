//
//  LoginDetailPage2.m
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 15/02/18.
//  Copyright © 2018 Ladybird websolutions pvt ltd. All rights reserved.
//

#import "LoginDetailPage2.h"

@interface LoginDetailPage2 ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation LoginDetailPage2

- (void)viewDidLoad {
    [super viewDidLoad];
   
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    LoginListMenuTableCell * cell=[tableView dequeueReusableCellWithIdentifier:@"LoginListMenuTableCellId"];
    //
    //    if (cell == nil)
    //    {
    //        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"LoginListMenuTableCell" owner:self options:nil];
    //        cell = [nib objectAtIndex:0];
    //    }
    
    UITableViewCell *cell;
    return cell;
}

@end
