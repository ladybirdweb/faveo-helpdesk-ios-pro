//
//  FilterLogic.m
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 14/11/17.
//  Copyright © 2017 Ladybird websolutions pvt ltd. All rights reserved.
//

#import "FilterLogic.h"
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
#import "FilterViewController.h"

@import FirebaseInstanceID;
@import FirebaseMessaging;

@interface FilterLogic ()<RMessageProtocol,CFMultistageDropdownMenuViewDelegate>
{
    
    Utils *utils;
    UIRefreshControl *refresh;
    NSUserDefaults *userDefaults;
    GlobalVariables *globalVariables;
    NSDictionary *tempDict;
    NSString *url;
    BDCustomAlertView *customAlert ;
    
    NSString * assignee111;
    NSString *dep111;
    NSString * apiValue;
    
    NSString * showInbox;
     NSString * showMyTickets;
     NSString * showUnassignedTickets;
     NSString * showClosedTickets;
     NSString * showTashTickets;
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

@implementation FilterLogic

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addUIRefresh];
    
    customAlert = [[BDCustomAlertView alloc] init];
    _multistageDropdownMenuView.tag=99;
    
    globalVariables=[GlobalVariables sharedInstance];
    userDefaults=[NSUserDefaults standardUserDefaults];
    
    if([globalVariables.filterId isEqualToString:@"INBOXFilter"])
    {
        [self setTitle:NSLocalizedString(@"Inbox",nil)];
    }else if([globalVariables.filterId isEqualToString:@"MYTICKETSFilter"])
    {
        [self setTitle:NSLocalizedString(@"My Tickets",nil)];
    }else if([globalVariables.filterId isEqualToString:@"UNASSIGNEDFilter"])
    {
        [self setTitle:NSLocalizedString(@"Unassigned Tickets",nil)];
    }else if([globalVariables.filterId isEqualToString:@"CLOSEDFilter"])
    {
        [self setTitle:NSLocalizedString(@"Closed Tickets",nil)];
    }else if([globalVariables.filterId isEqualToString:@"TRASHFilter"])
    {
        [self setTitle:NSLocalizedString(@"Trash Tickets",nil)];
    }
    
    self.view.backgroundColor=[UIColor grayColor];
    [self.view addSubview:self.multistageDropdownMenuView];
    
    
    NSString *refreshedToken = [[FIRInstanceID instanceID] token];
    NSLog(@"refreshed token  %@",refreshedToken);
    
    _mutableArray=[[NSMutableArray alloc]init];
    
    utils=[[Utils alloc]init];
    globalVariables=[GlobalVariables sharedInstance];
    userDefaults=[NSUserDefaults standardUserDefaults];
    
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
        
        
        
    }else {
        
        //              NSString * url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&priority=%@&types=%@&source=%@&status=%@&assigned=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,dep111,globalVariables.prioo1,globalVariables.typee1,globalVariables.sourcee1,globalVariables.statuss1,assignee111];
        //            NSLog(@"URL is : %@",url);
        
        
        if([globalVariables.filterId isEqualToString:@"INBOXFilter"]){ // Tikcet Filter
            
            //  http://jamboreebliss.com/sayar/public/api/v2/helpdesk/get-tickets?token=%@&api=1&show=inbox&departments=%@&source=%@&priority=%@&assigned=1&types=%@
            //departments priority types source status assigned
            
               apiValue=[NSString stringWithFormat:@"%i",1];
               showInbox = @"inbox";
            //  NSString * Alldeparatments=@"All";
            
              dep111=[NSString stringWithFormat:@"%@",globalVariables.deptt1];

            [Utils isEmpty:dep111];
            if([Utils isEmpty:dep111] || [dep111 isEqualToString:@""])
            {
                dep111=@"All";
            }
            else
            {
                dep111= [NSString stringWithFormat:@"%@",globalVariables.deptt1];
            }
//
             assignee111= [NSString stringWithFormat:@"%@",globalVariables.assignn1];

            if([assignee111 isEqualToString:@"Yes"])
            {
                assignee111=@"1";
            }else if([assignee111 isEqualToString:@"No"])
            {
                assignee111=@"0";
            }else  if([Utils isEmpty:assignee111] || [assignee111 isEqualToString:@""])
            {
                assignee111=@"";
            }

            
            [self apiCallMethod];
            
        }else if([globalVariables.filterId isEqualToString:@"MYTICKETSFilter"]){ // Tikcet Filter
            
            //  http://jamboreebliss.com/sayar/public/api/v2/helpdesk/get-tickets?token=%@&api=1&show=inbox&departments=%@&source=%@&priority=%@&assigned=1&types=%@
            //departments priority types source status assigned
            
            apiValue=[NSString stringWithFormat:@"%i",1];
            showInbox = @"mytickets";
            //  NSString * Alldeparatments=@"All";
            
            dep111=[NSString stringWithFormat:@"%@",globalVariables.deptt1];
            
            [Utils isEmpty:dep111];
            if([Utils isEmpty:dep111] || [dep111 isEqualToString:@""])
            {
                dep111=@"All";
            }
            else
            {
                dep111= [NSString stringWithFormat:@"%@",globalVariables.deptt1];
            }
            //
            assignee111= [NSString stringWithFormat:@"%@",globalVariables.assignn1];
            
            if([assignee111 isEqualToString:@"Yes"])
            {
                assignee111=@"1";
            }else if([assignee111 isEqualToString:@"No"])
            {
                assignee111=@"0";
            }else  if([Utils isEmpty:assignee111] || [assignee111 isEqualToString:@""])
            {
                assignee111=@"";
            }
            
            
            [self apiCallMethod];
            
        }
        else if([globalVariables.filterId isEqualToString:@"CLOSEDFilter"]){ // Tikcet Filter
            
            //  http://jamboreebliss.com/sayar/public/api/v2/helpdesk/get-tickets?token=%@&api=1&show=inbox&departments=%@&source=%@&priority=%@&assigned=1&types=%@
            //departments priority types source status assigned
            
            apiValue=[NSString stringWithFormat:@"%i",1];
            showInbox = @"closed";
            //  NSString * Alldeparatments=@"All";
            
            dep111=[NSString stringWithFormat:@"%@",globalVariables.deptt1];
            
            [Utils isEmpty:dep111];
            if([Utils isEmpty:dep111] || [dep111 isEqualToString:@""])
            {
                dep111=@"All";
            }
            else
            {
                dep111= [NSString stringWithFormat:@"%@",globalVariables.deptt1];
            }
            //
            assignee111= [NSString stringWithFormat:@"%@",globalVariables.assignn1];
            
            if([assignee111 isEqualToString:@"Yes"])
            {
                assignee111=@"1";
            }else if([assignee111 isEqualToString:@"No"])
            {
                assignee111=@"0";
            }else  if([Utils isEmpty:assignee111] || [assignee111 isEqualToString:@""])
            {
                assignee111=@"";
            }
            
            
            [self apiCallMethod];
            
        }
        else if([globalVariables.filterId isEqualToString:@"TRASHFilter"]){ // Tikcet Filter
            
            //  http://jamboreebliss.com/sayar/public/api/v2/helpdesk/get-tickets?token=%@&api=1&show=inbox&departments=%@&source=%@&priority=%@&assigned=1&types=%@
            //departments priority types source status assigned
            
            apiValue=[NSString stringWithFormat:@"%i",1];
            showInbox = @"trash";
            //  NSString * Alldeparatments=@"All";
            
            dep111=[NSString stringWithFormat:@"%@",globalVariables.deptt1];
            
            [Utils isEmpty:dep111];
            if([Utils isEmpty:dep111] || [dep111 isEqualToString:@""])
            {
                dep111=@"All";
            }
            else
            {
                dep111= [NSString stringWithFormat:@"%@",globalVariables.deptt1];
            }
            //
            assignee111= [NSString stringWithFormat:@"%@",globalVariables.assignn1];
            
            if([assignee111 isEqualToString:@"Yes"])
            {
                assignee111=@"1";
            }else if([assignee111 isEqualToString:@"No"])
            {
                assignee111=@"0";
            }else  if([Utils isEmpty:assignee111] || [assignee111 isEqualToString:@""])
            {
                assignee111=@"";
            }
            
            
            [self apiCallMethod];
            
        }
        
        
    }
}


-(void)apiCallMethod
{
    
    if(![Utils isEmpty:dep111] &&([Utils isEmpty:globalVariables.prioo1] && [Utils isEmpty:globalVariables.typee1] && [Utils isEmpty:globalVariables.sourcee1] &&  [Utils isEmpty:globalVariables.statuss1] && [Utils isEmpty:assignee111]) )
    {
        
        url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,dep111];
        
        NSLog(@"URL is : %@",url);
    }
    
    // priority  is not empty
   else if(![Utils isEmpty:globalVariables.prioo1] && ( [Utils isEmpty:globalVariables.typee1] && [Utils isEmpty:globalVariables.sourcee1] &&  [Utils isEmpty:globalVariables.statuss1] && [Utils isEmpty:assignee111]) )
    {
        url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&priority=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,dep111,globalVariables.prioo1];
        NSLog(@"URL is : %@",url);
    }
    // priority and type in not empty
  else  if((![Utils isEmpty:globalVariables.prioo1] && ![Utils isEmpty:globalVariables.typee1]) &&([Utils isEmpty:globalVariables.sourcee1] && [Utils isEmpty:globalVariables.statuss1] && [Utils isEmpty:assignee111]) )
    {
        url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&priority=%@&types=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,dep111,globalVariables.prioo1,globalVariables.typee1];
        NSLog(@"URL is : %@",url);
        
    }
    // prioity, type and source in not empty
  else  if((![Utils isEmpty:globalVariables.prioo1] && ![Utils isEmpty:globalVariables.typee1] && ![Utils isEmpty:globalVariables.sourcee1]) &&([Utils isEmpty:globalVariables.statuss1] && [Utils isEmpty:assignee111]) )
    {
        url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&priority=%@&types=%@&source=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,dep111,globalVariables.prioo1,globalVariables.typee1,globalVariables.sourcee1];
        NSLog(@"URL is : %@",url);
        
    }
    
    // prioity, type , source and status in not empty
   else if((![Utils isEmpty:globalVariables.prioo1] && ![Utils isEmpty:globalVariables.typee1] && ![Utils isEmpty:globalVariables.sourcee1] && ![Utils isEmpty:globalVariables.statuss1] ) && ([Utils isEmpty:assignee111]) )
    {
        
        url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&priority=%@&types=%@&source=%@&status=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,dep111,globalVariables.prioo1,globalVariables.typee1,globalVariables.sourcee1,globalVariables.sourcee1];
        NSLog(@"URL is : %@",url);
        
    }
    //  prioity, type , source and status & assignee in not empty
  else  if((![Utils isEmpty:globalVariables.prioo1] && ![Utils isEmpty:globalVariables.typee1] && ![Utils isEmpty:globalVariables.sourcee1] && ![Utils isEmpty:globalVariables.statuss1] && ![Utils isEmpty:assignee111]) )
    {
        url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&priority=%@&types=%@&source=%@&status=%@&assigned=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,dep111,globalVariables.prioo1,globalVariables.typee1,globalVariables.sourcee1,globalVariables.sourcee1,assignee111];
        NSLog(@"URL is : %@",url);
        
    }
    
    
    
    // type in not empty
  else  if(![Utils isEmpty:globalVariables.typee1] && ( [Utils isEmpty:globalVariables.prioo1] && [Utils isEmpty:globalVariables.sourcee1] &&  [Utils isEmpty:globalVariables.statuss1] && [Utils isEmpty:assignee111]) )
    {
        url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&types=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,dep111,globalVariables.typee1];
        NSLog(@"URL is : %@",url);
    }
    
    // type and source not empty
 else   if((![Utils isEmpty:globalVariables.typee1] && ![Utils isEmpty:globalVariables.sourcee1]) && ( [Utils isEmpty:globalVariables.prioo1] && [Utils isEmpty:globalVariables.statuss1] && [Utils isEmpty:assignee111]) )
    {
        url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&types=%@&source=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,dep111,globalVariables.typee1,globalVariables.sourcee1];
        NSLog(@"URL is : %@",url);
    }
    // type, source and priority not empty
else    if((![Utils isEmpty:globalVariables.typee1] && ![Utils isEmpty:globalVariables.sourcee1] && ![Utils isEmpty:globalVariables.prioo1]) && ([Utils isEmpty:globalVariables.statuss1] && [Utils isEmpty:assignee111]) )
    {
        
        url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&types=%@&source=%@&priority=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,dep111,globalVariables.typee1,globalVariables.sourcee1,globalVariables.prioo1];
        NSLog(@"URL is : %@",url);
        
    }
    
    // type, source ,priority and status not empty
 else   if((![Utils isEmpty:globalVariables.typee1] && ![Utils isEmpty:globalVariables.sourcee1] && ![Utils isEmpty:globalVariables.prioo1] && ![Utils isEmpty:globalVariables.statuss1]) && ( [Utils isEmpty:assignee111]) )
    {
        
        url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&types=%@&source=%@&priority=%@&status=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,dep111,globalVariables.typee1,globalVariables.sourcee1,globalVariables.prioo1,globalVariables.statuss1];
        NSLog(@"URL is : %@",url);
        
    }
    
    // source is not empty
  else  if(![Utils isEmpty:globalVariables.sourcee1] && ( [Utils isEmpty:globalVariables.prioo1] && [Utils isEmpty:globalVariables.typee1] &&  [Utils isEmpty:globalVariables.statuss1] && [Utils isEmpty:assignee111]) )
    {
        url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&source=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,dep111,globalVariables.sourcee1];
        NSLog(@"URL is : %@",url);
    }
    
    //source and prioity is not empty
   else if((![Utils isEmpty:globalVariables.sourcee1] && ![Utils isEmpty:globalVariables.prioo1]) && ([Utils isEmpty:globalVariables.typee1] &&  [Utils isEmpty:globalVariables.statuss1] && [Utils isEmpty:assignee111]) )
    {
        url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&source=%@&priority=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,dep111,globalVariables.sourcee1,globalVariables.prioo1];
        NSLog(@"URL is : %@",url);
    }
    
    //source , prioity and type is not empty
   else if((![Utils isEmpty:globalVariables.sourcee1] && ![Utils isEmpty:globalVariables.prioo1] && ![Utils isEmpty:globalVariables.typee1]) && ([Utils isEmpty:globalVariables.statuss1] && [Utils isEmpty:assignee111]) )
    {
        
        url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&source=%@&priority=%@&types=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,dep111,globalVariables.sourcee1,globalVariables.prioo1,globalVariables.typee1];
        NSLog(@"URL is : %@",url);
        
    }
    
    //source , prioity , type and status is not empty
 else   if((![Utils isEmpty:globalVariables.sourcee1] && ![Utils isEmpty:globalVariables.prioo1] && ![Utils isEmpty:globalVariables.typee1] && ![Utils isEmpty:globalVariables.statuss1]) && ([Utils isEmpty:assignee111]) )
    {
        url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&source=%@&priority=%@&types=%@&status=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,dep111,globalVariables.sourcee1,globalVariables.prioo1,globalVariables.typee1,globalVariables.statuss1];
        NSLog(@"URL is : %@",url);
    }
    
    //status is not empty
  else  if(![Utils isEmpty:globalVariables.statuss1] && ( [Utils isEmpty:globalVariables.prioo1] && [Utils isEmpty:globalVariables.typee1] &&  [Utils isEmpty:globalVariables.sourcee1] && [Utils isEmpty:assignee111]) )
    {
        url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&status=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,dep111,globalVariables.statuss1];
        NSLog(@"URL is : %@",url);
    }
    
    //status and prioty not empty
  else  if((![Utils isEmpty:globalVariables.statuss1] && ![Utils isEmpty:globalVariables.prioo1] )&& ( [Utils isEmpty:globalVariables.typee1] &&  [Utils isEmpty:globalVariables.sourcee1] && [Utils isEmpty:assignee111]) )
    {
        url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&status=%@&priority=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,dep111,globalVariables.statuss1,globalVariables.prioo1];
        NSLog(@"URL is : %@",url);
        
    }
    
    //status, prioty and types not empty
   else if((![Utils isEmpty:globalVariables.statuss1] && ![Utils isEmpty:globalVariables.prioo1] && ![Utils isEmpty:globalVariables.typee1]) && ([Utils isEmpty:globalVariables.sourcee1] && [Utils isEmpty:assignee111]) )
    {
        
        url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&status=%@&priority=%@&types=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,dep111,globalVariables.statuss1,globalVariables.prioo1,globalVariables.typee1];
        NSLog(@"URL is : %@",url);
        
    }
    
    //status, prioty , types and source not empty
 else   if((![Utils isEmpty:globalVariables.statuss1] && ![Utils isEmpty:globalVariables.prioo1] && ![Utils isEmpty:globalVariables.typee1] && ![Utils isEmpty:globalVariables.sourcee1])&& ( [Utils isEmpty:assignee111]) )
    {
        
        url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&status=%@&priority=%@&types=%@&source=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,dep111,globalVariables.statuss1,globalVariables.prioo1,globalVariables.typee1,globalVariables.sourcee1];
        NSLog(@"URL is : %@",url);
        
    }
    
    
    // assignee is not empty
   else if(![Utils isEmpty:assignee111] && ( [Utils isEmpty:globalVariables.prioo1] && [Utils isEmpty:globalVariables.typee1] &&  [Utils isEmpty:globalVariables.sourcee1] && [Utils isEmpty:globalVariables.statuss1]) )
    {
        url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&assigned=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,dep111,assignee111];
        NSLog(@"URL is : %@",url);
    }
    
    
    // assignee, priotity  is not empty
  else    if((![Utils isEmpty:assignee111] && ![Utils isEmpty:globalVariables.prioo1] ) && ([Utils isEmpty:globalVariables.typee1] &&  [Utils isEmpty:globalVariables.sourcee1] && [Utils isEmpty:globalVariables.statuss1]) )
    {
        url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&assigned=%@&priority=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,dep111,assignee111,globalVariables.prioo1];
        NSLog(@"URL is : %@",url);
    }
    
    // assignee, priotity and types is not empty
   else if((![Utils isEmpty:assignee111] && ![Utils isEmpty:globalVariables.prioo1] && ![Utils isEmpty:globalVariables.typee1]) && ([Utils isEmpty:globalVariables.sourcee1] && [Utils isEmpty:globalVariables.statuss1]) )
    {
        url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&assigned=%@&priority=%@&types=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,dep111,assignee111,globalVariables.prioo1,globalVariables.typee1];
        NSLog(@"URL is : %@",url);
        
    }
    
    // assignee, priotity , types and source is not empty
    else if((![Utils isEmpty:assignee111] && ![Utils isEmpty:globalVariables.prioo1] && ![Utils isEmpty:globalVariables.typee1] && ![Utils isEmpty:globalVariables.sourcee1]) && ( [Utils isEmpty:globalVariables.statuss1]) )
    {
        url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&assigned=%@&priority=%@&types=%@&source=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,dep111,assignee111,globalVariables.prioo1,globalVariables.typee1,globalVariables.sourcee1];
        NSLog(@"URL is : %@",url);
    }
    else
    {
    }
    
    
        MyWebservices *webservices=[MyWebservices sharedInstance];
        globalVariables.urlFromFilterLogicView=url;
        [webservices httpResponseGET:url parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
            
            
            
            if (error || [msg containsString:@"Error"]) {
                [refresh endRefreshing];
                [[AppDelegate sharedAppdelegate] hideProgressView];
                if (msg) {
                    
                    NSLog(@"Error msg is : %@",msg);
                    [utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",msg] sendViewController:self];
                    
                }else if(error)  {
                    [utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",error.localizedDescription] sendViewController:self];
                    NSLog(@"Thread-NO4-getInbox-Refresh-error == %@",error.localizedDescription);
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
        
        if([globalVariables.filterId isEqualToString:@"INBOXFilter"])
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
        else if([globalVariables.filterId isEqualToString:@"MYTICKETSFilter"])
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
        else if([globalVariables.filterId isEqualToString:@"UNASSIGNEDFilter"])
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
        else if([globalVariables.filterId isEqualToString:@"CLOSEDFilter"])
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
        else if([globalVariables.filterId isEqualToString:@"TRASHFilter"])
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


//-(void)loadMore{
//
//    if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable)
//    {
//        //connection unavailable
//
//        //   [RKDropdownAlert title:APP_NAME message:NO_INTERNET backgroundColor:[UIColor hx_colorWithHexRGBAString:FAILURE_COLOR] textColor:[UIColor whiteColor]];
//
//        if (self.navigationController.navigationBarHidden) {
//            [self.navigationController setNavigationBarHidden:NO];
//        }
//
//        [RMessage showNotificationInViewController:self.navigationController
//                                             title:NSLocalizedString(@"Error..!", nil)
//                                          subtitle:NSLocalizedString(@"There is no Internet Connection...!", nil)
//                                         iconImage:nil
//                                              type:RMessageTypeError
//                                    customTypeName:nil
//                                          duration:RMessageDurationAutomatic
//                                          callback:nil
//                                       buttonTitle:nil
//                                    buttonCallback:nil
//                                        atPosition:RMessagePositionNavBarOverlay
//                              canBeDismissedByUser:YES];
//
//
//    }else{
//
//        @try{
//
//            self.page = _page + 1;
//            // NSLog(@"Page is : %ld",(long)_page);
//
//            NSString *str=_nextPageUrl;
//
//            // NSString *szHaystack= @"http://jamboreebliss.com/sayar/public/api/v2/helpdesk/get-tickets?page=2";
//            NSString *szNeedle= @"http://jamboreebliss.com/sayar/public/api/v2/helpdesk/get-tickets?page=";
//            NSRange range = [str rangeOfString:szNeedle];
//            NSInteger idx = range.location + range.length;
//            NSString *szResult = [str substringFromIndex:idx];
//            NSString *Page = [str substringFromIndex:idx];
//
//            NSLog(@"String is : %@",szResult);
//            NSLog(@"Page is : %@",Page);
//
//            MyWebservices *webservices=[MyWebservices sharedInstance];
//            [webservices getNextPageURLInbox:_path1 pageNo:Page  callbackHandler:^(NSError *error,id json,NSString* msg) {
//
//                //[webservices getNextPageURL:_nextPageUrl  callbackHandler:^(NSError *error,id json,NSString* msg) {
//
//                if (error || [msg containsString:@"Error"]) {
//
//                    if (msg) {
//
//                        [utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",msg] sendViewController:self];
//
//                    }else if(error)  {
//                        [utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",error.localizedDescription] sendViewController:self];
//                        NSLog(@"Thread-NO4-getInbox-Refresh-error == %@",error.localizedDescription);
//                    }
//                    return ;
//                }
//
//                if ([msg isEqualToString:@"tokenRefreshed"]) {
//
//                    [self loadMore];
//                    //NSLog(@"Thread--NO4-call-getInbox");
//                    return;
//                }
//
//                if (json) {
//                    NSLog(@"Thread-NO4--getInboxAPI--%@",json);
//                    //_indexPaths=[[NSArray alloc]init];
//                    //_indexPaths = [json objectForKey:@"data"];
//                    _nextPageUrl =[json objectForKey:@"next_page_url"];
//                    _currentPage=[[json objectForKey:@"current_page"] integerValue];
//                    _totalTickets=[[json objectForKey:@"total"] integerValue];
//                    _totalPages=[[json objectForKey:@"last_page"] integerValue];
//
//
//                    _mutableArray= [_mutableArray mutableCopy];
//
//                    [_mutableArray addObjectsFromArray:[json objectForKey:@"data"]];
//
//                    //                NSLog(@"Thread-NO4.1getInbox-dic--%@", _mutableArray);
//                    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            [self.tableView reloadData];
//                            //                        [self.tableView beginUpdates];
//                            //                        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[_mutableArray count]-[_indexPaths count] inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
//                            //                        [self.tableView endUpdates];
//                        });
//                    });
//
//                }
//                NSLog(@"Thread-NO5-getInbox-closed");
//
//            }];
//        }@catch (NSException *exception)
//        {
//            // Print exception information
//            //            NSLog( @"NSException caught in loadMore method in Inbox ViewController" );
//            //            NSLog( @"Name: %@", exception.name);
//            //            NSLog( @"Reason: %@", exception.reason );
//            return;
//        }
//        @finally
//        {
//            // Cleanup, in both success and fail cases
//            //  NSLog( @"In finally block");
//
//        }
//    }
//}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
            
            
            NSString *assigneeFirstName= [finaldic objectForKey:@"a_fname"];
            NSString *assigneeLaststName= [finaldic objectForKey:@"a_lname"];
            NSString *assigneeUserName= [finaldic objectForKey:@"a_uname"];
            
            [Utils isEmpty:assigneeFirstName];
            [Utils isEmpty:assigneeLaststName];
            [Utils isEmpty:assigneeUserName];
            
            if (![Utils isEmpty:assigneeFirstName] || ![Utils isEmpty:assigneeLaststName])
            {
                if  (![Utils isEmpty:assigneeFirstName] && ![Utils isEmpty:assigneeLaststName])
                {
                    cell.agentLabel.text=[NSString stringWithFormat:@"%@ %@",[finaldic objectForKey:@"a_fname"],[finaldic objectForKey:@"a_lname"]];
                }
                else
                {
                    cell.agentLabel.text=[NSString stringWithFormat:@"%@ %@",[finaldic objectForKey:@"a_fname"],[finaldic objectForKey:@"a_lname"]];
                }
            }  else if(![Utils isEmpty:assigneeUserName])
            {
                cell.agentLabel.text= [finaldic objectForKey:@"a_uname"];
            }else
            {
                cell.agentLabel.text= NSLocalizedString(@"No Agent", nil);
            }
            
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
            
            
            NSString * source1=[finaldic objectForKey:@"source"];
            
            NSString *cc= [NSString stringWithFormat:@"%@",[finaldic objectForKey:@"countcollaborator"]];
            NSString *attachment1= [NSString stringWithFormat:@"%@",[finaldic objectForKey:@"countattachment"]];
            
            
            if([source1 isEqualToString:@"web"])
            {
                cell.sourceImgView.image=[UIImage imageNamed:@"internert"];
            }else  if([source1 isEqualToString:@"email"])
            {
                cell.sourceImgView.image=[UIImage imageNamed:@"agentORmail"];
            }else  if([source1 isEqualToString:@"agent"])
            {
                cell.sourceImgView.image=[UIImage imageNamed:@"agentORmail"];
            }else  if([source1 isEqualToString:@"facebook"])
            {
                cell.sourceImgView.image=[UIImage imageNamed:@"fb"];
            }else  if([source1 isEqualToString:@"twitter"])
            {
                cell.sourceImgView.image=[UIImage imageNamed:@"twitter"];
            }else  if([source1 isEqualToString:@"call"])
            {
                cell.sourceImgView.image=[UIImage imageNamed:@"call"];
            }else if([source1 isEqualToString:@"chat"])
            {
                cell.sourceImgView.image=[UIImage imageNamed:@"chat"];
            }
            
            if(![cc isEqualToString:@"0"])
            {
                cell.ccImgView.image=[UIImage imageNamed:@"cc1"];
            }
            
            if([cc isEqualToString:@"0"] && ![attachment1 isEqualToString:@"0"])
            {
                cell.ccImgView.image=[UIImage imageNamed:@"attach"];
            }
            else if(![cc isEqualToString:@"0"] && ![attachment1 isEqualToString:@"0"])
            {
                cell.attachImgView.image=[UIImage imageNamed:@"attach"];
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
            //     NSLog( @"In finally block");
            
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
  //  refresh.backgroundColor = [UIColor colorWithRed:0.46 green:0.8 blue:1.0 alpha:1.0];
     refresh.backgroundColor = [UIColor hx_colorWithHexRGBAString:@"#BDBDBD"];
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
    _multistageDropdownMenuView = [[CFMultistageDropdownMenuView alloc] initWithFrame:CGRectMake(0, -5, CFScreenWidth, 30)];
    
    
    //
    // main top menu 2 menu aahet aata
    _multistageDropdownMenuView.defaulTitleArray = [NSArray arrayWithObjects:@"Filter",@"Sort by", nil];
    
    NSArray *leftArr = @[
                         // Filter - left array
                         @[],
                         // sort - left array
                         @[@"ticket title", @"ticket number", @"priority", @"updated at", @"created at",@"due on"],
                         //
                         @[]
                         ];
    NSArray *rightArr = @[
                          // 对应dataSourceLeftArray
                          @[
                              
                              // @[]
                              @[@"show"]
                              
                              
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
    
    
    if(titleButtonIndex==0 && rightIndex==0)
    {
        NSLog(@"*************show********");
        
        if([globalVariables.filterId isEqualToString:@"INBOXFilter"]){
        globalVariables.filterCondition=@"INBOX";
        }else if([globalVariables.filterId isEqualToString:@"MYTICKETSFilter"]){
            globalVariables.filterCondition=@"MYTICKETS";
        }
        else if([globalVariables.filterId isEqualToString:@"UNASSIGNEDFilter"]){
            globalVariables.filterCondition=@"UNASSIGNED";
        }else if([globalVariables.filterId isEqualToString:@"CLOSEDFilter"]){
            globalVariables.filterCondition=@"CLOSED";
        }else if([globalVariables.filterId isEqualToString:@"TRASHFilter"]){
            globalVariables.filterCondition=@"TRASH";
        }else{
       
            NSLog(@"I am in FilterLogic View Controller");
            NSLog(@"I am in slese condoton");
        }
        
        FilterViewController * filter=[self.storyboard instantiateViewControllerWithIdentifier:@"filterID1"];
        [self.navigationController pushViewController:filter animated:YES];
        
    }
    // sort by - Tciket title
    if(titleButtonIndex==1 && leftIndex==0 && rightIndex==0 )
    {
        NSLog(@"Ticket title - ASC");
        //sortAlert
        
        if([globalVariables.filterId isEqualToString:@"INBOXFilter"]){
            globalVariables.filterCondition=@"INBOX";
            globalVariables.sortCondition=@"INBOX";
            globalVariables.filterId=@"INBOXFilter";
            
        }else if([globalVariables.filterId isEqualToString:@"MYTICKETSFilter"]){
            globalVariables.filterCondition=@"MYTICKETS";
            globalVariables.sortCondition=@"MYTICKETS";
            globalVariables.filterId=@"MYTICKETSFilter";
            
        }
        else if([globalVariables.filterId isEqualToString:@"UNASSIGNEDFilter"]){
            globalVariables.filterCondition=@"UNASSIGNED";
            globalVariables.sortCondition=@"UNASSIGNED";
            globalVariables.filterId=@"UNASSIGNEDFilter";
            
        }else if([globalVariables.filterId isEqualToString:@"CLOSEDFilter"]){
            globalVariables.filterCondition=@"CLOSED";
            globalVariables.sortCondition=@"CLOSED";
            globalVariables.filterId=@"CLOSEDFilter";
            
        }else if([globalVariables.filterId isEqualToString:@"TRASHFilter"]){
            globalVariables.filterCondition=@"TRASH";
            globalVariables.sortCondition=@"TRASH";
            globalVariables.filterId=@"TRASHFilter";
        }else{
            
        }
        
        globalVariables.sortingValueId=@"sortTitleAsc";
        globalVariables.sortAlert=@"sortTitleAscAlert";
        globalVariables.urlFromFilterLogicView=url;
        
        NSLog(@"Url is : %@",url);
        NSLog(@"Url is : %@",url);
        
        SortingViewController * sort=[self.storyboard instantiateViewControllerWithIdentifier:@"sortID"];
        [self.navigationController pushViewController:sort animated:YES];
        
    }
    else if (titleButtonIndex==1 && leftIndex==0 && rightIndex==1 )
    {
        NSLog(@"Ticket Title  - DSC");
        
        if([globalVariables.filterId isEqualToString:@"INBOXFilter"]){
            globalVariables.filterCondition=@"INBOX";
            globalVariables.sortCondition=@"INBOX";
            globalVariables.filterId=@"INBOXFilter";
            
        }else if([globalVariables.filterId isEqualToString:@"MYTICKETSFilter"]){
            globalVariables.filterCondition=@"MYTICKETS";
            globalVariables.sortCondition=@"MYTICKETS";
            globalVariables.filterId=@"MYTICKETSFilter";
            
        }
        else if([globalVariables.filterId isEqualToString:@"UNASSIGNEDFilter"]){
            globalVariables.filterCondition=@"UNASSIGNED";
            globalVariables.sortCondition=@"UNASSIGNED";
            globalVariables.filterId=@"UNASSIGNEDFilter";
            
        }else if([globalVariables.filterId isEqualToString:@"CLOSEDFilter"]){
            globalVariables.filterCondition=@"CLOSED";
            globalVariables.sortCondition=@"CLOSED";
            globalVariables.filterId=@"CLOSEDFilter";
            
        }else if([globalVariables.filterId isEqualToString:@"TRASHFilter"]){
            globalVariables.filterCondition=@"TRASH";
            globalVariables.sortCondition=@"TRASH";
            globalVariables.filterId=@"TRASHFilter";
        }else{
            
        }
        
        globalVariables.sortingValueId=@"sortTitleDsc";
        globalVariables.sortAlert=@"sortTitleDscAlert";
        globalVariables.urlFromFilterLogicView=url;
      //  globalVariables.sortCondition=@"INBOX";
        
        SortingViewController * sort=[self.storyboard instantiateViewControllerWithIdentifier:@"sortID"];
        [self.navigationController pushViewController:sort animated:YES];
        
        
    }
    
    
    //sort by - ticket number
    else  if(titleButtonIndex==1 && leftIndex==1 && rightIndex==0 )
    {
        NSLog(@" Ticket number - ASC");
        
        if([globalVariables.filterId isEqualToString:@"INBOXFilter"]){
            globalVariables.filterCondition=@"INBOX";
            globalVariables.sortCondition=@"INBOX";
            globalVariables.filterId=@"INBOXFilter";
            
        }else if([globalVariables.filterId isEqualToString:@"MYTICKETSFilter"]){
            globalVariables.filterCondition=@"MYTICKETS";
            globalVariables.sortCondition=@"MYTICKETS";
            globalVariables.filterId=@"MYTICKETSFilter";
            
        }
        else if([globalVariables.filterId isEqualToString:@"UNASSIGNEDFilter"]){
            globalVariables.filterCondition=@"UNASSIGNED";
            globalVariables.sortCondition=@"UNASSIGNED";
            globalVariables.filterId=@"UNASSIGNEDFilter";
            
        }else if([globalVariables.filterId isEqualToString:@"CLOSEDFilter"]){
            globalVariables.filterCondition=@"CLOSED";
            globalVariables.sortCondition=@"CLOSED";
            globalVariables.filterId=@"CLOSEDFilter";
            
        }else if([globalVariables.filterId isEqualToString:@"TRASHFilter"]){
            globalVariables.filterCondition=@"TRASH";
            globalVariables.sortCondition=@"TRASH";
            globalVariables.filterId=@"TRASHFilter";
        }else{
            
        }
        globalVariables.sortingValueId=@"sortNumberAsc";
        globalVariables.sortAlert=@"sortNumberAscAlert";
        globalVariables.urlFromFilterLogicView=url;
      //  globalVariables.sortCondition=@"INBOX";
        
        NSLog(@"Filter Condtion is : %@", globalVariables.filterCondition);
        NSLog(@"sortCondition Condtion is : %@", globalVariables.sortCondition);
        NSLog(@"sortingValueId is : %@", globalVariables.sortingValueId);
        NSLog(@"ssortAlert is : %@", globalVariables.sortAlert);
        NSLog(@"ssortAlert is : %@", globalVariables.sortAlert);
        
        SortingViewController * sort=[self.storyboard instantiateViewControllerWithIdentifier:@"sortID"];
        [self.navigationController pushViewController:sort animated:YES];
        
        
    }
    else if(titleButtonIndex==1 && leftIndex==1 && rightIndex==1 )
    {
        NSLog(@" Ticket number - DSC");
        
        if([globalVariables.filterId isEqualToString:@"INBOXFilter"]){
            globalVariables.filterCondition=@"INBOX";
            globalVariables.sortCondition=@"INBOX";
            globalVariables.filterId=@"INBOXFilter";
            
        }else if([globalVariables.filterId isEqualToString:@"MYTICKETSFilter"]){
            globalVariables.filterCondition=@"MYTICKETS";
            globalVariables.sortCondition=@"MYTICKETS";
            globalVariables.filterId=@"MYTICKETSFilter";
            
        }
        else if([globalVariables.filterId isEqualToString:@"UNASSIGNEDFilter"]){
            globalVariables.filterCondition=@"UNASSIGNED";
            globalVariables.sortCondition=@"UNASSIGNED";
            globalVariables.filterId=@"UNASSIGNEDFilter";
            
        }else if([globalVariables.filterId isEqualToString:@"CLOSEDFilter"]){
            globalVariables.filterCondition=@"CLOSED";
            globalVariables.sortCondition=@"CLOSED";
            globalVariables.filterId=@"CLOSEDFilter";
            
        }else if([globalVariables.filterId isEqualToString:@"TRASHFilter"]){
            globalVariables.filterCondition=@"TRASH";
            globalVariables.sortCondition=@"TRASH";
            globalVariables.filterId=@"TRASHFilter";
        }else{
            
        }
        globalVariables.sortingValueId=@"sortNumberDsc";
        globalVariables.sortAlert=@"sortNumberDscAlert";
        globalVariables.urlFromFilterLogicView=url;
     //   globalVariables.sortCondition=@"INBOX";
        
        SortingViewController * sort=[self.storyboard instantiateViewControllerWithIdentifier:@"sortID"];
        [self.navigationController pushViewController:sort animated:YES];
        
        
        
    }
    
    //ticket priority
    else if(titleButtonIndex==1 && leftIndex==2 && rightIndex==0 )
    {
        NSLog(@" Ticket priority - ASC");
        
        
        
        if([globalVariables.filterId isEqualToString:@"INBOXFilter"]){
            globalVariables.filterCondition=@"INBOX";
            globalVariables.sortCondition=@"INBOX";
            globalVariables.filterId=@"INBOXFilter";
            
        }else if([globalVariables.filterId isEqualToString:@"MYTICKETSFilter"]){
            globalVariables.filterCondition=@"MYTICKETS";
            globalVariables.sortCondition=@"MYTICKETS";
            globalVariables.filterId=@"MYTICKETSFilter";
            
        }
        else if([globalVariables.filterId isEqualToString:@"UNASSIGNEDFilter"]){
            globalVariables.filterCondition=@"UNASSIGNED";
            globalVariables.sortCondition=@"UNASSIGNED";
            globalVariables.filterId=@"UNASSIGNEDFilter";
            
        }else if([globalVariables.filterId isEqualToString:@"CLOSEDFilter"]){
            globalVariables.filterCondition=@"CLOSED";
            globalVariables.sortCondition=@"CLOSED";
            globalVariables.filterId=@"CLOSEDFilter";
            
        }else if([globalVariables.filterId isEqualToString:@"TRASHFilter"]){
            globalVariables.filterCondition=@"TRASH";
            globalVariables.sortCondition=@"TRASH";
            globalVariables.filterId=@"TRASHFilter";
        }else{
            
        }
        
        globalVariables.sortingValueId=@"sortPriorityAsc";
        globalVariables.sortAlert=@"sortPriorityAscAlert";
        globalVariables.urlFromFilterLogicView=url;
      //  globalVariables.sortCondition=@"INBOX";
        
        SortingViewController * sort=[self.storyboard instantiateViewControllerWithIdentifier:@"sortID"];
        [self.navigationController pushViewController:sort animated:YES];
        
        
    }
    else if(titleButtonIndex==1 && leftIndex==2 && rightIndex==1 )
    {
        NSLog(@" Ticket priority - DSC");
        
        if([globalVariables.filterId isEqualToString:@"INBOXFilter"]){
            globalVariables.filterCondition=@"INBOX";
            globalVariables.sortCondition=@"INBOX";
            globalVariables.filterId=@"INBOXFilter";
            
        }else if([globalVariables.filterId isEqualToString:@"MYTICKETSFilter"]){
            globalVariables.filterCondition=@"MYTICKETS";
            globalVariables.sortCondition=@"MYTICKETS";
            globalVariables.filterId=@"MYTICKETSFilter";
            
        }
        else if([globalVariables.filterId isEqualToString:@"UNASSIGNEDFilter"]){
            globalVariables.filterCondition=@"UNASSIGNED";
            globalVariables.sortCondition=@"UNASSIGNED";
            globalVariables.filterId=@"UNASSIGNEDFilter";
            
        }else if([globalVariables.filterId isEqualToString:@"CLOSEDFilter"]){
            globalVariables.filterCondition=@"CLOSED";
            globalVariables.sortCondition=@"CLOSED";
            globalVariables.filterId=@"CLOSEDFilter";
            
        }else if([globalVariables.filterId isEqualToString:@"TRASHFilter"]){
            globalVariables.filterCondition=@"TRASH";
            globalVariables.sortCondition=@"TRASH";
            globalVariables.filterId=@"TRASHFilter";
        }else{
            
        }
        globalVariables.sortingValueId=@"sortPriorityDsc";
        globalVariables.sortAlert=@"sortPriorityDscAlert";
        globalVariables.urlFromFilterLogicView=url;
       // globalVariables.sortCondition=@"INBOX";
        
        SortingViewController * sort=[self.storyboard instantiateViewControllerWithIdentifier:@"sortID"];
        [self.navigationController pushViewController:sort animated:YES];
        
        
    }
    // upated at
    else if(titleButtonIndex==1 && leftIndex==3 && rightIndex==0 )
    {
        NSLog(@" upated at - ASC");
        
        if([globalVariables.filterId isEqualToString:@"INBOXFilter"]){
            globalVariables.filterCondition=@"INBOX";
            globalVariables.sortCondition=@"INBOX";
            globalVariables.filterId=@"INBOXFilter";
            
        }else if([globalVariables.filterId isEqualToString:@"MYTICKETSFilter"]){
            globalVariables.filterCondition=@"MYTICKETS";
            globalVariables.sortCondition=@"MYTICKETS";
            globalVariables.filterId=@"MYTICKETSFilter";
            
        }
        else if([globalVariables.filterId isEqualToString:@"UNASSIGNEDFilter"]){
            globalVariables.filterCondition=@"UNASSIGNED";
            globalVariables.sortCondition=@"UNASSIGNED";
            globalVariables.filterId=@"UNASSIGNEDFilter";
            
        }else if([globalVariables.filterId isEqualToString:@"CLOSEDFilter"]){
            globalVariables.filterCondition=@"CLOSED";
            globalVariables.sortCondition=@"CLOSED";
            globalVariables.filterId=@"CLOSEDFilter";
            
        }else if([globalVariables.filterId isEqualToString:@"TRASHFilter"]){
            globalVariables.filterCondition=@"TRASH";
            globalVariables.sortCondition=@"TRASH";
            globalVariables.filterId=@"TRASHFilter";
        }else{
            
        }
        
        globalVariables.sortingValueId=@"sortUpdatedAsc";
        globalVariables.sortAlert=@"sortUpdatedAscAlert";
        globalVariables.urlFromFilterLogicView=url;
       // globalVariables.sortCondition=@"INBOX";
        
        SortingViewController * sort=[self.storyboard instantiateViewControllerWithIdentifier:@"sortID"];
        [self.navigationController pushViewController:sort animated:YES];
        
        
    }
    else if(titleButtonIndex==1 && leftIndex==3 && rightIndex==1 )
    {
        NSLog(@" upated at - DSC");
        
        if([globalVariables.filterId isEqualToString:@"INBOXFilter"]){
            globalVariables.filterCondition=@"INBOX";
            globalVariables.sortCondition=@"INBOX";
            globalVariables.filterId=@"INBOXFilter";
            
        }else if([globalVariables.filterId isEqualToString:@"MYTICKETSFilter"]){
            globalVariables.filterCondition=@"MYTICKETS";
            globalVariables.sortCondition=@"MYTICKETS";
            globalVariables.filterId=@"MYTICKETSFilter";
            
        }
        else if([globalVariables.filterId isEqualToString:@"UNASSIGNEDFilter"]){
            globalVariables.filterCondition=@"UNASSIGNED";
            globalVariables.sortCondition=@"UNASSIGNED";
            globalVariables.filterId=@"UNASSIGNEDFilter";
            
        }else if([globalVariables.filterId isEqualToString:@"CLOSEDFilter"]){
            globalVariables.filterCondition=@"CLOSED";
            globalVariables.sortCondition=@"CLOSED";
            globalVariables.filterId=@"CLOSEDFilter";
            
        }else if([globalVariables.filterId isEqualToString:@"TRASHFilter"]){
            globalVariables.filterCondition=@"TRASH";
            globalVariables.sortCondition=@"TRASH";
            globalVariables.filterId=@"TRASHFilter";
        }else{
            
        }
        
        globalVariables.sortingValueId=@"sortUpdatedDsc";
        globalVariables.sortAlert=@"sortUpdatedDscAlert";
        globalVariables.urlFromFilterLogicView=url;
        //globalVariables.sortCondition=@"INBOX";
        
        SortingViewController * sort=[self.storyboard instantiateViewControllerWithIdentifier:@"sortID"];
        [self.navigationController pushViewController:sort animated:YES];
        
        
    }
    
    // created at
    else if(titleButtonIndex==1 && leftIndex==4 && rightIndex==0 )
    {
        NSLog(@" created At - ASC");
        
        if([globalVariables.filterId isEqualToString:@"INBOXFilter"]){
            globalVariables.filterCondition=@"INBOX";
            globalVariables.sortCondition=@"INBOX";
            globalVariables.filterId=@"INBOXFilter";
            
        }else if([globalVariables.filterId isEqualToString:@"MYTICKETSFilter"]){
            globalVariables.filterCondition=@"MYTICKETS";
            globalVariables.sortCondition=@"MYTICKETS";
            globalVariables.filterId=@"MYTICKETSFilter";
            
        }
        else if([globalVariables.filterId isEqualToString:@"UNASSIGNEDFilter"]){
            globalVariables.filterCondition=@"UNASSIGNED";
            globalVariables.sortCondition=@"UNASSIGNED";
            globalVariables.filterId=@"UNASSIGNEDFilter";
            
        }else if([globalVariables.filterId isEqualToString:@"CLOSEDFilter"]){
            globalVariables.filterCondition=@"CLOSED";
            globalVariables.sortCondition=@"CLOSED";
            globalVariables.filterId=@"CLOSEDFilter";
            
        }else if([globalVariables.filterId isEqualToString:@"TRASHFilter"]){
            globalVariables.filterCondition=@"TRASH";
            globalVariables.sortCondition=@"TRASH";
            globalVariables.filterId=@"TRASHFilter";
        }else{
            
        }
        globalVariables.sortingValueId=@"sortCreatedAsc";
        globalVariables.sortAlert=@"sortCreatedAscAlert";
        globalVariables.urlFromFilterLogicView=url;
        //globalVariables.sortCondition=@"INBOX";
        
        SortingViewController * sort=[self.storyboard instantiateViewControllerWithIdentifier:@"sortID"];
        [self.navigationController pushViewController:sort animated:YES];
        
    }
    else if(titleButtonIndex==1 && leftIndex==4 && rightIndex==1 )
    {
        NSLog(@" created At - DSC");
        
        if([globalVariables.filterId isEqualToString:@"INBOXFilter"]){
            globalVariables.filterCondition=@"INBOX";
            globalVariables.sortCondition=@"INBOX";
            globalVariables.filterId=@"INBOXFilter";
            
        }else if([globalVariables.filterId isEqualToString:@"MYTICKETSFilter"]){
            globalVariables.filterCondition=@"MYTICKETS";
            globalVariables.sortCondition=@"MYTICKETS";
            globalVariables.filterId=@"MYTICKETSFilter";
            
        }
        else if([globalVariables.filterId isEqualToString:@"UNASSIGNEDFilter"]){
            globalVariables.filterCondition=@"UNASSIGNED";
            globalVariables.sortCondition=@"UNASSIGNED";
            globalVariables.filterId=@"UNASSIGNEDFilter";
            
        }else if([globalVariables.filterId isEqualToString:@"CLOSEDFilter"]){
            globalVariables.filterCondition=@"CLOSED";
            globalVariables.sortCondition=@"CLOSED";
            globalVariables.filterId=@"CLOSEDFilter";
            
        }else if([globalVariables.filterId isEqualToString:@"TRASHFilter"]){
            globalVariables.filterCondition=@"TRASH";
            globalVariables.sortCondition=@"TRASH";
            globalVariables.filterId=@"TRASHFilter";
        }else{
            
        }
        
        globalVariables.sortingValueId=@"sortCreatedDsc";
        globalVariables.sortAlert=@"sortCreatedDscAlert";
        globalVariables.urlFromFilterLogicView=url;
       // globalVariables.sortCondition=@"INBOX";
        
        SortingViewController * sort=[self.storyboard instantiateViewControllerWithIdentifier:@"sortID"];
        [self.navigationController pushViewController:sort animated:YES];
        
        
    }
    
    // due on
    else if(titleButtonIndex==1 && leftIndex==5 && rightIndex==0 )
    {
        NSLog(@" due on - ASC");
        if([globalVariables.filterId isEqualToString:@"INBOXFilter"]){
            globalVariables.filterCondition=@"INBOX";
            globalVariables.sortCondition=@"INBOX";
            globalVariables.filterId=@"INBOXFilter";
            
        }else if([globalVariables.filterId isEqualToString:@"MYTICKETSFilter"]){
            globalVariables.filterCondition=@"MYTICKETS";
            globalVariables.sortCondition=@"MYTICKETS";
            globalVariables.filterId=@"MYTICKETSFilter";
            
        }
        else if([globalVariables.filterId isEqualToString:@"UNASSIGNEDFilter"]){
            globalVariables.filterCondition=@"UNASSIGNED";
            globalVariables.sortCondition=@"UNASSIGNED";
            globalVariables.filterId=@"UNASSIGNEDFilter";
            
        }else if([globalVariables.filterId isEqualToString:@"CLOSEDFilter"]){
            globalVariables.filterCondition=@"CLOSED";
            globalVariables.sortCondition=@"CLOSED";
            globalVariables.filterId=@"CLOSEDFilter";
            
        }else if([globalVariables.filterId isEqualToString:@"TRASHFilter"]){
            globalVariables.filterCondition=@"TRASH";
            globalVariables.sortCondition=@"TRASH";
            globalVariables.filterId=@"TRASHFilter";
        }else{
            
        }
        
        globalVariables.sortingValueId=@"sortDueAsc";
        globalVariables.sortAlert=@"sortDueAscAlert";
        globalVariables.urlFromFilterLogicView=url;
       // globalVariables.sortCondition=@"INBOX";
        
        SortingViewController * sort=[self.storyboard instantiateViewControllerWithIdentifier:@"sortID"];
        [self.navigationController pushViewController:sort animated:YES];
        
    }
    else if(titleButtonIndex==1 && leftIndex==5 && rightIndex==1 )
    {
        NSLog(@" due on - DSC");
        
        if([globalVariables.filterId isEqualToString:@"INBOXFilter"]){
            globalVariables.filterCondition=@"INBOX";
            globalVariables.sortCondition=@"INBOX";
            globalVariables.filterId=@"INBOXFilter";
            
        }else if([globalVariables.filterId isEqualToString:@"MYTICKETSFilter"]){
            globalVariables.filterCondition=@"MYTICKETS";
            globalVariables.sortCondition=@"MYTICKETS";
            globalVariables.filterId=@"MYTICKETSFilter";
            
        }
        else if([globalVariables.filterId isEqualToString:@"UNASSIGNEDFilter"]){
            globalVariables.filterCondition=@"UNASSIGNED";
            globalVariables.sortCondition=@"UNASSIGNED";
            globalVariables.filterId=@"UNASSIGNEDFilter";
            
        }else if([globalVariables.filterId isEqualToString:@"CLOSEDFilter"]){
            globalVariables.filterCondition=@"CLOSED";
            globalVariables.sortCondition=@"CLOSED";
            globalVariables.filterId=@"CLOSEDFilter";
            
        }else if([globalVariables.filterId isEqualToString:@"TRASHFilter"]){
            globalVariables.filterCondition=@"TRASH";
            globalVariables.sortCondition=@"TRASH";
            globalVariables.filterId=@"TRASHFilter";
        }else{
            
        }
        
        globalVariables.sortingValueId=@"sortDueDsc";
        globalVariables.sortAlert=@"sortDueDscAlert";
        globalVariables.urlFromFilterLogicView=url;
     //   globalVariables.sortCondition=@"INBOX";
        
        SortingViewController * sort=[self.storyboard instantiateViewControllerWithIdentifier:@"sortID"];
        [self.navigationController pushViewController:sort animated:YES];
        
        
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
