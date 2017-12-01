//
//  EditClientDetail.m
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 21/11/17.
//  Copyright © 2017 Ladybird websolutions pvt ltd. All rights reserved.
//

#import "EditClientDetail.h"
#import "FilterViewController.h"
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
#import "DropDownListView.h"
#import "FilterLogic.h"
#import "ClientDetailViewController.h"
#import "ClientListViewController.h"
#import "BDCustomAlertView.h"

@import FirebaseInstanceID;
@import FirebaseMessaging;

@interface EditClientDetail (){
    
    Utils *utils;
    UIRefreshControl *refresh;
    NSUserDefaults *userDefaults;
    NSMutableArray *array1;
    NSDictionary *priDicc1;
    GlobalVariables *globalVariables;
    NSString * msg;
    
    
}
@property (weak, nonatomic) IBOutlet UISwitch *switch1;



@end

@implementation EditClientDetail

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title=@"Edit Profile";
    
    utils=[[Utils alloc]init];
    globalVariables=[GlobalVariables sharedInstance];
    userDefaults=[NSUserDefaults standardUserDefaults];
    
   // _userStateChangeView.backgroundColor=[UIColor hx_colorWithHexRGBAString:@"#FBEFF8"];
   [[IQKeyboardManager sharedManager] setEnableAutoToolbar:false];
    
    UIButton *done =  [UIButton buttonWithType:UIButtonTypeCustom];
    [done setImage:[UIImage imageNamed:@"doneButton"] forState:UIControlStateNormal];
    [done addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
    [done setFrame:CGRectMake(44, 0, 32, 32)];
    
    UIView *rightBarButtonItems = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 76, 32)];
    // [rightBarButtonItems addSubview:addBtn];
    [rightBarButtonItems addSubview:done];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarButtonItems];

    
    
    // textfield add button manually
    
    UIToolbar *toolBar= [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    UIBarButtonItem *removeBtn=[[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStylePlain  target:self action:@selector(removeKeyBoard)];
    
    UIBarButtonItem *space=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [toolBar setItems:[NSArray arrayWithObjects:space,removeBtn, nil]];
    
    [self.userNameTextField setInputAccessoryView:toolBar];
    [self.firstNameTextField setInputAccessoryView:toolBar];
    [self.lastNameTextField setInputAccessoryView:toolBar];
    [self.emailTextField setInputAccessoryView:toolBar];
    [self.phoneTextField setInputAccessoryView:toolBar];
    [self.mobileTextField setInputAccessoryView:toolBar];
    
    _userNameTextField.delegate=self;
    _firstNameTextField.delegate=self;
    _lastNameTextField.delegate=self;
    _emailTextField.delegate=self;
    _phoneTextField.delegate=self;
    _mobileTextField.delegate=self;
    
    _userNameTextField.text= [NSString stringWithFormat:@"%@",globalVariables.userNameInUserList];
    _firstNameTextField.text= [NSString stringWithFormat:@"%@",globalVariables.First_name];
    _lastNameTextField.text= [NSString stringWithFormat:@"%@",globalVariables.Last_name];
    _emailTextField.text= [NSString stringWithFormat:@"%@",globalVariables.emailInUserList];
    _phoneTextField.text= [NSString stringWithFormat:@"%@",globalVariables.phoneNumberInUserList];
    _mobileTextField.text= [NSString stringWithFormat:@"%@",globalVariables.mobileNumberInUserList];
    
    NSString *str= [NSString stringWithFormat:@"%@",globalVariables.ActiveDeactiveStateOfUser1];
   
   
    if([str isEqualToString:@"deActive"])
    {
        [_switch1 setOn:YES];
        _switch1.onTintColor= [UIColor redColor];
    }
    else
    {
         [_switch1 setOn:NO];
     //   _switch1.tintColor = [UIColor greenColor];
        _switch1.layer.cornerRadius = 16;
        _switch1.backgroundColor= [UIColor greenColor];
        
    }
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView=[[UIView alloc] initWithFrame:CGRectZero];
    
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:false];
    
 //   [[AppDelegate sharedAppdelegate] showProgressViewWithText:NSLocalizedString(@"Getting Data",nil)];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    // _submitButton.userInteractionEnabled = false;
    
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:true];
}

-(void)removeKeyBoard
{
    
    [_userNameTextField resignFirstResponder];
    [_firstNameTextField resignFirstResponder];
    [_lastNameTextField resignFirstResponder];
    [_emailTextField resignFirstResponder];
    [_phoneTextField resignFirstResponder];
    [_mobileTextField resignFirstResponder];
    
}

-(void)submit
{
    
    if(_userNameTextField.text.length==0 && _firstNameTextField.text.length==0 && _lastNameTextField.text.length==0 && _emailTextField.text.length==0)
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
        
        
    }else if (_firstNameTextField.text.length==0 && _lastNameTextField.text.length==0 &&_emailTextField.text.length==0){
        
        if(_firstNameTextField.text.length==0 && _lastNameTextField.text.length==0)
            
        {
            if (self.navigationController.navigationBarHidden) {
                [self.navigationController setNavigationBarHidden:NO];
            }
            
            [RMessage showNotificationInViewController:self.navigationController
                                                 title:NSLocalizedString(@"Warning !", nil)
                                              subtitle:NSLocalizedString(@"Enter First Name & Last Name.", nil)
                                             iconImage:nil
                                                  type:RMessageTypeWarning
                                        customTypeName:nil
                                              duration:RMessageDurationAutomatic
                                              callback:nil
                                           buttonTitle:nil
                                        buttonCallback:nil
                                            atPosition:RMessagePositionNavBarOverlay
                                  canBeDismissedByUser:YES];
        }else if(_firstNameTextField.text.length==0 && _emailTextField.text.length==0)
        {
            if (self.navigationController.navigationBarHidden) {
                [self.navigationController setNavigationBarHidden:NO];
            }
            
            [RMessage showNotificationInViewController:self.navigationController
                                                 title:NSLocalizedString(@"Warning !", nil)
                                              subtitle:NSLocalizedString(@"Enter First Name & Email", nil)
                                             iconImage:nil
                                                  type:RMessageTypeWarning
                                        customTypeName:nil
                                              duration:RMessageDurationAutomatic
                                              callback:nil
                                           buttonTitle:nil
                                        buttonCallback:nil
                                            atPosition:RMessagePositionNavBarOverlay
                                  canBeDismissedByUser:YES];
        }else if(_lastNameTextField.text.length==0 && _emailTextField.text.length==0)
        {
            if (self.navigationController.navigationBarHidden) {
                [self.navigationController setNavigationBarHidden:NO];
            }
            
            [RMessage showNotificationInViewController:self.navigationController
                                                 title:NSLocalizedString(@"Warning !", nil)
                                              subtitle:NSLocalizedString(@"Enter Last Name & Email", nil)
                                             iconImage:nil
                                                  type:RMessageTypeWarning
                                        customTypeName:nil
                                              duration:RMessageDurationAutomatic
                                              callback:nil
                                           buttonTitle:nil
                                        buttonCallback:nil
                                            atPosition:RMessagePositionNavBarOverlay
                                  canBeDismissedByUser:YES];
        }else{

        
        if (self.navigationController.navigationBarHidden) {
            [self.navigationController setNavigationBarHidden:NO];
        }
        
        [RMessage showNotificationInViewController:self.navigationController
                                             title:NSLocalizedString(@"Warning !", nil)
                                          subtitle:NSLocalizedString(@"Enter First Name, Last Name & Email.", nil)
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
    }else if (_userNameTextField.text.length==0 || _firstNameTextField.text.length==0 || _lastNameTextField || _emailTextField.text.length==0){
        
        if(_userNameTextField.text.length==0)
            {
                if (self.navigationController.navigationBarHidden)
                {
                   [self.navigationController setNavigationBarHidden:NO];
                }
        
                 [RMessage showNotificationInViewController:self.navigationController
                                             title:nil
                                          subtitle:NSLocalizedString(@"Please enter username.", nil)
                                         iconImage:nil
                                              type:RMessageTypeWarning
                                    customTypeName:nil
                                          duration:RMessageDurationAutomatic
                                          callback:nil
                                       buttonTitle:nil
                                    buttonCallback:nil
                                        atPosition:RMessagePositionNavBarOverlay
                              canBeDismissedByUser:YES];
        
            } else if(_firstNameTextField.text.length==0)
            {
                if (self.navigationController.navigationBarHidden)
                {
                    [self.navigationController setNavigationBarHidden:NO];
                }
                
                [RMessage showNotificationInViewController:self.navigationController
                                                     title:nil
                                                  subtitle:NSLocalizedString(@"Please enter First Name.", nil)
                                                 iconImage:nil
                                                      type:RMessageTypeWarning
                                            customTypeName:nil
                                                  duration:RMessageDurationAutomatic
                                                  callback:nil
                                               buttonTitle:nil
                                            buttonCallback:nil
                                                atPosition:RMessagePositionNavBarOverlay
                                      canBeDismissedByUser:YES];
            
            } if(_lastNameTextField.text.length==0)
            {
                if (self.navigationController.navigationBarHidden)
                {
                    [self.navigationController setNavigationBarHidden:NO];
                }
                
                [RMessage showNotificationInViewController:self.navigationController
                                                     title:nil
                                                  subtitle:NSLocalizedString(@"Please enter Last Name.", nil)
                                                 iconImage:nil
                                                      type:RMessageTypeWarning
                                            customTypeName:nil
                                                  duration:RMessageDurationAutomatic
                                                  callback:nil
                                               buttonTitle:nil
                                            buttonCallback:nil
                                                atPosition:RMessagePositionNavBarOverlay
                                      canBeDismissedByUser:YES];
            }if(_emailTextField.text.length==0)
            {
                if (self.navigationController.navigationBarHidden)
                {
                    [self.navigationController setNavigationBarHidden:NO];
                }
                
                [RMessage showNotificationInViewController:self.navigationController
                                                     title:nil
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
                
            }
    
    }else if(![Utils emailValidation:self.emailTextField.text]){
  
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
        
    }
    
        
    
    [self doneSubmitMethod];
    

}


-(void)doneSubmitMethod
{
    
    if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable)
        {
            [RKDropdownAlert title:APP_NAME message:NO_INTERNET backgroundColor:[UIColor hx_colorWithHexRGBAString:FAILURE_COLOR] textColor:[UIColor whiteColor]];
            
        }else{
            
            [[AppDelegate sharedAppdelegate] showProgressView];
        
            NSString *url =[NSString stringWithFormat:@"%@api/v2/helpdesk/user/edit/%@?api_key=%@&token=%@&user_name=%@&first_name=%@&last_name=%@&email=%@&phone_number=%@&mobile=%@",[userDefaults objectForKey:@"baseURL"],globalVariables.iD,API_KEY,[userDefaults objectForKey:@"token"],_userNameTextField.text,_firstNameTextField.text,_lastNameTextField.text,_emailTextField.text,_phoneTextField.text,_mobileTextField.text];

            MyWebservices *webservices=[MyWebservices sharedInstance];
            
      
            [webservices callPATCHAPIWithAPIName:url parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
            
 
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
                        NSLog(@"Thread-EditCustomerDetails-Refresh-error == %@",error.localizedDescription);
                    }
                    
                    return ;
                }
                
                if ([msg isEqualToString:@"tokenRefreshed"]) {
                    
                    [self doneSubmitMethod];
                    NSLog(@"Thread--NO4-call-EditCustomerDetails");
                    return;
                }
                
                
                if (json) {
                    NSLog(@"JSON-EditCustomerDetails-%@",json);
                        
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            if (self.navigationController.navigationBarHidden) {
                                [self.navigationController setNavigationBarHidden:NO];
                            }
                            
                            [RMessage showNotificationInViewController:self.navigationController
                                                                 title:NSLocalizedString(@"Sucess", nil)
                                                              subtitle:NSLocalizedString(@"Details Updated successfully.", nil)
                                                             iconImage:nil
                                                                  type:RMessageTypeSuccess
                                                        customTypeName:nil
                                                              duration:RMessageDurationAutomatic
                                                              callback:nil
                                                           buttonTitle:nil
                                                        buttonCallback:nil
                                                            atPosition:RMessagePositionNavBarOverlay
                                                  canBeDismissedByUser:YES];
                            

                            
                            globalVariables.userNameInUserList= _userNameTextField.text;
                            globalVariables.First_name= _firstNameTextField.text;
                            globalVariables.Last_name=_lastNameTextField.text;
                            globalVariables.emailInUserList= _emailTextField.text;
                            globalVariables.phoneNumberInUserList=_phoneTextField.text;
                            globalVariables.mobileNumberInUserList= _mobileTextField.text;
                            
                            
                       ClientDetailViewController  *create=[self.storyboard instantiateViewControllerWithIdentifier:@"ClientDetailVCID"];
                            [self.navigationController pushViewController:create animated:YES];
                        
                            
                            
                        });
                        
                        
                    }
                
                NSLog(@"Thread-NO5-EditCustomerDetails-closed");
                
            }];
            
        }
}


- (IBAction)ActivateOrDeactivateCilent:(id)sender {
    
    if([sender isOn]){
        NSLog(@"User Deactivate Switch Clicked - ON");
        
        BDCustomAlertView *customAlert = [[BDCustomAlertView alloc] init];
        
        [customAlert showAlertWithTitle:@"Alert !" message:@"Are You Sure to Deactivate ?" cancelButtonTitle:@"No" successButtonTitle:@"Yes" withSuccessBlock:^{
            
            globalVariables.ActiveDeactiveStateOfUser1=@"deActive";
            [_switch1 setOn:YES];
            _switch1.onTintColor= [UIColor redColor];
            [self deactivateUser];
        } cancelBlock:^{
            
            [_switch1 setOn:NO];
            //   _switch1.tintColor = [UIColor greenColor];
            _switch1.layer.cornerRadius = 16;
            _switch1.backgroundColor= [UIColor greenColor];
        }];
        
        
    } else{
         NSLog(@"User Activate Switch Clicked - OFF");
        
        BDCustomAlertView *customAlert = [[BDCustomAlertView alloc] init];
        
        [customAlert showAlertWithTitle:@"Alert !" message:@"Are You Sure to Activate ?" cancelButtonTitle:@"No" successButtonTitle:@"Yes" withSuccessBlock:^{
            
            [_switch1 setOn:NO];
            //   _switch1.tintColor = [UIColor greenColor];
            _switch1.layer.cornerRadius = 16;
            _switch1.backgroundColor= [UIColor greenColor];
         [self activeUser];
        } cancelBlock:^{
            [_switch1 setOn:YES];
            _switch1.onTintColor= [UIColor redColor];
        }];
    }
}


-(void)deactivateUser
{
    if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable)
    {
        [RKDropdownAlert title:APP_NAME message:NO_INTERNET backgroundColor:[UIColor hx_colorWithHexRGBAString:FAILURE_COLOR] textColor:[UIColor whiteColor]];
        
    }else{
        
        [[AppDelegate sharedAppdelegate] showProgressView];
        
        NSString *statusDeActivate= [NSString stringWithFormat:@"%i",1];
        
        NSString *url =[NSString stringWithFormat:@"%@api/v2/helpdesk/user/status/%@?token=%@&status=%@",[userDefaults objectForKey:@"baseURL"],globalVariables.iD,[userDefaults objectForKey:@"token"],statusDeActivate];
        
        NSLog(@"%@",url);
        NSLog(@"%@",url);
        
        MyWebservices *webservices=[MyWebservices sharedInstance];
        
        
        [webservices callPATCHAPIWithAPIName:url parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
            
            
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
                    NSLog(@"Thread-EditCustomerDetails-DeactivateUser-Refresh-error == %@",error.localizedDescription);
                }
                
                return ;
            }
            
            if ([msg isEqualToString:@"tokenRefreshed"]) {
                
                [self deactivateUser];
                NSLog(@"Thread-EditCustomerDetails-DeactivateUser");
                return;
            }
            
            
            if (json) {
                NSLog(@"Thread-EditCustomerDetails-DeactivateUser-%@",json);
                
                msg= [json objectForKey:@"message"];
                NSLog(@"Message is : %@",msg);
                
                if([msg isEqualToString:@"changed"]){
               
                    dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (self.navigationController.navigationBarHidden) {
                        [self.navigationController setNavigationBarHidden:NO];
                    }
                    
                    [RMessage showNotificationInViewController:self.navigationController
                                                         title:NSLocalizedString(@"Sucess", nil)
                                                      subtitle:NSLocalizedString(@"Deactivated successfully.", nil)
                                                     iconImage:nil
                                                          type:RMessageTypeSuccess
                                                customTypeName:nil
                                                      duration:RMessageDurationAutomatic
                                                      callback:nil
                                                   buttonTitle:nil
                                                buttonCallback:nil
                                                    atPosition:RMessagePositionNavBarOverlay
                                          canBeDismissedByUser:YES];
            
                        globalVariables.ActiveDeactiveStateOfUser=@"deactivated";
                        
                     ClientListViewController *list=[self.storyboard instantiateViewControllerWithIdentifier:@"ClientListID"];
                    [self.navigationController pushViewController:list animated:YES];
            
                });
                }else
                    
                {
                    
                    if (self.navigationController.navigationBarHidden) {
                        [self.navigationController setNavigationBarHidden:NO];
                    }
                    
                    [RMessage showNotificationInViewController:self.navigationController
                                                         title:NSLocalizedString(@"Error", nil)
                                                      subtitle:NSLocalizedString(@"Something is Wrong.", nil)
                                                     iconImage:nil
                                                          type:RMessageTypeSuccess
                                                customTypeName:nil
                                                      duration:RMessageDurationAutomatic
                                                      callback:nil
                                                   buttonTitle:nil
                                                buttonCallback:nil
                                                    atPosition:RMessagePositionNavBarOverlay
                                          canBeDismissedByUser:YES];
                    
                }
            } // end if json
            
            NSLog(@"Thread-NO5-EditCustomerDetails-Deactive-closed");
            
        }];
        
    }
    
    
}
-(void)activeUser
{
    
    
    if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable)
    {
        [RKDropdownAlert title:APP_NAME message:NO_INTERNET backgroundColor:[UIColor hx_colorWithHexRGBAString:FAILURE_COLOR] textColor:[UIColor whiteColor]];
        
    }else{
        
        [[AppDelegate sharedAppdelegate] showProgressView];
       
        
        NSString *statusActivate= [NSString stringWithFormat:@"%i",0];
        
       NSString *url =[NSString stringWithFormat:@"%@api/v2/helpdesk/user/status/%@?token=%@&status=%@",[userDefaults objectForKey:@"baseURL"],globalVariables.iD,[userDefaults objectForKey:@"token"],statusActivate];
        
        NSLog(@"%@",url);
        NSLog(@"%@",url);
        
        MyWebservices *webservices=[MyWebservices sharedInstance];
        
        
        [webservices callPATCHAPIWithAPIName:url parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
            
            
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
                    NSLog(@"Thread-EditCustomerDetails-DeactivateUser-Refresh-error == %@",error.localizedDescription);
                }
                
                return ;
            }
            
            if ([msg isEqualToString:@"tokenRefreshed"]) {
                
                [self deactivateUser];
                NSLog(@"Thread-EditCustomerDetails-activateUser");
                return;
            }
            
            
            if (json) {
                NSLog(@"Thread-EditCustomerDetails-activateUser-%@",json);
                
                msg= [json objectForKey:@"message"];
                NSLog(@"Message is : %@",msg);
                
                if([msg isEqualToString:@"changed"]){
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        if (self.navigationController.navigationBarHidden) {
                            [self.navigationController setNavigationBarHidden:NO];
                        }
                        
                        [RMessage showNotificationInViewController:self.navigationController
                                                             title:NSLocalizedString(@"Sucess", nil)
                                                          subtitle:NSLocalizedString(@"Activated successfully.", nil)
                                                         iconImage:nil
                                                              type:RMessageTypeSuccess
                                                    customTypeName:nil
                                                          duration:RMessageDurationAutomatic
                                                          callback:nil
                                                       buttonTitle:nil
                                                    buttonCallback:nil
                                                        atPosition:RMessagePositionNavBarOverlay
                                              canBeDismissedByUser:YES];
                        
                       globalVariables.ActiveDeactiveStateOfUser=@"activated";
                        
                        ClientListViewController *list=[self.storyboard instantiateViewControllerWithIdentifier:@"ClientListID"];
                        [self.navigationController pushViewController:list animated:YES];
                        
                    });
                }else
                    
                {
                    
                    if (self.navigationController.navigationBarHidden) {
                        [self.navigationController setNavigationBarHidden:NO];
                    }
                    
                    [RMessage showNotificationInViewController:self.navigationController
                                                         title:NSLocalizedString(@"Error", nil)
                                                      subtitle:NSLocalizedString(@"Something is Wrong.", nil)
                                                     iconImage:nil
                                                          type:RMessageTypeSuccess
                                                customTypeName:nil
                                                      duration:RMessageDurationAutomatic
                                                      callback:nil
                                                   buttonTitle:nil
                                                buttonCallback:nil
                                                    atPosition:RMessagePositionNavBarOverlay
                                          canBeDismissedByUser:YES];
                    
                }
            } // end if json
            
            NSLog(@"Thread-NO5-EditCustomerDetails-active-closed");
            
        }];
        
    }
    
    
}


#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    // verify the text field you wanna validate
    if (textField == _userNameTextField) {
        
        // do not allow the first character to be space | do not allow more than one space
        if ([string isEqualToString:@" "]) {
            if (!textField.text.length)
                return NO;
            //            if ([[textField.text stringByReplacingCharactersInRange:range withString:string] rangeOfString:@"  "].length)
            //                return NO;
        }
        
        // allow backspace
        if ([textField.text stringByReplacingCharactersInRange:range withString:string].length < textField.text.length) {
            return YES;
        }
        
        ///NARENDRA-SUBJECT-100 char
        // in case you need to limit the max number of characters
        if ([textField.text stringByReplacingCharactersInRange:range withString:string].length > 30) {
            return NO;
        }
        
        // limit the input to only the stuff in this character set, so no emoji or cirylic or any other insane characters
        NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@".@_-abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890 "];
        
        if ([string rangeOfCharacterFromSet:set].location == NSNotFound) {
            return NO;
        }
        
    }else  if (textField == _firstNameTextField || textField==_lastNameTextField) {
        
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
        NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"];
        
        if ([string rangeOfCharacterFromSet:set].location == NSNotFound) {
            return NO;
        }
        
    }
    else if(textField==_emailTextField){
        
        //do not allow the first character to be space | do not allow more than one space
        if ([string isEqualToString:@" "]) {
            if (!textField.text.length)
                return NO;
        }
        // allow backspace
        if ([textField.text stringByReplacingCharactersInRange:range withString:string].length < textField.text.length) {
            return YES;
        }
    
            
            //        // in case you need to limit the max number of characters
        if ([textField.text stringByReplacingCharactersInRange:range withString:string].length > 25) {
                return NO;
            }
            
            NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyz1234567890_-.@  "];
            
            if ([string rangeOfCharacterFromSet:set].location == NSNotFound) {
                return NO;
            }
        
        }
    else if(textField==_phoneTextField || textField== _mobileTextField){
        
        //do not allow the first character to be space | do not allow more than one space
        if ([string isEqualToString:@" "]) {
            if (!textField.text.length)
                return NO;
        }
        // allow backspace
        if ([textField.text stringByReplacingCharactersInRange:range withString:string].length < textField.text.length) {
            return YES;
        }
        
        
        //        // in case you need to limit the max number of characters
        if ([textField.text stringByReplacingCharactersInRange:range withString:string].length > 15) {
            return NO;
        }
        
        NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
        
        if ([string rangeOfCharacterFromSet:set].location == NSNotFound) {
            return NO;
        }
        
    }
    
    
    return YES;
}






@end



