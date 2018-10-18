//
//  LoginViewController.m
//  SideMEnuDemo
//
//  Created on 18/08/16.
//  Copyright © 2016 Ladybird websolutions pvt Ltd. All rights reserved.
//

#import "LoginViewController.h"
#import "InboxViewController.h"
#import "Reachability.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "AppConstanst.h"
#import "MyWebservices.h"
#import "Utils.h"
#import "HexColors.h"
#import "UIView+Shake.h"
#import "UITextField+PasswordField.h"
#import "RMessage.h"
#import "RMessageView.h"
#import "GlobalVariables.h"



@import Crashlytics;

@import FirebaseInstanceID;
@import FirebaseMessaging;
@import Firebase;

@interface LoginViewController () <UITextFieldDelegate,RMessageProtocol>
{
    Utils *utils;
    NSUserDefaults *userdefaults;
    NSString *errorMsg;
    NSString *baseURL;
    GlobalVariables *globalVariables;

    
}

@property (nonatomic, strong) MBProgressHUD *progressView;
@end

@implementation LoginViewController

//Following method is called after the view controller has loaded its view hierarchy into memory. This method is called regardless of whether the view hierarchy was loaded from a nib file or created programmatically in the loadView() method.

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
   /* Done button from keyboard it was not working so here is solution for it */
    
    [self.urlTextfield setDelegate:self];
    [self.urlTextfield setReturnKeyType:UIReturnKeyDone];
    [self.urlTextfield addTarget:self action:@selector(textFieldFinished:)forControlEvents:UIControlEventEditingDidEndOnExit];
    
    [self.userNameTextField setDelegate:self];
    [self.userNameTextField setReturnKeyType:UIReturnKeyDone];
    [self.userNameTextField addTarget:self
                               action:@selector(textFieldFinished:)
                     forControlEvents:UIControlEventEditingDidEndOnExit];
    
    [self.passcodeTextField setDelegate:self];
    [self.passcodeTextField setReturnKeyType:UIReturnKeyDone];
    [self.passcodeTextField addTarget:self
                               action:@selector(textFieldFinished:)
                     forControlEvents:UIControlEventEditingDidEndOnExit];
    
    // end solution
    
    
    // setting go button instead of next or donw on keyboard
    [_urlTextfield setReturnKeyType:UIReturnKeyGo];
    [_userNameTextField setReturnKeyType:UIReturnKeyDone];
    [_passcodeTextField setReturnKeyType:UIReturnKeyDone];
    
    //this for password eye icon
    [self.passcodeTextField addPasswordField];
    //end
    
    _loginButton.backgroundColor=[UIColor hx_colorWithHexRGBAString:@"#00aeef"];
    
    utils=[[Utils alloc]init];
    userdefaults=[NSUserDefaults standardUserDefaults];
    
    
}






-(void)textFieldFinished:(id)sender
{
    [_urlTextfield resignFirstResponder];
}

//Following method notifies the view controller that its view is about to be added to a view hierarchy.
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [[self navigationController] setNavigationBarHidden:YES];
    
   // self.urlTextfield.text=@"http://";
    
    [utils viewSlideInFromRightToLeft:self.companyURLview];
    [self.loginView setHidden:YES];
    [self.companyURLview setHidden:NO];
    
    
}


// After cling next arrow this method is called
- (IBAction)urlButton:(id)sender {
    
   // [self performSelector:@selector(URLValidationMethod) withObject:self afterDelay:1.0];
    [self URLValidationMethod];
}


// This method validates the URL

-(void)URLValidationMethod
{
    
    [self.urlTextfield resignFirstResponder];
    
    
    if (self.urlTextfield.text.length==0){
        
        [utils showAlertWithMessage:@"Please Enter the URL" sendViewController:self];
        
    }
    else{
        if ([Utils validateUrl:self.urlTextfield.text]) {
            
            baseURL=[[NSString alloc] init];
            
            if ([self.urlTextfield.text hasSuffix:@"/"]) {
                baseURL=self.urlTextfield.text;
            }else{
                baseURL=[self.urlTextfield.text stringByAppendingString:@"/"];
            }
           
            
            if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable)
            {
                //connection unavailable
                [RMessage
                 showNotificationWithTitle:NSLocalizedString(@"Something failed", nil)
                 subtitle:NSLocalizedString(@"The internet connection seems to be down. Please check it.", nil)
                 type:RMessageTypeError
                 customTypeName:nil
                 callback:nil];
                
            }else{
                //connection available
                
                [[AppDelegate sharedAppdelegate] showProgressViewWithText:NSLocalizedString(@"Verifying URL","")];
                
                NSString *url=[NSString stringWithFormat:@"%@api/v1/helpdesk/url?url=%@&api_key=%@",baseURL,[baseURL substringToIndex:[baseURL length]-1],API_KEY];
                NSLog(@"Check URL is :%@",url);
                
                globalVariables.urlDemo=baseURL;
                
                NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
                [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
                [request addValue:@"application/json" forHTTPHeaderField:@"Offer-type"];
                [request setTimeoutInterval:45.0];
                [request setURL:[NSURL URLWithString:url]];  // add your url
                [request setHTTPMethod:@"GET"];  // specify the JSON type to GET
                
                NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] ];
                // intialiaze NSURLSession
                
                [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    // Add your parameters in blocks
                    
                    // handle basic connectivity issues here
                    
                    if ([[error domain] isEqualToString:NSURLErrorDomain]) {
                        switch ([error code]) {
                                
                             [[AppDelegate sharedAppdelegate] hideProgressView];
                                
                            case NSURLErrorCannotFindHost:
                                self->errorMsg = NSLocalizedString(@"Cannot find specified host. Retype URL.", nil);
                                break;
                            case NSURLErrorCannotConnectToHost:
                                self->errorMsg = NSLocalizedString(@"Cannot connect to specified host. Server may be down.", nil);
                                break;
                            case NSURLErrorNotConnectedToInternet:
                                self->errorMsg = NSLocalizedString(@"Cannot connect to the internet. Service may not be available.", nil);
                                break;
                            default:
                                self->errorMsg = [error localizedDescription];
                                break;
                        }
                       
                        [self->utils showAlertWithMessage:self->errorMsg sendViewController:self];
                        
                        NSLog(@"dataTaskWithRequest error: %@", self->errorMsg);
                        return;
                    }else if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                        
                         [[AppDelegate sharedAppdelegate] hideProgressView];
                        
                        NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
                        
                        if (statusCode != 200) {
                            if (statusCode == 404) {
                                NSLog(@"dataTaskWithRequest HTTP status code: %ld", (long)statusCode);
                        
                                [self->utils showAlertWithMessage:@"The requested URL was not found on this server." sendViewController:self];
                                return;
                            }
                            else if(statusCode == 400)
                            {
                                NSLog(@"dataTaskWithRequest HTTP status code: %ld", (long)statusCode);
                                
                                [self->utils showAlertWithMessage:@"API is disabled in web, please enable it from Admin panel." sendViewController:self];
                                
                            }
                            else if (statusCode == 401 || statusCode == 400) {
                                NSLog(@"dataTaskWithRequest HTTP status code: %ld", (long)statusCode);
                                
                                [self->utils showAlertWithMessage: NSLocalizedString(@"API is disabled in web, please enable it from Admin panel.", nil) sendViewController:self];
                                
                                return;
                            }
                            else if (statusCode == 500) {
                                NSLog(@"dataTaskWithRequest HTTP status code: %ld", (long)statusCode);
                               
                                [self->utils showAlertWithMessage: NSLocalizedString(@"Internal Server Error. Something has gone wrong on the website's server", nil) sendViewController:self];
                            
                                return;
                            }
                            else{
                                NSLog(@"dataTaskWithRequest HTTP status code: %ld", (long)statusCode);
                               
                                [self->utils showAlertWithMessage:@"Unknown Error!" sendViewController:self];
                                 [[AppDelegate sharedAppdelegate] hideProgressView];
                                return;
                            }
                        }
                    }
                    
                    
                    NSString *replyStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    
                    NSLog(@"Get your response == %@", replyStr);
                
                    @try{  //result
                        if ([replyStr containsString:@"message"]) {
                            
                            NSDictionary *jsonData=[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                            
                            NSString *msg = [jsonData objectForKey:@"message"];
                            if([msg isEqualToString:@"API disabled"])
                            {
                                [self->utils showAlertWithMessage:@"API is disabled in web, please enable it from Admin panel." sendViewController:self];
                                [[AppDelegate sharedAppdelegate] hideProgressView];
                                
                            }
                            
                        }else if ([replyStr containsString:@"result"]) {
                            
                         NSDictionary *jsonData=[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                            
                         NSString *msg = [jsonData objectForKey:@"result"];
                            
                            if([msg isEqualToString:@"success"])
                            {
                                NSLog(@"Success");
                                
                                [self verifyBilling];
                                
                            }
                           
                        }else{
                            
                            [[AppDelegate sharedAppdelegate] hideProgressView];
                
                            [self->utils showAlertWithMessage:NSLocalizedString(@"Error - Please Check Your Helpdesk URL",nil)sendViewController:self];
                        }
                    }@catch (NSException *exception)
                    {
                        NSLog( @"Name: %@", exception.name);
                        NSLog( @"Reason: %@", exception.reason );
                        [self->utils showAlertWithMessage:exception.name sendViewController:self];
                        
                        return;
                    }
                    @finally
                    {
                        NSLog( @" I am in Validate URL method in Login ViewController" );
                        
                    }
                    
                    NSLog(@"Got response %@ with error %@.\n", response, error);
                    
                }]resume];
            }
            
        }else
            [utils showAlertWithMessage:NSLocalizedString(@"Please Enter a valid URL",nil) sendViewController:self];
    }
}



-(void)viewDidAppear:(BOOL)animated{
    [self.urlTextfield becomeFirstResponder];

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    if(textField == _urlTextfield)
    {
        [self URLValidationMethod];
        NSLog(@"Clicked on go");
    }
    
    return YES;
}


// Login button clicked

- (IBAction)btnLogin:(id)sender {
    
    if (((self.userNameTextField.text.length==0 || self.passcodeTextField.text.length==0)))
    {
        if (self.userNameTextField.text.length==0 && self.passcodeTextField.text.length==0){
        [utils showAlertWithMessage:  NSLocalizedString(@"Please insert username & password", nil) sendViewController:self];
        }else if(self.userNameTextField.text.length==0 && self.passcodeTextField.text.length!=0)
        {
            [utils showAlertWithMessage:NSLocalizedString(@"Please insert username", nil) sendViewController:self];
        }else if(self.userNameTextField.text.length!=0 && self.passcodeTextField.text.length==0)
        {
            [utils showAlertWithMessage: NSLocalizedString(@"Please insert password", nil)sendViewController:self];
        }
    }
    else {
        if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable)
        {
           
            [RMessage
             showNotificationWithTitle:NSLocalizedString(@"Something failed", nil)
             subtitle:NSLocalizedString(@"The internet connection seems to be down. Please check it!", nil)
             type:RMessageTypeError
             customTypeName:nil
             callback:nil];

            
        }else{
            
            [[AppDelegate sharedAppdelegate] showProgressView];
            
            NSString *url=[NSString stringWithFormat:@"%@authenticate",[[NSUserDefaults standardUserDefaults] objectForKey:@"companyURL"]];

            NSDictionary *param=[NSDictionary dictionaryWithObjectsAndKeys:self.userNameTextField.text,@"username",self.passcodeTextField.text,@"password",API_KEY,@"api_key",IP,@"ip",nil];
            
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            
            [request setURL:[NSURL URLWithString:url]];
            [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [request setTimeoutInterval:60];
            
            [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:param options:kNilOptions error:nil]];
            [request setHTTPMethod:@"POST"];
            
            NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] ];
            
            [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                
                if (error) {
                    NSLog(@"dataTaskWithRequest error: %@", error);
                    return;
                }else if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                    
                    NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
                    NSLog(@"Status code in Login : %ld",(long)statusCode);
                    NSLog(@"Status code in Login : %ld",(long)statusCode);
                    
                    if (statusCode != 200) {
                        
                    
                      if(statusCode == 404)
                        {
                            NSLog(@"dataTaskWithRequest HTTP status code: %ld", (long)statusCode);
                            [[AppDelegate sharedAppdelegate] hideProgressView];
                            [self->utils showAlertWithMessage:@"The requested URL was not found on this server." sendViewController:self];
                        }
                    
                        else if(statusCode == 405)
                        {
                            NSLog(@"dataTaskWithRequest HTTP status code: %ld", (long)statusCode);
                            [[AppDelegate sharedAppdelegate] hideProgressView];
                            [self->utils showAlertWithMessage:@"The request method is known by the server but has been disabled and cannot be used." sendViewController:self];
                        }
                        else if(statusCode == 500)
                        {
                            NSLog(@"dataTaskWithRequest HTTP status code: %ld", (long)statusCode);
                            [[AppDelegate sharedAppdelegate] hideProgressView];
                            [self->utils showAlertWithMessage:@"Internal Server Error. Something has gone wrong on the website's server." sendViewController:self];
                        }
                        
                    }
                    
                }
                
                NSString *replyStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                
                NSLog(@"Login Response is : %@",replyStr);
                
                NSDictionary *jsonData=[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                NSLog(@"JSON is : %@",jsonData);
        
                //main if 1
                if ([replyStr containsString:@"success"] && [replyStr containsString:@"message"] ) {
                    
            
                        NSString *msg=[jsonData objectForKey:@"message"];
                        
                            if([msg isEqualToString:@"Invalid credentials"])
                            {
                                [self->utils showAlertWithMessage:@"Invalid Credentials.Enter valid username or password" sendViewController:self];
                                 [[AppDelegate sharedAppdelegate] hideProgressView];
                            }
                            else if([msg isEqualToString:@"API disabled"])
                            {
                                [self->utils showAlertWithMessage:@"API is disabled in web, please enable it from Admin panel." sendViewController:self];
                                 [[AppDelegate sharedAppdelegate] hideProgressView];
                            }
                            
                }
                        
               else         //success = true
               if ([replyStr containsString:@"success"] && [replyStr containsString:@"data"] ) {
                        {
                            
                            NSDictionary *userDataDict=[jsonData objectForKey:@"data"];
                            NSString *tokenString=[NSString stringWithFormat:@"%@",[userDataDict objectForKey:@"token"]];
                            NSLog(@"Token is : %@",tokenString);
                            
                            [self->userdefaults setObject:[userDataDict objectForKey:@"token"] forKey:@"token"];
                            
                            NSDictionary *userDetailsDict=[userDataDict objectForKey:@"user"];
                            
                            NSString * userId=[NSString stringWithFormat:@"%@",[userDetailsDict objectForKey:@"id"]];
                            
                            NSString * firstName=[NSString stringWithFormat:@"%@",[userDetailsDict objectForKey:@"first_name"]];
                            
                            NSString * lastName=[NSString stringWithFormat:@"%@",[userDetailsDict objectForKey:@"last_name"]];
                            
                            NSString * userName=[NSString stringWithFormat:@"%@",[userDetailsDict objectForKey:@"user_name"]];
                            
                            NSString * userProfilePic=[NSString stringWithFormat:@"%@",[userDetailsDict objectForKey:@"profile_pic"]];
                            
                            NSString * userRole=[NSString stringWithFormat:@"%@",[userDetailsDict objectForKey:@"role"]];
                            
                            
                            
                            
                            [self->userdefaults setObject:userId forKey:@"user_id"];
                            [self->userdefaults setObject:userProfilePic forKey:@"profile_pic"];
                            [self->userdefaults setObject:userRole forKey:@"role"];
                            
                            NSString *profileName;
                            if ([userName isEqualToString:@""]) {
                                profileName=userName;
                            }else{
                                profileName=[NSString stringWithFormat:@"%@ %@",firstName,lastName];
                            }
                            
                            
                            [self->userdefaults setObject:profileName forKey:@"profile_name"];
                            [self->userdefaults setObject:self->baseURL forKey:@"baseURL"];
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                            [self->userdefaults setObject:self->_userNameTextField.text forKey:@"username"];
                            
                            [self->userdefaults setObject:self.passcodeTextField.text forKey:@"password"];
                            
                            });
                            
                            [self->userdefaults setBool:YES forKey:@"loginSuccess"];
                            [self->userdefaults synchronize];
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                if([userRole isEqualToString:@"admin"] || [userRole isEqualToString:@"agent"]){
                                    
                                   
                                    if (self.navigationController.navigationBarHidden) {
                                        [self.navigationController setNavigationBarHidden:NO];
                                    }
                                    
                                    [RMessage showNotificationInViewController:self.navigationController
                                                                         title:NSLocalizedString(@"Welcome.", nil)
                                                                      subtitle:NSLocalizedString(@"You have logged in successfully.", nil)
                                                                     iconImage:nil
                                                                          type:RMessageTypeSuccess
                                                                customTypeName:nil
                                                                      duration:RMessageDurationAutomatic
                                                                      callback:nil
                                                                   buttonTitle:nil
                                                                buttonCallback:nil
                                                                    atPosition:RMessagePositionNavBarOverlay
                                                          canBeDismissedByUser:YES];
                                
                                    [self sendDeviceToken];
                                    
                                     [[AppDelegate sharedAppdelegate] hideProgressView];
                                   
                                    InboxViewController *inboxVC=[self.storyboard  instantiateViewControllerWithIdentifier:@"InboxID"];
                                    [self.navigationController pushViewController:inboxVC animated:YES];
                                    //[self.navigationController popViewControllerAnimated:YES];
                                    [[self navigationController] setNavigationBarHidden:NO];
                                }else
                                {
                                    [self->utils showAlertWithMessage:@"Invalid entry for user. This app is used by Agent and Admin only." sendViewController:self];
                                    [[AppDelegate sharedAppdelegate] hideProgressView];
                                }
                            });
                            
                            
                        }   //end sucess=true if  here
                    
                        
                }else
                {
                    
                    
                    [self->utils showAlertWithMessage:@"Whoops! Something went Wrong! Please try again." sendViewController:self];
                    [[AppDelegate sharedAppdelegate] hideProgressView];
                    
                }
                
                
            }] resume];
            
        }
        
    }
    
}

//Following method used to verify URL - It check that entered URL is present or not present in Faveo Billing
-(void)verifyBilling{
    
    NSString *url=[NSString stringWithFormat:@"%@?url=%@",BILLING_API,baseURL];
    NSLog(@"url at VeryfuBillingIS : %@",url);
    
    @try{
        
        MyWebservices *webservices=[MyWebservices sharedInstance];
        
        [webservices httpResponseGET:url parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg){
            
            if (error || [msg containsString:@"Error"]) {
                
                [[AppDelegate sharedAppdelegate] hideProgressView];
                
                if (msg) {
                    if([msg isEqualToString:@"Error-402"])
                    {
                        NSLog(@"Message is : %@",msg);
                        [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Access denied - Either your role has been changed or your login credential has been changed."] sendViewController:self];
                    }
                    if([msg isEqualToString:@"Error-404"])
                    {
                        NSLog(@"Message is : %@",msg);
                        [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error 404 - Issue with Billing API while validating your Helpdesk URL. Contact to   Helpdesk Support."] sendViewController:self];
                    }
                    
                    else{
                        [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",msg] sendViewController:self];
                        NSLog(@"Thread-verifyBilling-error == %@",error.localizedDescription);
                    }
                    
                }else if(error)  {
                   // [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",error.localizedDescription] sendViewController:self];
                    [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error - Issue with Billing API while validating your Helpdesk URL. Contact to   Helpdesk Support."] sendViewController:self];
                    NSLog(@"Thread-verifyBilling-error == %@",error.localizedDescription);
                }
                return ;
            }
            
            if (json) {
                
                NSLog(@"Thread-sendAPNS-token-json-%@",json);
               
                NSString * resultMsg= [json objectForKey:@"result"];
                
                if([resultMsg isEqualToString:@"fails"])
                {
                     [self->utils showAlertWithMessage:@"Your HELPDESK URL is not verified. This URL is not found in FAVEO HELPDESK BILLING." sendViewController:self];
                    
                     [[AppDelegate sharedAppdelegate] hideProgressView];
                }
                else if([resultMsg isEqualToString:@"success"])
                {
                    NSLog(@"Billing successful!");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        
                        [RMessage showNotificationWithTitle:NSLocalizedString(@"Success", nil)
                                                   subtitle:NSLocalizedString(@"URL Verified successfully !", nil)
                                                       type:RMessageTypeSuccess
                                             customTypeName:nil
                                                   callback:nil];
                        
                        [self.companyURLview setHidden:YES];
                        [self.loginView setHidden:NO];
                        [self->utils viewSlideInFromRightToLeft:self.loginView];
                        [[AppDelegate sharedAppdelegate] hideProgressView];
                        
                    });
                    [self->userdefaults setObject:[self->baseURL stringByAppendingString:@"api/v1/"] forKey:@"companyURL"];
                    [self->userdefaults synchronize];
                    
                }else{
                    
                    [self->utils showAlertWithMessage:@"Something went wrong in Billing. Please try later." sendViewController:self];
                    
                    [[AppDelegate sharedAppdelegate] hideProgressView];
                }
            
            }
            
        }];
    }@catch (NSException *exception)
    {
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        [utils showAlertWithMessage:exception.name sendViewController:self];
        
        return;
    }
    @finally
    {
        NSLog( @" I am in Verify Billing method in Login ViewController" );
        
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}


//it will send an token to Firebase with user details (Logged user)
-(void)sendDeviceToken{
    NSString *refreshedToken =  [[FIRInstanceID instanceID] token];
    NSLog(@"refreshed token  %@",refreshedToken);
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSString *url=[NSString stringWithFormat:@"%@fcmtoken?user_id=%@&fcm_token=%@&os=%@",[userDefaults objectForKey:@"companyURL"],[userDefaults objectForKey:@"user_id"],[[FIRInstanceID instanceID] token],@"ios"];
  
@try{
    MyWebservices *webservices=[MyWebservices sharedInstance];
    [webservices httpResponsePOST:url parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg){
        if (error || [msg containsString:@"Error"]) {
            if (msg) {
                
        
                NSLog(@"Thread-postAPNS-toserver-error == %@",error.localizedDescription);
            }else if(error)  {
                //
                NSLog(@"Thread-postAPNS-toserver-error == %@",error.localizedDescription);
            }
            return ;
        }
        if (json) {
            
            NSLog(@"Thread-sendAPNS-token-json-%@",json);
        }
        
    }];
 }@catch (NSException *exception)
    {
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        [utils showAlertWithMessage:exception.name sendViewController:self];
        return;
    }
    @finally
    {
        NSLog( @" I am in sendDeviceToken method in Login ViewController" );
        
    }
}


@end
