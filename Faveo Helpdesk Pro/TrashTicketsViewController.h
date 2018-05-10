//
//  TrashTicketsViewController.h
//  SideMEnuDemo
//
//  Created on 01/09/16.
//  Copyright © 2016 Ladybird websolutions pvt ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"

/*!
 @class TrashTicketsViewController
 
 @brief This class contains list of Trash Tickets.
 
 @discussion This class contains a table view and it gives a list of trashed tickets. After clicking a particular ticket we will moves to conversation page. Here we will see conversation between Agent and client.
 */

@interface TrashTicketsViewController :UIViewController<SlideNavigationControllerDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic) NSInteger page;
@end
