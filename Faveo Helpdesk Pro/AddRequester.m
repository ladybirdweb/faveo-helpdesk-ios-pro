
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



@end

@implementation AddRequester

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    UIToolbar *toolBar= [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    UIBarButtonItem *removeBtn=[[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStylePlain  target:self action:@selector(removeKeyBoard)];
    
    UIBarButtonItem *space=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [toolBar setItems:[NSArray arrayWithObjects:space,removeBtn, nil]];
    
    [self.mobileView setInputAccessoryView:toolBar];
    [self.firstNameView setInputAccessoryView:toolBar];
    [self.lastNameView setInputAccessoryView:toolBar];
    [self.emailTextView setInputAccessoryView:toolBar];
    [self.companyName setInputAccessoryView:toolBar];
    
    _emailTextView.delegate=self;
    _firstNameView.delegate=self;
    _lastNameView.delegate=self;
    _mobileView.delegate=self;
    _companyName.delegate=self;
    
    
    globalVariables=[GlobalVariables sharedInstance];
    userDefaults=[NSUserDefaults standardUserDefaults];
    
    
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:false];
    
    utils=[[Utils alloc]init];
    
    userDefaults=[NSUserDefaults standardUserDefaults];
    //_codeTextField.text=[self setDefaultCountryCode];
    
    
    UIBarButtonItem *clearButton = [[UIBarButtonItem alloc]
                                    initWithTitle:@"Clear"
                                    style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(flipView)];
    self.navigationItem.rightBarButtonItem = clearButton;
    
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


-(void)removeKeyboard{
    [_emailTextView resignFirstResponder];
    // [_mobileTextField resignFirstResponder];
    //  [_msgTextField resignFirstResponder];
    
    [_firstNameView resignFirstResponder];
}
-(void)removeKeyBoard
{
    
    [_mobileView resignFirstResponder];
    [_emailTextView resignFirstResponder];
    [_firstNameView resignFirstResponder];
    [_lastNameView resignFirstResponder];
    [_companyName resignFirstResponder];
    
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
                                          subtitle:NSLocalizedString(@"FirstName should have more than 2 characters.", nil)
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
        //connection unavailable
        //[utils showAlertWithMessage:NO_INTERNET sendViewController:self];
        [RKDropdownAlert title:APP_NAME message:NO_INTERNET backgroundColor:[UIColor hx_colorWithHexRGBAString:FAILURE_COLOR] textColor:[UIColor whiteColor]];
        
    }else{
        
        [[AppDelegate sharedAppdelegate] showProgressView];
        
        
        
        //   NSString *url=[NSString stringWithFormat:@"%@helpdesk/ticket?api_key=%@&ip=%@&token=%@&id=%@",[userDefaults objectForKey:@"companyURL"],API_KEY,IP,[userDefaults objectForKey:@"token"],globalVariables.iD];
        // http://jamboreebliss.com/sayar/public/api/v1/helpdesk/register?token=&first_name=&last_name=&email=&mobile=&company
        
        NSString *url =[NSString stringWithFormat:@"%@helpdesk/register?token=%@&first_name=%@&last_name=%@&email=%@&mobile=%@&company=%@",[userDefaults objectForKey:@"companyURL"],[userDefaults objectForKey:@"token"],_firstNameView.text,_lastNameView.text,_emailTextView.text,_mobileView.text,_companyName.text];
        
        
        
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
            
            // let dictData = yourArrayOfDict[index] as Dictionary. let valueObject = dictData["message"]
            
            //  "message": "Activate your account! Click on the link that we've sent to your mail",
            // error
            
            NSArray * arr1=json;
            NSLog(@"Arrtay is 12345 : %@",arr1);
            NSDictionary * dictionary = (NSDictionary *)[arr1 objectAtIndex: 0];
            
            NSString * stringMessage111 = (NSString *)[dictionary valueForKey: @"message"];
            
            NSString * stringMessage222 = (NSString *)[dictionary valueForKey: @"error"];
            
            NSLog(@"stringMessage111 - %@",stringMessage111);
            NSLog(@"stringMessage222 - %@",stringMessage222);
            
            //                if([stringMessage111 hasPrefix:@"message"])
            //
            //                {
            //                    [RMessage showNotificationInViewController:self.navigationController
            //                                                         title:NSLocalizedString(@"Sucess", nil)
            //                                                      subtitle:NSLocalizedString(@"Requester Created successfully.", nil)
            //                                                     iconImage:nil
            //                                                          type:RMessageTypeSuccess
            //                                                customTypeName:nil
            //                                                      duration:RMessageDurationAutomatic
            //                                                      callback:nil
            //                                                   buttonTitle:nil
            //                                                buttonCallback:nil
            //                                                    atPosition:RMessagePositionBottom
            //                                          canBeDismissedByUser:YES];
            //
            //
            //                    InboxViewController *inboxVC=[self.storyboard instantiateViewControllerWithIdentifier:@"InboxID"];
            //                    [self.navigationController pushViewController:inboxVC animated:YES];
            //                }
            //
            //                if([stringMessage222 hasPrefix:@"error"])
            //
            //                {
            //                    [RMessage showNotificationInViewController:self.navigationController
            //                                                         title:NSLocalizedString(@"Fali", nil)
            //                                                      subtitle:NSLocalizedString(@"Fail.", nil)
            //                                                     iconImage:nil
            //                                                          type:RMessageTypeSuccess
            //                                                customTypeName:nil
            //                                                      duration:RMessageDurationAutomatic
            //                                                      callback:nil
            //                                                   buttonTitle:nil
            //                                                buttonCallback:nil
            //                                                    atPosition:RMessagePositionBottom
            //                                          canBeDismissedByUser:YES];
            //                }
            
            if (json) {
                NSLog(@"JSON-addRequester-%@",json);
                
                
                if([stringMessage111 hasPrefix:@"message"] || [stringMessage111 isEqualToString:@"Activate your account! Click on the link that we've sent to your mail"])
                    
                {
                    
                    
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // [RKDropdownAlert title:APP_NAME message:NSLocalizedString(@"Ticket created successfully!",nil) backgroundColor:[UIColor hx_colorWithHexRGBAString:SUCCESS_COLOR] textColor:[UIColor whiteColor]];
                        
                        
                        //                            [RMessage showNotificationInViewController:self.navigationController
                        //                                                                 title:NSLocalizedString(@"Sucess", nil)
                        //                                                              subtitle:NSLocalizedString(@"Requester Created successfully.", nil)
                        //                                                             iconImage:nil
                        //                                                                  type:RMessageTypeSuccess
                        //                                                        customTypeName:nil
                        //                                                              duration:RMessageDurationAutomatic
                        //                                                              callback:nil
                        //                                                           buttonTitle:nil
                        //                                                        buttonCallback:nil
                        //                                                            atPosition:RMessagePositionBottom
                        //                                                  canBeDismissedByUser:YES];
                        
                        
                        if (self.navigationController.navigationBarHidden) {
                            [self.navigationController setNavigationBarHidden:NO];
                        }
                        
                        [RMessage showNotificationInViewController:self.navigationController
                                                             title:NSLocalizedString(@"Sucess", nil)
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
                        globalVariables.mobileAddRequester=_mobileView.text;
                        
                        CreateTicketViewController *create=[self.storyboard instantiateViewControllerWithIdentifier:@"CreateTicket"];
                        [self.navigationController pushViewController:create animated:YES];
                        
                        
                        
                        
                    });
                    
                    
                }
                
                else if([stringMessage222 hasPrefix:@"error"])
                    
                {
                    
                    
                    [utils showAlertWithMessage:NSLocalizedString(@"Integrity constraint violation: 1062 Duplicate entry", nil) sendViewController:self];
                }
                
                else
                {
                    
                    
                    [utils showAlertWithMessage:NSLocalizedString(@"Integrity constraint violation: 1062 Duplicate entry", nil) sendViewController:self];
                }
                
                
                //                    if([msg isEqualToString:@"Activate your account! Click on the link that we've sent to your mail"])
                //                    {
                //                        dispatch_async(dispatch_get_main_queue(), ^{
                //                            // [RKDropdownAlert title:APP_NAME message:NSLocalizedString(@"Ticket created successfully!",nil) backgroundColor:[UIColor hx_colorWithHexRGBAString:SUCCESS_COLOR] textColor:[UIColor whiteColor]];
                //
                //
                //                            [RMessage showNotificationInViewController:self.navigationController
                //                                                                 title:NSLocalizedString(@"Sucess", nil)
                //                                                              subtitle:NSLocalizedString(@"Requester Created successfully.", nil)
                //                                                             iconImage:nil
                //                                                                  type:RMessageTypeSuccess
                //                                                        customTypeName:nil
                //                                                              duration:RMessageDurationAutomatic
                //                                                              callback:nil
                //                                                           buttonTitle:nil
                //                                                        buttonCallback:nil
                //                                                            atPosition:RMessagePositionBottom
                //                                                  canBeDismissedByUser:YES];
                //
                //
                //                            InboxViewController *inboxVC=[self.storyboard instantiateViewControllerWithIdentifier:@"InboxID"];
                //                            [self.navigationController pushViewController:inboxVC animated:YES];
                //                        });
                //                    } //
                //
                
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
    _companyName.text=@"";
    _mobileView.text=@"";
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    _submitButton.hidden = NO;
}

- (IBAction)Back
{
    BDCustomAlertView *customAlert = [[BDCustomAlertView alloc] init];
    
    [customAlert showAlertWithTitle:@"Alert" message:@" Discard Changes ?" cancelButtonTitle:@"No" successButtonTitle:@"Yes" withSuccessBlock:^{
        
        [self.navigationController popViewControllerAnimated:YES];
    } cancelBlock:^{
        
    }];
    
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    if (textView == _emailTextView)
    {
        
        //do not allow the first character to be space | do not allow more than one space
        if ([text isEqualToString:@" "]) {
            if (!textView.text.length)
                return NO;
            //                        if ([[textField.text stringByReplacingCharactersInRange:range withString:string] rangeOfString:@"  "].length)
            //                            return NO;
        }
        
        // allow backspace
        if ([textView.text stringByReplacingCharactersInRange:range withString:text].length < textView.text.length) {
            return YES;
        }
        
        // in case you need to limit the max number of characters
        if ([textView.text stringByReplacingCharactersInRange:range withString:text].length > 40) {
            return NO;
        }
        
        // limit the input to only the stuff in this character set, so no emoji or cirylic or any other insane characters
        NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyz1234567890@. "];
        
        if ([text rangeOfCharacterFromSet:set].location == NSNotFound) {
            return NO;
        }
        
    }else if(textView==_firstNameView || textView==_lastNameView){
        
        //do not allow the first character to be space | do not allow more than one space
        if ([text isEqualToString:@" "]) {
            if (!textView.text.length)
                return NO;
        }
        // allow backspace
        if ([textView.text stringByReplacingCharactersInRange:range withString:text].length < textView.text.length) {
            return YES;
        }
        
        if (textView==_firstNameView || textView==_lastNameView) {
            // limit the input to only the stuff in this character set, so no emoji or cirylic or any other insane characters
            
            //        // in case you need to limit the max number of characters
            if ([textView.text stringByReplacingCharactersInRange:range withString:text].length > 15) {
                return NO;
            }
            
            NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"];
            
            if ([text rangeOfCharacterFromSet:set].location == NSNotFound) {
                return NO;
            }
        }
        
    } else  if (textView == _mobileView) {
        
        //do not allow the first character to be space | do not allow more than one space
        if ([text isEqualToString:@" "]) {
            if (!textView.text.length)
                return NO;
            //                        if ([[textField.text stringByReplacingCharactersInRange:range withString:string] rangeOfString:@"  "].length)
            //                            return NO;
        }
        
        // allow backspace
        if ([textView.text stringByReplacingCharactersInRange:range withString:text].length < textView.text.length) {
            return YES;
        }
        
        // in case you need to limit the max number of characters
        if ([textView.text stringByReplacingCharactersInRange:range withString:text].length > 15) {
            return NO;
        }
        
        // limit the input to only the stuff in this character set, so no emoji or cirylic or any other insane characters
        NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"1234567890"];
        
        if ([text rangeOfCharacterFromSet:set].location == NSNotFound) {
            return NO;
        }
        
    }
    
    
    
    return YES;
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return NO;
}



-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}



@end


