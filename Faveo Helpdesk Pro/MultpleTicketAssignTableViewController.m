//
//  MultpleTicketAssignTableViewController.m
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 04/01/18.
//  Copyright © 2018 Ladybird websolutions pvt ltd. All rights reserved.
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
#import "MultpleTicketAssignTableViewController.h"

@interface MultpleTicketAssignTableViewController ()
{
    Utils *utils;
    NSUserDefaults *userDefaults;
    GlobalVariables *globalVariables;
    
    NSNumber *staff_id;
    NSNumber *source_id;
    NSMutableArray * staff_idArray;
}

@property (nonatomic, strong) NSMutableArray * staffArray;
@property (nonatomic, strong) NSMutableArray * assignArray;
- (void)staffWasSelected:(NSNumber *)selectedIndex element:(id)element;

@end

@implementation MultpleTicketAssignTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.separatorColor = [UIColor clearColor];
    
    
    staff_id=[[NSNumber alloc]init];
    
    //giving action to label
    _cancelLabel.userInteractionEnabled=YES;
    _assignLabel.userInteractionEnabled=YES;
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelButton)];
    UITapGestureRecognizer *tap2=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(assign)];
    
    [_cancelLabel addGestureRecognizer:tap];
    [_assignLabel addGestureRecognizer:tap2];
    
    utils=[[Utils alloc]init];
    globalVariables=[GlobalVariables sharedInstance];
    userDefaults=[NSUserDefaults standardUserDefaults];
    
  //  [self reload];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"< Back" style: UIBarButtonItemStylePlain target:self action:@selector(Back)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    [self readFromPlist];
    self.tableView.tableFooterView=[[UIView alloc] initWithFrame:CGRectZero];
}

-(void)Back
{
    globalVariables.backButtonActionFromMergeViewMenu=@"true";
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)readFromPlist{
    // Read plist from bundle and get Root Dictionary out of it
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"faveoData.plist"];
    
    
        if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath])
        {
            plistPath = [[NSBundle mainBundle] pathForResource:@"faveoData" ofType:@"plist"];
        }
        NSDictionary *resultDic = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        //    NSLog(@"resultDic--%@",resultDic);
    
        NSMutableArray *staffsArray=[resultDic objectForKey:@"staffs"];
    
        NSMutableArray *staffMU=[[NSMutableArray alloc]init];
        
        
        staff_idArray=[[NSMutableArray alloc]init];
        

        for (NSMutableDictionary *dicc in staffsArray) {
            if ([dicc objectForKey:@"email"]) {
                
                NSString * name= [NSString stringWithFormat:@"%@ %@",[dicc objectForKey:@"first_name"],[dicc objectForKey:@"last_name"]];
                
                // [staffMU insertObject:@"" atIndex:0]; // user_name
                //  [staffMU addObject:[dicc objectForKey:@"email"]];
                [Utils isEmpty:name];
                
                
                if  (![Utils isEmpty:name] )
                {
                    
                    [staffMU addObject:name];
                }
                else
                {
                    NSString * userName= [NSString stringWithFormat:@"%@",[dicc objectForKey:@"user_name"]];
                    [staffMU addObject:userName];
                }
                
                //  [staffMU addObject:name];
                [staff_idArray addObject:[dicc objectForKey:@"id"]];
                
            }
            
        } // end for loop
    
        _assignArray=[staffMU copy];
        

}



- (IBAction)selectAssignee:(id)sender {
    
    [self.view endEditing:YES];
    [_assinTextField resignFirstResponder];
    if (!_assignArray||!_assignArray.count) {
        _assinTextField.text=NSLocalizedString(@"Not Available",nil);
        source_id=0;
    }else{
        [ActionSheetStringPicker showPickerWithTitle:NSLocalizedString(@"Select Assignee",nil) rows:_assignArray initialSelection:0 target:self successAction:@selector(staffWasSelected:element:) cancelAction:@selector(actionPickerCancelled:) origin:sender];
    }
    
}

- (void)staffWasSelected:(NSNumber *)selectedIndex element:(id)element
{
    staff_id=(staff_idArray)[(NSUInteger) [selectedIndex intValue]];
    
    self.assinTextField.text = (_assignArray)[(NSUInteger) [selectedIndex intValue]];
    
}


- (void)actionPickerCancelled:(id)sender {
    NSLog(@"Delegate has been informed that ActionSheetPicker was cancelled");
}
-(void)cancelButton
{
    
    NSLog(@"Ckicked on cancel button");
    InboxViewController *vc=[self.storyboard instantiateViewControllerWithIdentifier:@"InboxID"];
    [self.navigationController pushViewController:vc animated:YES];
    
}

-(void)assign
{
    
    NSLog(@"clicked on Assign button");
    [[AppDelegate sharedAppdelegate] showProgressView];
    
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
        
    }else
    {
        
     //   NSString *url= [NSString stringWithFormat:@"%@api/v2/helpdesk/assign?api_key=%@&token=%@&id[]=%@&assign_id=%@",[userDefaults objectForKey:@"baseURL"],API_KEY,[userDefaults objectForKey:@"token”],array, _assinTextField.text];
        
        NSString *staffID= [NSString stringWithFormat:@"%@",staff_id];
        
        
        NSLog(@"stffId is : %@",staffID);
        NSLog(@"stffId is : %@",staffID);
        //int number = [string integerValue];
        if([staffID isEqualToString:@"(null)"] || [staffID isEqualToString:@""])
        {
            
            staffID=@"0";
            
        }
        
       
        
        
        NSString *url = [NSString stringWithFormat:@"%@api/v2/helpdesk/ticket/assign?api_key=%@&token=%@&assign_id=%@&id[]=%@",[userDefaults objectForKey:@"baseURL"],API_KEY,[userDefaults objectForKey:@"token"],staffID,globalVariables.ticketIDListForAssign];
        
         NSLog(@"URL is : %@",url);
        
        
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
                        NSLog(@"Message is : %@",msg);
                        [utils showAlertWithMessage:[NSString stringWithFormat:@"API is disabled in web, please enable it from Admin panel."] sendViewController:self];
                    }
                    else{
                        [utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",msg] sendViewController:self];
                    }
                    //  NSLog(@"Message is : %@",msg);
                    
                }else if(error)  {
                    [utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",error.localizedDescription] sendViewController:self];
                    NSLog(@"Thread-NO4-MultipleTicketAssign-Refresh-error == %@",error.localizedDescription);
                }
                
                return ;
            }
            
            if ([msg isEqualToString:@"tokenRefreshed"]) {
                
                [self assign];
                NSLog(@"Thread--NO4-call-MultipleTicketAssign");
                return;
            }
            
            if (json) {
                NSLog(@"JSON-CreateTicket-%@",json);
                
                NSString * str=[json objectForKey:@"success"];
                
                    if ([str isEqualToString:@"assigned successfully"])
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{

                            [RKDropdownAlert title: NSLocalizedString(@"success.", nil) message:NSLocalizedString(@"Assigned Successfully.", nil) backgroundColor:[UIColor hx_colorWithHexRGBAString:SUCCESS_COLOR] textColor:[UIColor whiteColor]];

                            InboxViewController *inboxVC=[self.storyboard instantiateViewControllerWithIdentifier:@"InboxID"];
                            [self.navigationController pushViewController:inboxVC animated:YES];

                        });

                    }else{
                        
                        [utils showAlertWithMessage:@"Something Went Wrong..!" sendViewController:self];
                        
                    }
            
            }// end if json
            
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

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:true];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





@end
