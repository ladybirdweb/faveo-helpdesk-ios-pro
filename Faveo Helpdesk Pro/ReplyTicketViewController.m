//
//  ReplyTicketViewController.m
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 06/03/18.
//  Copyright © 2018 Ladybird websolutions pvt ltd. All rights reserved.
//

#import "ReplyTicketViewController.h"
#import "AddRequester.h"
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
#import "addCCView.h"
#import "BIZPopupViewController.h"

@interface ReplyTicketViewController ()<UITextFieldDelegate>
{
    Utils *utils;
    NSUserDefaults *userDefaults;
    GlobalVariables *globalVariables;
    // NSString * count1;
    NSMutableArray *usersArray;
}
@end

@implementation ReplyTicketViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"Reply Ticket";
    self.tableview1.separatorColor=[UIColor clearColor];
    
    
    UIButton *done =  [UIButton buttonWithType:UIButtonTypeCustom];
    [done setImage:[UIImage imageNamed:@"doneButton"] forState:UIControlStateNormal];
    [done addTarget:self action:@selector(submitButton1) forControlEvents:UIControlEventTouchUpInside];
    [done setFrame:CGRectMake(44, 0, 32, 32)];
    
    UIView *rightBarButtonItems = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 76, 32)];
    // [rightBarButtonItems addSubview:addBtn];
    [rightBarButtonItems addSubview:done];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarButtonItems];
    
    globalVariables=[GlobalVariables sharedInstance];
    userDefaults=[NSUserDefaults standardUserDefaults];
    utils=[[Utils alloc]init];
    
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:false];
    
    _addCCLabelButton.userInteractionEnabled=YES;
    _viewCCandRemoveCCLabel.userInteractionEnabled=YES;
    
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickedOnCCSubButton)];
    _addCCLabelButton.userInteractionEnabled=YES;
    UITapGestureRecognizer *tapGesture2=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewCCorRemoceCCButton)];
    
    [_addCCLabelButton addGestureRecognizer:tapGesture];
    [_viewCCandRemoveCCLabel addGestureRecognizer:tapGesture2];
    
    
    if(globalVariables.ccCount==0)
    {
        _addCCLabelButton.text=@"Add cc";
    }else
    {
        _addCCLabelButton.text=[NSString stringWithFormat:@"Add cc (%@ Recipients)",globalVariables.ccCount];
    }
    
    UIToolbar *toolBar= [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    UIBarButtonItem *removeBtn=[[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStylePlain  target:self action:@selector(removeKeyBoard)];
    
    UIBarButtonItem *space=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [toolBar setItems:[NSArray arrayWithObjects:space,removeBtn, nil]];
    [self.messageTextView setInputAccessoryView:toolBar];
    
    _submitButton.backgroundColor=[UIColor hx_colorWithHexRGBAString:@"#00aeef"];
    
}

-(void)removeKeyBoard
{
    
    [_messageTextView resignFirstResponder];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self viewDidLoad];
    [self FetchCollaboratorAssociatedwithTicket];
    
    
    
}
-(void)clickedOnCCSubButton
{
    addCCView *cc1=[self.storyboard instantiateViewControllerWithIdentifier:@"addCCViewId"];
    [self.navigationController pushViewController:cc1 animated:YES];
    
}

-(void)viewCCorRemoceCCButton
{
    
    NSLog(@"Clicked");
          
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *smallViewController = [storyboard instantiateViewControllerWithIdentifier:@"SampleTableCellTableViewCellId"];
    
    BIZPopupViewController *popupViewController = [[BIZPopupViewController alloc] initWithContentViewController:smallViewController contentSize:CGSizeMake(250, 300)];
    [self presentViewController:popupViewController animated:NO completion:nil];
}
-(void)submitButton1
{
    NSLog(@"CLicked");
    [self ticketReplyMethodCalledHere];
    
}
- (IBAction)submitButtonClicked:(id)sender {
    
    if([_messageTextView.text isEqualToString:@""] || [_messageTextView.text length]==0)
    {
        [utils showAlertWithMessage:@"Enter the reply content.It can not be empty." sendViewController:self];
    }else
    {
       [self ticketReplyMethodCalledHere];
    }
}

-(void)ticketReplyMethodCalledHere
{
    if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable)
    {
        
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
        
        [[AppDelegate sharedAppdelegate] showProgressView];
        
        
        NSString *url=[NSString stringWithFormat:@"%@helpdesk/reply?api_key=%@&ip=%@&ticket_id=%@&reply_content=%@&token=%@",[userDefaults objectForKey:@"companyURL"],API_KEY,IP,globalVariables.iD,_messageTextView.text,[userDefaults objectForKey:@"token"]];
        
        
        NSLog(@"URL is : %@",url);
        @try{
            MyWebservices *webservices=[MyWebservices sharedInstance];
            
            [webservices httpResponsePOST:url parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
                
                
                
                [[AppDelegate sharedAppdelegate] hideProgressView];
                
                if (error || [msg containsString:@"Error"]) {
                    
                    if (msg) {
                        
                        [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",msg] sendViewController:self];
                        
                    }else if(error)  {
                        [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",error.localizedDescription] sendViewController:self];
                        NSLog(@"Thread-ticketReply-Refresh-error == %@",error.localizedDescription);
                    }
                    
                    return ;
                }
                
                if ([msg isEqualToString:@"tokenRefreshed"]) {
                    
                    [self ticketReplyMethodCalledHere];
                    NSLog(@"Thread-ticketReply");
                    return;
                }
                
                if (json) {
                    NSLog(@"JSON-Reply-Ticket-%@",json);
                    
                   // NSString * msg=[json objectForKey:@"message"];
                    NSString * successMsg=[NSString stringWithFormat:@"%@",[json objectForKey:@"success"]];
                    
                    if([successMsg isEqualToString:@"1"])
                    {
                        
                        [RKDropdownAlert title:NSLocalizedString(@"success", nil) message:NSLocalizedString(@"Posted your reply.", nil)backgroundColor:[UIColor hx_colorWithHexRGBAString:SUCCESS_COLOR] textColor:[UIColor whiteColor]];
                        
                         [[NSNotificationCenter defaultCenter] postNotificationName:@"reload_data" object:self];
                        
                        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
                        
                        
                        
                    }
                    else
                         if([successMsg isEqualToString:@"false"])
                       {
                        
                           [self->utils showAlertWithMessage:@"Enter the reply content.It can not be empty." sendViewController:self];
                      }
                }
                else
                {
                    [self->utils showAlertWithMessage:@"Something went wrong. Please try again." sendViewController:self];
                }
                NSLog(@"Thread-Ticket-Reply-closed");
                
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
            NSLog( @" I am in replatTicket method in TicketDetail ViewController" );
            
        }
        
        
    }
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)FetchCollaboratorAssociatedwithTicket
{
    if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable)
    {
        [RKDropdownAlert title:APP_NAME message:NO_INTERNET backgroundColor:[UIColor hx_colorWithHexRGBAString:FAILURE_COLOR] textColor:[UIColor whiteColor]];
        
    }else{
        
        NSString *url =[NSString stringWithFormat:@"%@helpdesk/collaborator/get-ticket?token=%@&ticket_id=%@&user_id=%@",[userDefaults objectForKey:@"companyURL"],[userDefaults objectForKey:@"token"],globalVariables.iD,globalVariables.userIdFromInbox];
        
        MyWebservices *webservices=[MyWebservices sharedInstance];
        
        [webservices httpResponsePOST:url parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
            [[AppDelegate sharedAppdelegate] hideProgressView];
            
            
            if (error || [msg containsString:@"Error"]) {
                
                if (msg) {
                    if([msg isEqualToString:@"Error-401"])
                    {
                        NSLog(@"Message is : %@",msg);
                        [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Access Denied.  Your credentials has been changed. Contact to Admin and try to login again."] sendViewController:self];
                    }
                    else
                        
                    if([msg isEqualToString:@"Error-403"])
                    {
                        [self->utils showAlertWithMessage:NSLocalizedString(@"Access Denied - You don't have permission.", nil) sendViewController:self];
                    }
                    else if([msg isEqualToString:@"Error-402"])
                    {
                        NSLog(@"Message is : %@",msg);
                        [self->utils showAlertWithMessage:[NSString stringWithFormat:@"API is disabled in web, please enable it from Admin panel."] sendViewController:self];
                    }else if([msg isEqualToString:@"Error-422"]){
                        
                        NSLog(@"Message is : %@",msg);
                    }else{
                        [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",msg] sendViewController:self];
                        NSLog(@"Error is11 : %@",msg);
                    }
                    
                }else if(error)  {
                    [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",error.localizedDescription] sendViewController:self];
                    NSLog(@"Thread-NO4-CollaboratorFetch-Refresh-error == %@",error.localizedDescription);
                }
                
                return ;
            }
            
            if ([msg isEqualToString:@"tokenRefreshed"]) {
                
                [self FetchCollaboratorAssociatedwithTicket];
                NSLog(@"Thread--NO4-call-CollaboratorFetch");
                return;
            }
            
            if (json) {
                NSLog(@"JSON-CollaboratorWithTicket-%@",json);
                //  NSDictionary * dict1=[json objectForKey:@"collaborator"];
                
                NSArray  * array1=[json objectForKey:@"collaborator"];
                self->globalVariables.ccCount=[NSString stringWithFormat:@"%lu",(unsigned long)array1.count];//array1.count;
                //NSLog(@"Array count is : %lu",(unsigned long)array1.count);
                NSLog(@"Array count is : %@",self->globalVariables.ccCount);
                [self viewDidLoad];
            }
            
        }];
    }
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    if(textView == _messageTextView)
    {
        
        if([text isEqualToString:@" "])
        {
            if(!textView.text.length)
            {
                return NO;
            }
        }
        
        if([textView.text stringByReplacingCharactersInRange:range withString:text].length < textView.text.length)
        {
            
            return  YES;
        }
        
        if([textView.text stringByReplacingCharactersInRange:range withString:text].length >500)
        {
            return NO;
        }
        
        NSCharacterSet *set=[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890,.1234567890!@#$^&*()--=+/?:;{}[]| "];
        
        
        if([text rangeOfCharacterFromSet:set].location == NSNotFound)
        {
            return NO;
        }
    }
    
    
    return YES;
}



@end

