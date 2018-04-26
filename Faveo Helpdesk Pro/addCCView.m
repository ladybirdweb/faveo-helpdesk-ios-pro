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
#import "userSearchDataCell.h"
#import "UIImageView+Letters.h"

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
    
    NSMutableArray *firstNameArray;
    NSMutableArray *uniquefirstNameArray;
    
    
    NSString * firstName;
    NSString * lastName;
    NSString *email;
    NSString *selectedUserEmail;
    // NSString *selectedUserId;
    
    NSNumber *user_id1;
    
    NSNumber *selectedUserId;
    NSString *selectedFirstName;
    
}
@end

@implementation addCCView

//This method is called after the view controller has loaded its view hierarchy into memory. This method is called regardless of whether the view hierarchy was loaded from a nib file or created programmatically in the loadView method.
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
    
    firstNameArray=[[NSMutableArray alloc]init];
    uniquefirstNameArray=[[NSMutableArray alloc]init];
    
    
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

// This method call the fetch collaborator associated with ticket, for getting count and number of cc list
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

// This method asks the delegate whether the specified text should be replaced in the text view.

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSLog(@"Data is : %@",_userSearchTextField.text);
    
    
    [self collaboratorApiMethod:_userSearchTextField.text];

    return YES;
}

// Add cc api is called here
-(void)collaboratorApiMethod:(NSString*)valueFromTextField
{
    
    if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable)
    {
        [RKDropdownAlert title:APP_NAME message:NO_INTERNET backgroundColor:[UIColor hx_colorWithHexRGBAString:FAILURE_COLOR] textColor:[UIColor whiteColor]];
        
    }else{
        
        NSString *searchString=[valueFromTextField stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        NSString *url =[NSString stringWithFormat:@"%@helpdesk/collaborator/search?token=%@&term=%@",[userDefaults objectForKey:@"companyURL"],[userDefaults objectForKey:@"token"],searchString];
      
    @try{
        MyWebservices *webservices=[MyWebservices sharedInstance];
        [webservices httpResponseGET:url parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
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
                    }else if([msg isEqualToString:@"Error-422"]){
                        
                        NSLog(@"Message is : %@",msg);
                    }else{
                        [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",msg] sendViewController:self];
                        NSLog(@"Error is11 : %@",msg);
                    }
                    
                }else if(error)  {
                    [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",error.localizedDescription] sendViewController:self];
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
                
                self->usersArray=[json objectForKey:@"users"];
                // NSIndexPath *indexpath;
                
                //  NSDictionary *userSearchDictionary=[usersArray objectAtIndex:indexpath.row];
                
                
                for (NSDictionary *dicc in self->usersArray) {
                    if ([dicc objectForKey:@"first_name"]) {
                        [self->userNameArray addObject:[dicc objectForKey:@"email"]];
                        [self->firstNameArray addObject:[NSString stringWithFormat:@"%@ %@",[dicc objectForKey:@"first_name"],[dicc objectForKey:@"last_name"]]];
                        //   [self->lastNameArray addObject:[dicc objectForKey:@"last_name"]];
                        [self->staff_idArray addObject:[dicc objectForKey:@"id"]];
                        [self->profilePicArray addObject:[dicc objectForKey:@"profile_pic"]];
                    }
                    
                }
                
                self->uniqueNameArray = [NSMutableArray array];
                
                for (id obj in self->userNameArray) {
                    if (![self->uniqueNameArray containsObject:obj]) {
                        [self->uniqueNameArray addObject:obj];
                    }
                }
                
                
                self->uniqueIdArray = [NSMutableArray array];
                
                for (id obj in self->staff_idArray) {
                    if (![self->uniqueIdArray containsObject:obj]) {
                        [self->uniqueIdArray addObject:obj];
                    }
                }
                
                self->UniqueprofilePicArray = [NSMutableArray array];
                
                for (id obj in self->profilePicArray) {
                    if (![self->UniqueprofilePicArray containsObject:obj]) {
                        [self->UniqueprofilePicArray addObject:obj];
                    }
                }
                //
                
                self->uniquefirstNameArray = [NSMutableArray array];
                
                for (id obj in self->firstNameArray) {
                    if (![self->uniquefirstNameArray containsObject:obj]) {
                        [self->uniquefirstNameArray addObject:obj];
                    }
                }
                
                
                NSLog(@"Names are : %@",self->uniqueNameArray);
                NSLog(@"Id are : %@",self->uniqueIdArray);
                NSLog(@"Profiles Names are : %@",self->uniquefirstNameArray);
                NSLog(@"Profiles IMages are : %@",self->UniqueprofilePicArray);
                
                
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
            NSLog( @" I am in Add CC method in CC ViewController" );
            
        }
    }
}



#pragma mark - UITextFieldAutoSuggestionDataSource

#pragma mark - UITextFieldAutoSuggestionDataSource

- (UITableViewCell *)autoSuggestionField:(UITextField *)field tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath forText:(NSString *)text {
    
    //    static NSString *cellIdentifier = @"MonthAutoSuggestionCell";
    //    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    //
    //    if (!cell) {
    //        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    //    }
    
    
    userSearchDataCell *cell=[tableView dequeueReusableCellWithIdentifier:@"userSearchDataCellId"];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"userSearchDataCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
 @try{
      NSArray *months = uniqueNameArray;
     //  NSArray *firstName=uniquefirstNameArray;
     // NSArray *image = UniqueprofilePicArray;
     
     
     if (text.length > 0) {
         NSPredicate *filterPredictate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@",text];
         months = [uniqueNameArray filteredArrayUsingPredicate:filterPredictate];
         //  firstName = [uniquefirstNameArray filteredArrayUsingPredicate:filterPredictate];
         //  image = [UniqueprofilePicArray filteredArrayUsingPredicate:filterPredictate];
     }
     
     //    cell.userNameLabel.text = firstName[indexPath.row];
     //    cell.emalLabel.text=months[indexPath.row];
     
     cell.userNameLabel.text = months[indexPath.row];
     cell.emalLabel.text=@"";
     
     // [cell setUserProfileimage:[image objectAtIndex:indexPath.row]];
     [cell.userProfileImage setImageWithString:months[indexPath.row] color:nil ];
    
   }@catch (NSException *exception)
    {
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        [utils showAlertWithMessage:exception.name sendViewController:self];
    }
    @finally
    {
        NSLog( @" I am in cell for row method in CC ViewController" );
        
    }
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
    return 65;
}


- (void)autoSuggestionField:(UITextField *)field tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath forText:(NSString *)text {
    // NSLog(@"Selected suggestion at index row - %ld", (long)indexPath.row);
    
    NSArray *months = userNameArray;
    
    if (text.length > 0) {
        NSPredicate *filterPredictate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", text];
        months = [uniqueNameArray filteredArrayUsingPredicate:filterPredictate];
    }
    
    _userSearchTextField.text =   months[indexPath.row];
    
    for (NSDictionary *dic in usersArray)
    {
        NSString *name  = dic[@"email"];
        
        if([name isEqual:_userSearchTextField.text])
        {
            selectedUserId= dic[@"id"];
            selectedUserEmail=dic[@"email"];
            selectedFirstName=dic[@"first_name"];
            
            NSLog(@"id is : %@",selectedUserId);
            NSLog(@"Name is : %@",selectedFirstName);
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
                           // [self.navigationController popViewControllerAnimated:YES];
                      
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
                        [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Entered value is not valid. Please select the proper email."] sendViewController:self];
                        
                    }
                    
                }
                else
                {
                    [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Something wen wrong. Please try again later."] sendViewController:self];
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


- (IBAction)viewCCButton:(id)sender {
}

- (IBAction)removeCCButton:(id)sender {
}
@end

