//
//  EditDetailTableViewController.h
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 23/09/17.
//  Copyright © 2017 Ladybird websolutions pvt ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 @class EditDetailTableViewController
 
 @brief This class used for edit ticket.
 
 @discussion By changing ticket properties like subject, status, type and assignee of the ticket user can able to update the ticket details only if agent/admin having permission of edit ticket else it will show an warning like you do not permission.
 
 */
@interface EditDetailTableViewController : UITableViewController<UITextFieldDelegate>


/*!
 @property helpTopicTextField
 
 @brief This is an textField property
 
 @discussion It used to show and update helptopic value.
 */

@property (weak, nonatomic) IBOutlet UITextField *helpTopicTextField;

/*!
 @property slaTextField
 
 @brief This is an textField property
 
 @discussion It used to show and update SLA value.
 */
@property (weak, nonatomic) IBOutlet UITextField *slaTextField;

/*!
 @property deptTextField
 
 @brief This is an textField property
 
 @discussion It used to show and update department value.
 */
@property (weak, nonatomic) IBOutlet UITextField *deptTextField;

/*!
 @property subjectTextField
 
 @brief This is an textField property
 
 @discussion It used to show and update ticket subject value.
 */
@property (weak, nonatomic) IBOutlet UITextField *subjectTextField;

/*!
 @property statusTextField
 
 @brief This is an textField property
 
 @discussion It used to show and update ticket status value.
 */
@property (weak, nonatomic) IBOutlet UITextField *statusTextField;

/*!
 @property typeTextField
 
 @brief This is an textField property
 
 @discussion It used to show and update ticket type value.
 */
@property (weak, nonatomic) IBOutlet UITextField *typeTextField;

/*!
 @property priorityTextField
 
 @brief This is an textField property
 
 @discussion It used to show and update ticket priority value.
 */
@property (weak, nonatomic) IBOutlet UITextField *priorityTextField;

/*!
 @property sourceTextField
 
 @brief This is an textField property
 
 @discussion It used to show and update ticket source value.
 */
@property (weak, nonatomic) IBOutlet UITextField *sourceTextField;


/*!
 @property helptopicsArray
 
 @brief This an Array property used to store all the helptopics names from the Helpdesk.
 */
@property (nonatomic, strong) NSArray * helptopicsArray;

/*!
 @property slaPlansArray
 
 @brief This an Array property used to store all the SLA names from the Helpdesk.
 */
@property (nonatomic, strong) NSArray * slaPlansArray;

/*!
 @property deptArray
 
 @brief This an Array property used to store all the department names from the Helpdesk.
 */
@property (nonatomic, strong) NSArray * deptArray;

/*!
 @property priorityArray
 
 @brief This an Array property used to store all the ticket priority names from the Helpdesk.
 */
@property (nonatomic, strong) NSArray * priorityArray;

/*!
 @property sourceArray
 
 @brief This an Array property used to store all the ticket source names from the Helpdesk.
 */
@property (nonatomic, strong) NSArray * sourceArray;

/*!
 @property statusArray
 
 @brief This an Array property used to store all the ticket status names from the Helpdesk.
 */
@property (nonatomic, strong) NSArray * statusArray;

/*!
 @property typeArray
 
 @brief This an Array property used to store all the ticket type names from the Helpdesk.
 */
@property (nonatomic, strong) NSArray * typeArray;


/*!
 @property saveButton
 
 @brief This is an button property.

 */
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

/*!
 @property selectedIndex
 
 @brief It used to represent the index of an pickerView
 */
@property (nonatomic, assign) NSInteger selectedIndex;


/*!
 @property assinTextField
 
 @brief This textField property used to show and update the value of an assignee/agent name.
 */
@property (weak, nonatomic) IBOutlet UITextField *assinTextField;

/*!
 @property subjectTextView
 
 @brief This textField is used to show and update the ticket subject data.+
 */
@property (weak, nonatomic) IBOutlet UITextView *subjectTextView;



/*!
 @method sourceClicked
 
 @brief This will gives List of all ticket source list.
 
 @code
 
 - (IBAction)sourceClicked:(id)sender;
 
 @endocde
 */
- (IBAction)sourceClicked:(id)sender;


/*!
 @method typeClicked
 
 @brief This will gives List of all ticket types list.
 
 @code
 
 - (IBAction)typeClicked:(id)sender;
 
 @endocde
 */
- (IBAction)typeClicked:(id)sender;

//- (IBAction)statusClicked:(id)sender;
- (IBAction)helpTopicClicked:(id)sender;


/*!
 @method assignClicked
 
 @brief This will gives List of all agent list.
 
 @code
 
 - (IBAction)assignClicked:(id)sender;
 
 @endocde
 */
- (IBAction)assignClicked:(id)sender;


/*!
 @method saveClicked
 
 @brief It will save the ticket details modified by user.
 
 @code
 
 - (IBAction)saveClicked:(id)sender;
 
 @endocde
 */
- (IBAction)saveClicked:(id)sender;


/*!
 @method priorityClicked
 
 @brief This will gives List of all ticket priority list.
 
 @code
 
 - (IBAction)priorityClicked:(id)sender;
 
 @endocde
 */
- (IBAction)priorityClicked:(id)sender;

//@property (nonatomic, strong) NSMutableArray * assignArray;


@end
