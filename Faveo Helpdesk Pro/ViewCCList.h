//
//  ViewCCList.h
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 04/05/18.
//  Copyright © 2018 Ladybird websolutions pvt ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 @class ViewCCList
 
 @brief This class used to show list of CC.
 
 @discussion TableView is used in order to shown cc list, user can able to remove cc from the tableView - 1 cc he can remove at a time.
 
 */
@interface ViewCCList : UIViewController <UITableViewDataSource,UITableViewDelegate>

/*!
 @property tableview1
 
 @brief This tableView property used for internal purpose.
 */
@property (weak, nonatomic) IBOutlet UITableView *tableview1;

/*!
 @property removeCCLabel
 
 @brief This label property used to show an label
 */
@property (weak, nonatomic) IBOutlet UIButton *removeCCLabel;

/*!
 @property removeFinalLabel
 
 @brief This label property used to show an label and acts as a button and remove cc
 */
@property (weak, nonatomic) IBOutlet UIButton *removeFinalLabel;

/*!
 @method removeFinalButton
 
 @brief This is an button action method.
 
 @discussion After clicking this button it will remove cc from the ticket.
 
 @code
 
 - (IBAction)removeFinalButton:(id)sender;
 
 @endcode
 */
- (IBAction)removeFinalButton:(id)sender;


/*!
 @method removeCCButton
 
 @brief This is an button action method.
 
 @discussion After clicking this button it will remove cc from the ticket.
 
 @code
 
 - (IBAction)removeCCButton:(id)sender;

 @endcode
 
 */
- (IBAction)removeCCButton:(id)sender;



@end
