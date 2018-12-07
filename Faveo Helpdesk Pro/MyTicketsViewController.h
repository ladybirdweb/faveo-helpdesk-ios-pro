//
//  MyTicketsViewController.h
//  SideMEnuDemo
//
//  Created by Narendra on 01/09/16.
//  Copyright © 2016 Ladybird websolutions pvt ltd. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"

/*!
 @class MyTicketsViewController
 
 @brief This class contains list of Tickets that assigned to particular agent.
 
 @discussion This class uses a table view and it gives a list of tickets. Every ticket contain ticket number, subject, profile picture and contact number of client. After clicking a particular ticket it will moves to conversation page. Here we will see conversation between Agent and client.
 */

@interface MyTicketsViewController :UIViewController<SlideNavigationControllerDelegate,UITableViewDataSource,UITableViewDelegate>

/*!
 @property page
 
 @brief This is an integer property
 
 @discussion It used to represent the page number.
 */
@property (nonatomic) NSInteger page;
@end
