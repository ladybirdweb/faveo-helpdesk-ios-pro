//
//  MultpleTicketAssignTableViewController.h
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 04/01/18.
//  Copyright © 2018 Ladybird websolutions pvt ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 @class MultpleTicketAssignTableViewController
 
 @brief This class used to implement the concept of multiple ticket assign feature.
 
 @discussion Here you can able to assign the number of ticket which was selected from Inbox and comes to this multiple ticket assign view. After navigating here user can able to select the assignee name i.e agent. When user selects the any agent name and hits on assign button then that selected tickets are assigned to that particular agent.
 
 */
@interface MultpleTicketAssignTableViewController : UITableViewController<UITableViewDataSource,UITableViewDelegate>

/*!
 @property cancelLabel
 
 @brief This is an Label property.
 
 @discussion This label is used as a button for performing some action.
 */
@property (weak, nonatomic) IBOutlet UILabel *cancelLabel;

/*!
 @property assignLabel
 
 @brief This is an Label property.
 
 @discussion This label is used as a button for performing some action.
 */
@property (weak, nonatomic) IBOutlet UILabel *assignLabel;


/*!
 @property assignLabel
 
 @brief This is an textField property.
 
 @discussion The selected value from picker view will appear here.
 */
@property (weak, nonatomic) IBOutlet UITextField *assinTextField;


/*!
 @method selectAssignee
 
 @brief This is an button action, it open an pickerView.
 
 @discussion When user clicks on assignTextField it will open an pickerView. User can select any one assignee/agent.
 
 @code
 
 - (IBAction)selectAssignee:(id)sender;
 
 @endcode
 */
- (IBAction)selectAssignee:(id)sender;

@end
