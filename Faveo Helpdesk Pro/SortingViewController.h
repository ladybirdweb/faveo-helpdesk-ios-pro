//
//  SortingViewController.h
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 01/11/17.
//  Copyright © 2017 Ladybird websolutions pvt ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"

@interface SortingViewController : UIViewController<SlideNavigationControllerDelegate,UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

-(void)NotificationBtnPressed;


@property (nonatomic) NSInteger page;

@end
