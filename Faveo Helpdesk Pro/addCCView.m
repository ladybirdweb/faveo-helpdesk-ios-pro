//
//  addCCView.m
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 06/03/18.
//  Copyright © 2018 Ladybird websolutions pvt ltd. All rights reserved.
//

#import "addCCView.h"
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
#import "UITextField+AutoSuggestion.h"
#import "ReplyTicketViewController.h"

@interface addCCView ()<RMessageProtocol,UITextFieldDelegate,UITextFieldAutoSuggestionDataSource>
{
    Utils *utils;
    NSUserDefaults *userDefaults;
    GlobalVariables *globalVariables;
    
    NSMutableArray *usersArray;
    NSMutableArray *uniqueNameArray;
    NSMutableArray *uniqueIdArray;
    NSMutableArray *UniqueuserLastNameArray;
    
    NSMutableArray *userNameArray;
    NSMutableArray *userLastNameArray;
    NSMutableArray * staff_idArray;
    
    NSMutableArray *profilePicArray;
    NSMutableArray * UniqueprofilePicArray;
    
    
    NSString * firstName;
    NSString * lastName;
    NSString *email;
    NSString *selectedUserEmail;
    // NSString *selectedUserId;
    
    NSNumber *user_id1;
    
    NSNumber *selectedUserId;
    
}
@end

@implementation addCCView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    user_id1=[[NSNumber alloc]init];
    selectedUserId=[[NSNumber alloc]init];
    
    staff_idArray=[[NSMutableArray alloc]init];
    userNameArray=[[NSMutableArray alloc]init];
    
    userLastNameArray=[[NSMutableArray alloc]init];
    //UniqueuserLastNameArray
    uniqueNameArray=[[NSMutableArray alloc]init];
    UniqueuserLastNameArray=[[NSMutableArray alloc]init];
    uniqueIdArray=[[NSMutableArray alloc]init];
    
    profilePicArray=[[NSMutableArray alloc]init];
    UniqueprofilePicArray=[[NSMutableArray alloc]init];
    
    
    globalVariables=[GlobalVariables sharedInstance];
    userDefaults=[NSUserDefaults standardUserDefaults];
    utils=[[Utils alloc]init];
    
    self.tablview.separatorColor=[UIColor clearColor];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:false];
    
    self.userSearchTextField.delegate = self;
    self.userSearchTextField.autoSuggestionDataSource = self;
    self.userSearchTextField.fieldIdentifier =@"oneId";
    self.userSearchTextField.showImmediately = true;
    [self.userSearchTextField observeTextFieldChanges];
    //
    //dismissing view
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    [self getCCCount];
    
    UIToolbar *toolBar= [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    UIBarButtonItem *removeBtn=[[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStylePlain  target:self action:@selector(removeKeyBoard)];
    
    UIBarButtonItem *space=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [toolBar setItems:[NSArray arrayWithObjects:space,removeBtn, nil]];
    [self.userSearchTextField setInputAccessoryView:toolBar];
    
    _addButton.backgroundColor=[UIColor hx_colorWithHexRGBAString:@"#00aeef"];
    
}
-(void)removeKeyBoard
{
    [_userSearchTextField resignFirstResponder];
}
-(void)getCCCount
{
    
    ReplyTicketViewController * rply=[[ReplyTicketViewController alloc]init];
    [rply FetchCollaboratorAssociatedwithTicket];
    
}

-(void)dismissKeyboard
{
    [_userSearchTextField resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSLog(@"Data is : %@",_userSearchTextField.text);
    [self collaboratorApiMethod:_userSearchTextField.text];
    return YES;
}


-(void)collaboratorApiMethod:(NSString*)valueFromTextField
{
    
    if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable)
    {
        [RKDropdownAlert title:APP_NAME message:NO_INTERNET backgroundColor:[UIColor hx_colorWithHexRGBAString:FAILURE_COLOR] textColor:[UIColor whiteColor]];
        
    }else{
    
        
        NSString *url =[NSString stringWithFormat:@"%@helpdesk/collaborator/search?token=%@&term=%@",[userDefaults objectForKey:@"companyURL"],[userDefaults objectForKey:@"token"],valueFromTextField];
        
        MyWebservices *webservices=[MyWebservices sharedInstance];
        [webservices httpResponseGET:url parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
            [[AppDelegate sharedAppdelegate] hideProgressView];
            
            
            if (error || [msg containsString:@"Error"]) {
                
                if (msg) {
                    if([msg isEqualToString:@"Error-403"])
                    {
                        [utils showAlertWithMessage:NSLocalizedString(@"Access Denied - You don't have permission.", nil) sendViewController:self];
                    }
                    else if([msg isEqualToString:@"Error-402"])
                    {
                        NSLog(@"Message is : %@",msg);
                        [utils showAlertWithMessage:[NSString stringWithFormat:@"API is disabled in web, please enable it from Admin panel."] sendViewController:self];
                    }else if([msg isEqualToString:@"Error-422"]){
                        
                        NSLog(@"Message is : %@",msg);
                    }else{
                        [utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",msg] sendViewController:self];
                        NSLog(@"Error is11 : %@",msg);
                    }
                    
                }else if(error)  {
                    [utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",error.localizedDescription] sendViewController:self];
                    NSLog(@"Thread-NO4-Collaborator-Refresh-error == %@",error.localizedDescription);
                }
                
                return ;
            }
            
            if ([msg isEqualToString:@"tokenRefreshed"]) {
                
                [self collaboratorApiMethod:valueFromTextField];
                NSLog(@"Thread--NO4-call-Collaborator");
                return;
            }
            
            if (json) {
                NSLog(@"JSON-HelpSupport-%@",json);
                //   NSLog(@"JSON-HelpSupport-%@",json);
                
                usersArray=[json objectForKey:@"users"];
                // NSIndexPath *indexpath;
                
                //  NSDictionary *userSearchDictionary=[usersArray objectAtIndex:indexpath.row];
                
                
                
                for (NSDictionary *dicc in usersArray) {
                    if ([dicc objectForKey:@"first_name"]) {
                        [userNameArray addObject:[dicc objectForKey:@"email"]];
                        //  [userLastNameArray addObject:[dicc objectForKey:@"last_name"]];
                        [staff_idArray addObject:[dicc objectForKey:@"id"]];
                        [profilePicArray addObject:[dicc objectForKey:@"profile_pic"]];
                    }
                    
                }
                
                uniqueNameArray = [NSMutableArray array];
                
                for (id obj in userNameArray) {
                    if (![uniqueNameArray containsObject:obj]) {
                        [uniqueNameArray addObject:obj];
                    }
                }
                
                
                uniqueIdArray = [NSMutableArray array];
                
                for (id obj in staff_idArray) {
                    if (![uniqueIdArray containsObject:obj]) {
                        [uniqueIdArray addObject:obj];
                    }
                }
                
                UniqueprofilePicArray = [NSMutableArray array];
                
                for (id obj in profilePicArray) {
                    if (![UniqueprofilePicArray containsObject:obj]) {
                        [UniqueprofilePicArray addObject:obj];
                    }
                }
                
                
                NSLog(@"Names are : %@",uniqueNameArray);
                NSLog(@"Id are : %@",uniqueIdArray);
                
                
            }
            
        }];
    }
    
}



#pragma mark - UITextFieldAutoSuggestionDataSource

- (UITableViewCell *)autoSuggestionField:(UITextField *)field tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath forText:(NSString *)text {
    
    static NSString *cellIdentifier = @"MonthAutoSuggestionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSArray *months = uniqueNameArray;
    //    NSArray *image = UniqueprofilePicArray;
    
    
    if (text.length > 0) {
        NSPredicate *filterPredictate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", text];
        months = [uniqueNameArray filteredArrayUsingPredicate:filterPredictate];
    }
    
    cell.textLabel.text = months[indexPath.row];
    //cell.imageView.image = [UIImage imageNamed:[image objectAtIndex:indexPath.row]];
    
    
    
    
    // NSLog(@"id is : %@",staff_idArray[indexPath.row ]);
    
    return cell;
    
}

- (NSInteger)autoSuggestionField:(UITextField *)field tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section forText:(NSString *)text {
    
    if (text.length == 0) {
        return uniqueNameArray.count;
    }
    
    NSPredicate *filterPredictate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", text];
    NSInteger count = [uniqueNameArray filteredArrayUsingPredicate:filterPredictate].count;
    return count;
    
}


- (CGFloat)autoSuggestionField:(UITextField *)field tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath forText:(NSString *)text {
    return 50;
}


- (void)autoSuggestionField:(UITextField *)field tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath forText:(NSString *)text {
    // NSLog(@"Selected suggestion at index row - %ld", (long)indexPath.row);
    
    NSArray *months = userNameArray;
    
    if (text.length > 0) {
        NSPredicate *filterPredictate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", text];
        months = [uniqueNameArray filteredArrayUsingPredicate:filterPredictate];
    }
    
    self.userSearchTextField.text =   months[indexPath.row];
    
    for (NSDictionary *dic in usersArray)
    {
        NSString *name  = dic[@"email"];
        
        if([name isEqual:_userSearchTextField.text])
        {
            selectedUserId= dic[@"id"];
            selectedUserEmail=dic[@"email"];
            
            NSLog(@"id is : %@",selectedUserId);
            NSLog(@"Email is : %@",selectedUserEmail);
            
        }
    }
    
}


- (IBAction)addCCMethod:(id)sender {
    [self add];
}

-(void)add
{
    
    if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable)
    {
        [RKDropdownAlert title:APP_NAME message:NO_INTERNET backgroundColor:[UIColor hx_colorWithHexRGBAString:FAILURE_COLOR] textColor:[UIColor whiteColor]];
        
    }else{
        
        NSString *url =[NSString stringWithFormat:@"%@helpdesk/collaborator/create?token=%@&ticket_id=%@&email=%@&user_id=%@",[userDefaults objectForKey:@"companyURL"],[userDefaults objectForKey:@"token"],globalVariables.iD,selectedUserEmail,selectedUserId];
        
        MyWebservices *webservices=[MyWebservices sharedInstance];
        
        [webservices httpResponsePOST:url parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
            [[AppDelegate sharedAppdelegate] hideProgressView];
            
            
            if (error || [msg containsString:@"Error"]) {
                
                if (msg) {
                    if([msg isEqualToString:@"Error-403"])
                    {
                        [utils showAlertWithMessage:NSLocalizedString(@"Access Denied - You don't have permission.", nil) sendViewController:self];
                    }
                    else if([msg isEqualToString:@"Error-402"])
                    {
                        NSLog(@"Message is : %@",msg);
                        [utils showAlertWithMessage:[NSString stringWithFormat:@"API is disabled in web, please enable it from Admin panel."] sendViewController:self];
                    }else if([msg isEqualToString:@"Error-422"]){
                        
                        NSLog(@"Message is : %@",msg);
                    }else{
                        [utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",msg] sendViewController:self];
                        NSLog(@"Error is11 : %@",msg);
                    }
                    
                }else if(error)  {
                    [utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",error.localizedDescription] sendViewController:self];
                    NSLog(@"Thread-NO4-Collaborator-Refresh-error == %@",error.localizedDescription);
                }
                
                return ;
            }
            
            if ([msg isEqualToString:@"tokenRefreshed"]) {
                
                [self add];
                NSLog(@"Thread--NO4-call-Collaborator");
                return;
            }
            
            if (json) {
                NSLog(@"JSON-HelpSupport-%@",json);
                
                // NSObject *obj=[json objectForKey:@"collaborator"];
                
                
                if([[json objectForKey:@"collaborator"] isKindOfClass:[NSDictionary class]])
                {
                    
                    for (UIViewController *controller in self.navigationController.viewControllers)
                    {
                        //Do not forget to import AnOldViewController.h
                        if ([controller isKindOfClass:[ReplyTicketViewController class]])
                        {
                            [self getCCCount];
                            [self.navigationController popToViewController:controller animated:YES];
                            
                            [RKDropdownAlert title:@"Success" message:@"Added cc Successfully" backgroundColor:[UIColor hx_colorWithHexRGBAString:SUCCESS_COLOR] textColor:[UIColor whiteColor]];
                            
                            return;
                        }
                    }
                    
                    
                    
                }else if([[json objectForKey:@"error"] isKindOfClass:[NSDictionary class]])
                {
                    
                    NSDictionary * dict=[json objectForKey:@"error"];
                    NSObject *obj=[dict objectForKey:@"user_id"];
                    
                    if([obj isKindOfClass:[NSArray class]])
                    {
                        [utils showAlertWithMessage:[NSString stringWithFormat:@"Entered value is not valid. Please select the proper email."] sendViewController:self];
                        
                    }
                    
                }
                else
                {
                    [utils showAlertWithMessage:[NSString stringWithFormat:@"Something wen wrong. Please try again later."] sendViewController:self];
                }
            }
            
        }];
    }
    
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return true;
}


@end

