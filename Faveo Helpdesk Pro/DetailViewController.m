//
//  DetailViewController.m
//  SideMEnuDemo
//
//  Created  on 16/09/16.
//  Copyright © 2016 Ladybird websolutions pvt ltd. All rights reserved.
//

#import "DetailViewController.h"
#import "ActionSheetStringPicker.h"
#import "HexColors.h"
#import "Utils.h"
#import "AppConstanst.h"
#import "MyWebservices.h"
#import "Reachability.h"
#import "AppDelegate.h"
#import "GlobalVariables.h"
#import "IQKeyboardManager.h"
#import "NotificationViewController.h"
#import "RMessage.h"
#import "RMessageView.h" 

@interface DetailViewController ()<RMessageProtocol>{
    
    Utils *utils;
    NSUserDefaults *userDefaults;
    GlobalVariables *globalVariables;
    
    NSNumber *sla_id;
    NSNumber *type_id;
    NSNumber *help_topic_id;
    NSNumber *dept_id;
    NSNumber *priority_id;
    NSNumber *source_id;
    NSNumber *status_id;
    NSNumber *staff_id;
    
    
    NSMutableArray * sla_idArray;
    NSMutableArray * type_idArray;
    NSMutableArray * dept_idArray;
    NSMutableArray * pri_idArray;
    NSMutableArray * helpTopic_idArray;
    NSMutableArray * status_idArray;
    NSMutableArray * source_idArray;
    NSMutableArray * staff_idArray;
    
}

@property (nonatomic,retain) UIImageView *imgViewLoading;

@end

@implementation DetailViewController


//This method is called after the view controller has loaded its view hierarchy into memory. This method is called regardless of whether the view hierarchy was loaded from a nib file or created programmatically in the loadView method.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:false];
    sla_id=[[NSNumber alloc]init];
    dept_id=[[NSNumber alloc]init];
    help_topic_id=[[NSNumber alloc]init];
    priority_id=[[NSNumber alloc]init];
    source_id=[[NSNumber alloc]init];
    status_id=[[NSNumber alloc]init];
    type_id=[[NSNumber alloc]init];
    staff_id=[[NSNumber alloc]init];
    
    _saveButton.backgroundColor=[UIColor hx_colorWithHexRGBAString:@"#00aeef"];
    _imgViewLoading = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 78, 78)];
    _imgViewLoading.image=[UIImage imageNamed:@"loading_imgBlue_78x78"];
    _imgViewLoading.center=CGPointMake(self.view.frame.size.width/2,(self.view.frame.size.height/2)-100);
    [self.view addSubview:_imgViewLoading];
    [self.imgViewLoading.layer addAnimation:[self imageAnimationForEmptyDataSet] forKey:@"transform"];
    

    utils=[[Utils alloc]init];
    globalVariables=[GlobalVariables sharedInstance];
   // _subjectTextField.text=globalVariables.title;
    userDefaults=[NSUserDefaults standardUserDefaults];
    //[_activityIndicatorObject startAnimating];
    
    self.subjectTextView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.subjectTextView.layer.borderWidth = 0.4;
    self.subjectTextView.layer.cornerRadius = 3;
    
    [self reload];

    self.tableView.tableFooterView=[[UIView alloc] initWithFrame:CGRectZero];
    // Do any additional setup after loading the view.
}

//This method notifies the view controller that its view is about to be removed from a view hierarchy.
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:true];
}


// This method calls an API for getting tickets, it will returns an JSON which contains 10 records with ticket details.
-(void)reload{
    
    if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable)
    {
       
        [_imgViewLoading setHidden:YES];

        
        if (self.navigationController.navigationBarHidden) {
            [self.navigationController setNavigationBarHidden:NO];
        }
        
        [RMessage showNotificationInViewController:self.navigationController
                                             title:NSLocalizedString(@"Error..!", nil)
                                          subtitle:NSLocalizedString(@"There is no Internet Connection...!", nil)
                                         iconImage:nil
                                              type:RMessageTypeError
                                    customTypeName:nil
                                          duration:RMessageDurationAutomatic
                                          callback:nil
                                       buttonTitle:nil
                                    buttonCallback:nil
                                        atPosition:RMessagePositionNavBarOverlay
                              canBeDismissedByUser:YES];

        
    }else{
        
        NSString *url=[NSString stringWithFormat:@"%@helpdesk/ticket?api_key=%@&ip=%@&token=%@&id=%@",[userDefaults objectForKey:@"companyURL"],API_KEY,IP,[userDefaults objectForKey:@"token"],globalVariables.iD];
 @try{
        MyWebservices *webservices=[MyWebservices sharedInstance];
        [webservices httpResponseGET:url parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
            
            if (error) {
                
                [self->utils showAlertWithMessage:@"Error" sendViewController:self];
                NSLog(@"Thread-NO4-getDetail-Refresh-error == %@",error.localizedDescription);
                
                return ;
            }
            if (error || [msg containsString:@"Error"]) {
                
                [self.refreshControl endRefreshing];
                //[_activityIndicatorObject stopAnimating];
                [self->_imgViewLoading setHidden:YES];
                
                if (msg) {
                    
                    if([msg isEqualToString:@"Error-401"])
                    {
                        NSLog(@"Message is : %@",msg);
                        [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Access Denied.  Your credentials has been changed. Contact to Admin and try to login again."] sendViewController:self];
                    }
                    else
                        
                    if([msg isEqualToString:@"Error-402"])
                    {
                        NSLog(@"Message is : %@",msg);
                        [self->utils showAlertWithMessage:[NSString stringWithFormat:@"API is disabled in web, please enable it from Admin panel."] sendViewController:self];
                    }
                    else if([msg isEqualToString:@"Error-403"] || [msg isEqualToString:@"403"])
                    {
                        NSLog(@"Message is : %@",msg);
                        [self->utils showAlertWithMessage:@"Access Denied. Either your credentials has been changed or You are not an Agent/Admin." sendViewController:self];
                    }
                    else if([msg isEqualToString:@"Error-422"])
                    {
                        NSLog(@"Message is : %@",msg);
                        [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Unprocessable Entity. Please try again later."] sendViewController:self];
                    }
                    else if([msg isEqualToString:@"Error-404"])
                    {
                        NSLog(@"Message is : %@",msg);
                        [self->utils showAlertWithMessage:[NSString stringWithFormat:@"The requested URL was not found on this server."] sendViewController:self];
                    }
                    else if([msg isEqualToString:@"Error-405"] ||[msg isEqualToString:@"405"])
                    {
                        NSLog(@"Message is : %@",msg);
                        [self->utils showAlertWithMessage:[NSString stringWithFormat:@"The requested URL was not found on this server."] sendViewController:self];
                    }
                    else if([msg isEqualToString:@"Error-500"] ||[msg isEqualToString:@"500"])
                    {
                        NSLog(@"Message is : %@",msg);
                        [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Internal Server Error.Something has gone wrong on the website's server."] sendViewController:self];
                    }
                    else if([msg isEqualToString:@"Error-400"] ||[msg isEqualToString:@"400"])
                    {
                        NSLog(@"Message is : %@",msg);
                        [self->utils showAlertWithMessage:[NSString stringWithFormat:@"The request could not be understood by the server due to malformed syntax."] sendViewController:self];
                    }
                    
                    else{
                        [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",msg] sendViewController:self];
                    }
                    
                    
                }else if(error)  {
                    [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",error.localizedDescription] sendViewController:self];
                    NSLog(@"Thread-NO4-getInbox-Refresh-error == %@",error.localizedDescription);
                }
                
                return ;
            }
            
            if ([msg isEqualToString:@"tokenRefreshed"]) {
                
                [self reload];
                NSLog(@"Thread--NO4-call-getDetail");
                return;
            }
            
            if (json) {
                //NSError *error;
                NSLog(@"Thread-NO4--getDetailAPI--%@",json);
                
                NSDictionary *dic= [json objectForKey:@"data"];
                NSDictionary * ticketDict=[dic objectForKey:@"ticket"];
                
                dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                    
                        if([NSNull null] != [ticketDict objectForKey:@"created_at"])
                        {
                           self->_createdDateTextField.text= [self->utils getLocalDateTimeFromUTC:[ticketDict objectForKey:@"created_at"]];
                        }else
                        {
                            self->_createdDateTextField.text=NSLocalizedString(@"Not Available",nil);
                        }
                    
                        NSDictionary *userData=[ticketDict objectForKey:@"from"];
                        
                        if (([[userData objectForKey:@"first_name"] isEqual:[NSNull null]] ) || ( [[userData objectForKey:@"first_name"] length] == 0 )) {
                            self->_firstnameTextField.text=NSLocalizedString(@"Not Available",nil);
                        }else self->_firstnameTextField.text=[userData objectForKey:@"first_name"];
                        
                        
                        self->globalVariables.ticket_number=[ticketDict objectForKey:@"ticket_number"];
                        //______________________________________________________________________________________________________
                        ////////////////for UTF-8 data encoding ///////
        
                        NSString *encodedString =[ticketDict objectForKey:@"title"];
                        
                        
                        [Utils isEmpty:encodedString];
                        
                        if  ([Utils isEmpty:encodedString]){
                           // _subjectTextField.text =@"No Title";
                            self->_subjectTextView.text= NSLocalizedString(@"Not Available",nil);
                        }
                        else
                        {
                            
                            NSMutableString *decodedString = [[NSMutableString alloc] init];
                            
                            if ([encodedString hasPrefix:@"=?UTF-8?Q?"] || [encodedString hasSuffix:@"?="])
                            {
                                NSScanner *scanner = [NSScanner scannerWithString:encodedString];
                                NSString *buf = nil;
                                //  NSMutableString *decodedString = [[NSMutableString alloc] init];
                                
                                while ([scanner scanString:@"=?UTF-8?Q?" intoString:NULL]
                                       || ([scanner scanUpToString:@"=?UTF-8?Q?" intoString:&buf] && [scanner scanString:@"=?UTF-8?Q?" intoString:NULL])) {
                                    if (buf != nil) {
                                        [decodedString appendString:buf];
                                    }
                                    
                                    buf = nil;
                                    
                                    NSString *encodedRange;
                                    
                                    if (![scanner scanUpToString:@"?=" intoString:&encodedRange]) {
                                        break; // Invalid encoding
                                    }
                                    
                                    [scanner scanString:@"?=" intoString:NULL]; // Skip the terminating "?="
                                    
                                    // Decode the encoded portion (naively using UTF-8 and assuming it really is Q encoded)
                                    // I'm doing this really naively, but it should work
                                    
                                    // Firstly I'm encoding % signs so I can cheat and turn this into a URL-encoded string, which NSString can decode
                                    encodedRange = [encodedRange stringByReplacingOccurrencesOfString:@"%" withString:@"=25"];
                                    
                                    // Turn this into a URL-encoded string
                                    encodedRange = [encodedRange stringByReplacingOccurrencesOfString:@"=" withString:@"%"];
                                    
                                    
                                    // Remove the underscores
                                    encodedRange = [encodedRange stringByReplacingOccurrencesOfString:@"_" withString:@" "];
                                    
                                    // [decodedString appendString:[encodedRange stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                                    
                                    NSString *str1= [encodedRange stringByRemovingPercentEncoding];
                                    [decodedString appendString:str1];
                                    
                                    
                                }
                                
                                NSLog(@"Decoded string = %@", decodedString);
                                
                                self->_subjectTextView.text= decodedString;
                            }
                            else{
                                
                                self->_subjectTextView.text= encodedString;
                                
                            }
                            
                        }
                        ///////////////////////////////////////////////////
                        //____________________________________________________________________________________________________
                        
                        
                        if([NSNull null] != [userData objectForKey:@"email"])
                        {
                           self->_emailTextField.text=[userData objectForKey:@"email"];
                        }else
                        {
                            self->_emailTextField.text=NSLocalizedString(@"Not Available",nil);
                        }
                        
                        
                        if([NSNull null] != [ticketDict objectForKey:@"updated_at"])
                        {
                            self->_lastResponseDateTextField.text=[self->utils getLocalDateTimeFromUTC:[ticketDict objectForKey:@"updated_at"]];
                        }else
                        {
                            self->_lastResponseDateTextField.text=NSLocalizedString(@"Not Available",nil);
                        }
                        
                       
            
                        
                
                        if (([[ticketDict objectForKey:@"type_name"] isEqual:[NSNull null]] ) || ( [[ticketDict objectForKey:@"type_name"] length] == 0 )) {
                            self->_typeTextField.text= NSLocalizedString(@"Not Available",nil);
                        }else self->_typeTextField.text=[ticketDict objectForKey:@"type_name"];
                        
                        if (([[ticketDict objectForKey:@"helptopic_name"] isEqual:[NSNull null]] ) || ( [[ticketDict objectForKey:@"helptopic_name"] length] == 0 )) {
                            self->_helpTopicTextField.text=NSLocalizedString(@"Not Available",nil);
                            
                        }else self->_helpTopicTextField.text=[ticketDict objectForKey:@"helptopic_name"];
                        
                        
                        if (([[ticketDict objectForKey:@"source_name"] isEqual:[NSNull null]] ) || ( [[ticketDict objectForKey:@"source_name"] length] == 0 )) {
                            self->_sourceTextField.text=NSLocalizedString(@"Not Available",nil);
                            
                        }else self->_sourceTextField.text=[ticketDict objectForKey:@"source_name"];
                        
                        if (([[ticketDict objectForKey:@"priority_name"] isEqual:[NSNull null]] ) || ( [[ticketDict objectForKey:@"priority_name"] length] == 0 )) {
                            self->_priorityTextField.text=NSLocalizedString(@"Not Available",nil);
                            
                        }else self->_priorityTextField.text=[ticketDict objectForKey:@"priority_name"];
                        
                       
                       
                        
                        if([NSNull null] != [ticketDict objectForKey:@"assignee"])
                        {
                          NSDictionary *assinee=[ticketDict objectForKey:@"assignee"];
                            
                            
                            if (([[assinee objectForKey:@"email"] isEqual:[NSNull null]] ) || ( [[assinee objectForKey:@"email"] length] == 0 )) {
                            
                                self->_assinTextField.text=NSLocalizedString(@"Not Available",nil);
                            }else{
                                NSString * name= [NSString stringWithFormat:@"%@ %@",[assinee objectForKey:@"first_name"],[assinee objectForKey:@"last_name"]];
                                
                                self->_assinTextField.text=name;
                            }
                            
                        }else
                        {
                            self->_assinTextField.text=NSLocalizedString(@"Not Available",nil);
                        }
                        
                    
                         if([NSNull null] != [ticketDict objectForKey:@"duedate"])
                         {
                             self->_dueDateTextField.text= [self->utils getLocalDateTimeFromUTCDueDate:[ticketDict objectForKey:@"duedate"]];
                         }else
                         {
                             self->_dueDateTextField.text=NSLocalizedString(@"Not Available",nil);
                         }
                      //  self->_dueDateTextField.text= [self->utils getLocalDateTimeFromUTC:[ticketDict objectForKey:@"duedate"]];
                        
                        
                        [self.refreshControl endRefreshing];
                        [self->_imgViewLoading setHidden:YES];
                        //[_activityIndicatorObject stopAnimating];
                        [self.tableView reloadData];
                        
                    });
                });
            }
            
            NSLog(@"Thread-NO5-getDetail-closed");
            
        }];
 }@catch (NSException *exception)
        {
            [utils showAlertWithMessage:exception.name sendViewController:self];
            NSLog( @"Name: %@", exception.name);
            NSLog( @"Reason: %@", exception.reason );
            return;
        }
        @finally
        {
            NSLog( @" I am in reload method in TicketDetailView ViewController" );
            
        }


    }
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return NO;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CAAnimation *)imageAnimationForEmptyDataSet{
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    animation.toValue = [NSValue valueWithCATransform3D: CATransform3DMakeRotation(M_PI_2, 0.0, 0.0, 1.0) ];
    animation.duration = 0.25;
    animation.cumulative = YES;
    animation.repeatCount = MAXFLOAT;
    
    return animation;
}

//This method the delegate if the specified text should be changed.
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    
    if(textField==_helpTopicTextField)
    {
        return NO;
    }
    
    if(textField==_typeTextField)
    {
        return NO;
    }
    
    if(textField==_priorityTextField)
    {
        return NO;
    }
    
    if(textField==_assinTextField)
    {
        return NO;
    }
    

    return YES;
}

@end
