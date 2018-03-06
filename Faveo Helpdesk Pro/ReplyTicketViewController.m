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

@interface ReplyTicketViewController ()<UITextFieldDelegate>
{
    Utils *utils;
    NSUserDefaults *userDefaults;
    GlobalVariables *globalVariables;
    
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
    [done addTarget:self action:@selector(submitButton) forControlEvents:UIControlEventTouchUpInside];
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
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickedOnCCSubButton)];
    
    [_addCCLabelButton addGestureRecognizer:tapGesture];
    
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

-(void)submitButton
{
    NSLog(@"CLicked");
    
}
- (IBAction)submitButtonClicked:(id)sender {
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
                NSInteger count=array1.count;
                //NSLog(@"Array count is : %lu",(unsigned long)array1.count);
                NSLog(@"Array count is : %lu",count);
            }
            
        }];
    }
    
}


@end
