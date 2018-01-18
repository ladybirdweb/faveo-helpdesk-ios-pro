
#import "AddRequester.h"
#import "InboxViewController.h"
#import "CreateTicketViewController.h"
#import "LeftMenuViewController.h"
#import "ActionSheetStringPicker.h"
#import "HexColors.h"
#import "Utils.h"
#import "Reachability.h"
#import "AppConstanst.h"
#import "MyWebservices.h"
#import "AppDelegate.h"
#import "RKDropdownAlert.h"
#import "IQKeyboardManager.h"
#import "Dat.h"
#import "RMessage.h"
#import "RMessageView.h"
#import "AddRequester.h"
#import "GlobalVariables.h"
#import "BDCustomAlertView.h"


@interface AddRequester ()<RMessageProtocol,UITextViewDelegate>{
    
    Utils *utils;
    NSUserDefaults *userDefaults;
    NSMutableArray *array1;
    NSDictionary *priDicc1;
    GlobalVariables *globalVariables;
}

- (void)countryCodeWasSelected:(NSNumber *)selectedIndex element:(id)element;

@end

@implementation AddRequester

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self split];
    UIToolbar *toolBar= [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    UIBarButtonItem *removeBtn=[[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStylePlain  target:self action:@selector(removeKeyBoard)];
    
    UIBarButtonItem *space=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [toolBar setItems:[NSArray arrayWithObjects:space,removeBtn, nil]];
    
    [self.mobileTextField setInputAccessoryView:toolBar];
    [self.firstNameView setInputAccessoryView:toolBar];
    [self.lastNameView setInputAccessoryView:toolBar];
    [self.emailTextView setInputAccessoryView:toolBar];
    
   
    globalVariables=[GlobalVariables sharedInstance];
    userDefaults=[NSUserDefaults standardUserDefaults];
    
    
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:false];
    
    utils=[[Utils alloc]init];
    
    userDefaults=[NSUserDefaults standardUserDefaults];
    
    UIButton *clearButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    [clearButton setImage:[UIImage imageNamed:@"clearAll"] forState:UIControlStateNormal];
    [clearButton addTarget:self action:@selector(flipView) forControlEvents:UIControlEventTouchUpInside];
    [clearButton setFrame:CGRectMake(44, 0, 32, 32)];
    
    UIView *rightBarButtonItems = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 76, 32)];
    [rightBarButtonItems addSubview: clearButton];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarButtonItems];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"< Back" style: UIBarButtonItemStylePlain target:self action:@selector(Back)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _submitButton.backgroundColor=[UIColor hx_colorWithHexRGBAString:@"#00aeef"];
    _submitButton.hidden=YES;
    
    //  _titleBar.backgroundColor =  [UIColor hx_colorWithHexRGBAString:@"#F9E9E6"];
    
    self.headerTitleView.backgroundColor=[UIColor hx_colorWithHexRGBAString:@"#F9E9E6"];
    
    self.tableView.tableFooterView=[[UIView alloc] initWithFrame:CGRectZero];
    // Do any additional setup after loading the view.
}



-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    // _submitButton.userInteractionEnabled = false;
     [[IQKeyboardManager sharedManager] setEnableAutoToolbar:true];
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)removeKeyBoard
{
    
    [_mobileTextField resignFirstResponder];
    [_emailTextView resignFirstResponder];
    [_firstNameView resignFirstResponder];
    [_lastNameView resignFirstResponder];
    
}

- (IBAction)countryCodeClicked:(id)sender {
    [_codeTextField resignFirstResponder];
    [self.view endEditing:YES];
    [_codeTextField setTintColor:[UIColor clearColor]];
    
    [ActionSheetStringPicker showPickerWithTitle:NSLocalizedString(@"Select CountryCode",nil) rows:_countryArray initialSelection:0 target:self successAction:@selector(countryCodeWasSelected:element:) cancelAction:@selector(actionPickerCancelled:) origin:sender];
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    // Here You can do additional code or task instead of writing with keyboard
    if(textField==_codeTextField)
    {
        return NO;
    }
    
    return YES;
}

// check below solution later its work or not // date 18 Jan 2018
//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
//{
//    if(textfield == yourtextField)
//    {
//        [textfield resignFirstResponder];
//        // Show you custom picker here....
//        return NO;
//    }
//}


- (void)countryCodeWasSelected:(NSNumber *)selectedIndex element:(id)element{
    // self.selectedIndex = [selectedIndex intValue];
    
    //may have originated from textField or barButtonItem, use an IBOutlet instead of element
    self.codeTextField.text = (_codeArray)[(NSUInteger) [selectedIndex intValue]];
}

- (void)actionPickerCancelled:(id)sender {
    NSLog(@"Delegate has been informed that ActionSheetPicker was cancelled");
}


- (IBAction)submitClicked:(id)sender {
    
    
    if(self.emailTextView.text.length==0 && self.firstNameView.text.length==0 && _lastNameView.text.length==0)
    {
        if (self.navigationController.navigationBarHidden) {
            [self.navigationController setNavigationBarHidden:NO];
        }
        
        [RMessage showNotificationInViewController:self.navigationController
                                             title:NSLocalizedString(@"Warning !", nil)
                                          subtitle:NSLocalizedString(@"Please fill all mandatory fields.", nil)
                                         iconImage:nil
                                              type:RMessageTypeWarning
                                    customTypeName:nil
                                          duration:RMessageDurationAutomatic
                                          callback:nil
                                       buttonTitle:nil
                                    buttonCallback:nil
                                        atPosition:RMessagePositionNavBarOverlay
                              canBeDismissedByUser:YES];
        
        
    }else if (self.emailTextView.text.length==0){
        //[RKDropdownAlert title:APP_NAME message:NSLocalizedString(@"Please enter EMAIL-ID",nil) backgroundColor:[UIColor hx_colorWithHexRGBAString:ALERT_COLOR] textColor:[UIColor whiteColor]];
        if (self.navigationController.navigationBarHidden) {
            [self.navigationController setNavigationBarHidden:NO];
        }
        
        [RMessage showNotificationInViewController:self.navigationController
                                             title:NSLocalizedString(@"Warning !", nil)
                                          subtitle:NSLocalizedString(@"Please enter Email.", nil)
                                         iconImage:nil
                                              type:RMessageTypeWarning
                                    customTypeName:nil
                                          duration:RMessageDurationAutomatic
                                          callback:nil
                                       buttonTitle:nil
                                    buttonCallback:nil
                                        atPosition:RMessagePositionNavBarOverlay
                              canBeDismissedByUser:YES];
        
        
    }else if(![Utils emailValidation:self.emailTextView.text]){
        // [RKDropdownAlert title:APP_NAME message:NSLocalizedString(@"Invalid EMAIL_ID",nil) backgroundColor:[UIColor hx_colorWithHexRGBAString:ALERT_COLOR] textColor:[UIColor whiteColor]];
        
        if (self.navigationController.navigationBarHidden) {
            [self.navigationController setNavigationBarHidden:NO];
        }
        
        [RMessage showNotificationInViewController:self.navigationController
                                             title:NSLocalizedString(@"Error !", nil)
                                          subtitle:NSLocalizedString(@"Please enter valid email id.", nil)
                                         iconImage:nil
                                              type:RMessageTypeWarning
                                    customTypeName:nil
                                          duration:RMessageDurationAutomatic
                                          callback:nil
                                       buttonTitle:nil
                                    buttonCallback:nil
                                        atPosition:RMessagePositionNavBarOverlay
                              canBeDismissedByUser:YES];
        
    } else if (self.emailTextView.text.length<2) {
        
        //[RKDropdownAlert title:APP_NAME message:NSLocalizedString(@"FirstName should have more than 2 characters",nil) backgroundColor:[UIColor hx_colorWithHexRGBAString:ALERT_COLOR] textColor:[UIColor whiteColor]];
        
        if (self.navigationController.navigationBarHidden) {
            [self.navigationController setNavigationBarHidden:NO];
        }
        
        [RMessage showNotificationInViewController:self.navigationController
                                             title:NSLocalizedString(@"Warning !", nil)
                                          subtitle:NSLocalizedString(@"Enter Full Email", nil)
                                         iconImage:nil
                                              type:RMessageTypeWarning
                                    customTypeName:nil
                                          duration:RMessageDurationAutomatic
                                          callback:nil
                                       buttonTitle:nil
                                    buttonCallback:nil
                                        atPosition:RMessagePositionNavBarOverlay
                              canBeDismissedByUser:YES];
        
        
    }else if (self.firstNameView.text.length==0 && self.lastNameView.text.length==0 ){
        //[RKDropdownAlert title:APP_NAME message:NSLocalizedString(@"Please enter EMAIL-ID",nil) backgroundColor:[UIColor hx_colorWithHexRGBAString:ALERT_COLOR] textColor:[UIColor whiteColor]];
        
        if (self.navigationController.navigationBarHidden) {
            [self.navigationController setNavigationBarHidden:NO];
        }
        
        [RMessage showNotificationInViewController:self.navigationController
                                             title:NSLocalizedString(@"Warning !", nil)
                                          subtitle:NSLocalizedString(@"Enter First Name and Last Name.", nil)
                                         iconImage:nil
                                              type:RMessageTypeWarning
                                    customTypeName:nil
                                          duration:RMessageDurationAutomatic
                                          callback:nil
                                       buttonTitle:nil
                                    buttonCallback:nil
                                        atPosition:RMessagePositionNavBarOverlay
                              canBeDismissedByUser:YES];
        
        
    } else if (self.firstNameView.text.length==0 || self.lastNameView.text.length==0 ){
        //[RKDropdownAlert title:APP_NAME message:NSLocalizedString(@"Please enter EMAIL-ID",nil) backgroundColor:[UIColor hx_colorWithHexRGBAString:ALERT_COLOR] textColor:[UIColor whiteColor]];
        if (self.firstNameView.text.length==0){
            if (self.navigationController.navigationBarHidden) {
                [self.navigationController setNavigationBarHidden:NO];
            }
            
            [RMessage showNotificationInViewController:self.navigationController
                                                 title:NSLocalizedString(@"Warning !", nil)
                                              subtitle:NSLocalizedString(@"Enter First Name.", nil)
                                             iconImage:nil
                                                  type:RMessageTypeWarning
                                        customTypeName:nil
                                              duration:RMessageDurationAutomatic
                                              callback:nil
                                           buttonTitle:nil
                                        buttonCallback:nil
                                            atPosition:RMessagePositionNavBarOverlay
                                  canBeDismissedByUser:YES];
            
        }
        if (self.lastNameView.text.length==0){
            if (self.navigationController.navigationBarHidden) {
                [self.navigationController setNavigationBarHidden:NO];
            }
            
            [RMessage showNotificationInViewController:self.navigationController
                                                 title:NSLocalizedString(@"Warning !", nil)
                                              subtitle:NSLocalizedString(@"Enter Last Name.", nil)
                                             iconImage:nil
                                                  type:RMessageTypeWarning
                                        customTypeName:nil
                                              duration:RMessageDurationAutomatic
                                              callback:nil
                                           buttonTitle:nil
                                        buttonCallback:nil
                                            atPosition:RMessagePositionNavBarOverlay
                                  canBeDismissedByUser:YES];
            
        }
        
        
    }
    else
    {
        [self createTicket];
        
    }
    
}
-(void)createTicket{
    if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable)
    {
        [RKDropdownAlert title:APP_NAME message:NO_INTERNET backgroundColor:[UIColor hx_colorWithHexRGBAString:FAILURE_COLOR] textColor:[UIColor whiteColor]];
        
    }else{
        
        [[AppDelegate sharedAppdelegate] showProgressView];
        
        
        NSString *url =[NSString stringWithFormat:@"%@helpdesk/register?token=%@&first_name=%@&last_name=%@&email=%@&mobile=%@&code=%@",[userDefaults objectForKey:@"companyURL"],[userDefaults objectForKey:@"token"],_firstNameView.text,_lastNameView.text,_emailTextView.text,_mobileTextField.text,_codeTextField.text];
        
        
        
        MyWebservices *webservices=[MyWebservices sharedInstance];
        
        [webservices httpResponsePOST:url parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
            [[AppDelegate sharedAppdelegate] hideProgressView];
            
            if (error || [msg containsString:@"Error"]) {
                
                if (msg) {
                    if([msg isEqualToString:@"Error-403"])
                    {
                        [utils showAlertWithMessage:NSLocalizedString(@"Access Denied - You don't have permission.", nil) sendViewController:self];
                    }else{
                        [utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",msg] sendViewController:self];
                        NSLog(@"Error is : %@",msg);
                    }
                    
                }else if(error)  {
                    [utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",error.localizedDescription] sendViewController:self];
                    NSLog(@"Thread-NO4-addRequester-Refresh-error == %@",error.localizedDescription);
                }
                
                return ;
            }
            
            if ([msg isEqualToString:@"tokenRefreshed"]) {
                
                [self createTicket];
                NSLog(@"Thread--NO4-call-postAddRequester");
                return;
            }
            
  
            NSArray * arr1=json;
            NSLog(@"Arrtay is 12345 : %@",arr1);
            NSDictionary * dictionary = (NSDictionary *)[arr1 objectAtIndex: 0];
            
            NSString * stringMessage111 = (NSString *)[dictionary valueForKey: @"message"];
            
            NSString * stringMessage222 = (NSString *)[dictionary valueForKey: @"error"];
            
            NSLog(@"stringMessage111 - %@",stringMessage111);
            NSLog(@"stringMessage222 - %@",stringMessage222);
            
     
            
            if (json) {
                NSLog(@"JSON-addRequester-%@",json);
                
                
                if([stringMessage111 hasPrefix:@"message"] || [stringMessage111 isEqualToString:@"Activate your account! Click on the link that we've sent to your mail"])
                    
                {
                    
                    
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                   
                        if (self.navigationController.navigationBarHidden) {
                            [self.navigationController setNavigationBarHidden:NO];
                        }
                        
                        [RMessage showNotificationInViewController:self.navigationController
                                                             title:NSLocalizedString(@"success", nil)
                                                          subtitle:NSLocalizedString(@"Requester Created successfully.", nil)
                                                         iconImage:nil
                                                              type:RMessageTypeSuccess
                                                    customTypeName:nil
                                                          duration:RMessageDurationAutomatic
                                                          callback:nil
                                                       buttonTitle:nil
                                                    buttonCallback:nil
                                                        atPosition:RMessagePositionNavBarOverlay
                                              canBeDismissedByUser:YES];
                        
                        
                        globalVariables.emailAddRequester=_emailTextView.text;
                        globalVariables.firstNameAddRequester=_firstNameView.text;
                        globalVariables.lastAddRequester=_lastNameView.text;
                        globalVariables.mobileAddRequester=_mobileTextField.text;
                        globalVariables.mobileCode=_codeTextField.text;
                        
                        
                        CreateTicketViewController *create=[self.storyboard instantiateViewControllerWithIdentifier:@"CreateTicket"];
                        [self.navigationController pushViewController:create animated:YES];
                        
                        
                        
                        
                    });
                    
                    
                }
                
                else if([stringMessage222 hasPrefix:@"error"])
                    
                {
                    
                    [utils showAlertWithMessage:NSLocalizedString(@"Email already exist.", nil) sendViewController:self];
                 //   [utils showAlertWithMessage:NSLocalizedString(@"Integrity constraint violation: 1062 Duplicate entry", nil) sendViewController:self];
                }
                
                else
                {
                    
                    [utils showAlertWithMessage:NSLocalizedString(@"Email already exist.", nil) sendViewController:self];
                  //  [utils showAlertWithMessage:NSLocalizedString(@"Integrity constraint violation: 1062 Duplicate entry", nil) sendViewController:self];
                }
                
                
           
            }
            NSLog(@"Thread-NO5-postCreateTicket-closed");
            
        }];
        
    }
}

-(IBAction)flipView
{
    NSLog(@"Clciked");
    _emailTextView.text=@"";
    _firstNameView.text=@"";
    _lastNameView.text=@"";
   
    _mobileTextField.text=@"";
    _codeTextField.text=@"";
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    _submitButton.hidden = NO;
}

- (IBAction)Back
{
    BDCustomAlertView *customAlert = [[BDCustomAlertView alloc] init];
    
    [customAlert showAlertWithTitle:@"Alert" message:NSLocalizedString(@"Discard Changes ?",nil) cancelButtonTitle:NSLocalizedString(@"No",nil) successButtonTitle:NSLocalizedString(@"Yes",nil) withSuccessBlock:^{
        
        [self.navigationController popViewControllerAnimated:YES];
    } cancelBlock:^{
        
    }];
    
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if(textField == _emailTextView)
    {
        //do not allow the first character to be space | do not allow more than one space
        if ([string isEqualToString:@" "]) {
            if (!textField.text.length)
                return NO;
            //                        if ([[textField.text stringByReplacingCharactersInRange:range withString:string] rangeOfString:@"  "].length)
            //                            return NO;
        }
        
        // allow backspace
        if ([textField.text stringByReplacingCharactersInRange:range withString:string].length < textField.text.length) {
            return YES;
        }
        
        // in case you need to limit the max number of characters
        if ([textField.text stringByReplacingCharactersInRange:range withString:string].length > 40) {
            return NO;
        }
        
        // limit the input to only the stuff in this character set, so no emoji or cirylic or any other insane characters
        NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyz1234567890@. "];
        
        if ([string rangeOfCharacterFromSet:set].location == NSNotFound) {
            return NO;
        }
    }
    else if(textField==_firstNameView || textField==_lastNameView){
        
        //do not allow the first character to be space | do not allow more than one space
        if ([string isEqualToString:@" "]) {
            if (!textField.text.length)
                return NO;
        }
        // allow backspace
        if ([textField.text stringByReplacingCharactersInRange:range withString:string].length < textField.text.length) {
            return YES;
        }
        
        if (textField==_firstNameView || textField==_lastNameView) {
            // limit the input to only the stuff in this character set, so no emoji or cirylic or any other insane characters
            
            //        // in case you need to limit the max number of characters
            if ([textField.text stringByReplacingCharactersInRange:range withString:string].length > 15) {
                return NO;
            }
            
            NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"];
            
            if ([string rangeOfCharacterFromSet:set].location == NSNotFound) {
                return NO;
            }
        }
        
    } else  if (textField == _mobileTextField) {
        
        //do not allow the first character to be space | do not allow more than one space
        if ([string isEqualToString:@" "]) {
            if (!textField.text.length)
                return NO;
            //                        if ([[textField.text stringByReplacingCharactersInRange:range withString:string] rangeOfString:@"  "].length)
            //                            return NO;
        }
        
        // allow backspace
        if ([textField.text stringByReplacingCharactersInRange:range withString:string].length < textField.text.length) {
            return YES;
        }
        
        // in case you need to limit the max number of characters
        if ([textField.text stringByReplacingCharactersInRange:range withString:string].length > 15) {
            return NO;
        }
        
        // limit the input to only the stuff in this character set, so no emoji or cirylic or any other insane characters
        NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"1234567890"];
        
        if ([string rangeOfCharacterFromSet:set].location == NSNotFound) {
            return NO;
        }
        
    }
    
    
    return YES;
}




//#pragma mark - UITextFieldDelegate
//
//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
//    return NO;
//}



-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
  // [textField resignFirstResponder];
    if (textField == _emailTextView) {
        
        [_firstNameView becomeFirstResponder];
        
    } else if (textField == _firstNameView) {
        
        [_lastNameView becomeFirstResponder];
        //[textField resignFirstResponder]
    }else if(textField == _lastNameView)
    {
        [textField resignFirstResponder];
    }
    
    
    return YES;
}

-(void)split{
    
    _countryDic = @{
                    @"Canada"                                       : @"+1",
                    @"China"                                        : @"+86",
                    @"France"                                       : @"+33",
                    @"Germany"                                      : @"+49",
                    @"India"                                        : @"+91",
                    @"Japan"                                        : @"+81",
                    @"Pakistan"                                     : @"+92",
                    @"United Kingdom"                               : @"+44",
                    @"United States"                                : @"+1",
                    @"Abkhazia"                                     : @"+7 840",
                    @"Abkhazia"                                     : @"+7 940",
                    @"Afghanistan"                                  : @"+93",
                    @"Albania"                                      : @"+355",
                    @"Algeria"                                      : @"+213",
                    @"American Samoa"                               : @"+1 684",
                    @"Andorra"                                      : @"+376",
                    @"Angola"                                       : @"+244",
                    @"Anguilla"                                     : @"+1 264",
                    @"Antigua and Barbuda"                          : @"+1 268",
                    @"Argentina"                                    : @"+54",
                    @"Armenia"                                      : @"+374",
                    @"Aruba"                                        : @"+297",
                    @"Ascension"                                    : @"+247",
                    @"Australia"                                    : @"+61",
                    @"Australian External Territories"              : @"+672",
                    @"Austria"                                      : @"+43",
                    @"Azerbaijan"                                   : @"+994",
                    @"Bahamas"                                      : @"+1 242",
                    @"Bahrain"                                      : @"+973",
                    @"Bangladesh"                                   : @"+880",
                    @"Barbados"                                     : @"+1 246",
                    @"Barbuda"                                      : @"+1 268",
                    @"Belarus"                                      : @"+375",
                    @"Belgium"                                      : @"+32",
                    @"Belize"                                       : @"+501",
                    @"Benin"                                        : @"+229",
                    @"Bermuda"                                      : @"+1 441",
                    @"Bhutan"                                       : @"+975",
                    @"Bolivia"                                      : @"+591",
                    @"Bosnia and Herzegovina"                       : @"+387",
                    @"Botswana"                                     : @"+267",
                    @"Brazil"                                       : @"+55",
                    @"British Indian Ocean Territory"               : @"+246",
                    @"British Virgin Islands"                       : @"+1 284",
                    @"Brunei"                                       : @"+673",
                    @"Bulgaria"                                     : @"+359",
                    @"Burkina Faso"                                 : @"+226",
                    @"Burundi"                                      : @"+257",
                    @"Cambodia"                                     : @"+855",
                    @"Cameroon"                                     : @"+237",
                    @"Canada"                                       : @"+1",
                    @"Cape Verde"                                   : @"+238",
                    @"Cayman Islands"                               : @"+ 345",
                    @"Central African Republic"                     : @"+236",
                    @"Chad"                                         : @"+235",
                    @"Chile"                                        : @"+56",
                    @"China"                                        : @"+86",
                    @"Christmas Island"                             : @"+61",
                    @"Cocos-Keeling Islands"                        : @"+61",
                    @"Colombia"                                     : @"+57",
                    @"Comoros"                                      : @"+269",
                    @"Congo"                                        : @"+242",
                    @"Congo, Dem. Rep. of (Zaire)"                  : @"+243",
                    @"Cook Islands"                                 : @"+682",
                    @"Costa Rica"                                   : @"+506",
                    @"Ivory Coast"                                  : @"+225",
                    @"Croatia"                                      : @"+385",
                    @"Cuba"                                         : @"+53",
                    @"Curacao"                                      : @"+599",
                    @"Cyprus"                                       : @"+537",
                    @"Czech Republic"                               : @"+420",
                    @"Denmark"                                      : @"+45",
                    @"Diego Garcia"                                 : @"+246",
                    @"Djibouti"                                     : @"+253",
                    @"Dominica"                                     : @"+1 767",
                    @"Dominican Republic"                           : @"+1 809",
                    @"Dominican Republic"                           : @"+1 829",
                    @"Dominican Republic"                           : @"+1 849",
                    @"East Timor"                                   : @"+670",
                    @"Easter Island"                                : @"+56",
                    @"Ecuador"                                      : @"+593",
                    @"Egypt"                                        : @"+20",
                    @"El Salvador"                                  : @"+503",
                    @"Equatorial Guinea"                            : @"+240",
                    @"Eritrea"                                      : @"+291",
                    @"Estonia"                                      : @"+372",
                    @"Ethiopia"                                     : @"+251",
                    @"Falkland Islands"                             : @"+500",
                    @"Faroe Islands"                                : @"+298",
                    @"Fiji"                                         : @"+679",
                    @"Finland"                                      : @"+358",
                    @"France"                                       : @"+33",
                    @"French Antilles"                              : @"+596",
                    @"French Guiana"                                : @"+594",
                    @"French Polynesia"                             : @"+689",
                    @"Gabon"                                        : @"+241",
                    @"Gambia"                                       : @"+220",
                    @"Georgia"                                      : @"+995",
                    @"Germany"                                      : @"+49",
                    @"Ghana"                                        : @"+233",
                    @"Gibraltar"                                    : @"+350",
                    @"Greece"                                       : @"+30",
                    @"Greenland"                                    : @"+299",
                    @"Grenada"                                      : @"+1 473",
                    @"Guadeloupe"                                   : @"+590",
                    @"Guam"                                         : @"+1 671",
                    @"Guatemala"                                    : @"+502",
                    @"Guinea"                                       : @"+224",
                    @"Guinea-Bissau"                                : @"+245",
                    @"Guyana"                                       : @"+595",
                    @"Haiti"                                        : @"+509",
                    @"Honduras"                                     : @"+504",
                    @"Hong Kong SAR China"                          : @"+852",
                    @"Hungary"                                      : @"+36",
                    @"Iceland"                                      : @"+354",
                    @"India"                                        : @"+91",
                    @"Indonesia"                                    : @"+62",
                    @"Iran"                                         : @"+98",
                    @"Iraq"                                         : @"+964",
                    @"Ireland"                                      : @"+353",
                    @"Israel"                                       : @"+972",
                    @"Italy"                                        : @"+39",
                    @"Jamaica"                                      : @"+1 876",
                    @"Japan"                                        : @"+81",
                    @"Jordan"                                       : @"+962",
                    @"Kazakhstan"                                   : @"+7 7",
                    @"Kenya"                                        : @"+254",
                    @"Kiribati"                                     : @"+686",
                    @"North Korea"                                  : @"+850",
                    @"South Korea"                                  : @"+82",
                    @"Kuwait"                                       : @"+965",
                    @"Kyrgyzstan"                                   : @"+996",
                    @"Laos"                                         : @"+856",
                    @"Latvia"                                       : @"+371",
                    @"Lebanon"                                      : @"+961",
                    @"Lesotho"                                      : @"+266",
                    @"Liberia"                                      : @"+231",
                    @"Libya"                                        : @"+218",
                    @"Liechtenstein"                                : @"+423",
                    @"Lithuania"                                    : @"+370",
                    @"Luxembourg"                                   : @"+352",
                    @"Macau SAR China"                              : @"+853",
                    @"Macedonia"                                    : @"+389",
                    @"Madagascar"                                   : @"+261",
                    @"Malawi"                                       : @"+265",
                    @"Malaysia"                                     : @"+60",
                    @"Maldives"                                     : @"+960",
                    @"Mali"                                         : @"+223",
                    @"Malta"                                        : @"+356",
                    @"Marshall Islands"                             : @"+692",
                    @"Martinique"                                   : @"+596",
                    @"Mauritania"                                   : @"+222",
                    @"Mauritius"                                    : @"+230",
                    @"Mayotte"                                      : @"+262",
                    @"Mexico"                                       : @"+52",
                    @"Micronesia"                                   : @"+691",
                    @"Midway Island"                                : @"+1 808",
                    @"Micronesia"                                   : @"+691",
                    @"Moldova"                                      : @"+373",
                    @"Monaco"                                       : @"+377",
                    @"Mongolia"                                     : @"+976",
                    @"Montenegro"                                   : @"+382",
                    @"Montserrat"                                   : @"+1664",
                    @"Morocco"                                      : @"+212",
                    @"Myanmar"                                      : @"+95",
                    @"Namibia"                                      : @"+264",
                    @"Nauru"                                        : @"+674",
                    @"Nepal"                                        : @"+977",
                    @"Netherlands"                                  : @"+31",
                    @"Netherlands Antilles"                         : @"+599",
                    @"Nevis"                                        : @"+1 869",
                    @"New Caledonia"                                : @"+687",
                    @"New Zealand"                                  : @"+64",
                    @"Nicaragua"                                    : @"+505",
                    @"Niger"                                        : @"+227",
                    @"Nigeria"                                      : @"+234",
                    @"Niue"                                         : @"+683",
                    @"Norfolk Island"                               : @"+672",
                    @"Northern Mariana Islands"                     : @"+1 670",
                    @"Norway"                                       : @"+47",
                    @"Oman"                                         : @"+968",
                    @"Pakistan"                                     : @"+92",
                    @"Palau"                                        : @"+680",
                    @"Palestinian Territory"                        : @"+970",
                    @"Panama"                                       : @"+507",
                    @"Papua New Guinea"                             : @"+675",
                    @"Paraguay"                                     : @"+595",
                    @"Peru"                                         : @"+51",
                    @"Philippines"                                  : @"+63",
                    @"Poland"                                       : @"+48",
                    @"Portugal"                                     : @"+351",
                    @"Puerto Rico"                                  : @"+1 787",
                    @"Puerto Rico"                                  : @"+1 939",
                    @"Qatar"                                        : @"+974",
                    @"Reunion"                                      : @"+262",
                    @"Romania"                                      : @"+40",
                    @"Russia"                                       : @"+7",
                    @"Rwanda"                                       : @"+250",
                    @"Samoa"                                        : @"+685",
                    @"San Marino"                                   : @"+378",
                    @"Saudi Arabia"                                 : @"+966",
                    @"Senegal"                                      : @"+221",
                    @"Serbia"                                       : @"+381",
                    @"Seychelles"                                   : @"+248",
                    @"Sierra Leone"                                 : @"+232",
                    @"Singapore"                                    : @"+65",
                    @"Slovakia"                                     : @"+421",
                    @"Slovenia"                                     : @"+386",
                    @"Solomon Islands"                              : @"+677",
                    @"South Africa"                                 : @"+27",
                    @"South Georgia and the South Sandwich Islands" : @"+500",
                    @"Spain"                                        : @"+34",
                    @"Sri Lanka"                                    : @"+94",
                    @"Sudan"                                        : @"+249",
                    @"Suriname"                                     : @"+597",
                    @"Swaziland"                                    : @"+268",
                    @"Sweden"                                       : @"+46",
                    @"Switzerland"                                  : @"+41",
                    @"Syria"                                        : @"+963",
                    @"Taiwan"                                       : @"+886",
                    @"Tajikistan"                                   : @"+992",
                    @"Tanzania"                                     : @"+255",
                    @"Thailand"                                     : @"+66",
                    @"Timor Leste"                                  : @"+670",
                    @"Togo"                                         : @"+228",
                    @"Tokelau"                                      : @"+690",
                    @"Tonga"                                        : @"+676",
                    @"Trinidad and Tobago"                          : @"+1 868",
                    @"Tunisia"                                      : @"+216",
                    @"Turkey"                                       : @"+90",
                    @"Turkmenistan"                                 : @"+993",
                    @"Turks and Caicos Islands"                     : @"+1 649",
                    @"Tuvalu"                                       : @"+688",
                    @"Uganda"                                       : @"+256",
                    @"Ukraine"                                      : @"+380",
                    @"United Arab Emirates"                         : @"+971",
                    @"United Kingdom"                               : @"+44",
                    @"United States"                                : @"+1",
                    @"Uruguay"                                      : @"+598",
                    @"U.S. Virgin Islands"                          : @"+1 340",
                    @"Uzbekistan"                                   : @"+998",
                    @"Vanuatu"                                      : @"+678",
                    @"Venezuela"                                    : @"+58",
                    @"Vietnam"                                      : @"+84",
                    @"Wake Island"                                  : @"+1 808",
                    @"Wallis and Futuna"                            : @"+681",
                    @"Yemen"                                        : @"+967",
                    @"Zambia"                                       : @"+260",
                    @"Zanzibar"                                     : @"+255",
                    @"Zimbabwe"                                     : @"+263"
                    };
    _countryArray=[_countryDic allKeys];
    _codeArray=[_countryDic allValues];
    NSLog(@"keys %@",[_countryDic allKeys]);
    NSLog(@"values %@",[_countryDic allValues]);
}

- (NSDictionary *)getCountryCodeDictionary {
    // Country code
    
    return [NSDictionary dictionaryWithObjectsAndKeys:@"972", @"IL",
            @"93", @"AF", @"355", @"AL", @"213", @"DZ", @"1", @"AS",
            @"376", @"AD", @"244", @"AO", @"1", @"AI", @"1", @"AG",
            @"54", @"AR", @"374", @"AM", @"297", @"AW", @"61", @"AU",
            @"43", @"AT", @"994", @"AZ", @"1", @"BS", @"973", @"BH",
            @"880", @"BD", @"1", @"BB", @"375", @"BY", @"32", @"BE",
            @"501", @"BZ", @"229", @"BJ", @"1", @"BM", @"975", @"BT",
            @"387", @"BA", @"267", @"BW", @"55", @"BR", @"246", @"IO",
            @"359", @"BG", @"226", @"BF", @"257", @"BI", @"855", @"KH",
            @"237", @"CM", @"1", @"CA", @"238", @"CV", @"345", @"KY",
            @"236", @"CF", @"235", @"TD", @"56", @"CL", @"86", @"CN",
            @"61", @"CX", @"57", @"CO", @"269", @"KM", @"242", @"CG",
            @"682", @"CK", @"506", @"CR", @"385", @"HR", @"53", @"CU",
            @"537", @"CY", @"420", @"CZ", @"45", @"DK", @"253", @"DJ",
            @"1", @"DM", @"1", @"DO", @"593", @"EC", @"20", @"EG",
            @"503", @"SV", @"240", @"GQ", @"291", @"ER", @"372", @"EE",
            @"251", @"ET", @"298", @"FO", @"679", @"FJ", @"358", @"FI",
            @"33", @"FR", @"594", @"GF", @"689", @"PF", @"241", @"GA",
            @"220", @"GM", @"995", @"GE", @"49", @"DE", @"233", @"GH",
            @"350", @"GI", @"30", @"GR", @"299", @"GL", @"1", @"GD",
            @"590", @"GP", @"1", @"GU", @"502", @"GT", @"224", @"GN",
            @"245", @"GW", @"595", @"GY", @"509", @"HT", @"504", @"HN",
            @"36", @"HU", @"354", @"IS", @"91", @"IN", @"62", @"ID",
            @"964", @"IQ", @"353", @"IE", @"972", @"IL", @"39", @"IT",
            @"1", @"JM", @"81", @"JP", @"962", @"JO", @"77", @"KZ",
            @"254", @"KE", @"686", @"KI", @"965", @"KW", @"996", @"KG",
            @"371", @"LV", @"961", @"LB", @"266", @"LS", @"231", @"LR",
            @"423", @"LI", @"370", @"LT", @"352", @"LU", @"261", @"MG",
            @"265", @"MW", @"60", @"MY", @"960", @"MV", @"223", @"ML",
            @"356", @"MT", @"692", @"MH", @"596", @"MQ", @"222", @"MR",
            @"230", @"MU", @"262", @"YT", @"52", @"MX", @"377", @"MC",
            @"976", @"MN", @"382", @"ME", @"1", @"MS", @"212", @"MA",
            @"95", @"MM", @"264", @"NA", @"674", @"NR", @"977", @"NP",
            @"31", @"NL", @"599", @"AN", @"687", @"NC", @"64", @"NZ",
            @"505", @"NI", @"227", @"NE", @"234", @"NG", @"683", @"NU",
            @"672", @"NF", @"1", @"MP", @"47", @"NO", @"968", @"OM",
            @"92", @"PK", @"680", @"PW", @"507", @"PA", @"675", @"PG",
            @"595", @"PY", @"51", @"PE", @"63", @"PH", @"48", @"PL",
            @"351", @"PT", @"1", @"PR", @"974", @"QA", @"40", @"RO",
            @"250", @"RW", @"685", @"WS", @"378", @"SM", @"966", @"SA",
            @"221", @"SN", @"381", @"RS", @"248", @"SC", @"232", @"SL",
            @"65", @"SG", @"421", @"SK", @"386", @"SI", @"677", @"SB",
            @"27", @"ZA", @"500", @"GS", @"34", @"ES", @"94", @"LK",
            @"249", @"SD", @"597", @"SR", @"268", @"SZ", @"46", @"SE",
            @"41", @"CH", @"992", @"TJ", @"66", @"TH", @"228", @"TG",
            @"690", @"TK", @"676", @"TO", @"1", @"TT", @"216", @"TN",
            @"90", @"TR", @"993", @"TM", @"1", @"TC", @"688", @"TV",
            @"256", @"UG", @"380", @"UA", @"971", @"AE", @"44", @"GB",
            @"1", @"US", @"598", @"UY", @"998", @"UZ", @"678", @"VU",
            @"681", @"WF", @"967", @"YE", @"260", @"ZM", @"263", @"ZW",
            @"591", @"BO", @"673", @"BN", @"61", @"CC", @"243", @"CD",
            @"225", @"CI", @"500", @"FK", @"44", @"GG", @"379", @"VA",
            @"852", @"HK", @"98", @"IR", @"44", @"IM", @"44", @"JE",
            @"850", @"KP", @"82", @"KR", @"856", @"LA", @"218", @"LY",
            @"853", @"MO", @"389", @"MK", @"691", @"FM", @"373", @"MD",
            @"258", @"MZ", @"970", @"PS", @"872", @"PN", @"262", @"RE",
            @"7", @"RU", @"590", @"BL", @"290", @"SH", @"1", @"KN",
            @"1", @"LC", @"590", @"MF", @"508", @"PM", @"1", @"VC",
            @"239", @"ST", @"252", @"SO", @"47", @"SJ", @"963", @"SY",
            @"886", @"TW", @"255", @"TZ", @"670", @"TL", @"58", @"VE",
            @"84", @"VN", @"1", @"VG", @"1", @"VI", nil];
}




@end


