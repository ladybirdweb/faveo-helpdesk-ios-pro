

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"


@interface AddRequester : UITableViewController<SlideNavigationControllerDelegate,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,UITextViewDelegate>


@property (weak, nonatomic) IBOutlet UITextField *emailTextView;


@property (weak, nonatomic) IBOutlet UITextField *firstNameView;


@property (weak, nonatomic) IBOutlet UITextField *lastNameView;



@property (weak, nonatomic) IBOutlet UITextField *mobileTextField;




@property (weak, nonatomic) IBOutlet UIButton *submitButton;



@property (nonatomic, strong) NSArray * countryArray;


@property (nonatomic, strong) NSArray * codeArray;


@property (weak, nonatomic) IBOutlet UIView *headerTitleView;


@property (weak, nonatomic) IBOutlet UITextField *codeTextField;

- (IBAction)countryCodeClicked:(id)sender;

@property (nonatomic, strong) NSDictionary * countryDic;



@end

