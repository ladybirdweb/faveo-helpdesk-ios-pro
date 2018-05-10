//
//  InboxViewController.h
//  SideMEnuDemo
//
//  Created  on 19/08/16.
//  Copyright © 2016 Ladybird websolutions pvt ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"

/*!
 @class InboxViewController
 
 @brief This class contains list of tickets.
 
 @discussion This class contains a table view and it gives a list of Clients. After clicking a particular ticket we can see name of client, email id, profile picture, contact number.
 Also it will show client is active and inactive.
 It contains a list of messages that he was created.
 
 */

@interface InboxViewController : UIViewController<SlideNavigationControllerDelegate,UITableViewDataSource,UITableViewDelegate>

{
    BOOL searching;
}
/*!
 @property tableView
 
 @brief This propert is an instance of a table view.
 
 @discussion Table views are versatile user interface objects frequently found in iOS apps. A table view presents data in a scrollable list of multiple rows that may be divided into sections.
 */
@property (weak, nonatomic) IBOutlet UITableView *tableView;


-(void)NotificationBtnPressed;

@property (nonatomic) NSInteger page;

@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) NSMutableArray *sampleDataArray;
@property (strong, nonatomic) NSMutableArray *filteredSampleDataArray;


-(void)hideTableViewEditMode;


-(void)showMessageForLogout:(NSString*)message sendViewController:(UIViewController *)viewController;

@end

