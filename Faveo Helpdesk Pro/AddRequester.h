

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"


@interface AddRequester : UITableViewController<SlideNavigationControllerDelegate,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,UITextViewDelegate>


// Email TextField
@property (weak, nonatomic) IBOutlet UITextField *emailTextView;

// First name TextField
@property (weak, nonatomic) IBOutlet UITextField *firstNameView;

// Last name TextField
@property (weak, nonatomic) IBOutlet UITextField *lastNameView;


// Mobile number TextField
@property (weak, nonatomic) IBOutlet UITextField *mobileTextField;

// Mobile code  TextField
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;


//Submit button instance
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

//Following array Used to store all country names
@property (nonatomic, strong) NSArray * countryArray;

//Following array used to store all country codes
@property (nonatomic, strong) NSArray * codeArray;


@property (weak, nonatomic) IBOutlet UIView *headerTitleView;

// Picker view action
- (IBAction)countryCodeClicked:(id)sender;

@property (nonatomic, strong) NSDictionary * countryDic;



@end

