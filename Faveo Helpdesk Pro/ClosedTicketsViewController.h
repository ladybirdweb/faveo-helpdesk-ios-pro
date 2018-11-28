//
//  ClosedTicketsViewController.h
//  SideMEnuDemo
//
//  Created on 01/09/16.
//  Copyright © 2016 Ladybird websolutions pvt ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"

/*!
 @class ClosedTicketsViewController
 
 @brief This class contains list of Trash Tickets.
 
 @discussion This class contains a table view and it gives a list of trashed tickets. After clicking a particular ticket we will moves to conversation page. Here we will see conversation between Agent and client.
 */

@interface ClosedTicketsViewController :UIViewController<SlideNavigationControllerDelegate,UITableViewDataSource,UITableViewDelegate>

/*!
 @property page
 
 @brief This is an integer property
 
 @discussion It used to represent the page number.
 */
@property (nonatomic) NSInteger page;

@end
