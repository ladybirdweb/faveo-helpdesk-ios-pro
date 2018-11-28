

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"


/*!
 @class AddRequester
 
 @brief This class used for registering the user.
 
 @discussion This class contains some textFields which is used to take values of the users and using these details he can able to register in the Faveo using Register API call.
 */

@interface AddRequester : UITableViewController<SlideNavigationControllerDelegate,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,UITextViewDelegate>


/*!
 @property emailTextView
 
 @brief This is an textField property.
 
 @discussion This is used to accept the email of the user.
 */
@property (weak, nonatomic) IBOutlet UITextField *emailTextView;

/*!
 @property firstNameView
 
 @brief This is an textField property.
 
 @discussion This is used to accept the first name of the user.
 */
@property (weak, nonatomic) IBOutlet UITextField *firstNameView;

/*!
 @property lastNameView
 
 @brief This is an textField property.
 
 @discussion This is used to accept the last name of the user.
 */
@property (weak, nonatomic) IBOutlet UITextField *lastNameView;


/*!
 @property mobileTextField
 
 @brief This is an textField property.
 
 @discussion This is used to accept the mobile of the user.
 */
@property (weak, nonatomic) IBOutlet UITextField *mobileTextField;

/*!
 @property codeTextField
 
 @brief This is an textField property.
 
 @discussion This is used to accept the mobile code(country) of the user.
 */
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;


/*!
 @property submitButton
 
 @brief This is an Button property.
 
 @discussion After clicking this it validate the data entered in the textField and then after verifying resgister API is called.
 */
@property (weak, nonatomic) IBOutlet UIButton *submitButton;


/*!
 @property countryArray
 
 @brief This is an Array property.
 
 @discussion This is used show collection of country code used along with mobile number.
 */
@property (nonatomic, strong) NSArray * countryArray;

/*!
 @property codeArray
 
 @brief This is an Array property.
 
 @discussion This is used show collection of country code used along with mobile number.
 */
@property (nonatomic, strong) NSArray * codeArray;

/*!
 @property headerTitleView
 
 @brief This is an View property.
 
 @discussion This is used to show na view at the header of the view.
 */
@property (weak, nonatomic) IBOutlet UIView *headerTitleView;

// Picker view action
- (IBAction)countryCodeClicked:(id)sender;

/*!
 @property countryDic
 
 @brief This is an Dictionary property.
 
 @discussion This is used to store some values of country names along with country codes.
 */
@property (nonatomic, strong) NSDictionary * countryDic;



@end

