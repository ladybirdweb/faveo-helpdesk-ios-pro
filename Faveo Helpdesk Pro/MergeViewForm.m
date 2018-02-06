//
//  MergeViewForm.m
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 08/12/17.
//  Copyright © 2017 Ladybird websolutions pvt ltd. All rights reserved.
//

#import "Dat.h"
#import "RMessage.h"
#import "RMessageView.h"
#import "AddRequester.h"
#import "GlobalVariables.h"
#import "BDCustomAlertView.h"
#import "IQKeyboardManager.h"
#import "MergeViewForm.h"
#import "Utils.h"
#import "Reachability.h"
#import "HexColors.h"
#import "InboxViewController.h"
#import "ActionSheetStringPicker.h"
#import "Reachability.h"
#import "AppConstanst.h"
#import "MyWebservices.h"
#import "AppDelegate.h"
#import "RKDropdownAlert.h"

@interface MergeViewForm ()
{
    
    Utils *utils;
    NSUserDefaults *userDefaults;
    GlobalVariables *globalVariables;
    
     NSNumber *subject_id;
     NSMutableArray * subject_idArray;
     NSString *filteredID;
    NSString *concatnateNewString;
}

@property (nonatomic, strong) NSMutableArray * SubjectArray1;
- (void)SubjectWasSelected:(NSNumber *)selectedIndex element:(id)element;
- (void)actionPickerCancelled:(id)sender;

@end

@implementation MergeViewForm

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title=NSLocalizedString(@"Merge Tickets",nil);
    self.tableView.separatorColor = [UIColor clearColor];
    
     subject_id =[[NSNumber alloc]init];
     subject_idArray=[[NSMutableArray alloc]init];
    
    utils=[[Utils alloc]init];
    globalVariables=[GlobalVariables sharedInstance];
    userDefaults=[NSUserDefaults standardUserDefaults];
    
    UIToolbar *toolBar= [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    UIBarButtonItem *removeBtn=[[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStylePlain  target:self action:@selector(removeKeyBoard)];
    
    UIBarButtonItem *space=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [toolBar setItems:[NSArray arrayWithObjects:space,removeBtn, nil]];
    [self.newtitleTextview setInputAccessoryView:toolBar];
    [self.reasonTextView setInputAccessoryView:toolBar];
   // [self.parentTicketTextField setInputAccessoryView:toolBar];
    
    //giving action to label
    _cancelLabel.userInteractionEnabled=YES;
    _mergeLabel.userInteractionEnabled=YES;
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelButton)];
    UITapGestureRecognizer *tap2=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mergeButton)];
    
    [_cancelLabel addGestureRecognizer:tap];
    [_mergeLabel addGestureRecognizer:tap2];
    
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"< Back" style: UIBarButtonItemStylePlain target:self action:@selector(Back)];
    self.navigationItem.leftBarButtonItem = backButton;
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:true];
}


- (IBAction)SelectParentTicket:(id)sender {
    
    // [self.view endEditing:YES];
    [ActionSheetStringPicker showPickerWithTitle:NSLocalizedString(@"Select Parent Ticket",nil) rows:globalVariables.subjectList initialSelection:0 target:self successAction:@selector(SubjectWasSelected:element:) cancelAction:@selector(actionPickerCancelled:) origin:sender];

}

- (void)actionPickerCancelled:(id)sender {
    NSLog(@"Delegate has been informed that ActionSheetPicker was cancelled");
}


- (void)SubjectWasSelected:(NSNumber *)selectedIndex element:(id)element
{
    subject_id=(globalVariables.idList)[(NSUInteger) [selectedIndex intValue]];
    self.parentTicketTextField.text = (globalVariables.subjectList)[(NSUInteger) [selectedIndex intValue]];
    
    NSLog(@"List of id is :%@",globalVariables.idList);
    NSLog(@"Subject_id issss :%@",subject_id);
    NSLog(@"Selectd value in textfiled is : %@",_parentTicketTextField.text);
    
    
    
}


-(void)Back
{
    globalVariables.backButtonActionFromMergeViewMenu=@"true";
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)removeKeyBoard{
    [_newtitleTextview resignFirstResponder];
    [_reasonTextView resignFirstResponder];
}


-(void)cancelButton
{
    NSLog(@"Ckicked on cancel button");
    InboxViewController *vc=[self.storyboard instantiateViewControllerWithIdentifier:@"InboxID"];
    [self.navigationController pushViewController:vc animated:YES];
    
}
-(void)mergeButton
{
    [[AppDelegate sharedAppdelegate] showProgressView];
    NSLog(@"Ckicked on merge button");
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
         [[AppDelegate sharedAppdelegate] hideProgressView];
        
    }else if([_parentTicketTextField.text length] == 0 || [_parentTicketTextField.text isEqualToString:@""])
    {
        
        if (self.navigationController.navigationBarHidden) {
            [self.navigationController setNavigationBarHidden:NO];
        }
        
        [RMessage showNotificationInViewController:self.navigationController
                                             title:NSLocalizedString(@"Warning !", nil)
                                          subtitle:NSLocalizedString(@"Please Select The Parent Ticket.", nil)
                                         iconImage:nil
                                              type:RMessageTypeWarning
                                    customTypeName:nil
                                          duration:RMessageDurationAutomatic
                                          callback:nil
                                       buttonTitle:nil
                                    buttonCallback:nil
                                        atPosition:RMessagePositionNavBarOverlay
                              canBeDismissedByUser:YES];
        
         [[AppDelegate sharedAppdelegate] hideProgressView];
        
    }else  {
        
        // reomving parenmt id from array
        for(id item in globalVariables.idList) {
            if([item isEqual:subject_id]) {
                [globalVariables.idList removeObject:item];
                NSLog(@"New Array is: %@",globalVariables.idList);
                
                filteredID = [globalVariables.idList componentsJoinedByString:@","];
                
                 NSLog(@"New Array 111 is: %@",filteredID);
                
                break;
            }
        }
        
       
    //    NSString * str=@"[]=";
        
    //    filteredID= [str stringByAppendingString:filteredID];

        
      NSString *url= [NSString stringWithFormat:@"%@api/v2/helpdesk/merge?api_key=%@&token=%@&p_id=%@&t_id[]=%@&title=%@&reason=%@",[userDefaults objectForKey:@"baseURL"],API_KEY,[userDefaults objectForKey:@"token"],subject_id,filteredID,_newtitleTextview.text,_reasonTextView.text];
        
        NSLog(@"Url is : %@",url);
     //   NSLog(@"Url is : %@",url);
        
        MyWebservices *webservices=[MyWebservices sharedInstance];
        
        [webservices httpResponsePOST:url parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
            [[AppDelegate sharedAppdelegate] hideProgressView];
            
            if (error || [msg containsString:@"Error"]) {
                
                if (msg) {
                    if([msg isEqualToString:@"Error-403"])
                    {
                        [utils showAlertWithMessage:NSLocalizedString(@"Access Denied - You don't have permission.", nil) sendViewController:self];
                        [[AppDelegate sharedAppdelegate] hideProgressView];
                    }
                    else if([msg isEqualToString:@"Error-402"])
                    {
                        [utils showAlertWithMessage:NSLocalizedString(@"Your account credentials were changed, contact to Admin and please log back in.", nil) sendViewController:self];
                        
                    }
                    else{
                        [utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",msg] sendViewController:self];
                        NSLog(@"Error is : %@",msg);
                        [[AppDelegate sharedAppdelegate] hideProgressView];
                    }
                    
                }else if(error)  {
                    [utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",error.localizedDescription] sendViewController:self];
                    NSLog(@"Thread-NO4-postMerge-Refresh-error == %@",error.localizedDescription);
                    [[AppDelegate sharedAppdelegate] hideProgressView];
                }
                
                return ;
            }
            
            if ([msg isEqualToString:@"tokenRefreshed"]) {
                
                [self mergeButton];
                NSLog(@"Thread--NO4-call-postMerge");
                return;
            }
            
            
            if (json) {
                NSLog(@"JSON-Merge-Function%@",json);
               
                NSDictionary *dict1= [json objectForKey:@"response"];
                NSString *msg= [dict1 objectForKey:@"message"];
                
                    dispatch_async(dispatch_get_main_queue(), ^{
           
                        if([msg isEqualToString:@"merged successfully"])
                            
                        {
                            [RKDropdownAlert title: NSLocalizedString(@"success.", nil) message:NSLocalizedString(@"Merged Successfully.", nil) backgroundColor:[UIColor hx_colorWithHexRGBAString:SUCCESS_COLOR] textColor:[UIColor whiteColor]];
                        
                          InboxViewController *create=[self.storyboard instantiateViewControllerWithIdentifier:@"InboxID"];
                            [self.navigationController pushViewController:create animated:YES];
                        }else
                        if([msg isEqualToString:@"tickets from different users"])
                        {
                            
                        
                            [RMessage showNotificationInViewController:self.navigationController
                                                                 title:NSLocalizedString(@"Alert !", nil)
                                                              subtitle:NSLocalizedString(@"Tickets from different users.", nil)
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
                        else
                        {
                            NSDictionary *dict1= [json objectForKey:@"response"];
                            NSDictionary *dict2= [dict1 objectForKey:@"message"];
                            NSString * str = [dict2 objectForKey:@"message"];
                            if([str isEqualToString:@"tickets from different users"])
                            {
                                [RMessage showNotificationInViewController:self.navigationController
                                                                     title:NSLocalizedString(@"Alert !", nil)
                                                                  subtitle:NSLocalizedString(@"Tickets from different users.", nil)
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
                            else
                            {
                               [utils showAlertWithMessage:@"Error..!" sendViewController:self];
                                
                            }
                        }
                        
                    });
                    
                    
            }
            NSLog(@"Thread-NO5-postMerge-closed");
            
        }];
    }
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

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    if(textView == _newtitleTextview ||textView == _reasonTextView )
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
        
        if([textView.text stringByReplacingCharactersInRange:range withString:text].length >100)
        {
            return NO;
        }
        
        NSCharacterSet *set=[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890\".,?()+=*&^%$#@!<>}{[]| "];
        
        
        if([text rangeOfCharacterFromSet:set].location == NSNotFound)
        {
            return NO;
        }
    }
    
    
    return YES;
}





@end
