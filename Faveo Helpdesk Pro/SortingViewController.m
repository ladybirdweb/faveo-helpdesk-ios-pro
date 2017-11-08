//
//  SortingViewController.m
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 01/11/17.
//  Copyright © 2017 Ladybird websolutions pvt ltd. All rights reserved.
//

#import "SortingViewController.h"
#import "InboxViewController.h"
#import "TicketTableViewCell.h"
#import "CreateTicketViewController.h"
#import "TicketDetailViewController.h"
#import "AppDelegate.h"
#import "Utils.h"
#import "Reachability.h"
#import "AppConstanst.h"
#import "MyWebservices.h"
#import "GlobalVariables.h"
#import "LoadingTableViewCell.h"
#import "RKDropdownAlert.h"
#import "HexColors.h"
#import "RMessage.h"
#import "RMessageView.h"
#import "NotificationViewController.h"
#import "CFMacro.h"
#import "CFMultistageDropdownMenuView.h"
#import "CFMultistageConditionTableView.h"
#import "BDCustomAlertView.h"


@import FirebaseInstanceID;
@import FirebaseMessaging;

@interface SortingViewController ()<RMessageProtocol,CFMultistageDropdownMenuViewDelegate>
{
    
    Utils *utils;
    UIRefreshControl *refresh;
    NSUserDefaults *userDefaults;
    GlobalVariables *globalVariables;
    NSDictionary *tempDict;
    NSString *url;
    BDCustomAlertView *customAlert ;
}

@property (nonatomic, strong) NSMutableArray *mutableArray;
@property (nonatomic, strong) NSArray *indexPaths;
@property (nonatomic, assign) NSInteger totalPages;
@property (nonatomic, assign) NSInteger currentPage;

@property (nonatomic, assign) NSInteger totalTickets;
@property (nonatomic, strong) NSString *nextPageUrl;
@property (nonatomic, strong) NSString *path1;

@property (nonatomic, strong) CFMultistageDropdownMenuView *multistageDropdownMenuView;
@property (nonatomic, strong) CFMultistageConditionTableView *multistageConditionTableView;

@end

@implementation SortingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    customAlert = [[BDCustomAlertView alloc] init];
    _multistageDropdownMenuView.tag=99;
   
    globalVariables=[GlobalVariables sharedInstance];
    userDefaults=[NSUserDefaults standardUserDefaults];
    
     if([globalVariables.sortCondition isEqualToString:@"INBOX"])
     {
          [self setTitle:NSLocalizedString(@"Inbox",nil)];
     }else if([globalVariables.sortCondition isEqualToString:@"MYTICKETS"])
     {
          [self setTitle:NSLocalizedString(@"My Tickets",nil)];
     }else if([globalVariables.sortCondition isEqualToString:@"UNASSIGNED"])
     {
         [self setTitle:NSLocalizedString(@"Unassigned Tickets",nil)];
     }else if([globalVariables.sortCondition isEqualToString:@"CLOSED"])
     {
         [self setTitle:NSLocalizedString(@"Closed Tickets",nil)];
     }else if([globalVariables.sortCondition isEqualToString:@"TRASH"])
     {
         [self setTitle:NSLocalizedString(@"Trash Tickets",nil)];
     }
    
    self.view.backgroundColor=[UIColor grayColor];
    [self.view addSubview:self.multistageDropdownMenuView];
    
    
    NSString *refreshedToken = [[FIRInstanceID instanceID] token];
    NSLog(@"refreshed token  %@",refreshedToken);
    
   // [self setTitle:NSLocalizedString(@"Inbox",nil)];
    
   // [self addUIRefresh];
    
    NSLog(@"string %@",NSLocalizedString(@"Inbox",nil));
    _mutableArray=[[NSMutableArray alloc]init];
    
    utils=[[Utils alloc]init];
    
    NSLog(@"device_token %@",[userDefaults objectForKey:@"deviceToken"]);
    
    UIButton *NotificationBtn =  [UIButton buttonWithType:UIButtonTypeCustom];
    [NotificationBtn setImage:[UIImage imageNamed:@"notification.png"] forState:UIControlStateNormal];
    [NotificationBtn addTarget:self action:@selector(NotificationBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [NotificationBtn setFrame:CGRectMake(44, 0, 32, 32)];
    
    UIView *rightBarButtonItems = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 76, 32)];
    //[rightBarButtonItems addSubview:addBtn];
    [rightBarButtonItems addSubview:NotificationBtn];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarButtonItems];
    
    
    
    
    [[AppDelegate sharedAppdelegate] showProgressViewWithText:NSLocalizedString(@"Getting Data",nil)];
    [self reload];
    [self getDependencies];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)reload{
    
    if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable)
    {
        [refresh endRefreshing];
        
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
        
         if([globalVariables.sortCondition isEqualToString:@"INBOX"])
         {
                  NSString * apiValue=[NSString stringWithFormat:@"%i",1];
                  NSString * showInbox = @"inbox";
                  NSString * Alldeparatments=@"All";
        
        
                  NSString * ticketSortByTicketTitle=@"ticket_title";
                  NSString * ticketSortByTicketNumber=@"ticket_number";
                  NSString * ticketSortByPriority=@"priority";
                  NSString * ticketSortByUpdatedAt=@"updated_at";
                  NSString * ticketSortByCreatedAt=@"created_at";
                  NSString * ticketSortByDue=@"due";
        
                  NSString * orderASC =@"ASC";
                  NSString * orderDESC =@"DESC";
        
       
        NSLog(@"Value of globalsort i s: %@",globalVariables.sortingValueId);
       
        
           if ([globalVariables.sortingValueId isEqualToString:@"sortTitleAsc"])
        {
            url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,Alldeparatments,ticketSortByTicketTitle,orderASC];
            NSLog(@"URL is : %@",url);
        }
        
      else   if ([globalVariables.sortingValueId isEqualToString:@"sortTitleDsc"])
        {
            url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,Alldeparatments,ticketSortByTicketTitle,orderDESC];
            NSLog(@"URL is : %@",url);
        }
   
        
      else  if ([globalVariables.sortingValueId isEqualToString:@"sortNumberAsc"])
        {
            url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,Alldeparatments,ticketSortByTicketNumber,orderASC];
            NSLog(@"URL is : %@",url);
          
        }

      else if ([globalVariables.sortingValueId isEqualToString:@"sortNumberDsc"])
        {
            url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,Alldeparatments,ticketSortByTicketNumber,orderDESC];
            NSLog(@"URL is : %@",url);
          
        }
 
      else  if ([globalVariables.sortingValueId isEqualToString:@"sortPriorityAsc"])
        {
            url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,Alldeparatments,ticketSortByPriority,orderASC];
            NSLog(@"URL is : %@",url);
    
        }

     else  if ([globalVariables.sortingValueId isEqualToString:@"sortPriorityDsc"])
        {
            url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,Alldeparatments,ticketSortByPriority,orderDESC];
            NSLog(@"URL is : %@",url);
    
        }

      else  if ([globalVariables.sortingValueId isEqualToString:@"sortUpdatedAsc"])
        {
            url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,Alldeparatments,ticketSortByUpdatedAt,orderASC];
            NSLog(@"URL is : %@",url);
          
        }

       else if ([globalVariables.sortingValueId isEqualToString:@"sortUpdatedDsc"])
        {
            url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,Alldeparatments,ticketSortByUpdatedAt,orderDESC];
            NSLog(@"URL is : %@",url);
           
        }

       else if ([globalVariables.sortingValueId isEqualToString:@"sortCreatedAsc"])
        {
            url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,Alldeparatments,ticketSortByCreatedAt,orderASC];
            NSLog(@"URL is : %@",url);
        }

       else if ([globalVariables.sortingValueId isEqualToString:@"sortCreatedDsc"])
        {
            url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,Alldeparatments,ticketSortByCreatedAt,orderDESC];
            NSLog(@"URL is : %@",url);
        }
//
     else   if ([globalVariables.sortingValueId isEqualToString:@"sortDueAsc"])
        {
            url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,Alldeparatments,ticketSortByDue,orderASC];
            NSLog(@"URL is : %@",url);
        }

       else if ([globalVariables.sortingValueId isEqualToString:@"sortDueDsc"])
        {
            url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,Alldeparatments,ticketSortByDue,orderDESC];
            NSLog(@"URL is : %@",url);
        }
        else
        { //
        }
//
//
         }else  if([globalVariables.sortCondition isEqualToString:@"UNASSIGNED"])
         {
             NSString * apiValue=[NSString stringWithFormat:@"%i",1];
             NSString * showInbox = @"inbox";
             NSString * Alldeparatments=@"All";
           //  NSString * assigned = [NSString stringWithFormat:@"%i",0];
             
             
             NSString * ticketSortByTicketTitle=@"ticket_title";
             NSString * ticketSortByTicketNumber=@"ticket_number";
             NSString * ticketSortByPriority=@"priority";
             NSString * ticketSortByUpdatedAt=@"updated_at";
             NSString * ticketSortByCreatedAt=@"created_at";
             NSString * ticketSortByDue=@"due";
             
             NSString * orderASC =@"ASC";
             NSString * orderDESC =@"DESC";
             
             
             NSLog(@"Value of globalsort i s: %@",globalVariables.sortingValueId);
             
             
             if ([globalVariables.sortingValueId isEqualToString:@"sortTitleAsc"])
             {
                 url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,Alldeparatments,ticketSortByTicketTitle,orderASC];
                 NSLog(@"URL is : %@",url);
             }
             
             else   if ([globalVariables.sortingValueId isEqualToString:@"sortTitleDsc"])
             {
                 url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,Alldeparatments,ticketSortByTicketTitle,orderDESC];
                 NSLog(@"URL is : %@",url);
             }
             
             
             else  if ([globalVariables.sortingValueId isEqualToString:@"sortNumberAsc"])
             {
                 url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,Alldeparatments,ticketSortByTicketNumber,orderASC];
                 NSLog(@"URL is : %@",url);
                 
             }
             
             else if ([globalVariables.sortingValueId isEqualToString:@"sortNumberDsc"])
             {
                 url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,Alldeparatments,ticketSortByTicketNumber,orderDESC];
                 NSLog(@"URL is : %@",url);
                 
             }
             
             else  if ([globalVariables.sortingValueId isEqualToString:@"sortPriorityAsc"])
             {
                 url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,Alldeparatments,ticketSortByPriority,orderASC];
                 NSLog(@"URL is : %@",url);
                 
             }
             
             else  if ([globalVariables.sortingValueId isEqualToString:@"sortPriorityDsc"])
             {
                 url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,Alldeparatments,ticketSortByPriority,orderDESC];
                 NSLog(@"URL is : %@",url);
                 
             }
             
             else  if ([globalVariables.sortingValueId isEqualToString:@"sortUpdatedAsc"])
             {
                 url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,Alldeparatments,ticketSortByUpdatedAt,orderASC];
                 NSLog(@"URL is : %@",url);
                 
             }
             
             else if ([globalVariables.sortingValueId isEqualToString:@"sortUpdatedDsc"])
             {
                 url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,Alldeparatments,ticketSortByUpdatedAt,orderDESC];
                 NSLog(@"URL is : %@",url);
                 
             }
             
             else if ([globalVariables.sortingValueId isEqualToString:@"sortCreatedAsc"])
             {
                 url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,Alldeparatments,ticketSortByCreatedAt,orderASC];
                 NSLog(@"URL is : %@",url);
             }
             
             else if ([globalVariables.sortingValueId isEqualToString:@"sortCreatedDsc"])
             {
                 url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,Alldeparatments,ticketSortByCreatedAt,orderDESC];
                 NSLog(@"URL is : %@",url);
             }
             //
             else   if ([globalVariables.sortingValueId isEqualToString:@"sortDueAsc"])
             {
                 url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,Alldeparatments,ticketSortByDue,orderASC];
                 NSLog(@"URL is : %@",url);
             }
             
             else if ([globalVariables.sortingValueId isEqualToString:@"sortDueDsc"])
             {
                 url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,Alldeparatments,ticketSortByDue,orderDESC];
                 NSLog(@"URL is : %@",url);
             }
             else
             { //
             }
             //
             //
             
             
         } else if([globalVariables.sortCondition isEqualToString:@"MYTICKETS"])
         {
             NSString * apiValue=[NSString stringWithFormat:@"%i",1];
             NSString * showMyTickets = @"mytickets";
             NSString * Alldeparatments=@"All";
             
             
             NSString * ticketSortByTicketTitle=@"ticket_title";
             NSString * ticketSortByTicketNumber=@"ticket_number";
             NSString * ticketSortByPriority=@"priority";
             NSString * ticketSortByUpdatedAt=@"updated_at";
             NSString * ticketSortByCreatedAt=@"created_at";
             NSString * ticketSortByDue=@"due";
             
             NSString * orderASC =@"ASC";
             NSString * orderDESC =@"DESC";
             
             
             NSLog(@"Value of globalsort i s: %@",globalVariables.sortingValueId);
             
             
             if ([globalVariables.sortingValueId isEqualToString:@"sortTitleAsc"])
             {
                 url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showMyTickets,Alldeparatments,ticketSortByTicketTitle,orderASC];
                 NSLog(@"URL is : %@",url);
             }
             
             else   if ([globalVariables.sortingValueId isEqualToString:@"sortTitleDsc"])
             {
                 url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showMyTickets,Alldeparatments,ticketSortByTicketTitle,orderDESC];
                 NSLog(@"URL is : %@",url);
             }
             
             
             else  if ([globalVariables.sortingValueId isEqualToString:@"sortNumberAsc"])
             {
                 url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showMyTickets,Alldeparatments,ticketSortByTicketNumber,orderASC];
                 NSLog(@"URL is : %@",url);
                 
             }
             
             else if ([globalVariables.sortingValueId isEqualToString:@"sortNumberDsc"])
             {
                 url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showMyTickets,Alldeparatments,ticketSortByTicketNumber,orderDESC];
                 NSLog(@"URL is : %@",url);
                 
             }
             
             else  if ([globalVariables.sortingValueId isEqualToString:@"sortPriorityAsc"])
             {
                 url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showMyTickets,Alldeparatments,ticketSortByPriority,orderASC];
                 NSLog(@"URL is : %@",url);
                 
             }
             
             else  if ([globalVariables.sortingValueId isEqualToString:@"sortPriorityDsc"])
             {
                 url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showMyTickets,Alldeparatments,ticketSortByPriority,orderDESC];
                 NSLog(@"URL is : %@",url);
                 
             }
             
             else  if ([globalVariables.sortingValueId isEqualToString:@"sortUpdatedAsc"])
             {
                 url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showMyTickets,Alldeparatments,ticketSortByUpdatedAt,orderASC];
                 NSLog(@"URL is : %@",url);
                 
             }
             
             else if ([globalVariables.sortingValueId isEqualToString:@"sortUpdatedDsc"])
             {
                 url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showMyTickets,Alldeparatments,ticketSortByUpdatedAt,orderDESC];
                 NSLog(@"URL is : %@",url);
                 
             }
             
             else if ([globalVariables.sortingValueId isEqualToString:@"sortCreatedAsc"])
             {
                 url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showMyTickets,Alldeparatments,ticketSortByCreatedAt,orderASC];
                 NSLog(@"URL is : %@",url);
             }
             
             else if ([globalVariables.sortingValueId isEqualToString:@"sortCreatedDsc"])
             {
                 url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showMyTickets,Alldeparatments,ticketSortByCreatedAt,orderDESC];
                 NSLog(@"URL is : %@",url);
             }
             //
             else   if ([globalVariables.sortingValueId isEqualToString:@"sortDueAsc"])
             {
                 url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showMyTickets,Alldeparatments,ticketSortByDue,orderASC];
                 NSLog(@"URL is : %@",url);
             }
             
             else if ([globalVariables.sortingValueId isEqualToString:@"sortDueDsc"])
             {
                 url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showMyTickets,Alldeparatments,ticketSortByDue,orderDESC];
                 NSLog(@"URL is : %@",url);
             }
             else
             {
                 // end my tickets
             }
             
         }  else  if([globalVariables.sortCondition isEqualToString:@"CLOSED"])
         {
             
             NSString * apiValue=[NSString stringWithFormat:@"%i",1];
             NSString * showClosedTickets = @"closed";
             NSString * Alldeparatments=@"All";
             
             
             NSString * ticketSortByTicketTitle=@"ticket_title";
             NSString * ticketSortByTicketNumber=@"ticket_number";
             NSString * ticketSortByPriority=@"priority";
             NSString * ticketSortByUpdatedAt=@"updated_at";
             NSString * ticketSortByCreatedAt=@"created_at";
             NSString * ticketSortByDue=@"due";
             
             NSString * orderASC =@"ASC";
             NSString * orderDESC =@"DESC";
             
             
             NSLog(@"Value of globalsort i s: %@",globalVariables.sortingValueId);
             
             
             if ([globalVariables.sortingValueId isEqualToString:@"sortTitleAsc"])
             {
                 url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showClosedTickets,Alldeparatments,ticketSortByTicketTitle,orderASC];
                 NSLog(@"URL is : %@",url);
             }
             
             else   if ([globalVariables.sortingValueId isEqualToString:@"sortTitleDsc"])
             {
                 url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showClosedTickets,Alldeparatments,ticketSortByTicketTitle,orderDESC];
                 NSLog(@"URL is : %@",url);
             }
             
             
             else  if ([globalVariables.sortingValueId isEqualToString:@"sortNumberAsc"])
             {
                 url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showClosedTickets,Alldeparatments,ticketSortByTicketNumber,orderASC];
                 NSLog(@"URL is : %@",url);
                 
             }
             
             else if ([globalVariables.sortingValueId isEqualToString:@"sortNumberDsc"])
             {
                 url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showClosedTickets,Alldeparatments,ticketSortByTicketNumber,orderDESC];
                 NSLog(@"URL is : %@",url);
                 
             }
             
             else  if ([globalVariables.sortingValueId isEqualToString:@"sortPriorityAsc"])
             {
                 url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showClosedTickets,Alldeparatments,ticketSortByPriority,orderASC];
                 NSLog(@"URL is : %@",url);
                 
             }
             
             else  if ([globalVariables.sortingValueId isEqualToString:@"sortPriorityDsc"])
             {
                 url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showClosedTickets,Alldeparatments,ticketSortByPriority,orderDESC];
                 NSLog(@"URL is : %@",url);
                 
             }
             
             else  if ([globalVariables.sortingValueId isEqualToString:@"sortUpdatedAsc"])
             {
                 url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showClosedTickets,Alldeparatments,ticketSortByUpdatedAt,orderASC];
                 NSLog(@"URL is : %@",url);
                 
             }
             
             else if ([globalVariables.sortingValueId isEqualToString:@"sortUpdatedDsc"])
             {
                 url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showClosedTickets,Alldeparatments,ticketSortByUpdatedAt,orderDESC];
                 NSLog(@"URL is : %@",url);
                 
             }
             
             else if ([globalVariables.sortingValueId isEqualToString:@"sortCreatedAsc"])
             {
                 url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showClosedTickets,Alldeparatments,ticketSortByCreatedAt,orderASC];
                 NSLog(@"URL is : %@",url);
             }
             
             else if ([globalVariables.sortingValueId isEqualToString:@"sortCreatedDsc"])
             {
                 url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showClosedTickets,Alldeparatments,ticketSortByCreatedAt,orderDESC];
                 NSLog(@"URL is : %@",url);
             }
             //
             else   if ([globalVariables.sortingValueId isEqualToString:@"sortDueAsc"])
             {
                 url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showClosedTickets,Alldeparatments,ticketSortByDue,orderASC];
                 NSLog(@"URL is : %@",url);
             }
             
             else if ([globalVariables.sortingValueId isEqualToString:@"sortDueDsc"])
             {
                 url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showClosedTickets,Alldeparatments,ticketSortByDue,orderDESC];
                 NSLog(@"URL is : %@",url);
             }
             else
             {
                 // end close tickets
             }
             
             
         } else  if([globalVariables.sortCondition isEqualToString:@"TRASH"])
         {
             
             NSString * apiValue=[NSString stringWithFormat:@"%i",1];
             NSString * showTrashTickets = @"trash";
             NSString * Alldeparatments=@"All";
             
             
             NSString * ticketSortByTicketTitle=@"ticket_title";
             NSString * ticketSortByTicketNumber=@"ticket_number";
             NSString * ticketSortByPriority=@"priority";
             NSString * ticketSortByUpdatedAt=@"updated_at";
             NSString * ticketSortByCreatedAt=@"created_at";
             NSString * ticketSortByDue=@"due";
             
             NSString * orderASC =@"ASC";
             NSString * orderDESC =@"DESC";
             
             
             NSLog(@"Value of globalsort i s: %@",globalVariables.sortingValueId);
             
             
             if ([globalVariables.sortingValueId isEqualToString:@"sortTitleAsc"])
             {
                 url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showTrashTickets,Alldeparatments,ticketSortByTicketTitle,orderASC];
                 NSLog(@"URL is : %@",url);
             }
             
             else   if ([globalVariables.sortingValueId isEqualToString:@"sortTitleDsc"])
             {
                 url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showTrashTickets,Alldeparatments,ticketSortByTicketTitle,orderDESC];
                 NSLog(@"URL is : %@",url);
             }
             
             
             else  if ([globalVariables.sortingValueId isEqualToString:@"sortNumberAsc"])
             {
                 url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showTrashTickets,Alldeparatments,ticketSortByTicketNumber,orderASC];
                 NSLog(@"URL is : %@",url);
                 
             }
             
             else if ([globalVariables.sortingValueId isEqualToString:@"sortNumberDsc"])
             {
                 url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showTrashTickets,Alldeparatments,ticketSortByTicketNumber,orderDESC];
                 NSLog(@"URL is : %@",url);
                 
             }
             
             else  if ([globalVariables.sortingValueId isEqualToString:@"sortPriorityAsc"])
             {
                 url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showTrashTickets,Alldeparatments,ticketSortByPriority,orderASC];
                 NSLog(@"URL is : %@",url);
                 
             }
             
             else  if ([globalVariables.sortingValueId isEqualToString:@"sortPriorityDsc"])
             {
                 url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showTrashTickets,Alldeparatments,ticketSortByPriority,orderDESC];
                 NSLog(@"URL is : %@",url);
                 
             }
             
             else  if ([globalVariables.sortingValueId isEqualToString:@"sortUpdatedAsc"])
             {
                 url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showTrashTickets,Alldeparatments,ticketSortByUpdatedAt,orderASC];
                 NSLog(@"URL is : %@",url);
                 
             }
             
             else if ([globalVariables.sortingValueId isEqualToString:@"sortUpdatedDsc"])
             {
                 url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showTrashTickets,Alldeparatments,ticketSortByUpdatedAt,orderDESC];
                 NSLog(@"URL is : %@",url);
                 
             }
             
             else if ([globalVariables.sortingValueId isEqualToString:@"sortCreatedAsc"])
             {
                 url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showTrashTickets,Alldeparatments,ticketSortByCreatedAt,orderASC];
                 NSLog(@"URL is : %@",url);
             }
             
             else if ([globalVariables.sortingValueId isEqualToString:@"sortCreatedDsc"])
             {
                 url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showTrashTickets,Alldeparatments,ticketSortByCreatedAt,orderDESC];
                 NSLog(@"URL is : %@",url);
             }
             //
             else   if ([globalVariables.sortingValueId isEqualToString:@"sortDueAsc"])
             {
                 url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showTrashTickets,Alldeparatments,ticketSortByDue,orderASC];
                 NSLog(@"URL is : %@",url);
             }
             
             else if ([globalVariables.sortingValueId isEqualToString:@"sortDueDsc"])
             {
                 url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showTrashTickets,Alldeparatments,ticketSortByDue,orderDESC];
                 NSLog(@"URL is : %@",url);
             }
             else
             {
                 // end trash tickets
             }
             
             
         }
         else
         {//end all
         }
        
        
        @try{
            MyWebservices *webservices=[MyWebservices sharedInstance];
            [webservices httpResponseGET:url parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
                
                
                
                if (error || [msg containsString:@"Error"]) {
                    [refresh endRefreshing];
                    [[AppDelegate sharedAppdelegate] hideProgressView];
                    if (msg) {
                        
                        [utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",msg] sendViewController:self];
                        
                    }else if(error)  {
                        [utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",error.localizedDescription] sendViewController:self];
                        NSLog(@"Thread-sortingpage-Refresh-error == %@",error.localizedDescription);
                    }
                    return ;
                }
                
                if ([msg isEqualToString:@"tokenRefreshed"]) {
                    
                    [self reload];
                    NSLog(@"Thread--NO4-call-getInbox");
                    return;
                }
                
                if (json) {
                    //NSError *error;
                    NSLog(@"Thread-NO4--getInboxAPI--%@",json);
                    _mutableArray = [json objectForKey:@"data"];
                    _nextPageUrl =[json objectForKey:@"next_page_url"];
                    NSLog(@"bexr page url is : %@",_nextPageUrl);
                    
                    _path1=[json objectForKey:@"path"];
                    
                    _currentPage=[[json objectForKey:@"current_page"] integerValue];
                    _totalTickets=[[json objectForKey:@"total"] integerValue];
                    _totalPages=[[json objectForKey:@"last_page"] integerValue];
                    NSLog(@"Thread-NO4.1getInbox-dic--%@", _mutableArray);
                    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[AppDelegate sharedAppdelegate] hideProgressView];
                            [refresh endRefreshing];
                            [self.tableView reloadData];
                        });
                    });
                    
                }
                NSLog(@"Thread-NO5-getInbox-closed");
                
            }];
        }@catch (NSException *exception)
        {
            // Print exception information
            // NSLog( @"NSException caught in reload method in Inbox ViewController " );
            // NSLog( @"Name: %@", exception.name);
            // NSLog( @"Reason: %@", exception.reason );
            return;
        }
        @finally
        {
            // Cleanup, in both success and fail cases
            //  NSLog( @"In finally block");
            
        }
    }
}


-(void)getDependencies{
    
    NSLog(@"Thread-NO1-getDependencies()-start");
    if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable)
    {
        //connection unavailable
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
        
        NSString *url=[NSString stringWithFormat:@"%@helpdesk/dependency?api_key=%@&ip=%@&token=%@",[userDefaults objectForKey:@"companyURL"],API_KEY,IP,[userDefaults objectForKey:@"token"]];
        
        @try{
            MyWebservices *webservices=[MyWebservices sharedInstance];
            [webservices httpResponseGET:url parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg){
                NSLog(@"Thread-NO3-getDependencies-start-error-%@-json-%@-msg-%@",error,json,msg);
                if (error || [msg containsString:@"Error"]) {
                    
                    NSLog(@"Thread-NO4-postCreateTicket-Refresh-error == %@",error.localizedDescription);
                    return ;
                }
                
                if ([msg isEqualToString:@"tokenRefreshed"]) {
                    //               dispatch_async(dispatch_get_main_queue(), ^{
                    //                  [self getDependencies];
                    //               });
                    
                    [self getDependencies];
                    NSLog(@"Thread--NO4-call-getDependecies");
                    return;
                }
                
                if (json) {
                    
                    NSLog(@"Thread-NO4-getDependencies-dependencyAPI--%@",json);
                    NSDictionary *resultDic = [json objectForKey:@"result"];
                    NSArray *ticketCountArray=[resultDic objectForKey:@"tickets_count"];
                    
                    for (int i = 0; i < ticketCountArray.count; i++) {
                        NSString *name = [[ticketCountArray objectAtIndex:i]objectForKey:@"name"];
                        NSString *count = [[ticketCountArray objectAtIndex:i]objectForKey:@"count"];
                        if ([name isEqualToString:@"Open"]) {
                            globalVariables.OpenCount=count;
                        }else if ([name isEqualToString:@"Closed"]) {
                            globalVariables.ClosedCount=count;
                        }else if ([name isEqualToString:@"Deleted"]) {
                            globalVariables.DeletedCount=count;
                        }else if ([name isEqualToString:@"unassigned"]) {
                            globalVariables.UnassignedCount=count;
                        }else if ([name isEqualToString:@"mytickets"]) {
                            globalVariables.MyticketsCount=count;
                        }
                    }
                    
                    NSArray *ticketStatusArray=[resultDic objectForKey:@"status"];
                    
                    for (int i = 0; i < ticketStatusArray.count; i++) {
                        NSString *statusName = [[ticketStatusArray objectAtIndex:i]objectForKey:@"name"];
                        NSString *statusId = [[ticketStatusArray objectAtIndex:i]objectForKey:@"id"];
                        
                        if ([statusName isEqualToString:@"Open"]) {
                            globalVariables.OpenStausId=statusId;
                        }else if ([statusName isEqualToString:@"Resolved"]) {
                            globalVariables.ResolvedStausId=statusId;
                        }else if ([statusName isEqualToString:@"Closed"]) {
                            globalVariables.ClosedStausId=statusId;
                        }else if ([statusName isEqualToString:@"Deleted"]) {
                            globalVariables.DeletedStausId=statusId;
                        }else if ([statusName isEqualToString:@"Request for close"]) {
                            globalVariables.RequestCloseStausId=statusId;
                        }else if ([statusName isEqualToString:@"Spam"]) {
                            globalVariables.SpamStausId=statusId;
                        }
                    }
                    
                    
                    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
                    
                    // get documents path
                    NSString *documentsPath = [paths objectAtIndex:0];
                    
                    // get the path to our Data/plist file
                    NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"faveoData.plist"];
                    NSError *writeError = nil;
                    
                    NSData *plistData = [NSPropertyListSerialization dataWithPropertyList:resultDic format:NSPropertyListXMLFormat_v1_0 options:NSPropertyListImmutable error:&writeError];
                    
                    if(plistData)
                    {
                        [plistData writeToFile:plistPath atomically:YES];
                        NSLog(@"Data saved sucessfully");
                    }
                    else
                    {
                        NSLog(@"Error in saveData: %@", writeError.localizedDescription);               }
                    
                }
                NSLog(@"Thread-NO5-getDependencies-closed");
            }
             ];
        }@catch (NSException *exception)
        {
            // Print exception information
//            NSLog( @"NSException caught in getDependencies method in Inbox ViewController" );
//            NSLog( @"Name: %@", exception.name);
//            NSLog( @"Reason: %@", exception.reason );
            return;
        }
        @finally
        {
            // Cleanup, in both success and fail cases
          //  NSLog( @"In finally block");
            
        }
    }
    NSLog(@"Thread-NO2-getDependencies()-closed");
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger numOfSections = 0;
    if ([_mutableArray count]==0)
    {
        UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, tableView.bounds.size.height)];
        noDataLabel.text             =  NSLocalizedString(@"No Records..!!!",nil);
        noDataLabel.textColor        = [UIColor blackColor];
        noDataLabel.textAlignment    = NSTextAlignmentCenter;
        tableView.backgroundView = noDataLabel;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    else
    {
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        numOfSections                = 1;
        tableView.backgroundView = nil;
    }
    
    return numOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.currentPage == self.totalPages
        || self.totalTickets == _mutableArray.count) {
        return _mutableArray.count;
    }
    
    
    return _mutableArray.count + 1;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    if (indexPath.row == [_mutableArray count] - 1 ) {
        NSLog(@"nextURL  %@",_nextPageUrl);
        if (( ![_nextPageUrl isEqual:[NSNull null]] ) && ( [_nextPageUrl length] != 0 )) {
            [self loadMore];
        }
        else{
            // [RKDropdownAlert title:@"" message:@"All Caught Up...!" backgroundColor:[UIColor hx_colorWithHexRGBAString:ALERT_COLOR] textColor:[UIColor whiteColor]];
            
            [RMessage showNotificationInViewController:self
                                                 title:nil
                                              subtitle:NSLocalizedString(@"All Caught Up)", nil)
                                             iconImage:nil
                                                  type:RMessageTypeSuccess
                                        customTypeName:nil
                                              duration:RMessageDurationAutomatic
                                              callback:nil
                                           buttonTitle:nil
                                        buttonCallback:nil
                                            atPosition:RMessagePositionBottom
                                  canBeDismissedByUser:YES];
        }
    }
}


-(void)loadMore{
    
    if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable)
    {
        //connection unavailable
        
        //   [RKDropdownAlert title:APP_NAME message:NO_INTERNET backgroundColor:[UIColor hx_colorWithHexRGBAString:FAILURE_COLOR] textColor:[UIColor whiteColor]];
        
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
        
    
//            MyWebservices *webservices=[MyWebservices sharedInstance];
//            [webservices getNextPageURL:_nextPageUrl callbackHandler:^(NSError *error,id json,NSString* msg) {
        
        if([globalVariables.sortCondition isEqualToString:@"INBOX"])
        {   self.page = _page + 1;
            
            
            NSString *str=_nextPageUrl;
            NSString *szNeedle= @"http://jamboreebliss.com/sayar/public/api/v2/helpdesk/get-tickets?page=";
            NSRange range = [str rangeOfString:szNeedle];
            NSInteger idx = range.location + range.length;
            NSString *szResult = [str substringFromIndex:idx];
            NSString *Page = [str substringFromIndex:idx];
            
            NSLog(@"String is : %@",szResult);
            NSLog(@"Page is : %@",Page);
            
            MyWebservices *webservices=[MyWebservices sharedInstance];
            [webservices getNextPageURLInbox:_path1 pageNo:Page  callbackHandler:^(NSError *error,id json,NSString* msg) {
                
                if (error || [msg containsString:@"Error"]) {
                    
                    if (msg) {
                        
                        [utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",msg] sendViewController:self];
                        
                    }else if(error)  {
                        [utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",error.localizedDescription] sendViewController:self];
                        NSLog(@"Thread-NO4-getInbox-Refresh-error == %@",error.localizedDescription);
                    }
                    return ;
                }
                
                if ([msg isEqualToString:@"tokenRefreshed"]) {
                    
                    [self loadMore];
                    //NSLog(@"Thread--NO4-call-getInbox");
                    return;
                }
                
                if (json) {
                    NSLog(@"Thread-NO4--getInboxAPI--%@",json);
                    //_indexPaths=[[NSArray alloc]init];
                    //_indexPaths = [json objectForKey:@"data"];
                    _nextPageUrl =[json objectForKey:@"next_page_url"];
                    _currentPage=[[json objectForKey:@"current_page"] integerValue];
                    _totalTickets=[[json objectForKey:@"total"] integerValue];
                    _totalPages=[[json objectForKey:@"last_page"] integerValue];
                    
                    
                    _mutableArray= [_mutableArray mutableCopy];
                    
                    [_mutableArray addObjectsFromArray:[json objectForKey:@"data"]];
                
                    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.tableView reloadData];
                           
                        });
                    });
                    
                }
                NSLog(@"Thread-NO5-getInbox-closed");
                
            }];
       
        }
        else if([globalVariables.sortCondition isEqualToString:@"MYTICKETS"])
        {
            
            self.page = _page + 1;
            
            
            NSString *str=_nextPageUrl;
            NSString *szNeedle= @"http://jamboreebliss.com/sayar/public/api/v2/helpdesk/get-tickets?page=";
            NSRange range = [str rangeOfString:szNeedle];
            NSInteger idx = range.location + range.length;
            NSString *szResult = [str substringFromIndex:idx];
            NSString *Page = [str substringFromIndex:idx];
            
            NSLog(@"String is : %@",szResult);
            NSLog(@"Page is : %@",Page);
            
            MyWebservices *webservices=[MyWebservices sharedInstance];
            [webservices getNextPageURLMyTickets:_path1 pageNo:Page  callbackHandler:^(NSError *error,id json,NSString* msg) {
                
                if (error || [msg containsString:@"Error"]) {
                    
                    if (msg) {
                        
                        [utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",msg] sendViewController:self];
                        
                    }else if(error)  {
                        [utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",error.localizedDescription] sendViewController:self];
                        NSLog(@"Thread-NO4-getInbox-Refresh-error == %@",error.localizedDescription);
                    }
                    return ;
                }
                
                if ([msg isEqualToString:@"tokenRefreshed"]) {
                    
                    [self loadMore];
                    //NSLog(@"Thread--NO4-call-getInbox");
                    return;
                }
                
                if (json) {
                    NSLog(@"Thread-NO4--getInboxAPI--%@",json);
                    //_indexPaths=[[NSArray alloc]init];
                    //_indexPaths = [json objectForKey:@"data"];
                    _nextPageUrl =[json objectForKey:@"next_page_url"];
                    _currentPage=[[json objectForKey:@"current_page"] integerValue];
                    _totalTickets=[[json objectForKey:@"total"] integerValue];
                    _totalPages=[[json objectForKey:@"last_page"] integerValue];
                    
                    
                    _mutableArray= [_mutableArray mutableCopy];
                    
                    [_mutableArray addObjectsFromArray:[json objectForKey:@"data"]];
                    
                    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.tableView reloadData];
                            
                        });
                    });
                    
                }
                NSLog(@"Thread-NO5-getInbox-closed");
                
            }];
            
        }
        else if([globalVariables.sortCondition isEqualToString:@"UNASSIGNED"])
        {
            
            self.page = _page + 1;
            
            
            NSString *str=_nextPageUrl;
            NSString *szNeedle= @"http://jamboreebliss.com/sayar/public/api/v2/helpdesk/get-tickets?page=";
            NSRange range = [str rangeOfString:szNeedle];
            NSInteger idx = range.location + range.length;
            NSString *szResult = [str substringFromIndex:idx];
            NSString *Page = [str substringFromIndex:idx];
            
            NSLog(@"String is : %@",szResult);
            NSLog(@"Page is : %@",Page);
            
            MyWebservices *webservices=[MyWebservices sharedInstance];
            [webservices getNextPageURLUnassigned:_path1 pageNo:Page  callbackHandler:^(NSError *error,id json,NSString* msg) {
                
                if (error || [msg containsString:@"Error"]) {
                    
                    if (msg) {
                        
                        [utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",msg] sendViewController:self];
                        
                    }else if(error)  {
                        [utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",error.localizedDescription] sendViewController:self];
                        NSLog(@"Thread-NO4-getInbox-Refresh-error == %@",error.localizedDescription);
                    }
                    return ;
                }
                
                if ([msg isEqualToString:@"tokenRefreshed"]) {
                    
                    [self loadMore];
                    //NSLog(@"Thread--NO4-call-getInbox");
                    return;
                }
                
                if (json) {
                    NSLog(@"Thread-NO4--getInboxAPI--%@",json);
                    //_indexPaths=[[NSArray alloc]init];
                    //_indexPaths = [json objectForKey:@"data"];
                    _nextPageUrl =[json objectForKey:@"next_page_url"];
                    _currentPage=[[json objectForKey:@"current_page"] integerValue];
                    _totalTickets=[[json objectForKey:@"total"] integerValue];
                    _totalPages=[[json objectForKey:@"last_page"] integerValue];
                    
                    
                    _mutableArray= [_mutableArray mutableCopy];
                    
                    [_mutableArray addObjectsFromArray:[json objectForKey:@"data"]];
                    
                    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.tableView reloadData];
                            
                        });
                    });
                    
                }
                NSLog(@"Thread-NO5-getInbox-closed");
                
            }];
            
            
        }
        else if([globalVariables.sortCondition isEqualToString:@"CLOSED"])
        {
            
            
            self.page = _page + 1;
            
            
            NSString *str=_nextPageUrl;
            NSString *szNeedle= @"http://jamboreebliss.com/sayar/public/api/v2/helpdesk/get-tickets?page=";
            NSRange range = [str rangeOfString:szNeedle];
            NSInteger idx = range.location + range.length;
            NSString *szResult = [str substringFromIndex:idx];
            NSString *Page = [str substringFromIndex:idx];
            
            NSLog(@"String is : %@",szResult);
            NSLog(@"Page is : %@",Page);
            
            MyWebservices *webservices=[MyWebservices sharedInstance];
            [webservices getNextPageURLClosed:_path1 pageNo:Page  callbackHandler:^(NSError *error,id json,NSString* msg) {
                
                if (error || [msg containsString:@"Error"]) {
                    
                    if (msg) {
                        
                        [utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",msg] sendViewController:self];
                        
                    }else if(error)  {
                        [utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",error.localizedDescription] sendViewController:self];
                        NSLog(@"Thread-NO4-getInbox-Refresh-error == %@",error.localizedDescription);
                    }
                    return ;
                }
                
                if ([msg isEqualToString:@"tokenRefreshed"]) {
                    
                    [self loadMore];
                    //NSLog(@"Thread--NO4-call-getInbox");
                    return;
                }
                
                if (json) {
                    NSLog(@"Thread-NO4--getInboxAPI--%@",json);
                    //_indexPaths=[[NSArray alloc]init];
                    //_indexPaths = [json objectForKey:@"data"];
                    _nextPageUrl =[json objectForKey:@"next_page_url"];
                    _currentPage=[[json objectForKey:@"current_page"] integerValue];
                    _totalTickets=[[json objectForKey:@"total"] integerValue];
                    _totalPages=[[json objectForKey:@"last_page"] integerValue];
                    
                    
                    _mutableArray= [_mutableArray mutableCopy];
                    
                    [_mutableArray addObjectsFromArray:[json objectForKey:@"data"]];
                    
                    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.tableView reloadData];
                            
                        });
                    });
                    
                }
                NSLog(@"Thread-NO5-getInbox-closed");
                
            }];
            
        }
        else if([globalVariables.sortCondition isEqualToString:@"TRASH"])
        {
            
            
            self.page = _page + 1;
            
            
            NSString *str=_nextPageUrl;
            NSString *szNeedle= @"http://jamboreebliss.com/sayar/public/api/v2/helpdesk/get-tickets?page=";
            NSRange range = [str rangeOfString:szNeedle];
            NSInteger idx = range.location + range.length;
            NSString *szResult = [str substringFromIndex:idx];
            NSString *Page = [str substringFromIndex:idx];
            
            NSLog(@"String is : %@",szResult);
            NSLog(@"Page is : %@",Page);
            
            MyWebservices *webservices=[MyWebservices sharedInstance];
            [webservices getNextPageURLTrash:_path1 pageNo:Page  callbackHandler:^(NSError *error,id json,NSString* msg) {
                
                if (error || [msg containsString:@"Error"]) {
                    
                    if (msg) {
                        
                        [utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",msg] sendViewController:self];
                        
                    }else if(error)  {
                        [utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",error.localizedDescription] sendViewController:self];
                        NSLog(@"Thread-NO4-getInbox-Refresh-error == %@",error.localizedDescription);
                    }
                    return ;
                }
                
                if ([msg isEqualToString:@"tokenRefreshed"]) {
                    
                    [self loadMore];
                    //NSLog(@"Thread--NO4-call-getInbox");
                    return;
                }
                
                if (json) {
                    NSLog(@"Thread-NO4--getInboxAPI--%@",json);
                    //_indexPaths=[[NSArray alloc]init];
                    //_indexPaths = [json objectForKey:@"data"];
                    _nextPageUrl =[json objectForKey:@"next_page_url"];
                    _currentPage=[[json objectForKey:@"current_page"] integerValue];
                    _totalTickets=[[json objectForKey:@"total"] integerValue];
                    _totalPages=[[json objectForKey:@"last_page"] integerValue];
                    
                    
                    _mutableArray= [_mutableArray mutableCopy];
                    
                    [_mutableArray addObjectsFromArray:[json objectForKey:@"data"]];
                    
                    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.tableView reloadData];
                            
                        });
                    });
                    
                }
                NSLog(@"Thread-NO5-getInbox-closed");
                
            }];
        }
    }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if (indexPath.row == [_mutableArray count]) {
        
        LoadingTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"LoadingCellID"];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"LoadingTableViewCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[cell.contentView viewWithTag:1];
        [activityIndicator startAnimating];
        return cell;
    }else{
        
        TicketTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"TableViewCellID"];
        
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TicketTableViewCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        NSDictionary *finaldic=[_mutableArray objectAtIndex:indexPath.row];
        
        tempDict= [_mutableArray objectAtIndex:indexPath.row];
        //cell.ticketIdLabel.text=[finaldic objectForKey:@"ticket_number"];
        
        @try{
            NSString *ticketNumber=[finaldic objectForKey:@"ticket_number"];
            
            [Utils isEmpty:ticketNumber];
            
            
            if  (![Utils isEmpty:ticketNumber] && ![ticketNumber isEqualToString:@""])
            {
                cell.ticketIdLabel.text=ticketNumber;
            }
            else
            {
                cell.ticketIdLabel.text=NSLocalizedString(@"Not Available", nil);
            }
            
            NSString *fname= [finaldic objectForKey:@"c_fname"];
            NSString *lname= [finaldic objectForKey:@"c_lname"];
          //  NSString *userName= [finaldic objectForKey:@"c_uname"];
            NSString*email1=[finaldic objectForKey:@"c_uname"];
            
            [Utils isEmpty:fname];
            [Utils isEmpty:lname];
            [Utils isEmpty:email1];
            
            
            
            
            if  (![Utils isEmpty:fname] || ![Utils isEmpty:lname])
            {
                if (![Utils isEmpty:fname] && ![Utils isEmpty:lname])
                {   cell.mailIdLabel.text=[NSString stringWithFormat:@"%@ %@",[finaldic objectForKey:@"c_fname"],[finaldic objectForKey:@"c_lname"]];
                }
                else{
                    cell.mailIdLabel.text=[NSString stringWithFormat:@"%@ %@",[finaldic objectForKey:@"c_fname"],[finaldic objectForKey:@"c_lname"]];
                }
            }
            else
            {
//                if(![Utils isEmpty:userName])
//               {
//                cell.mailIdLabel.text=[finaldic objectForKey:@"user_name"];
//               }
              
                if(![Utils isEmpty:email1])
                {
                    cell.mailIdLabel.text=[finaldic objectForKey:@"c_uname"];
                }
                else{
                    cell.mailIdLabel.text=NSLocalizedString(@"Not Available", nil);
                }
                
            }
            
            
            
            cell.timeStampLabel.text=[utils getLocalDateTimeFromUTC:[finaldic objectForKey:@"updated_at"]];
            
            
        } @catch (NSException *exception)
        {
            // Print exception information
//            NSLog( @"NSException caught in cellForRowAtIndexPath method in Inbox ViewController" );
//            NSLog( @"Name: %@", exception.name);
//            NSLog( @"Reason: %@", exception.reason );
            return cell;
        }
        @finally
        {
            // Cleanup, in both success and fail cases
         //   NSLog( @"In finally block");
            
        }
        // ______________________________________________________________________________________________________
        ////////////////for UTF-8 data encoding ///////
        //   cell.ticketSubLabel.text=[finaldic objectForKey:@"title"];
        
        
        
        // NSString *encodedString = @"=?UTF-8?Q?Re:_Robin_-_Implementing_Faveo_H?= =?UTF-8?Q?elp_Desk._Let=E2=80=99s_get_you_started.?=";
        
        
        
        
        
        NSString *encodedString =[finaldic objectForKey:@"ticket_title"];
        
        
        [Utils isEmpty:encodedString];
        
        if  ([Utils isEmpty:encodedString]){
            cell.ticketSubLabel.text=@"No Title";
        }
        else
        {
            
            NSMutableString *decodedString = [[NSMutableString alloc] init];
            
            if ([encodedString hasPrefix:@"=?UTF-8?Q?"] || [encodedString hasSuffix:@"?="])
            {
                NSScanner *scanner = [NSScanner scannerWithString:encodedString];
                NSString *buf = nil;
                //  NSMutableString *decodedString = [[NSMutableString alloc] init];
                
                while ([scanner scanString:@"=?UTF-8?Q?" intoString:NULL]
                       || ([scanner scanUpToString:@"=?UTF-8?Q?" intoString:&buf] && [scanner scanString:@"=?UTF-8?Q?" intoString:NULL])) {
                    if (buf != nil) {
                        [decodedString appendString:buf];
                    }
                    
                    buf = nil;
                    
                    NSString *encodedRange;
                    
                    if (![scanner scanUpToString:@"?=" intoString:&encodedRange]) {
                        break; // Invalid encoding
                    }
                    
                    [scanner scanString:@"?=" intoString:NULL]; // Skip the terminating "?="
                    
                    // Decode the encoded portion (naively using UTF-8 and assuming it really is Q encoded)
                    // I'm doing this really naively, but it should work
                    
                    // Firstly I'm encoding % signs so I can cheat and turn this into a URL-encoded string, which NSString can decode
                    encodedRange = [encodedRange stringByReplacingOccurrencesOfString:@"%" withString:@"=25"];
                    
                    // Turn this into a URL-encoded string
                    encodedRange = [encodedRange stringByReplacingOccurrencesOfString:@"=" withString:@"%"];
                    
                    
                    // Remove the underscores
                    encodedRange = [encodedRange stringByReplacingOccurrencesOfString:@"_" withString:@" "];
                    
                    // [decodedString appendString:[encodedRange stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                    
                    NSString *str1= [encodedRange stringByRemovingPercentEncoding];
                    [decodedString appendString:str1];
                    
                    
                }
                
                NSLog(@"Decoded string = %@", decodedString);
                
                cell.ticketSubLabel.text= decodedString;
            }
            else{
                
                cell.ticketSubLabel.text= encodedString;
                
            }
            
        }
        ///////////////////////////////////////////////////
        //____________________________________________________________________________________________________
        
        
        
        
        
        
        // [cell setUserProfileimage:[finaldic objectForKey:@"profile_pic"]];
        @try{
            
            if (  ![[finaldic objectForKey:@"profile_pic"] isEqual:[NSNull null]]   )
            {
                [cell setUserProfileimage:[finaldic objectForKey:@"profile_pic"]];
                
            }
            else
            {
                [cell setUserProfileimage:@"default_pic.png"];
            }
            
            
            if ( ( ![[finaldic objectForKey:@"duedate"] isEqual:[NSNull null]] ) && ( [[finaldic objectForKey:@"duedate"] length] != 0 ) ) {
                
                /* if([utils compareDates:[finaldic objectForKey:@"overdue_date"]]){
                 [cell.overDueLabel setHidden:NO];
                 
                 }else [cell.overDueLabel setHidden:YES];
                 
                 } */
                
                if([utils compareDates:[finaldic objectForKey:@"duedate"]]){
                    [cell.overDueLabel setHidden:NO];
                    [cell.today setHidden:YES];
                }else
                {
                    [cell.overDueLabel setHidden:YES];
                    [cell.today setHidden:NO];
                }
                
            }
            
            
            
            cell.indicationView.layer.backgroundColor=[[UIColor hx_colorWithHexRGBAString:[finaldic objectForKey:@"color"]] CGColor];
            
            
            
        }@catch (NSException *exception)
        {
            // Print exception information
//            NSLog( @"NSException caught in cellForRowAtIndexPath method in Inbox ViewController" );
//            NSLog( @"Name: %@", exception.name);
//            NSLog( @"Reason: %@", exception.reason );
            return cell;
        }
        @finally
        {
            // Cleanup, in both success and fail cases
          //  NSLog( @"In finally block");
            
        }
        
        return cell;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TicketDetailViewController *td=[self.storyboard instantiateViewControllerWithIdentifier:@"TicketDetailVCID"];
    
    NSDictionary *finaldic=[_mutableArray objectAtIndex:indexPath.row];
    
    globalVariables.iD=[finaldic objectForKey:@"id"];
    globalVariables.ticket_number=[finaldic objectForKey:@"ticket_number"];
    
    globalVariables.First_name=[finaldic objectForKey:@"c_fname"];
    globalVariables.Last_name=[finaldic objectForKey:@"c_lname"];
    
    globalVariables.Ticket_status=[finaldic objectForKey:@"ticket_status_name"];
    
    
    
    [self.navigationController pushViewController:td animated:YES];
}

#pragma mark - SlideNavigationController Methods -

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

-(void)addBtnPressed{
    
    
    CreateTicketViewController *createTicket=[self.storyboard instantiateViewControllerWithIdentifier:@"CreateTicket"];
    
    [self.navigationController pushViewController:createTicket animated:YES];
    
}

-(void)NotificationBtnPressed

{
    
    globalVariables.ticket_number=[tempDict objectForKey:@"ticket_number"];
    globalVariables.Ticket_status=[tempDict objectForKey:@"ticket_status_name"];
    
    NotificationViewController *not=[self.storyboard instantiateViewControllerWithIdentifier:@"Notify"];
    
    
    [self.navigationController pushViewController:not animated:YES];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [[self navigationController] setNavigationBarHidden:NO];
    
}

-(void)addUIRefresh{
    
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSAttributedString *refreshing = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Refreshing",nil) attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18], NSParagraphStyleAttributeName : paragraphStyle,NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    refresh=[[UIRefreshControl alloc] init];
    refresh.tintColor=[UIColor whiteColor];
    refresh.backgroundColor = [UIColor colorWithRed:0.46 green:0.8 blue:1.0 alpha:1.0];
    refresh.attributedTitle =refreshing;
    [refresh addTarget:self action:@selector(reloadd) forControlEvents:UIControlEventValueChanged];
    [_tableView insertSubview:refresh atIndex:0];
    
}



-(void)reloadd{
    [self reload];
    //    [refresh endRefreshing];
}


#pragma mark - lazy

- (CFMultistageDropdownMenuView *)multistageDropdownMenuView
{
    // DEMO
    _multistageDropdownMenuView = [[CFMultistageDropdownMenuView alloc] initWithFrame:CGRectMake(0, -5, CFScreenWidth, 45)];
    
    
    //
    // main top menu 2 menu aahet aata
    _multistageDropdownMenuView.defaulTitleArray = [NSArray arrayWithObjects:@"Filter",@"Sort by", nil];
    
    NSArray *leftArr = @[
                         // Filter - left array
                         @[@"Departments", @"Helptopic", @"SLA Plans", @"Priorities", @"Assigned", @"Source",@"Ticket Type",@"clear"],
                         // sort - left array
                         @[@"ticket title", @"ticket number", @"priority", @"updated at", @"created at",@"due on"],
                         //
                         @[]
                         ];
    NSArray *rightArr = @[
                          // 对应dataSourceLeftArray
                          @[
                              
                              @[@"All",@"Operation",@"Sales",@"Support"],
                              
                              @[@"Sales Query", @"Support Query", @"Operational Query"],
                              
                              @[@"Emergency", @"High", @"Low", @"Normal"],
                              
                              @[@"Emergency", @"High", @"Low",@"Normal"],
                              
                              @[@"No", @"Yes"],
                              
                              @[@"agent", @"call", @"chat", @"email",@"facebook",@"twitter",@"web"],
                              
                              @[@"Feature Request", @"Incident", @"Problem",@"Question"],
                              
                              ],
                          @[
                              // 一级菜单
                              // 金额
                              @[@"ASC", @"DES"], @[@"ASC", @"DES"], @[@"ASC", @"DES"], @[@"ASC", @"DES"],@[@"ASC", @"DES"],@[@"ASC", @"DES"]
                              ],
                          //                          @[
                          //                              // 一级菜单
                          //                              // 排序
                          //                              @[@"全部", @"人气最高", @"最新加入", @"金额从低到高", @"金额从高到低"]
                          //                              ]
                          //
                          ];
    
    [_multistageDropdownMenuView setupDataSourceLeftArray:leftArr rightArray:rightArr];
    
    _multistageDropdownMenuView.delegate = self;
    
    // 下拉列表 起始y
    _multistageDropdownMenuView.startY = CGRectGetMaxY(_multistageDropdownMenuView.frame);
    
    //    _multistageDropdownMenuView.maxRowCount = 3;
    _multistageDropdownMenuView.stateConfigDict = @{
                                                    @"selected" : @[[UIColor purpleColor], @"测试紫箭头"],
                                                    @"normal" : @[[UIColor redColor], @"测试红箭头"]
                                                    };
    
    
    
    
    return _multistageDropdownMenuView;
    
}

#pragma mark - CFMultistageDropdownMenuViewDelegate
- (void)multistageDropdownMenuView:(CFMultistageDropdownMenuView *)multistageDropdownMenuView selecteTitleButtonIndex:(NSInteger)titleButtonIndex conditionLeftIndex:(NSInteger)leftIndex conditionRightIndex:(NSInteger)rightIndex
{
    
    
    
    // sort by - Tciket title// UNASSIGNED
    if(titleButtonIndex==1 && leftIndex==0 && rightIndex==0 )
    {
        
        NSLog(@"Ticket title - ASC");
        
//        if(([globalVariables.sortAlert isEqualToString:@"sortTitleAscAlert"] && [globalVariables.sortCondition isEqualToString:@"INBOX"] ) || ([globalVariables.sortAlert isEqualToString:@"sortTitleAscAlert"] && [globalVariables.sortCondition isEqualToString:@"MYTICKETS"] ) || ([globalVariables.sortAlert isEqualToString:@"sortTitleAscAlert"] && [globalVariables.sortCondition isEqualToString:@"UNASSIGNED"] )|| ([globalVariables.sortAlert isEqualToString:@"sortTitleDscAlert"] && [globalVariables.sortCondition isEqualToString:@"CLOSED"] ) || ([globalVariables.sortAlert isEqualToString:@"sortTitleDscAlert"] && [globalVariables.sortCondition isEqualToString:@"TRASH"] ))
    if([globalVariables.sortAlert isEqualToString:@"sortTitleAscAlert"] && ([globalVariables.sortCondition isEqualToString:@"INBOX"] || [globalVariables.sortCondition isEqualToString:@"MYTICKETS"] || [globalVariables.sortCondition isEqualToString:@"UNASSIGNED"] || [globalVariables.sortCondition isEqualToString:@"CLOSED"] || [globalVariables.sortCondition isEqualToString:@"TRASH"]) )
        {
         [utils showAlertWithMessage:@"Sorted Already in Ascending order " sendViewController:self];
           
        }
        else
        {
            if([globalVariables.sortingValueId isEqualToString:@"sortTitleAsc"])
            {
                 [utils showAlertWithMessage:@"Sorted Already in Ascending order " sendViewController:self];
            }else{
            globalVariables.sortingValueId=@"sortTitleAsc";
        
             SortingViewController * sort=[self.storyboard instantiateViewControllerWithIdentifier:@"sortID"];
            [self.navigationController pushViewController:sort animated:YES];
            }
        }
    }
    else if(titleButtonIndex==1 && leftIndex==0 && rightIndex==1 )
    {
        NSLog(@"Ticket Title  - DSC");
        
        if([globalVariables.sortAlert isEqualToString:@"sortTitleDscAlert"] && ([globalVariables.sortCondition isEqualToString:@"INBOX"] || [globalVariables.sortCondition isEqualToString:@"MYTICKETS"] || [globalVariables.sortCondition isEqualToString:@"UNASSIGNED"] || [globalVariables.sortCondition isEqualToString:@"CLOSED"] || [globalVariables.sortCondition isEqualToString:@"TRASH"]) )
        {
            [utils showAlertWithMessage:@"Sorted Already in Descending order " sendViewController:self];
        }else{
            if([globalVariables.sortingValueId isEqualToString:@"sortTitleDsc"])
            {
                [utils showAlertWithMessage:@"Sorted Already in Descending order " sendViewController:self];
            }else{
                  globalVariables.sortingValueId=@"sortTitleDsc";
        
                  SortingViewController * sort=[self.storyboard instantiateViewControllerWithIdentifier:@"sortID"];
                 [self.navigationController pushViewController:sort animated:YES];
            }
        }
    }
    
    //sort by - ticket number // globalVariables.sortAlert=@"sortNumberAscAlert";
    else  if(titleButtonIndex==1 && leftIndex==1 && rightIndex==0 )
    {
        NSLog(@" Ticket number - ASC");
        
        if([globalVariables.sortAlert isEqualToString:@"sortNumberAscAlert"] && ([globalVariables.sortCondition isEqualToString:@"INBOX"] || [globalVariables.sortCondition isEqualToString:@"MYTICKETS"] || [globalVariables.sortCondition isEqualToString:@"UNASSIGNED"] || [globalVariables.sortCondition isEqualToString:@"CLOSED"] || [globalVariables.sortCondition isEqualToString:@"TRASH"]) )
        {
            [utils showAlertWithMessage:@"Sorted Already in Ascending order " sendViewController:self];
        }else{
            if([globalVariables.sortingValueId isEqualToString:@"sortNumberAsc"])
            {
                 [utils showAlertWithMessage:@"Sorted Already in Ascending order " sendViewController:self];
            }else{
                 globalVariables.sortingValueId=@"sortNumberAsc";
        
                SortingViewController * sort=[self.storyboard instantiateViewControllerWithIdentifier:@"sortID"];
               [self.navigationController pushViewController:sort animated:YES];
            }
        }
    }
    else if(titleButtonIndex==1 && leftIndex==1 && rightIndex==1 )
    {
        NSLog(@" Ticket number - DSC");
        
        if([globalVariables.sortAlert isEqualToString:@"sortNumberDscAlert"] && ([globalVariables.sortCondition isEqualToString:@"INBOX"] || [globalVariables.sortCondition isEqualToString:@"MYTICKETS"] || [globalVariables.sortCondition isEqualToString:@"UNASSIGNED"] || [globalVariables.sortCondition isEqualToString:@"CLOSED"] || [globalVariables.sortCondition isEqualToString:@"TRASH"]) )
        {
            [utils showAlertWithMessage:@"Sorted Already in Descending order " sendViewController:self];
        }else{
            if([globalVariables.sortingValueId isEqualToString:@"sortNumberDsc"])
            {
                 [utils showAlertWithMessage:@"Sorted Already in Descending order " sendViewController:self];
            }else{
                   globalVariables.sortingValueId=@"sortNumberDsc";
        
                   SortingViewController * sort=[self.storyboard instantiateViewControllerWithIdentifier:@"sortID"];
                [self.navigationController pushViewController:sort animated:YES];
            }
        
        }
    }
    // sortPriorityDscAlert
    else if(titleButtonIndex==1 && leftIndex==2 && rightIndex==0 )
    {
        NSLog(@" Ticket priority - ASC");
        
        if([globalVariables.sortAlert isEqualToString:@"sortPriorityAscAlert"] && ([globalVariables.sortCondition isEqualToString:@"INBOX"] || [globalVariables.sortCondition isEqualToString:@"MYTICKETS"] || [globalVariables.sortCondition isEqualToString:@"UNASSIGNED"] || [globalVariables.sortCondition isEqualToString:@"CLOSED"] || [globalVariables.sortCondition isEqualToString:@"TRASH"]) )
        {
            [utils showAlertWithMessage:@"Sorted Already in Ascending order " sendViewController:self];
        }else{
            if([globalVariables.sortingValueId isEqualToString:@"sortPriorityAsc"])
            {
                [utils showAlertWithMessage:@"Sorted Already in Ascending order " sendViewController:self];
            }else{
                  globalVariables.sortingValueId=@"sortPriorityAsc";
        
                  SortingViewController * sort=[self.storyboard instantiateViewControllerWithIdentifier:@"sortID"];
                [self.navigationController pushViewController:sort animated:YES];
            }
        }
    }
    else if(titleButtonIndex==1 && leftIndex==2 && rightIndex==1 )
    {
        NSLog(@" Ticket priority - DSC");
        
        if([globalVariables.sortAlert isEqualToString:@"sortPriorityDscAlert"] && ([globalVariables.sortCondition isEqualToString:@"INBOX"] || [globalVariables.sortCondition isEqualToString:@"MYTICKETS"] || [globalVariables.sortCondition isEqualToString:@"UNASSIGNED"] || [globalVariables.sortCondition isEqualToString:@"CLOSED"] || [globalVariables.sortCondition isEqualToString:@"TRASH"]) )
        {
            [utils showAlertWithMessage:@"Sorted Already in Descending order " sendViewController:self];
        }else{
            if([globalVariables.sortingValueId isEqualToString:@"sortPriorityDsc"])
            {
                [utils showAlertWithMessage:@"Sorted Already in Descending order " sendViewController:self];
            }else{
                  globalVariables.sortingValueId=@"sortPriorityDsc";
        
                 SortingViewController * sort=[self.storyboard instantiateViewControllerWithIdentifier:@"sortID"];
               [self.navigationController pushViewController:sort animated:YES];
            }
        }
    }
    //sortUpdatedDscAlert
    else if(titleButtonIndex==1 && leftIndex==3 && rightIndex==0 )
    {
        NSLog(@" upated at - ASC");
        
        if([globalVariables.sortAlert isEqualToString:@"sortUpdatedAscAlert"] && ([globalVariables.sortCondition isEqualToString:@"INBOX"] || [globalVariables.sortCondition isEqualToString:@"MYTICKETS"] || [globalVariables.sortCondition isEqualToString:@"UNASSIGNED"] || [globalVariables.sortCondition isEqualToString:@"CLOSED"] || [globalVariables.sortCondition isEqualToString:@"TRASH"]) )
        {
             [utils showAlertWithMessage:@"Sorted Already in Ascending order " sendViewController:self];
        }else{
            if([globalVariables.sortingValueId isEqualToString:@"sortUpdatedAsc"])
            {
                [utils showAlertWithMessage:@"Sorted Already in Ascending order " sendViewController:self];
            }else{
                   globalVariables.sortingValueId=@"sortUpdatedAsc";
        
                  SortingViewController * sort=[self.storyboard instantiateViewControllerWithIdentifier:@"sortID"];
                [self.navigationController pushViewController:sort animated:YES];
            }
        
        }
    }
    else if(titleButtonIndex==1 && leftIndex==3 && rightIndex==1 )
    {
        NSLog(@" upated at - DSC");
        
        if([globalVariables.sortAlert isEqualToString:@"sortUpdatedDscAlert"] && ([globalVariables.sortCondition isEqualToString:@"INBOX"] || [globalVariables.sortCondition isEqualToString:@"MYTICKETS"] || [globalVariables.sortCondition isEqualToString:@"UNASSIGNED"] || [globalVariables.sortCondition isEqualToString:@"CLOSED"] || [globalVariables.sortCondition isEqualToString:@"TRASH"]) )
        {
            [utils showAlertWithMessage:@"Sorted Already in Descending order " sendViewController:self];
        }else{
            if([globalVariables.sortingValueId isEqualToString:@"sortUpdatedDsc"])
            {
                [utils showAlertWithMessage:@"Sorted Already in Descending order " sendViewController:self];
            }else{
                  globalVariables.sortingValueId=@"sortUpdatedDsc";
        
                  SortingViewController * sort=[self.storyboard instantiateViewControllerWithIdentifier:@"sortID"];
                 [self.navigationController pushViewController:sort animated:YES];
            }
        
        }
    }
    //sortCreatedAscAlert
    else if(titleButtonIndex==1 && leftIndex==4 && rightIndex==0 )
    {
        NSLog(@" created At - ASC");
        
        if([globalVariables.sortAlert isEqualToString:@"sortCreatedAscAlert"] && ([globalVariables.sortCondition isEqualToString:@"INBOX"] || [globalVariables.sortCondition isEqualToString:@"MYTICKETS"] || [globalVariables.sortCondition isEqualToString:@"UNASSIGNED"] || [globalVariables.sortCondition isEqualToString:@"CLOSED"] || [globalVariables.sortCondition isEqualToString:@"TRASH"]) )
        {
            [utils showAlertWithMessage:@"Sorted Already in Ascending order " sendViewController:self];
        }else{
            if([globalVariables.sortingValueId isEqualToString:@"sortCreatedAsc"])
            {
                 [utils showAlertWithMessage:@"Sorted Already in Ascending order " sendViewController:self];
            }else{
                     globalVariables.sortingValueId=@"sortCreatedAsc";
        
                     SortingViewController * sort=[self.storyboard instantiateViewControllerWithIdentifier:@"sortID"];
                   [self.navigationController pushViewController:sort animated:YES];
            }
        }
    }
    else if(titleButtonIndex==1 && leftIndex==4 && rightIndex==1 )
    {
        NSLog(@" created At - DSC");
        
        if([globalVariables.sortAlert isEqualToString:@"sortCreatedDscAlert"] && ([globalVariables.sortCondition isEqualToString:@"INBOX"] || [globalVariables.sortCondition isEqualToString:@"MYTICKETS"] || [globalVariables.sortCondition isEqualToString:@"UNASSIGNED"] || [globalVariables.sortCondition isEqualToString:@"CLOSED"] || [globalVariables.sortCondition isEqualToString:@"TRASH"]) )
        {
             [utils showAlertWithMessage:@"Sorted Already in Descending order " sendViewController:self];
        }else{
            if([globalVariables.sortingValueId isEqualToString:@"sortCreatedDsc"])
            {
                [utils showAlertWithMessage:@"Sorted Already in Descending order " sendViewController:self];
            }else{
                globalVariables.sortingValueId=@"sortCreatedDsc";
        
                SortingViewController * sort=[self.storyboard instantiateViewControllerWithIdentifier:@"sortID"];
              [self.navigationController pushViewController:sort animated:YES];
            }
        }
    }
    // due on // sortDueAscAlert
    else if(titleButtonIndex==1 && leftIndex==5 && rightIndex==0 )
    {
        NSLog(@" due on - ASC");
        
        if([globalVariables.sortAlert isEqualToString:@"sortDueAscAlert"] && ([globalVariables.sortCondition isEqualToString:@"INBOX"] || [globalVariables.sortCondition isEqualToString:@"MYTICKETS"] || [globalVariables.sortCondition isEqualToString:@"UNASSIGNED"] || [globalVariables.sortCondition isEqualToString:@"CLOSED"] || [globalVariables.sortCondition isEqualToString:@"TRASH"]) )
        {
           [utils showAlertWithMessage:@"Sorted Already in Ascending order " sendViewController:self];
        }else{
            if([globalVariables.sortingValueId isEqualToString:@"sortDueAsc"])
            {
                [utils showAlertWithMessage:@"Sorted Already in Ascending order " sendViewController:self];
            }else{
                  globalVariables.sortingValueId=@"sortDueAsc";
        
                  SortingViewController * sort=[self.storyboard instantiateViewControllerWithIdentifier:@"sortID"];
               [self.navigationController pushViewController:sort animated:YES];
            }
        }
    }
    else if(titleButtonIndex==1 && leftIndex==5 && rightIndex==1 )
    {
        NSLog(@" due on - DSC");
        
        if([globalVariables.sortAlert isEqualToString:@"sortDueDscAlert"] && ([globalVariables.sortCondition isEqualToString:@"INBOX"] || [globalVariables.sortCondition isEqualToString:@"MYTICKETS"] || [globalVariables.sortCondition isEqualToString:@"UNASSIGNED"] || [globalVariables.sortCondition isEqualToString:@"CLOSED"] || [globalVariables.sortCondition isEqualToString:@"TRASH"]) )
        {
            [utils showAlertWithMessage:@"Sorted Already in Descending order " sendViewController:self];
        }else{
            if([globalVariables.sortingValueId isEqualToString:@"sortDueDsc"])
            {
                [utils showAlertWithMessage:@"Sorted Already in Descending order " sendViewController:self];
            }else{
                    globalVariables.sortingValueId=@"sortDueDsc";
        
                   SortingViewController * sort=[self.storyboard instantiateViewControllerWithIdentifier:@"sortID"];
                  [self.navigationController pushViewController:sort animated:YES];
            }
        }
    }
    else
    {
    }
    
    
    NSString *titleStr = [multistageDropdownMenuView.defaulTitleArray objectAtIndex:titleButtonIndex];
    NSArray *leftArr = [multistageDropdownMenuView.dataSourceLeftArray objectAtIndex:titleButtonIndex];
    NSArray *rightArr = [multistageDropdownMenuView.dataSourceRightArray objectAtIndex:titleButtonIndex];
    NSString *leftStr = @"";
    NSString *rightStr = @"";
    NSString *str2 = @"";
    if (leftArr.count>0) { // 二级菜单
        leftStr = [leftArr objectAtIndex:leftIndex];
        NSArray *arr = [rightArr objectAtIndex:leftIndex];
        rightStr = [arr objectAtIndex:rightIndex];
        //imp pop 2
        str2 = [NSString stringWithFormat:@"titleStr \"%@\" 分类下的 \"%@\"-\"%@\"", titleStr, leftStr, rightStr];
    } else {
        rightStr = [rightArr[0] objectAtIndex:rightIndex];
        str2 = [NSString stringWithFormat:@"titleStr \"%@\" rightStr \"%@\"", titleStr, rightStr];
    }
    
    NSMutableString *mStr22 = [NSMutableString stringWithFormat:@" "];
    NSArray *btnArr = multistageDropdownMenuView.titleButtonArray;
    for (UIButton *btn in btnArr) {
        [mStr22 appendString:[NSString stringWithFormat:@"\"%@\"", btn.titleLabel.text]];
        [mStr22 appendString:@" "];
    }
    NSString *str22 = [NSString stringWithFormat:@"2nd Pop up:\n (%@)", mStr22];
    NSLog(@"%@",str22);
    
    //  NSString *str = [NSString stringWithFormat:@"Filter\n TiltleButton Index is %zd, leftIndex is %zd, rightIndex %zd",titleButtonIndex, leftIndex, rightIndex];
    
    
    
    
    
    //    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"1st popUp" message:str preferredStyle:UIAlertControllerStyleAlert];
    //    [self presentViewController:alertController animated:NO completion:^{
    //        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    //
    //            UIAlertController *alertController2 = [UIAlertController alertControllerWithTitle:str22 message:str2 preferredStyle:UIAlertControllerStyleAlert];
    //            [self presentViewController:alertController2 animated:NO completion:^{
    //                UIAlertAction *alertAction2 = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    //
    //                }];
    //                [alertController2 addAction:alertAction2];
    //            }];
    //
    //        }];
    //        [alertController addAction:alertAction];
    //    }];
    //
}



- (void)multistageDropdownMenuView:(CFMultistageDropdownMenuView *)multistageDropdownMenuView selectTitleButtonWithCurrentTitle:(NSString *)currentTitle currentTitleArray:(NSArray *)currentTitleArray
{
    NSMutableString *mStr = [NSMutableString stringWithFormat:@" "];
    
    for (NSString *str in currentTitleArray) {
        [mStr appendString:[NSString stringWithFormat:@"\"%@\"", str]];
        [mStr appendString:@" "];
    }
    NSString *str = [NSString stringWithFormat:@"当前选中的是 \"%@\" \n 当前展示的所有条件是:\n (%@)",currentTitle, mStr];
    NSLog(@"%@",str);
    
    
    //    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"第二个代理方法" message:str preferredStyle:UIAlertControllerStyleAlert];
    //    [self presentViewController:alertController animated:NO completion:^{
    //        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    //
    //
    //        }];
    //        [alertController addAction:alertAction];
    //    }];
}



@end