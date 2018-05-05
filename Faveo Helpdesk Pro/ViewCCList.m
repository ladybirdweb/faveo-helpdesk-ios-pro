//
//  ViewCCList.m
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 04/05/18.
//  Copyright © 2018 Ladybird websolutions pvt ltd. All rights reserved.
//

#import "ViewCCList.h"
#import "Utils.h"
#import "GlobalVariables.h"
#import "AppDelegate.h"
#import "userSearchDataCell.h"
#import "UIImageView+Letters.h"
#import "MyWebservices.h"
#import "RMessage.h"
#import "RMessageView.h"

@interface ViewCCList ()
{
    
    int count1;
    
    GlobalVariables *globalvariable;
    NSUserDefaults *userDefaults;
    Utils *utils;
    NSMutableArray *ccListArray;
    BOOL editingTable;
    
}

@property (strong,nonatomic) NSIndexPath *selectedPath;

@end

@implementation ViewCCList

- (void)viewDidLoad {
    [super viewDidLoad];
   
    utils=[[Utils alloc]init];
    globalvariable=[GlobalVariables sharedInstance];
    userDefaults=[NSUserDefaults standardUserDefaults];
    
    _removeFinalLabel.hidden=YES;
    
    ccListArray =[[NSMutableArray alloc]init];
    
    ccListArray = [NSMutableArray arrayWithArray:globalvariable.ccListArray1];
    
   
    count1=0;
    editingTable=false;
 //   self.tableview1.allowsMultipleSelectionDuringEditing = true;

}

-(void)viewWillAppear:(BOOL)animated
{
    globalvariable=[GlobalVariables sharedInstance];
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)removeCCButton:(id)sender {
    
    NSLog(@"Clicked on remove cc Button");
    _removeCCLabel.hidden=YES;
    _removeFinalLabel.hidden=NO;
    editingTable=YES;
    [self.tableview1 setEditing:YES animated:YES];
    
}

- (IBAction)removeFinalButton:(id)sender {
     NSLog(@"Clicked on Final Button");
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return ccListArray.count;
}

// This method asks the data source for a cell to insert in a particular location of the table view.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    userSearchDataCell *cell=[tableView dequeueReusableCellWithIdentifier:@"userSearchDataCellId"];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"userSearchDataCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
 @try{
    NSDictionary *ccDict=[ccListArray objectAtIndex:indexPath.row];
    
    NSString * userName=[ccDict objectForKey:@"user_name"];
    NSString * emailId =[ccDict objectForKey:@"email"];
    NSString * profilPic=[ccDict objectForKey:@"avatar"];
    
   
    if(![Utils isEmpty:userName])
    {
        cell.userNameLabel.text=userName;
    }
    else{
        cell.userNameLabel.text=@"System";
    }
    
    if(![Utils isEmpty:emailId])
    {
        cell.emalLabel.text=emailId;
    }else{
        cell.emalLabel.text=@"";
    }
    
    if(![Utils isEmpty:profilPic])
    {
        [cell setUserProfileimage:profilPic];
    }
    
    //Image view
    if([profilPic hasSuffix:@"system.png"] || [profilPic hasSuffix:@".jpg"] || [profilPic hasSuffix:@".jpeg"] || [profilPic hasSuffix:@".png"] )
    {
        if([profilPic hasSuffix:@"system.png"])
        {
            cell.userProfileImage.image=[UIImage imageNamed:@"systemIcon.png"];
        }
        else{
                 [cell setUserProfileimage:profilPic];
            }
    }
    else if(![Utils isEmpty:userName])
    {
        [cell.userProfileImage setImageWithString:userName color:nil ];
    }
    else
    {
        [cell.userProfileImage setImageWithString:emailId color:nil ];
    }
    
}@catch (NSException *exception)
    {
        [utils showAlertWithMessage:exception.name sendViewController:self];
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
    }
    @finally
    {
        NSLog( @" I am in reload method in TicketDetailView ViewController" );
        
    }

    
    return cell;
    
}



//
//// This method used for implementing the feature of multiple ticket select, using this we can select and deselects the tableview rows and perform futher actions on that seleected rows.
//-(void)EditTableView:(UIGestureRecognizer*)gesture{
//
//    [self.tableview1 setEditing:YES animated:YES];
//
//}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
//     self.selectedPath = indexPath;
//
//     NSDictionary *ccDict=[ccListArray objectAtIndex:indexPath.row];
//
//    if(editingTable==true)
//    {
//
//    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
     NSDictionary *ccDict=[ccListArray objectAtIndex:indexPath.row];
     NSMutableArray *emailArray=[[NSMutableArray alloc]init];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSLog(@"Selected index: %ld",(long)indexPath.row);
        [emailArray addObject:[ccDict objectForKey:@"email"]];
        NSLog(@"Selected array is : %@",emailArray);
        NSString *emailId=[emailArray objectAtIndex:0];
        NSLog(@"Email string is : %@",emailId);
        
        [self removeCCApiCallMethod:emailId];
        [ccListArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        NSLog(@"Unhandled editing style! %ld", (long)editingStyle);
    }
}

-(void)removeCCApiCallMethod:(NSString *)emailId
{
    
    NSString *url =[NSString stringWithFormat:@"%@helpdesk/collaborator/remove?token=%@&ticket_id=%@&email=%@",[userDefaults objectForKey:@"companyURL"],[userDefaults objectForKey:@"token"],globalvariable.iD,emailId];
    
    NSLog(@"URL is : %@",url);
    
    MyWebservices *webservices=[MyWebservices sharedInstance];
    
    [webservices httpResponsePOST:url parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
        
        
        if (error || [msg containsString:@"Error"]) {
            [[AppDelegate sharedAppdelegate] hideProgressView];
            
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
                    else  if([msg isEqualToString:@"Error-402"])
                    {
                        NSLog(@"Message is : %@",msg);
                        [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Access denied - Either your role has been changed or your login credential has been changed."] sendViewController:self];
                    }
                    else if([msg isEqualToString:@"Error-422"]){
                        
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
            
            [self removeCCApiCallMethod:emailId];
            NSLog(@"Thread--NO4-call-CollaboratorRemove");
            return;
        }
        
        if (json) {
            NSLog(@"JSON-CollaboratorWithTicket-%@",json);
            
            NSString *ccMsg=[json objectForKey:@"collaborator"];
            
            if([ccMsg isEqualToString:@"deleted successfully"])
            {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                   //  ViewCCList *smallViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ccListID"];
                    
                    
                    
                    if (self.navigationController.navigationBarHidden) {
                        [self.navigationController setNavigationBarHidden:NO];
                    }
                    
                    [RMessage showNotificationInViewController:self.navigationController
                                                         title:NSLocalizedString(@"Success", nil)
                                                      subtitle:NSLocalizedString(@"Removed successfully.", nil)
                                                     iconImage:nil
                                                          type:RMessageTypeSuccess
                                                customTypeName:nil
                                                      duration:RMessageDurationAutomatic
                                                      callback:nil
                                                   buttonTitle:nil
                                                buttonCallback:nil
                                                    atPosition:RMessagePositionNavBarOverlay
                                          canBeDismissedByUser:YES];
                    
                    [self dismissViewControllerAnimated:YES completion:nil];
                    [self.navigationController popViewControllerAnimated:YES];
                  //   [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:3] animated:YES];
            
                });
                
            }
        }
        
    }];
    
}

@end
