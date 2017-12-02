//
//  FilterLogic.h
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 14/11/17.
//  Copyright © 2017 Ladybird websolutions pvt ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"


@interface FilterLogic : UIViewController<SlideNavigationControllerDelegate,UITableViewDataSource,UITableViewDelegate>


@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) NSInteger page;


@end
