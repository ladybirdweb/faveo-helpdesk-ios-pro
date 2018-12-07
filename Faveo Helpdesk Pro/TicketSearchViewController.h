//
//  TicketSearchViewController.h
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 09/03/18.
//  Copyright © 2018 Ladybird websolutions pvt ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 @class TicketSearchViewController
 
 @brief This class used to search tickets and users.
 
 @discussion In this class, 2 tableview used, one is for showing tickets and one is for showing user list. There one textField used to take input from user and when he clicks on search button he will get data depending upon segmented control selection (By default first segment selection is there so it will show tickets data) if not present any data or match not found then it show no data.
 
 */
@interface TicketSearchViewController : UIViewController

/*!
 @property page
 
 @brief This integer property used to declare page number.
 */
@property (nonatomic) NSInteger page;

/*!
 @property path1
 
 @brief This integer property used to declare url path.
 */
@property (nonatomic, strong) NSString *path1;

/*!
 @property seachTextField
 
 @brief This is an textField property
 
 @discussion This property used for search option.
 */
@property (weak, nonatomic) IBOutlet UITextField *seachTextField;

/*!
 @property tableview1
 
 @brief This is an tableView property
 
 @discussion This property used to show search results of tickets data.
 */
@property (weak, nonatomic) IBOutlet UITableView *tableview1;

/*!
 @property tableview2
 
 @brief This is an tableView property
 
 @discussion This property used to show search results of user data.
 */
@property (weak, nonatomic) IBOutlet UITableView *tableview2;


@end
