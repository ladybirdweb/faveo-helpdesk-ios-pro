//
//  NotificationViewController.h
//  Faveo Helpdesk Pro
//
//  Created by Narendra on 14/07/17.
//  Copyright © 2017 Ladybird websolutions pvt ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end
