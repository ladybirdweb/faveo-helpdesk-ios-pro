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

//This method is called after the view controller has loaded its view hierarchy into memory. This method is called regardless of whether the view hierarchy was loaded from a nib file or created programmatically in the loadView method.
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
    
    _cancelLabel.backgroundColor=[UIColor hx_colorWithHexRGBAString:@"#00aeef"];
    _mergeLabel.backgroundColor=[UIColor hx_colorWithHexRGBAString:@"#00aeef"];

    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"< Back" style: UIBarButtonItemStylePlain target:self action:@selector(Back)];
    self.navigationItem.leftBarButtonItem = backButton;
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:true];
}

// Using this picker, we can select the parent ticket
- (IBAction)SelectParentTicket:(id)sender {
    
    // [self.view endEditing:YES];
    [ActionSheetStringPicker showPickerWithTitle:NSLocalizedString(@"Select Parent Ticket",nil) rows:globalVariables.subjectList initialSelection:0 target:self successAction:@selector(SubjectWasSelected:element:) cancelAction:@selector(actionPickerCancelled:) origin:sender];

}

// This is action called when picker view cancelled
- (void)actionPickerCancelled:(id)sender {
    NSLog(@"Delegate has been informed that ActionSheetPicker was cancelled");
}

//This method used to select the subejct
- (void)SubjectWasSelected:(NSNumber *)selectedIndex element:(id)element
{
    subject_id=(globalVariables.idList)[(NSUInteger) [selectedIndex intValue]];
    self.parentTicketTextField.text = (globalVariables.subjectList)[(NSUInteger) [selectedIndex intValue]];
    
    NSLog(@"List of id is :%@",globalVariables.idList);
    NSLog(@"Subject_id issss :%@",subject_id);
    NSLog(@"Selectd value in textfiled is : %@",_parentTicketTextField.text);
    
    
    
}

// Added naviagtion button on left side of view.
-(void)Back
{
    globalVariables.backButtonActionFromMergeViewMenu=@"true";
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)removeKeyBoard{
    [_newtitleTextview resignFirstResponder];
    [_reasonTextView resignFirstResponder];
}

// After clicking this cancel button, it will redirect back to inbox page.
-(void)cancelButton
{
    NSLog(@"Ckicked on cancel button");
    InboxViewController *vc=[self.storyboard instantiateViewControllerWithIdentifier:@"InboxID"];
    [self.navigationController pushViewController:vc animated:YES];
    
}

// This is the main method, after selecting all values which are required to merge the tickets. AFter clicking on merge button, it will call an merge API and gives an JSON.
-(void)mergeButton
{
    [[AppDelegate sharedAppdelegate] showProgressView];
    NSLog(@"Ckicked on merge button");
   
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
  
    
@try{
        MyWebservices *webservices=[MyWebservices sharedInstance];
        
        [webservices httpResponsePOST:url parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
            
            if (error || [msg containsString:@"Error"]) {
                
                if (msg) {
                    
                    if([msg isEqualToString:@"Error-401"])
                    {
                        NSLog(@"Message is : %@",msg);
                        [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Access Denied.  Your credentials has been changed. Contact to Admin and try to login again."] sendViewController:self];
                        [[AppDelegate sharedAppdelegate] hideProgressView];
                    }
                    else
                        
                    if([msg isEqualToString:@"Error-403"])
                    {
                        [self->utils showAlertWithMessage:NSLocalizedString(@"Access Denied - You don't have permission.", nil) sendViewController:self];
                        [[AppDelegate sharedAppdelegate] hideProgressView];
                    }
                    else if([msg isEqualToString:@"Error-402"])
                    {
                        [self->utils showAlertWithMessage:NSLocalizedString(@"Your account credentials were changed, contact to Admin and please log back in.", nil) sendViewController:self];
                        [[AppDelegate sharedAppdelegate] hideProgressView];
                        
                    }
                    else if([msg isEqualToString:@"Error-422"])
                    {
                        NSLog(@"Message is : %@",msg);
                        [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Unprocessable Entity. Please try again later."] sendViewController:self];
                        [[AppDelegate sharedAppdelegate] hideProgressView];
                    }
                    else if([msg isEqualToString:@"Error-404"])
                    {
                        NSLog(@"Message is : %@",msg);
                        [self->utils showAlertWithMessage:[NSString stringWithFormat:@"The requested URL was not found on this server."] sendViewController:self];
                        [[AppDelegate sharedAppdelegate] hideProgressView];
                    }
                    else if([msg isEqualToString:@"Error-405"] ||[msg isEqualToString:@"405"])
                    {
                        NSLog(@"Message is : %@",msg);
                            [self->utils showAlertWithMessage:[NSString stringWithFormat:@"The requested URL was not found on this server."] sendViewController:self];
                        [[AppDelegate sharedAppdelegate] hideProgressView];
                    }
                    else if([msg isEqualToString:@"Error-500"] ||[msg isEqualToString:@"500"])
                    {
                        NSLog(@"Message is : %@",msg);
                        [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Internal Server Error.Something has gone wrong on the website's server."] sendViewController:self];
                        [[AppDelegate sharedAppdelegate] hideProgressView];
                    }
                    else if([msg isEqualToString:@"Error-400"] ||[msg isEqualToString:@"400"])
                    {
                        NSLog(@"Message is : %@",msg);
                        [self->utils showAlertWithMessage:[NSString stringWithFormat:@"The request could not be understood by the server due to malformed syntax."] sendViewController:self];
                        [[AppDelegate sharedAppdelegate] hideProgressView];
                    }
                    
                    else{
                        [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",msg] sendViewController:self];
                        NSLog(@"Error is : %@",msg);
                        [[AppDelegate sharedAppdelegate] hideProgressView];
                    }
                    
                }else if(error)  {
                    [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",error.localizedDescription] sendViewController:self];
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
                
                NSObject * response1=[dict1 objectForKey:@"message"];
               
                //checking response is king of dictionary
                if([response1 isKindOfClass:[NSDictionary class]])
                {
                    NSDictionary *dict1= [json objectForKey:@"response"];
                    
                    NSDictionary * dict2=[dict1 objectForKey:@"message"];
                    NSString *str=[dict2 objectForKey:@"message"];
                    
                    if([str isEqualToString:@"tickets from different users"])
                    {
                        [self->utils showAlertWithMessage:@"You can't merge these tickets because tickets from different users" sendViewController:self];
                        [[AppDelegate sharedAppdelegate] hideProgressView];
                    }
                    else
                    {
                         [self->utils showAlertWithMessage:@"Something went wrong...!" sendViewController:self];
                        [[AppDelegate sharedAppdelegate] hideProgressView];
                    }
                }
                else{
                    
                    NSDictionary *dict1= [json objectForKey:@"response"];
                    
                    NSString * response1=[dict1 objectForKey:@"message"];
                    NSString * msg=@"merged successfully";
                    
                     [[AppDelegate sharedAppdelegate] showProgressView];
                        if([response1 isEqualToString: msg])
                        {
                            [RKDropdownAlert title: NSLocalizedString(@"success.", nil) message:NSLocalizedString(@"Merged Successfully.", nil) backgroundColor:[UIColor hx_colorWithHexRGBAString:SUCCESS_COLOR] textColor:[UIColor whiteColor]];
                            
                            InboxViewController *create=[self.storyboard instantiateViewControllerWithIdentifier:@"InboxID"];
                            [self.navigationController pushViewController:create animated:YES];
                        }else
                        {
                            [self->utils showAlertWithMessage:@"Something went wrong...!" sendViewController:self];
                            [[AppDelegate sharedAppdelegate] hideProgressView];
                        }
                        
                    
                    
                }
            }
            NSLog(@"Thread-NO5-postMerge-closed");
             [[AppDelegate sharedAppdelegate] hideProgressView];
            
        }];
}@catch (NSException *exception)
        {
            NSLog( @"Name: %@", exception.name);
            NSLog( @"Reason: %@", exception.reason );
             [utils showAlertWithMessage:exception.name sendViewController:self];
            [[AppDelegate sharedAppdelegate] hideProgressView];
            return;
        }
        @finally
        {
            NSLog( @" I am in mergeButton method in MergeViewForm ViewController" );
            
        }
        
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

// This method used to control on giving input values in textfield or textviews
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
