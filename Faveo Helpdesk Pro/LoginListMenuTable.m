//
//  LoginListMenuTable.m
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 15/02/18.
//  Copyright © 2018 Ladybird websolutions pvt ltd. All rights reserved.
//

#import "LoginListMenuTable.h"
#import "LoginListMenuTableCell.h"
#import "LoginDetailPage1.h"
#import "LoginDetailPage2.h"


@interface LoginListMenuTable ()<UITableViewDataSource,UITableViewDelegate>
{
    NSArray *subjects;
  //  NSArray *images;
    
}
@end

@implementation LoginListMenuTable

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title=@"Login Information";
    
    subjects=[NSArray arrayWithObjects:@"1. Login using Faveo Credentials",@"2. Login via Social Media", nil];
   // images=[NSArray arrayWithObjects:@"call1",@"cc1",@"chat", nil];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return subjects.count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LoginListMenuTableCell * cell=[tableView dequeueReusableCellWithIdentifier:@"LoginListMenuTableCellId"];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"LoginListMenuTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
 
    cell.questionLabel.text=[subjects objectAtIndex:indexPath.row];
   //cell.imageView.image=[UIImage imageNamed:[images objectAtIndex:indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.row==0)
    {
        
        LoginDetailPage1 * one=[self.storyboard instantiateViewControllerWithIdentifier:@"LoginDetailPage1Id"];
        [self.navigationController pushViewController:one animated:YES];
    }
    else if(indexPath.row==1)
    {
//        LoginDetailPage2 * two=[self.storyboard instantiateViewControllerWithIdentifier:@"LoginDetailPage2Id"];
//        [self.navigationController pushViewController:two animated:YES];
//        LoginDetailPage1 * one=[self.storyboard instantiateViewControllerWithIdentifier:@"LoginDetailPage1Id"];
//        [self.navigationController pushViewController:one animated:YES];
    }
    
}


@end
