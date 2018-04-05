//
//  SampleTable.m
//  Example
//
//  Created by Mallikarjun on 12/03/18.
//  Copyright © 2018 IgorBizi@mail.ru. All rights reserved.
//

#import "SampleTable.h"
#import "SampleTableCellTableViewCell.h"
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

@interface SampleTable ()<UITableViewDelegate,UITableViewDataSource>
{
    
    NSMutableArray * arr1;
    NSMutableArray *selectedEmailArray;
    NSMutableArray *selectedIdArray;
    
    NSMutableArray *emailArray;
    NSMutableArray *idArray;
    
     NSString *selectedIDs;
    
    Utils *utils;
    NSUserDefaults *userDefaults;
    GlobalVariables *globalVariables;
    
    int count1;
}
@property (strong,nonatomic) NSIndexPath *selectedPath;

@end

@implementation SampleTable

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    globalVariables=[GlobalVariables sharedInstance];
    userDefaults=[NSUserDefaults standardUserDefaults];
    utils=[[Utils alloc]init];
    
    emailArray = [[NSMutableArray alloc] init];
    idArray = [[NSMutableArray alloc] init];
    
    selectedEmailArray = [[NSMutableArray alloc] init];
    selectedIdArray = [[NSMutableArray alloc] init];
    
  //  emailArray=[[NSMutableArray alloc]initWithObjects:@"One",@"Two",@"Threee",@"Four",@"Five", nil];
 //   idArray=[[NSMutableArray alloc]initWithObjects:@"1",@"2",@"3",@"4",@"5", nil];
    
    //To set Gesture on Tableview for multiselection
    count1=0;
    
    
  
    
    //cc list method calling
    [self FetchCollaboratorAssociatedwithTicket];
    
//    self.tableview1.allowsMultipleSelectionDuringEditing = true;
//    UILongPressGestureRecognizer *lpGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(EditTableView:)];
//    [lpGesture setMinimumPressDuration:1];
//    [self.tableview1 addGestureRecognizer:lpGesture];
    
}

-(void)EditTableView:(UIGestureRecognizer*)gesture{
    [self.tableview1 setEditing:YES animated:YES];
   // navbar.hidden=NO;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return emailArray.count;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

    cell.selectionStyle=UITableViewCellSelectionStyleNone;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   // if(tableView==edi)
    SampleTableCellTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"SampleTableCellTableViewCellId"];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SampleTableCellTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.label1.text=[emailArray objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
 // [_tableview1 cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    
//    self.selectedPath = indexPath;
//
//     if ([tableView isEditing])
//     {
//         [selectedEmailArray addObject:[idArray objectAtIndex:indexPath.row]];
//         count1=(int)[selectedEmailArray count];
//         NSLog(@"Selected count is :%i",count1);
//
//         //  selectedIDs = [selectedArray componentsJoinedByString:@","];
//         NSLog(@"Slected Emails are : %@",selectedEmailArray);
//         selectedIDs = [selectedEmailArray componentsJoinedByString:@","];
//
//         NSLog(@"Emails 111 are : %@",selectedIDs);
//     }
}

//-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
//
//    self.selectedPath = indexPath;
//
//    self.selectedPath = indexPath;
//
//    if ([tableView isEditing])
//    {
//        [selectedEmailArray removeObject:[idArray objectAtIndex:indexPath.row]];
//        count1=(int)[selectedEmailArray count];
//        NSLog(@"Selected count is :%i",count1);
//
//        //  selectedIDs = [selectedArray componentsJoinedByString:@","];
//        NSLog(@"Slected Emails are : %@",selectedEmailArray);
//        selectedIDs = [selectedEmailArray componentsJoinedByString:@","];
//
//         NSLog(@"Emails 111 are : %@",selectedIDs);
//
//
//        if (!selectedEmailArray.count) {
//            [self.tableview1 setEditing:NO animated:YES];
//           // navbar.hidden=YES;
//        }
//
//    }
//
//}
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
                
                NSMutableArray  * ccArray=[json objectForKey:@"collaborator"];
                self->globalVariables.ccCount=[NSString stringWithFormat:@"%lu",(unsigned long)ccArray.count];//array1.count;
                
                NSDictionary *tempDict= [ccArray objectAtIndex:self->_selectedPath.row];
                self->emailArray=[tempDict objectForKey:@"email"];
                
            }
            
        }];
    }
    
}



@end
