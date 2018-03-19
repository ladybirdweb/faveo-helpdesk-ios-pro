//
//  LoginDetailPage1.m
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 15/02/18.
//  Copyright © 2018 Ladybird websolutions pvt ltd. All rights reserved.
//

#import "LoginDetailPage1.h"
#import "LoginDetailPage1Cell.h"


@interface LoginDetailPage1 ()<UITableViewDataSource,UITableViewDelegate>
{
   
}
@end

@implementation LoginDetailPage1

- (void)viewDidLoad {
    [super viewDidLoad];
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if(indexPath.section==0){
    LoginDetailPage1Cell * cell=[tableView dequeueReusableCellWithIdentifier:@"LoginDetailPage1CellId"];

    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"LoginDetailPage1Cell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }

   // cell.number.text=[array1 objectAtIndex:indexPath.row];
    return cell;
//    }
    
 //   if(indexPath.section==1)//{
//    LoginDetailPage2Cell * cell=[tableView dequeueReusableCellWithIdentifier:@"LoginDetailPage2CellId"];
//
//    if (cell == nil)
//    {
//        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"LoginDetailPage2Cell" owner:self options:nil];
//        cell = [nib objectAtIndex:0];
//    }
//
//   // cell.number.text=[array1 objectAtIndex:indexPath.row];
//    return cell;
//    }
//    UITableViewCell *cell;
//   return  cell;
}

@end
