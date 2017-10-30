

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"


@interface AddRequester : UITableViewController<SlideNavigationControllerDelegate,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *emailTextView;

@property (weak, nonatomic) IBOutlet UITextView *firstNameView;

@property (weak, nonatomic) IBOutlet UITextView *lastNameView;

@property (weak, nonatomic) IBOutlet UITextField *codeTextField;

@property (weak, nonatomic) IBOutlet UITextField *mobileTextField;
@property (weak, nonatomic) IBOutlet UITextView *mobileView;


@property (weak, nonatomic) IBOutlet UITextField *priorityTextField;

@property (weak, nonatomic) IBOutlet UITextField *assignTextField;


@property (weak, nonatomic) IBOutlet UIButton *submitButton;



@property (nonatomic, strong) NSArray * countryArray;


@property (nonatomic, strong) NSArray * codeArray;











@property (weak, nonatomic) IBOutlet UITextView *companyName;


@end
