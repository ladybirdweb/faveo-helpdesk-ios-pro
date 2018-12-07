//
//  SortingViewController.h
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 01/11/17.
//  Copyright © 2017 Ladybird websolutions pvt ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"

/*!
 @class SortingViewController
 
 @brief This class used to implement ticket sorting.
 
 @discussion Depending upon the selection of ticket sorting value from multi-stage drop down view it will call an API and gives you the sorting result.
 
 */

@interface SortingViewController : UIViewController<SlideNavigationControllerDelegate,UITableViewDataSource,UITableViewDelegate>


/*!
 @property page
 
 @brief This is an integer property.
 
 @discussion It used to represent the page number.
 */
@property (nonatomic) NSInteger page;

/*!
 @property tableView
 
 @brief This is an tableView property.
 
 @discussion It used for some internal purpose like updating data, reloading the data.
 */
@property (weak, nonatomic) IBOutlet UITableView *tableView;


/*!
 @method NotificationBtnPressed
 
 @brief This is an button actioc method.
 
 @discussion When you will click on this button it will navigate to the notifications view which will show list of notifications.
 
 @code
 
-(void)NotificationBtnPressed;
 
 @endcode
 */
-(void)NotificationBtnPressed;



@end
