//
//  FilterViewController.h
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 13/11/17.
//  Copyright © 2017 Ladybird websolutions pvt ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DropDownListView.h"

/*!
 @class FilterViewController
 
 @brief This class used to create UI for ticket filter.
 
 @discussion Depending upon required ticket filter is implemented by adding some textFields which accepts the filter parameter and sends to ticket filter logic view.
 */

@interface FilterViewController : UITableViewController<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>


/*!
 @property departmentTextField
 
 @brief This is an textField property
 
 @discussion This textField is used to accept the department parameter for filter
 */
@property (weak, nonatomic) IBOutlet UITextField *departmentTextField;

/*!
 @property priorityTextField
 
 @brief This is an textField property
 
 @discussion This textField is used to accept the ticket priority parameter for filter
 */
@property (weak, nonatomic) IBOutlet UITextField *priorityTextField;

/*!
 @property typeTextField
 
 @brief This is an textField property
 
 @discussion This textField is used to accept the ticket type parameter for filter
 */
@property (weak, nonatomic) IBOutlet UITextField *typeTextField;

/*!
 @property sourceTextField
 
 @brief This is an textField property
 
 @discussion This textField is used to accept the ticket source parameter for filter
 */
@property (weak, nonatomic) IBOutlet UITextField *sourceTextField;

/*!
 @property statusTextField
 
 @brief This is an textField property
 
 @discussion This textField is used to accept the ticket status parameter for filter
 */
@property (weak, nonatomic) IBOutlet UITextField *statusTextField;

/*!
 @property assignTextField
 
 @brief This is an textField property
 
 @discussion This textField is used to accept the agent parameter for filter
 */
@property (weak, nonatomic) IBOutlet UITextField *assignTextField;

/*!
 @property submitButton
 
 @brief This is an Button property
 
 @discussion This property created for changing the color of button according to your requirement.
 */
@property (weak, nonatomic) IBOutlet UIButton *submitButton;


/*!
 @method submitClicked
 
 @brief This is an button method.
 
 @discussion When user clicks on submits an submit buttons then it takes all parameters which are selected for ticket filter and navigate to ticket filter logic and shows an filtered tickets.
 
 @code
 
- (IBAction)submitClicked:(id)sender;
 
 @endcode
 
 */
- (IBAction)submitClicked:(id)sender;


/*!
 @property sourceArray
 
 @brief This is an Array property
 
 @discussion It is used to store and represents all list of ticket sources.
 */
@property (nonatomic, strong) NSArray * sourceArray;

/*!
 @property helptopicsArray
 
 @brief This is an Array property
 
 @discussion It is used to store and represents all list of  help topics.
 */
@property (nonatomic, strong) NSArray * helptopicsArray;

/*!
 @property slaPlansArray
 
 @brief This is an Array property
 
 @discussion It is used to store and represents all list of SLA plans present in the Helpdesk.
 */
@property (nonatomic, strong) NSArray * slaPlansArray;

/*!
 @property deptArray
 
 @brief This is an Array property
 
 @discussion It is used to store and represents all list of department present in the Helpdesk.
 */
@property (nonatomic, strong) NSArray * deptArray;

/*!
 @property priorityArray
 
 @brief This is an Array property
 
 @discussion It is used to store and represents all list of ticket priorities present in the Helpdesk.
 */
@property (nonatomic, strong) NSArray * priorityArray;

/*!
 @property typeArray
 
 @brief This is an Array property
 
 @discussion It is used to store and represents all list of ticket types present in the Helpdesk.
 */
@property (nonatomic, strong) NSArray * typeArray;

/*!
 @property statusArray
 
 @brief This is an Array property
 
 @discussion It is used to store and represents all list of ticket status present in the helpdesk.
 */
@property (nonatomic, strong) NSArray * statusArray;


/*!
 @method SelectDepartment
 
 @brief This is an button action used to show an popup view.
 
 @discussion Using this user can able to select any department value from this pop-up view and used for filter
 
 @code
 
- (IBAction)SelectDepartment:(id)sender;
 
 @endcode
 */
- (IBAction)SelectDepartment:(id)sender;


/*!
 @method SelectPriority
 
 @brief This is an button action used with show an popup view.
 
 @discussion Using this user can able to select any ticket priority value from this pop-up view and used for filter
 
 @code
 
 - (IBAction)SelectPriority:(id)sender;
 
 @endcode
 */
- (IBAction)SelectPriority:(id)sender;

/*!
 @method SelectTicketTypes
 
 @brief This is an button action used with show an popup view.
 
 @discussion Using this user can able to select any ticket type value from this pop-up view and used for filter
 
 @code
 
- (IBAction)SelectTicketTypes:(id)sender;
 
 @endcode
 */
- (IBAction)SelectTicketTypes:(id)sender;



/*!
 @method SelectTicketSource
 
 @brief This is an button action used with show an popup view.
 
 @discussion Using this user can able to select any ticket source value from this pop-up view and used for filter
 
 @code
 
 - (IBAction)SelectTicketSource:(id)sender;
 
 @endcode
 */
- (IBAction)SelectTicketSource:(id)sender;

/*!
 @method SelectTicketStatus
 
 @brief This is an button action used with show an popup view.
 
 @discussion Using this user can able to select any ticket status value from this pop-up view and used for filter
 
 @code
 
 - (IBAction)SelectTicketStatus:(id)sender;

 
 @endcode
 */
- (IBAction)SelectTicketStatus:(id)sender;


/*!
 @method SelectAssignee
 
 @brief This is an button action used with show an popup view.
 
 @discussion Using this user can able to select any agent value from this pop-up view and used for filter
 
 @code
 
 - (IBAction)SelectAssignee:(id)sender;
 
 @endcode
 */
- (IBAction)SelectAssignee:(id)sender;


@end
