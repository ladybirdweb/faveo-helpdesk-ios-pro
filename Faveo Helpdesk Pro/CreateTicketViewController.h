//
//  CreateTicketViewController.h
//  SideMEnuDemo
//
//  Created on 19/08/16.
//  Copyright © 2016 Ladybird websolutions pvt ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"

/*!
 @class CreateTicketViewController
 
 @brief This class contain Ticket  create process.
 
 @discussion Here  we can create a ticket by filling some necessary information. After filling valid infomation, ticket will be crated.
 */

@interface CreateTicketViewController : UITableViewController<SlideNavigationControllerDelegate,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,UITextViewDelegate>

/*!
 @property textViewMsg
 
 @brief Using this user can write multiple lines of messages even paragraph also.
 
 @discussion UITextView supports the display of text using custom style information and also supports text editing. You typically use a text view to display multiple lines of text, such as when displaying the body of a large text document.
 */

@property (weak, nonatomic) IBOutlet UITextView *textViewMsg;

/*!
 @property emailTextField
 
 @brief It is textfiled that allows a user to enter his email address.
 */
@property (weak, nonatomic) IBOutlet UITextView *emailTextView;

/*!
 @property firstNameTextField
 
 @brief It is textfiled that allows a user to enter his first name.
 */
@property (weak, nonatomic) IBOutlet UITextView *firstNameView;

/*!
 @property lastNameTextField
 
 @brief It is textfiled that allows a user to enter his last name.
 */
@property (weak, nonatomic) IBOutlet UITextView *lastNameView;

/*!
 @property codeTextField
 
 @brief It is textfiled that allows a user to enter country code of a mobile or phone.
 */
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;

/*!
 @property mobileTextField
 
 @brief It is textfiled that allows a user to enter his mobile number.
 */
@property (weak, nonatomic) IBOutlet UITextView *mobileView;

/*!
 @property helpTopicTextField
 
 @brief It is textfiled that allows a user to enter Help Topic name.
 */
@property (weak, nonatomic) IBOutlet UITextField *helpTopicTextField;

/*!
 @property slaTextField
 
 @brief It is textfiled that allows a user to enter SLA plan.
 */
@property (weak, nonatomic) IBOutlet UITextField *slaTextField;

/*!
 @property deptTextField
 
 @brief It is textfiled that allows a user to enter Department.
 */
@property (weak, nonatomic) IBOutlet UITextField *deptTextField;

/*!
 @property subjectTextField
 
 @brief It is textfiled that allows a user to write a subject.
 */
@property (weak, nonatomic) IBOutlet UITextView *subjectView;

/*!
 @property priorityTextField
 
 @brief It is textfiled allows to select priority.
 */

@property (weak, nonatomic) IBOutlet UITextField *priorityTextField;

@property (weak, nonatomic) IBOutlet UITextField *assignTextField;

/*!
 @property submitButton
 
 @brief This is a button property.
 
 @discussion When you tap a button, or select a button that has focus, the button performs any actions attached to it. You communicate the purpose of a button using a text label, an image, or both.
 */
@property (weak, nonatomic) IBOutlet UIButton *submitButton;


/*!
 @property helptopicsArray
 
 @brief This is array that represents list of Help Topics.
 
 @discussion An object representing a static ordered collection, for use instead of an Array constant in cases that require reference semantics.
 */
@property (nonatomic, strong) NSArray * helptopicsArray;

/*!
 @property slaPlansArray
 
 @brief This is array that represents list of SLA plans.
 
 @discussion An object representing a static ordered collection, for use instead of an Array constant in cases that require reference semantics.
 */
@property (nonatomic, strong) NSArray * slaPlansArray;

/*!
 @property deptArray
 
 @brief This is array that represents list of Departments.
 
 @discussion An object representing a static ordered collection, for use instead of an Array constant in cases that require reference semantics.
 */
@property (nonatomic, strong) NSArray * deptArray;

/*!
 @property priorityArray
 
 @brief This is array that represents list of Priorities.
 
 @discussion An object representing a static ordered collection, for use instead of an Array constant in cases that require reference semantics.
 */
@property (nonatomic, strong) NSArray * priorityArray;

/*!
 @property countryArray
 
 @brief This is array that represents list of Country names.
 
 @discussion An object representing a static ordered collection, for use instead of an Array constant in cases that require reference semantics.
 */
@property (nonatomic, strong) NSArray * countryArray;

/*!
 @property codeArray
 
 @brief This is array that represents list of Country Codes.
 
 @discussion An object representing a static ordered collection, for use instead of an Array constant in cases that require reference semantics.
 */
@property (nonatomic, strong) NSArray * codeArray;

/*!
 @property staffArray
 
 @brief This is array that represents list of Agent Lists.
 
 @discussion An object representing a static ordered collection, for use instead of an Array constant in cases that require reference semantics.
 */
@property (nonatomic, strong) NSMutableArray * staffArray;

/*!
 @property countryDic
 
 @brief This is Dictionary that represents list of Country Names.
 
 @discussion An object representing a static collection of key-value pairs, for use instead ofa Dictionary constant in cases that require reference semantics.
 */
@property (nonatomic, strong) NSDictionary * countryDic;

/*!
 @property selectedIndex
 
 @brief It is an interger number that indicates an Index.
 */
@property (nonatomic, assign) NSInteger selectedIndex;


/*!
 @method helpTopicClicked
 
 @brief It will gives List of Help Topics.
 
 @discussion After clicking this button it will show list of help topics.
 
 The help topics can be Support Query, Sales Query or Operational Query.
 
 @code
 
- (IBAction)helpTopicClicked:(id)sender;
 
 @endcode

 */

- (IBAction)helpTopicClicked:(id)sender;

/*!
 @method priorityClicked
 
 @brief This will gives List of Ticket Priorities.
 
 @discussion After clicking this button whatever we done any chnages in ticket, it will save and updated in ticket details.
 
 @code
 
 - (IBAction)priorityClicked:(id)sender;

 @endocde
 */


/*!
 @method submitClicked
 
 @brief This is an button that perform an action.
 
 @discussion  After cicking this submit button, the data enetered in textfiled while ticket creation will be saved.
 
 @code
 
 - (IBAction)submitClicked:(id)sender;
 
 @endcode

 */
- (IBAction)submitClicked:(id)sender;

/*!
 @method countryCodeClicked
 
 @brief This will gives List of all country codes.
 
 @code
 
 - (IBAction)countryCodeClicked:(id)sender;

 @endocde
 */
- (IBAction)countryCodeClicked:(id)sender;

/*!
 @method staffClicked
 
 @brief This will gives List of all agent list.
 
 @code
 
 - (IBAction)staffClicked:(id)sender;
 
 @endocde
 */
- (IBAction)staffClicked:(id)sender;



/*!
 @method addRequesterClicked
 
 @brief This is an button method and used to add user.
 
 @code
 
 - (IBAction)addRequesterClicked:(id)sender;
 
 @endocde
 */
- (IBAction)addRequesterClicked:(id)sender;

/*!
 @property addReqImg
 
 @brief This is an property of type image used show an image Icon.
 
 @discussion This is used to shown an image for register button. After clicking on this button it will navigate to the register user page.
 */
@property (weak, nonatomic) IBOutlet UIImageView *addReqImg;

/*!
 @property ccTextField
 
 @brief This is an textField property.
 
 @discussion This is used to add cc (user mail) to the ticket.
 */
@property (weak, nonatomic) IBOutlet UITextField *ccTextField;

/*!
 @property fileImage
 
 @brief This is an Image Property.
 
 @discussion This is used to show an icon (attachment type) of selected attachment.
 */
@property (weak, nonatomic) IBOutlet UIImageView *fileImage;

/*!
 @property fileName123
 
 @brief This is an Label Property.
 
 @discussion This is used to show file name of the selected attachment.
 */
@property (weak, nonatomic) IBOutlet UILabel *fileName123;

/*!
 @property fileSize123
 
 @brief This is an Label Property.
 
 @discussion This is used to show file size of the selected attachment.
 */
@property (weak, nonatomic) IBOutlet UILabel *fileSize123;


@end
