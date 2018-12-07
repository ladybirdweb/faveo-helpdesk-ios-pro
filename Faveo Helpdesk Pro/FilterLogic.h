//
//  FilterLogic.h
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 14/11/17.
//  Copyright © 2017 Ladybird websolutions pvt ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"

/*!
 @class FilterLogic
 
 @brief This class used to implement ticket filters.
 
 @discussion Depending upon user selected the filters, according to that values it perform an filter action and will give your filtered tickets
 
 */
@interface FilterLogic : UIViewController<SlideNavigationControllerDelegate,UITableViewDataSource,UITableViewDelegate>



/*!
 @property tableView
 
 @brief This is tableView property
 
 @discussion This is an instance an tableView used for internal purpose.
 */

@property (weak, nonatomic) IBOutlet UITableView *tableView;

/*!
 @property page
 
 @brief This is integer property
 
 @discussion This is used to represent current page number.
 */

@property (nonatomic) NSInteger page;


@end
