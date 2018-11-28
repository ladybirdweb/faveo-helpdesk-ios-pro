//
//  DetailViewController.h
//  SideMEnuDemo
//
//  Created by Narendra on 16/09/16.
//  Copyright © 2016 Ladybird websolutions pvt ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 @class DetailViewController
 
 @brief This class contains details of a ticket.
 
 @discussion This contain details of a ticket like Subject, Priority, HelpTopic, Name, email, source, ticket type and sue date.
 Here agent can edit things like subject, ticket priority,HelpTopic and Source.
 
*/

@interface DetailViewController : UITableViewController <UITextFieldDelegate>

/*!
 @property emailTextField
 
 @brief This property defines a textfield that shows email of a user.
 */
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

/*!
 @property firstnameTextField
 
 @brief This property defines a textfield that shows name of a user.
 */
@property (weak, nonatomic) IBOutlet UITextField *firstnameTextField;
//@property (weak, nonatomic) IBOutlet UITextField *lastnameTextField;

/*!
 @property helpTopicTextField
 
 @brief This property defines a textfield that shows Help Topic name.
 */
@property (weak, nonatomic) IBOutlet UITextField *helpTopicTextField;

/*!
 @property slaTextField
 
 @brief This property defines a textfield that shows SLA.
 */
@property (weak, nonatomic) IBOutlet UITextField *slaTextField;

/*!
 @property deptTextField
 
 @brief This property defines a textfield that shows department.
 */
@property (weak, nonatomic) IBOutlet UITextField *deptTextField;

/*!
 @property subjectTextField
 
 @brief This property defines a textfield that shows subject.
 */
@property (weak, nonatomic) IBOutlet UITextField *subjectTextField;

/*!
 @property statusTextField
 
 @brief This property defines a textfield that shows status of ticket.
 */
@property (weak, nonatomic) IBOutlet UITextField *statusTextField;

/**
 @property typeTextField
 
 @brief This property defines a textfield that shows type of ticket.
 */
@property (weak, nonatomic) IBOutlet UITextField *typeTextField;

/*!
 @property priorityTextField
 
 @brief This property defines a textfield that shows ticket priority.
 */
@property (weak, nonatomic) IBOutlet UITextField *priorityTextField;

/*!
 @property sourceTextField
 
 @brief This property defines a textfield that shows sorce of ticket.
 */
@property (weak, nonatomic) IBOutlet UITextField *sourceTextField;

/*!
 @property dueDateTextField
 
 @brief This property defines a textfield that shows due date of a ticket.
 */
@property (weak, nonatomic) IBOutlet UITextField *dueDateTextField;

/*!
 @property createdDateTextField
 
 @brief This property defines a textfield that shows date of ticket created.
 */
@property (weak, nonatomic) IBOutlet UITextField *createdDateTextField;

/*!
 @property lastResponseDateTextField
 
 @brief This property defines a textfield that shows date of last response of a tocket.
 */
@property (weak, nonatomic) IBOutlet UITextField *lastResponseDateTextField;


/*!
 @property helptopicsArray
 
 @brief This property defines a array that shows list of Help Topics.
 */
@property (nonatomic, strong) NSArray * helptopicsArray;

/*!
 @property slaPlansArray
 
 @brief This property defines a array that shows list of SLA plans.
 */
@property (nonatomic, strong) NSArray * slaPlansArray;

/*!
 @property deptArray
 
 @brief This property defines a array that shows list of Departments.
 */
@property (nonatomic, strong) NSArray * deptArray;

/*!
 @property priorityArray
 
 @brief This property defines a array that shows list of Ticket Priority.
 */
@property (nonatomic, strong) NSArray * priorityArray;

/*!
 @property sourceArray
 
 @brief This property defines a array that shows list of Ticket Source.
 */
@property (nonatomic, strong) NSArray * sourceArray;

/*!
 @property statusArray
 
 @brief This property defines a array that shows list of Ticket Status.
 */
@property (nonatomic, strong) NSArray * statusArray;

/*!
 @property typeArray
 
 @brief This property defines a array that shows list of Ticket types.
 */
@property (nonatomic, strong) NSArray * typeArray;

/*!
 @property saveButton
 
 @brief This property defines button action.
 
 @discussion Buttons use the Target-Action design pattern to notify your app when the user taps the button. Rather than handle touch events directly, you assign action methods to the button and designate which events trigger calls to your methods. At runtime, the button handles all incoming touch events and calls your methods in response.

 */
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

/*!
 @property selectedIndex
 
 @brief This property defines in index which is an Integer format.
 */
@property (nonatomic, assign) NSInteger selectedIndex;


/*!
 @property assignArray
 
 @brief This property defines an array which contains a list of assignee/agent names
 */
@property (nonatomic, strong) NSMutableArray * assignArray;

/*!
 @property assinTextField
 
 @brief This textField property used to show assignee/agent name
 */
@property (weak, nonatomic) IBOutlet UITextField *assinTextField;

/*!
 @property subjectTextView
 
 @brief This textView property used to show ticket subject
 */
@property (weak, nonatomic) IBOutlet UITextView *subjectTextView;

@end
