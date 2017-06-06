//
//  LeftMenuViewController.h
//  SideMEnuDemo
//
//  Created by Narendra on 17/08/16.
//  Copyright © 2016 Ladybird websolutions pvt ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"

@interface LeftMenuViewController :UITableViewController

@property (nonatomic, assign) BOOL slideOutAnimationEnabled;
@property (weak, nonatomic) IBOutlet UIImageView *user_profileImage;
@property (weak, nonatomic) IBOutlet UILabel *user_role;
@property (weak, nonatomic) IBOutlet UILabel *url_label;
@property (weak, nonatomic) IBOutlet UILabel *user_nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *inbox_countLabel;
@property (weak, nonatomic) IBOutlet UILabel *myTickets_countLabel;
@property (weak, nonatomic) IBOutlet UILabel *unassigned_countLabel;
@property (weak, nonatomic) IBOutlet UILabel *closed_countLabel;
@property (weak, nonatomic) IBOutlet UILabel *trash_countLabel;

@end
