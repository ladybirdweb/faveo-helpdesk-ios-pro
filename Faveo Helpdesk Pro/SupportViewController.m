//
//  SupportViewController.m
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 27/02/18.
//  Copyright © 2018 Ladybird websolutions pvt ltd. All rights reserved.
//

#import "SupportViewController.h"
#import "RMessage.h"
#import "RMessageView.h"
#import "HexColors.h"
#import "Reachability.h"
#import "Dat.h"
#import "AppConstanst.h"
#import "MyWebservices.h"
#import "GlobalVariables.h"
#import "BDCustomAlertView.h"
#import "AppDelegate.h"
#import "Utils.h"
#import "HelpSectionHomePage.h"


@interface SupportViewController ()<UITextViewDelegate,RMessageProtocol>
{
    Utils *utils;
    NSUserDefaults *userDefaults;
    NSMutableArray *array1;
    NSDictionary *priDicc1;
    GlobalVariables *globalVariables;
}
@end

@implementation SupportViewController

//This method is called after the view controller has loaded its view hierarchy into memory. This method is called regardless of whether the view hierarchy was loaded from a nib file or created programmatically in the loadView method.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _emailTextView.text=@"support@ladybirdweb.com";
    
    globalVariables=[GlobalVariables sharedInstance];
    userDefaults=[NSUserDefaults standardUserDefaults];
    utils=[[Utils alloc]init];
    
    self.tableView1.separatorColor=[UIColor clearColor];
    UINavigationBar* navbar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    
    UINavigationItem* navItem = [[UINavigationItem alloc] initWithTitle:@""];
    // [navbar setBarTintColor:[UIColor lightGrayColor]];
    UIBarButtonItem* cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(onTapCancel:)];
    navItem.rightBarButtonItem = cancelBtn;
    //    UIBarButtonItem* doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onTapDone:)];
    //    navItem.rightBarButtonItem = doneBtn;
    
    [navbar setItems:@[navItem]];
    [self.view addSubview:navbar];
    
    
    
    UIToolbar *toolBar= [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    UIBarButtonItem *removeBtn=[[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStylePlain  target:self action:@selector(removeKeyBoard)];
    
    UIBarButtonItem *space=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [toolBar setItems:[NSArray arrayWithObjects:space,removeBtn, nil]];
    
    [self.subjectTextView setInputAccessoryView:toolBar];
    [self.messageTextView setInputAccessoryView:toolBar];
    
    _submitButton.backgroundColor=[UIColor hx_colorWithHexRGBAString:@"#00aeef"];
}


-(void)onTapCancel:(UIBarButtonItem*)item{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)removeKeyBoard
{
    
    [_subjectTextView resignFirstResponder];
    [_messageTextView resignFirstResponder];

}


// This method is called to validate the data enetered in textfields, it not fine then it will show error message else it calls the API.
- (IBAction)ButtonClicked:(id)sender {
    
    if(self.subjectTextView.text.length==0 && self.messageTextView.text.length==0)
    {
        
        [utils showAlertWithMessage:NSLocalizedString(@"Please fill all mandatory fields.", nil) sendViewController:self];
        
    }
    else if (self.subjectTextView.text.length==0){
        [utils showAlertWithMessage:NSLocalizedString(@"Please write the subject.", nil) sendViewController:self];
        
    }else if (self.messageTextView.text.length==0){
        
        [utils showAlertWithMessage:NSLocalizedString(@"Please enter the message details.", nil) sendViewController:self];
    
        
    } else if ((self.subjectTextView.text.length<5) && (self.messageTextView.text.length<5) ) {
        
        [utils showAlertWithMessage:NSLocalizedString(@"Enter more than 5 characters for Subject or Message.", nil) sendViewController:self];
        
    
        
    }else if ((self.subjectTextView.text.length>200) || (self.messageTextView.text.length>500) ) {
        
        [utils showAlertWithMessage:NSLocalizedString(@"You exceeded the character limits.", nil) sendViewController:self];
    
        
    }
    else
    {
        [self supportMethod];
    }
}

-(void)supportMethod
{
    if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable)
    {
        
        
        [[AppDelegate sharedAppdelegate] hideProgressView];
        
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
        
        NSString *string0=@"<br> </br>";
        NSString *string1=[NSString stringWithFormat:@"<br><b>From: </b>%@</br>",[userDefaults objectForKey:@"profile_name"]];
        NSString *string2=[NSString stringWithFormat:@"<br><b>Domain URL: </b>%@</br>",[userDefaults objectForKey:@"baseURL"]];
        
        NSString *finalString=[NSString stringWithFormat:@"%@\n%@\n%@\n\n%@",_messageTextView.text,string0,string1,string2];
        
        NSString *url =[NSString stringWithFormat:@"%@helpdesk/helpsection/mails?token=%@&help_email=%@&help_subject=%@&help_massage=%@",[userDefaults objectForKey:@"companyURL"],[userDefaults objectForKey:@"token"],_emailTextView.text,_subjectTextView.text,finalString];
        
    
        
        MyWebservices *webservices=[MyWebservices sharedInstance];
        
        [webservices httpResponsePOST:url parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
            [[AppDelegate sharedAppdelegate] hideProgressView];
            
            
            if (error || [msg containsString:@"Error"]) {
                
                if (msg) {
                    if([msg isEqualToString:@"Error-403"])
                    {
                        [self->utils showAlertWithMessage:NSLocalizedString(@"Access Denied - You don't have permission.", nil) sendViewController:self];
                    }
                    else if([msg isEqualToString:@"Error-402"])
                    {
                        NSLog(@"Message is : %@",msg);
                        [self->utils showAlertWithMessage:[NSString stringWithFormat:@"API is disabled in web, please enable it from Admin panel."] sendViewController:self];
                    }else{
                        [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",msg] sendViewController:self];
                        NSLog(@"Error is : %@",msg);
                    }
                    
                }else if(error)  {
                    [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",error.localizedDescription] sendViewController:self];
                    NSLog(@"Thread-NO4-HelpSupport-Refresh-error == %@",error.localizedDescription);
                }
                
                return ;
            }
            
            if ([msg isEqualToString:@"tokenRefreshed"]) {
                
                [self supportMethod];
                NSLog(@"Thread--NO4-call-HelpSupport");
                return;
            }
            
            if (json) {
                NSLog(@"JSON-HelpSupport-%@",json);
                
                NSString *resultMessage=[json objectForKey:@"message"];
                
                if([resultMessage isEqualToString:@"Message Sent! Thanks for reaching out! Someone from our team will get back to you soon."] || [resultMessage hasPrefix:@"Message Sent!"])
                {
                    NSLog(@"I am here..!");
                    
                    [self dismissViewControllerAnimated:YES completion:nil];
                    
                    if (self.navigationController.navigationBarHidden) {
                        [self.navigationController setNavigationBarHidden:NO];
                    }
                    
                    [RMessage showNotificationInViewController:self.navigationController
                                                         title:NSLocalizedString(@"Message Sent!", nil)
                                                      subtitle:NSLocalizedString(@"Thanks for reaching out! Someone from our team will get back to you soon.", nil)
                                                     iconImage:nil
                                                          type:RMessageTypeSuccess
                                                customTypeName:nil
                                                      duration:RMessageDurationAutomatic
                                                      callback:nil
                                                   buttonTitle:nil
                                                buttonCallback:nil
                                                    atPosition:RMessagePositionNavBarOverlay
                                          canBeDismissedByUser:YES];
                    
                }else
                {
                    NSLog(@"Nothing execute..!");
                }
                
            }
            
        }];
    }
    
}

//Asks the delegate if the specified text should be changed.
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{

    if(textView==_subjectTextView || textView==_messageTextView){

        //do not allow the first character to be space | do not allow more than one space
        if ([text isEqualToString:@" "]) {
            if (!textView.text.length)
                return NO;
        }
        // allow backspace
        if ([textView.text stringByReplacingCharactersInRange:range withString:text].length < textView.text.length) {
            return YES;
        }

        if (textView==_subjectTextView || textView==_messageTextView) {
            // limit the input to only the stuff in this character set, so no emoji or cirylic or any other insane characters

            //        // in case you need to limit the max number of characters
            if ([textView.text stringByReplacingCharactersInRange:range withString:text].length > 500) {
                return NO;
            }

            NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@" 1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ.?<>:[]{}-_=+*&%$#@!|"];

            if ([text rangeOfCharacterFromSet:set].location == NSNotFound) {
                return NO;
            }
        }
        
    }

    return YES;

}
@end

