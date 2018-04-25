//
//  LoginViewController.m
//  SideMEnuDemo
//
//  Created on 18/08/16.
//  Copyright © 2016 Ladybird websolutions pvt ltd. All rights reserved.
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
#import "RKDropdownAlert.h"
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
- (void)viewDidLoad {
    [super viewDidLoad];
    

  
    // done button on keyboard was not working so here is solution
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

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [[self navigationController] setNavigationBarHidden:YES];
    
   // self.urlTextfield.text=@"http://";
    
    [utils viewSlideInFromRightToLeft:self.companyURLview];
    [self.loginView setHidden:YES];
    [self.companyURLview setHidden:NO];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)urlButton:(id)sender {
    
    
    [self URLValidationMethod];
}

//URL validation method
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
                        [[AppDelegate sharedAppdelegate] hideProgressView];
                        [self->utils showAlertWithMessage:self->errorMsg sendViewController:self];
                        
                        NSLog(@"dataTaskWithRequest error: %@", self->errorMsg);
                        return;
                    }else if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                        
                        NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
                        
                        if (statusCode != 200) {
                            if (statusCode == 404) {
                                NSLog(@"dataTaskWithRequest HTTP status code: %ld", (long)statusCode);
                                [[AppDelegate sharedAppdelegate] hideProgressView];
                                [self->utils showAlertWithMessage:@"The requested URL was not found on this server." sendViewController:self];
                                return;
                            }
                            else if(statusCode == 400)
                            {
                                NSLog(@"dataTaskWithRequest HTTP status code: %ld", (long)statusCode);
                                [[AppDelegate sharedAppdelegate] hideProgressView];
                                [self->utils showAlertWithMessage:@"API is disabled in web, please enable it from Admin panel." sendViewController:self];
                            }
                           else if (statusCode == 401 || statusCode == 400) {
                                NSLog(@"dataTaskWithRequest HTTP status code: %ld", (long)statusCode);
                                [[AppDelegate sharedAppdelegate] hideProgressView];
                                [self->utils showAlertWithMessage: NSLocalizedString(@"API is disabled in web, please enable it from Admin panel.", nil) sendViewController:self];
                               
                                return;
                            }
                           else if (statusCode == 500) {
                               NSLog(@"dataTaskWithRequest HTTP status code: %ld", (long)statusCode);
                               [[AppDelegate sharedAppdelegate] hideProgressView];
                               [self->utils showAlertWithMessage: NSLocalizedString(@"Internal Server Error. Something has gone wrong on the website's server", nil) sendViewController:self];
                               
                               return;
                           }
                            else{
                                NSLog(@"dataTaskWithRequest HTTP status code: %ld", (long)statusCode);
                                [[AppDelegate sharedAppdelegate] hideProgressView];
                                [self->utils showAlertWithMessage:@"Unknown Error!" sendViewController:self];
                                return;
                            }
                        }
                    }
                    
                    
                    NSString *replyStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    
                    NSLog(@"Get your response == %@", replyStr);
                    
                    @try{
                        if ([replyStr containsString:@"success"]) {
                            
                            NSLog(@"Success");
                            
                            [self verifyBilling];
                            
                            
                        }else{
                            
                            [[AppDelegate sharedAppdelegate] hideProgressView];
                           
                            [self->utils showAlertWithMessage:NSLocalizedString(@"Error - Please Check Your Helpdesk URL",nil)sendViewController:self];
                        }
                    }@catch (NSException *exception)
                    {
                        NSLog( @"Name: %@", exception.name);
                        NSLog( @"Reason: %@", exception.reason );
                        [self->utils showAlertWithMessage:exception.name sendViewController:self];
                         [[AppDelegate sharedAppdelegate] hideProgressView];

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
           [[AppDelegate sharedAppdelegate] hideProgressView];
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


// login button method
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
            // NSString *params=[NSString string];
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
                         if (statusCode == 401) {
                            NSLog(@"dataTaskWithRequest HTTP status code: %ld", (long)statusCode);
                            [[AppDelegate sharedAppdelegate] hideProgressView];
                            [self->utils showAlertWithMessage: NSLocalizedString(@"API is disabled in web, please enable it from Admin panel.", nil) sendViewController:self];
                            //[utils showAlertWithMessage:@"Wrong Username or Password" sendViewController:self];
                            return;
                        }else if(statusCode == 400)
                        {
                            NSLog(@"dataTaskWithRequest HTTP status code: %ld", (long)statusCode);
                            [[AppDelegate sharedAppdelegate] hideProgressView];
                            [self->utils showAlertWithMessage:@"API is disabled in web, please enable it from Admin panel." sendViewController:self];
                        }
                       else if(statusCode == 404)
                        {
                            NSLog(@"dataTaskWithRequest HTTP status code: %ld", (long)statusCode);
                            [[AppDelegate sharedAppdelegate] hideProgressView];
                            [self->utils showAlertWithMessage:@"The requested URL was not found on this server." sendViewController:self];
                        }
                        else if(statusCode == 400)
                        {
                            NSLog(@"dataTaskWithRequest HTTP status code: %ld", (long)statusCode);
                            [[AppDelegate sharedAppdelegate] hideProgressView];
                            [self->utils showAlertWithMessage:@"The request could not be understood by the server due to malformed syntax." sendViewController:self];
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
                        else{
                            NSLog(@"dataTaskWithRequest HTTP status code: %ld", (long)statusCode);
                            [[AppDelegate sharedAppdelegate] hideProgressView];
                            [self->utils showAlertWithMessage:NSLocalizedString(@"Unknown Error !", nil)sendViewController:self];
                            return;
                        }
                    }
                    
                }
                
                NSString *replyStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                
        
                
        
                if ([replyStr containsString:@"success"] || [replyStr containsString:@"data"]) {
                    
                    @try{
                        
                        NSDictionary *jsonData=[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                        
                        NSLog(@"JSON is : %@",jsonData);
                        NSLog(@"JSON is : %@",jsonData);
                        
                        // [userdefaults setObject:[jsonData objectForKey:@"token"] forKey:@"token"];
                       
                        NSDictionary *userDataDict=[jsonData objectForKey:@"data"];
                        NSString *tokenString=[NSString stringWithFormat:@"%@",[userDataDict objectForKey:@"token"]];
                        NSLog(@"Token is : %@",tokenString);
                        
                        [self->userdefaults setObject:[userDataDict objectForKey:@"token"] forKey:@"token"];
                        
                        NSDictionary *userDetailsDict=[userDataDict objectForKey:@"user"];
                        
                        NSString * userId=[NSString stringWithFormat:@"%@",[userDetailsDict objectForKey:@"id"]];
                        
                        NSString * firstName=[NSString stringWithFormat:@"%@",[userDetailsDict objectForKey:@"first_name"]];
                        
                        NSString * lastName=[NSString stringWithFormat:@"%@",[userDetailsDict objectForKey:@"last_name"]];
                        
                        NSString * userName=[NSString stringWithFormat:@"%@",[userDetailsDict objectForKey:@"user_name"]];
                        
                      //  NSString * userEmail=[NSString stringWithFormat:@"%@",[userDetailsDict objectForKey:@"email"]];
                        
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
                        [self->userdefaults setObject:self.userNameTextField.text forKey:@"username"];
                        
                        [self->userdefaults setObject:self.passcodeTextField.text forKey:@"password"];
                        [self->userdefaults setBool:YES forKey:@"loginSuccess"];
                        [self->userdefaults synchronize];
                        
                
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                        if([userRole isEqualToString:@"admin"] || [userRole isEqualToString:@"agent"]){
                          
                                [RKDropdownAlert title:NSLocalizedString(@"Welcome.",nil) message:NSLocalizedString(@"You have logged in successfully.",nil) backgroundColor:[UIColor hx_colorWithHexRGBAString:SUCCESS_COLOR] textColor:[UIColor whiteColor]];
                            
                    
                            
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
                    }
                    @catch (NSException *exception)
                    {
                        NSLog( @"Name: %@", exception.name);
                        NSLog( @"Reason: %@", exception.reason );
                        [self->utils showAlertWithMessage:exception.name sendViewController:self];

                        return;
                    }
                    @finally
                    {
                        NSLog( @" I am in Login method in Login ViewController" );
                        
                    }
                    
                }else {
                    [[AppDelegate sharedAppdelegate] hideProgressView];
                    
                    if ([replyStr containsString:@"invalid_credentials"]) {
                        
                        [self->utils showAlertWithMessage:@"Enter valid username or password" sendViewController:self];
                    }else{
                        
                        [self->utils showAlertWithMessage:@"invalid_credentials" sendViewController:self];
                    }
                }
                
                
                NSLog(@"Got response %@ with error %@.\n", response, error);
            }] resume];
            
        }
        
    }
    
}

//It will verify the URL either paid or not
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
                    [self->utils showAlertWithMessage:[NSString stringWithFormat:@"API is disabled in web, please enable it from Admin panel."] sendViewController:self];
                }
                
                else{
                    [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",msg] sendViewController:self];
                    NSLog(@"Thread-verifyBilling-error == %@",error.localizedDescription);
                }
                
            }else if(error)  {
                [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",error.localizedDescription] sendViewController:self];
                NSLog(@"Thread-verifyBilling-error == %@",error.localizedDescription);
            }
            return ;
        }
        
        if (json) {
            NSLog(@"Thread-sendAPNS-token-json-%@",json);
            // if([[json objectForKey:@"result"] isEqualToString:@"success"]){
            NSLog(@"Billing successful!");
            dispatch_async(dispatch_get_main_queue(), ^{
            
                [RMessage showNotificationWithTitle:NSLocalizedString(@"Success", nil)
                                           subtitle:NSLocalizedString(@"URL Verified successfully !", nil)
                                               type:RMessageTypeSuccess
                                     customTypeName:nil
                                           callback:nil];
                
                [[AppDelegate sharedAppdelegate] hideProgressView];
                [self.companyURLview setHidden:YES];
                [self.loginView setHidden:NO];
                [self->utils viewSlideInFromRightToLeft:self.loginView];
            });
            [self->userdefaults setObject:[self->baseURL stringByAppendingString:@"api/v1/"] forKey:@"companyURL"];
            [self->userdefaults synchronize];
        
            
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
