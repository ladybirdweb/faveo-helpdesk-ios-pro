//
//  UnassignedTicketsViewController.h
//  SideMEnuDemo
//
//  Created  on 01/09/16.
//  Copyright © 2016 Ladybird websolutions pvt ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"

/*!
 @class UnassignedTicketsViewController
 
 @brief This class contains list of Unassigned Tickets.
 
 @discussion This class contains a table view and it gives a list of unassigned tickets. After clicking a particular ticket we can see name of user, ticket number and his email id. 
     Also It shows ticket created Time and also show overdue time if ticket is due.
*/
@interface UnassignedTicketsViewController :UIViewController<SlideNavigationControllerDelegate,UITableViewDataSource,UITableViewDelegate>


@end
