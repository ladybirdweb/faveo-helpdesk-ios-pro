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
#import "FTPopOverMenu.h"
#import "MergeViewForm.h"
#import "IQKeyboardManager.h"
#import "UIImageView+Letters.h"
#import "MultpleTicketAssignTableViewController.h"
#import "TicketSearchViewController.h"

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
    
    NSMutableArray *selectedArray;
    NSMutableArray *selectedSubjectArray;
    NSMutableArray *selectedTicketOwner;
    
    int count1;
    NSString *selectedIDs;
    UINavigationBar*  navbar;
    
    NSArray *ticketStatusArray;
    
    NSMutableArray *statusArrayforChange;
    NSMutableArray *statusIdforChange;
    NSMutableArray *uniqueStatusNameArray;
    NSString *selectedStatusName;
    NSString *selectedStatusId;
}

@property (strong,nonatomic) NSIndexPath *selectedPath;

@property (nonatomic, strong) NSMutableArray *mutableArray;
@property (nonatomic, strong) NSArray *indexPaths;
@property (nonatomic, assign) NSInteger totalPages;
@property (nonatomic, assign) NSInteger currentPage;

@property (nonatomic, assign) NSInteger totalTickets;
@property (nonatomic, strong) NSString *nextPageUrl;
@property (nonatomic, strong) NSString *path1;
@property (nonatomic) int pageInt;

@property (nonatomic, strong) CFMultistageDropdownMenuView *multistageDropdownMenuView;
@property (nonatomic, strong) CFMultistageConditionTableView *multistageConditionTableView;


@end

@implementation FilterLogic

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addUIRefresh];
    
    customAlert = [[BDCustomAlertView alloc] init];
    statusArrayforChange = [[NSMutableArray alloc] init];
    statusIdforChange = [[NSMutableArray alloc] init];
    uniqueStatusNameArray = [[NSMutableArray alloc] init];
    
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
    
    
    _mutableArray=[[NSMutableArray alloc]init];
    selectedTicketOwner = [[NSMutableArray alloc] init];
    selectedSubjectArray = [[NSMutableArray alloc] init];
    
    utils=[[Utils alloc]init];
    globalVariables=[GlobalVariables sharedInstance];
    userDefaults=[NSUserDefaults standardUserDefaults];
    
    NSLog(@"device_token %@",[userDefaults objectForKey:@"deviceToken"]);
    
    UIButton *moreButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    [moreButton setImage:[UIImage imageNamed:@"search1"] forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(searchButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    //    [moreButton setFrame:CGRectMake(46, 0, 32, 32)];
    [moreButton setFrame:CGRectMake(10, 0, 35, 35)];
    
    UIButton *NotificationBtn =  [UIButton buttonWithType:UIButtonTypeCustom];
    [NotificationBtn setImage:[UIImage imageNamed:@"notification.png"] forState:UIControlStateNormal];
    [NotificationBtn addTarget:self action:@selector(NotificationBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    // [NotificationBtn setFrame:CGRectMake(10, 0, 32, 32)];
    
    
    [NotificationBtn setFrame:CGRectMake(46, 0, 32, 32)];
    
    UIView *rightBarButtonItems = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 76, 32)];
    [rightBarButtonItems addSubview:moreButton];
    [rightBarButtonItems addSubview:NotificationBtn];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarButtonItems];
    
    
    //To set Gesture on Tableview for multiselection
    count1=0;
    selectedArray = [[NSMutableArray alloc] init];
    self.tableView.allowsMultipleSelectionDuringEditing = true;
    UILongPressGestureRecognizer *lpGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(EditTableView:)];
    [lpGesture setMinimumPressDuration:1];
    [self.tableView addGestureRecognizer:lpGesture];
    
    
    navbar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    
    UIImage *image1 = [UIImage imageNamed:@"merg111"];
    UIImage *image2 = [UIImage imageNamed:@"x1"];
    
    
    
    // UINavigationItem* navItem = [[UINavigationItem alloc] initWithTitle:@"Assign"];
    UINavigationItem* navItem = [[UINavigationItem alloc] init];
    // self.navigationItem.titleView = myImageView;
    
    UIImage *image5 = [UIImage imageNamed:@"merge2a"];
    //chnaging size of img
    CGRect rect = CGRectMake(0,0,26,26);
    UIGraphicsBeginImageContext( rect.size );
    [image5 drawInRect:rect];
    UIImage *picture1 = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *imageData = UIImagePNGRepresentation(picture1);
    UIImage *img3=[UIImage imageWithData:imageData];
    
    UIImageView* img = [[UIImageView alloc] initWithImage:img3];
    
    //giving action to image
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickedOnAssignButton)];
    singleTap.numberOfTapsRequired = 1;
    [img setUserInteractionEnabled:YES];
    [img addGestureRecognizer:singleTap];
    
    
    navItem.titleView = img;
    
    
    UIBarButtonItem *button1 = [[UIBarButtonItem alloc] initWithImage:image1 style:UIBarButtonItemStylePlain  target:self action:@selector(MergeButtonClicked)];
    navItem.leftBarButtonItem = button1;
    
    
    UIBarButtonItem *button2 = [[UIBarButtonItem alloc] initWithImage:image2 style:UIBarButtonItemStylePlain  target:self action:@selector(onNavButtonTapped:event:)];
    navItem.rightBarButtonItem = button2;
    
    [navbar setItems:@[navItem]];
    [self.view addSubview:navbar];
    
    
    
    
    [[AppDelegate sharedAppdelegate] showProgressViewWithText:NSLocalizedString(@"Getting Data",nil)];
    
    [self reload];
    [self getDependencies];
    
    
}

- (IBAction)searchButtonClicked {
    
    TicketSearchViewController * search=[self.storyboard instantiateViewControllerWithIdentifier:@"TicketSearchViewControllerId"];
    [self.navigationController pushViewController:search animated:YES];
    
    
}

-(void)clickedOnAssignButton{
    
    @try{
        NSLog(@"Clicked on Asign");
        if (!selectedArray.count) {
            
            [utils showAlertWithMessage:@"Select The Tickets for Assign" sendViewController:self];
            
        }
        else{
            //selectedIDs
            
            globalVariables.ticketIDListForAssign=selectedIDs;
            
            MultpleTicketAssignTableViewController * vc=[self.storyboard instantiateViewControllerWithIdentifier:@"multipleAssignID"];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }@catch (NSException *exception)
    {
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        [utils showAlertWithMessage:exception.name sendViewController:self];
        return;
    }
    @finally
    {
        NSLog( @" I am in clickedOnAssignButton method in FilterLogic ViewController" );
        
    }
    
    
    
}

-(void)MergeButtonClicked
{
    NSLog(@"Clicked on merge");
    
    @try{
        if (!selectedArray.count) {
            
            [utils showAlertWithMessage:@"Select The Tickets for Merge" sendViewController:self];
            
        }else if(selectedArray.count<2)
        {
            [utils showAlertWithMessage:@"Select 2 or more Tickets for Merge" sendViewController:self];
        }else{
            
            NSString * email1= [selectedTicketOwner objectAtIndex:0];
            NSString * email2= [selectedTicketOwner objectAtIndex:1];
            NSLog(@"email 1 is : %@",email1);
            NSLog(@"email 2 is : %@",email2);
            if(![email1 isEqualToString:email2] || ![email1 isEqualToString:[selectedTicketOwner lastObject]])
            {
                [utils showAlertWithMessage:@"You can't merge these tickets because tickets from different users" sendViewController:self];
            }
            else{
                
                globalVariables.idList=selectedArray;
                globalVariables.subjectList=selectedSubjectArray;
                
                MergeViewForm * merge=[self.storyboard instantiateViewControllerWithIdentifier:@"mergeViewID1"];
                [self.navigationController pushViewController:merge animated:YES];
            }
        }
        
    }@catch (NSException *exception)
    {
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        [utils showAlertWithMessage:exception.name sendViewController:self];
        return;
    }
    @finally
    {
        NSLog( @" I am in mergeButtonClciked method in FilterLogic ViewController" );
        
    }
    
}




-(void)viewWillAppear:(BOOL)animated{
    
    if (self.selectedPath != nil) {
        [_tableView selectRowAtIndexPath:self.selectedPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    if([globalVariables.backButtonActionFromMergeViewMenu isEqualToString:@"true"])
    {
        navbar.hidden=NO;
        globalVariables.backButtonActionFromMergeViewMenu=@"false";
    }else{
        navbar.hidden=YES;
        
    }
    [super viewWillAppear:YES];
    [[self navigationController] setNavigationBarHidden:NO];
    
}

- (void)reloadTableView
{
    NSArray *indexPaths = [self.tableView indexPathsForSelectedRows];
    [self.tableView reloadData];
    for (NSIndexPath *path in indexPaths) {
        [self.tableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
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
            
        }
        if([globalVariables.filterId isEqualToString:@"UNASSIGNEDFilter"]){ // Tikcet Filter
            
            //  http://jamboreebliss.com/sayar/public/api/v2/helpdesk/get-tickets?token=%@&api=1&show=inbox&departments=%@&source=%@&priority=%@&assigned=1&types=%@
            //departments priority types source status assigned
            
            apiValue=[NSString stringWithFormat:@"%i",1];
            showInbox = @"inbox&assigned=0";
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
        else if([globalVariables.filterId isEqualToString:@"MYTICKETSFilter"]){ // Tikcet Filter
            
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
    // departmnt is no empty
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
    NSLog(@"URL is : %@",url);
    NSLog(@"URL is : %@",url);
    NSLog(@"URL is : %@",url);
    
    [webservices httpResponseGET:url parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
        
        
        
        if (error || [msg containsString:@"Error"]) {
            [self->refresh endRefreshing];
            [[AppDelegate sharedAppdelegate] hideProgressView];
            if (msg) {
                
                if([msg isEqualToString:@"Error-401"])
                {
                    NSLog(@"Message is : %@",msg);
                    [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Access Denied.  Your credentials has been changed. Contact to Admin and try to login again."] sendViewController:self];
                    [[AppDelegate sharedAppdelegate] hideProgressView];
                }
                    else if([msg isEqualToString:@"Error-403"])
                    {
                        [self->utils showAlertWithMessage:NSLocalizedString(@"Access Denied - You don't have permission.", nil) sendViewController:self];
                        [[AppDelegate sharedAppdelegate] hideProgressView];
                    }
                    else if([msg isEqualToString:@"Error-403"] && [self->globalVariables.roleFromAuthenticateAPI isEqualToString:@"user"])
                    {
                        [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Access Denied.  Your credentials/Role has been changed. Contact to Admin and try to login again."] sendViewController:self];
                        [[AppDelegate sharedAppdelegate] hideProgressView];
                    }
                else  if([msg isEqualToString:@"Error-402"])
                {
                    NSLog(@"Message is : %@",msg);
                    [self->utils showAlertWithMessage:[NSString stringWithFormat:@"API is disabled in web, please enable it from Admin panel."] sendViewController:self];
                    [[AppDelegate sharedAppdelegate] hideProgressView];
                }
                else
                {
                    NSLog(@"Error msg is : %@",msg);
                    [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",msg] sendViewController:self];
                    [[AppDelegate sharedAppdelegate] hideProgressView];
                }
                
            }else if(error)  {
                [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",error.localizedDescription] sendViewController:self];
                NSLog(@"Thread-NO4-getInbox-Refresh-error == %@",error.localizedDescription);
                [[AppDelegate sharedAppdelegate] hideProgressView];
            }
            return ;
        }
        
        if ([msg isEqualToString:@"tokenRefreshed"]) {
            
            [self reload];
            NSLog(@"Thread--NO4-call-getInbox");
            return;
        }
        
        if ([msg isEqualToString:@"tokenNotRefreshed"]) {
            
            // [[AppDelegate sharedAppdelegate] hideProgressView];
            [self->utils showAlertWithMessage:@"Your HELPDESK URL or your Login credentials were changed, contact to Admin and please log back in." sendViewController:self];
            [[AppDelegate sharedAppdelegate] hideProgressView];
            
            return;
        }
        
        if (json) {
            //NSError *error;
            NSLog(@"Thread-NO4--getInboxAPI--%@",json);
            NSDictionary *data1Dict=[json objectForKey:@"data"];
            
            self->_mutableArray = [data1Dict objectForKey:@"data"];
            
            self->_nextPageUrl =[data1Dict objectForKey:@"next_page_url"];
            self->_path1=[data1Dict objectForKey:@"path"];
            self->_currentPage=[[data1Dict objectForKey:@"current_page"] integerValue];
            self->_totalTickets=[[data1Dict objectForKey:@"total"] integerValue];
            self->_totalPages=[[data1Dict objectForKey:@"last_page"] integerValue];
            
            
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[AppDelegate sharedAppdelegate] hideProgressView];
                    [self->refresh endRefreshing];
                    
                    [self reloadTableView];
                    
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
        
        NSLog(@"URL is : %@",url);
        @try{
            MyWebservices *webservices=[MyWebservices sharedInstance];
            [webservices httpResponseGET:url parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg){
                //   NSLog(@"Thread-NO3-getDependencies-start-error-%@-json-%@-msg-%@",error,json,msg);
                
                if (error || [msg containsString:@"Error"]) {
                    
                    if( [msg containsString:@"Error-401"])
                        
                    {
                        [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Your Credential Has been changed"] sendViewController:self];
                        [[AppDelegate sharedAppdelegate] hideProgressView];
                        
                    }
                    else
                        if( [msg containsString:@"Error-429"])
                            
                        {
                            [self->utils showAlertWithMessage:[NSString stringWithFormat:@"your request counts exceed our limit"] sendViewController:self];
                            [[AppDelegate sharedAppdelegate] hideProgressView];
                            
                        }
                    
                        else if( [msg isEqualToString:@"Error-403"] && [self->globalVariables.roleFromAuthenticateAPI isEqualToString:@"user"])
                            
                        {
                            [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Access Denied.  Your credentials/Role has been changed. Contact to Admin and try to login again."] sendViewController:self];
                            [[AppDelegate sharedAppdelegate] hideProgressView];
                            
                        }
                    
                        else if( [msg containsString:@"Error-403"])
                            
                        {
                            [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Access Denied.  Your credentials/Role has been changed. Contact to Admin and try to login again."] sendViewController:self];
                            [[AppDelegate sharedAppdelegate] hideProgressView];
                            
                        }
                    
                        else if([msg isEqualToString:@"Error-404"])
                        {
                            NSLog(@"Message is : %@",msg);
                            [self->utils showAlertWithMessage:[NSString stringWithFormat:@"The requested URL was not found on this server."] sendViewController:self];
                            [[AppDelegate sharedAppdelegate] hideProgressView];
                        }
                    
                    
                        else{
                            NSLog(@"Error message is %@",msg);
                            NSLog(@"Thread-NO4-getdependency-Refresh-error == %@",error.localizedDescription);
                            [self->utils showAlertWithMessage:msg sendViewController:self];
                            [[AppDelegate sharedAppdelegate] hideProgressView];
                            
                            return ;
                        }
                }
                
                
                // [[AppDelegate sharedAppdelegate] hideProgressView];
                if ([msg isEqualToString:@"tokenRefreshed"]) {
                    
                    [self getDependencies];
                    NSLog(@"Thread--NO4-call-getDependecies");
                    return;
                }
                
                if (json) {
                    
                    //  NSLog(@"Thread-NO4-getDependencies-dependencyAPI--%@",json);
                    NSDictionary *resultDic = [json objectForKey:@"data"];
                    NSArray *ticketCountArray=[resultDic objectForKey:@"tickets_count"];
                    
                    for (int i = 0; i < ticketCountArray.count; i++) {
                        NSString *name = [[ticketCountArray objectAtIndex:i]objectForKey:@"name"];
                        NSString *count = [[ticketCountArray objectAtIndex:i]objectForKey:@"count"];
                        if ([name isEqualToString:@"Open"]) {
                            self->globalVariables.OpenCount=count;
                            
                        }else if ([name isEqualToString:@"Closed"]) {
                            self->globalVariables.ClosedCount=count;
                        }else if ([name isEqualToString:@"Deleted"]) {
                            self->globalVariables.DeletedCount=count;
                        }else if ([name isEqualToString:@"unassigned"]) {
                            self->globalVariables.UnassignedCount=count;
                        }else if ([name isEqualToString:@"mytickets"]) {
                            self->globalVariables.MyticketsCount=count;
                        }
                    }
                    
                    self->ticketStatusArray=[resultDic objectForKey:@"status"];
                    
                    for (int i = 0; i < self->ticketStatusArray.count; i++) {
                        NSString *statusName = [[self->ticketStatusArray objectAtIndex:i]objectForKey:@"name"];
                        NSString *statusId = [[self->ticketStatusArray objectAtIndex:i]objectForKey:@"id"];
                        
                        if ([statusName isEqualToString:@"Open"]) {
                            self->globalVariables.OpenStausId=statusId;
                            self->globalVariables.OpenStausLabel=statusName;
                        }else if ([statusName isEqualToString:@"Resolved"]) {
                            self->globalVariables.ResolvedStausId=statusId;
                            self->globalVariables.ResolvedStausLabel=statusName;
                        }else if ([statusName isEqualToString:@"Closed"]) {
                            self->globalVariables.ClosedStausId=statusId;
                            self->globalVariables.ClosedStausLabel=statusName;
                        }else if ([statusName isEqualToString:@"Deleted"]) {
                            self->globalVariables.DeletedStausId=statusId;
                            self->globalVariables.DeletedStausLabel=statusName;
                        }else if ([statusName isEqualToString:@"Request for close"]) {
                            self->globalVariables.RequestCloseStausId=statusId;
                        }else if ([statusName isEqualToString:@"Spam"]) {
                            self->globalVariables.SpamStausId=statusId;
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
            NSLog( @"Name: %@", exception.name);
            NSLog( @"Reason: %@", exception.reason );
            [utils showAlertWithMessage:exception.name sendViewController:self];
            [[AppDelegate sharedAppdelegate] hideProgressView];
            return;
        }
        @finally
        {
            NSLog( @" I am in getDependencies method in Inbox ViewController" );
            [[AppDelegate sharedAppdelegate] hideProgressView];
            
        }
    }
    NSLog(@"Thread-NO2-getDependencies()-closed");
}




-(void)EditTableView:(UIGestureRecognizer*)gesture{
    [self.tableView setEditing:YES animated:YES];
    navbar.hidden=NO;
    //  [selectedTicketOwner removeAllObjects];
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
    
    
    // cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    if (indexPath.row == [_mutableArray count] - 1 ) {
        NSLog(@"nextURL  %@",_nextPageUrl);
        if (( ![_nextPageUrl isEqual:[NSNull null]] ) && ( [_nextPageUrl length] != 0 )) {
            [self loadMore];
        }
        else{
            // [RKDropdownAlert title:@"" message:@"All Caught Up...!" backgroundColor:[UIColor hx_colorWithHexRGBAString:ALERT_COLOR] textColor:[UIColor whiteColor]];
            
            [RMessage showNotificationInViewController:self
                                                 title:nil
                                              subtitle:NSLocalizedString(@"All Caught Up", nil)
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
            NSString *Page = [str substringFromIndex:[str length] - 1];
            
            //     NSLog(@"String is : %@",szResult);
            NSLog(@"Page is : %@",Page);
            NSLog(@"Page is : %@",Page);
            globalVariables.filterId=@"INBOXFilter";
            
            MyWebservices *webservices=[MyWebservices sharedInstance];
            
            //     [webservices getNextPageURLInbox:_path1 pageNo:Page  callbackHandler:^(NSError *error,id json,NSString* msg) {
            
            [webservices getNextPageURLInbox:url pageNo:Page  callbackHandler:^(NSError *error,id json,NSString* msg) {
                
                if (error || [msg containsString:@"Error"]) {
                    
                    if (msg) {
                        
                        if([msg isEqualToString:@"Error-403"])
                        {
                            [self->utils showAlertWithMessage:NSLocalizedString(@"Access Denied - You don't have permission.", nil) sendViewController:self];
                            [[AppDelegate sharedAppdelegate] hideProgressView];
                        }
                        else if([msg isEqualToString:@"Error-403"] && [self->globalVariables.roleFromAuthenticateAPI isEqualToString:@"user"])
                        {
                            [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Access Denied.  Your credentials/Role has been changed. Contact to Admin and try to login again."] sendViewController:self];
                            [[AppDelegate sharedAppdelegate] hideProgressView];
                        }
                        else{
                        
                        [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",msg] sendViewController:self];
                        }
                        
                    }else if(error)  {
                        [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",error.localizedDescription] sendViewController:self];
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
                    
                    NSDictionary *data1Dict=[json objectForKey:@"data"];
                    
                    self->_nextPageUrl =[data1Dict objectForKey:@"next_page_url"];
                    self->_path1=[data1Dict objectForKey:@"path"];
                    self->_currentPage=[[data1Dict objectForKey:@"current_page"] integerValue];
                    self->_totalTickets=[[data1Dict objectForKey:@"total"] integerValue];
                    self->_totalPages=[[data1Dict objectForKey:@"last_page"] integerValue];
                    
                    self->_mutableArray= [self->_mutableArray mutableCopy];
                    
                    [self->_mutableArray addObjectsFromArray:[data1Dict objectForKey:@"data"]];
                    
                    
                    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [self reloadTableView];
                            
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
            NSString *Page = [str substringFromIndex:[str length] - 1];
            
            //     NSLog(@"String is : %@",szResult);
            NSLog(@"Page is : %@",Page);
            NSLog(@"Page is : %@",Page);
            globalVariables.filterId=@"MYTICKETSFilter";
            
            MyWebservices *webservices=[MyWebservices sharedInstance];
            // [webservices getNextPageURLMyTickets:_path1 pageNo:Page  callbackHandler:^(NSError *error,id json,NSString* msg) {
            
            [webservices getNextPageURLMyTickets:url pageNo:Page  callbackHandler:^(NSError *error,id json,NSString* msg) {
                if (error || [msg containsString:@"Error"]) {
                    
                    if (msg) {
                        
                        [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",msg] sendViewController:self];
                        
                    }else if(error)  {
                        [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",error.localizedDescription] sendViewController:self];
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
                    
                    NSDictionary *data1Dict=[json objectForKey:@"data"];
                    
                    self->_nextPageUrl =[data1Dict objectForKey:@"next_page_url"];
                    self->_path1=[data1Dict objectForKey:@"path"];
                    self->_currentPage=[[data1Dict objectForKey:@"current_page"] integerValue];
                    self->_totalTickets=[[data1Dict objectForKey:@"total"] integerValue];
                    self->_totalPages=[[data1Dict objectForKey:@"last_page"] integerValue];
                    
                    self->_mutableArray= [self->_mutableArray mutableCopy];
                    
                    [self->_mutableArray addObjectsFromArray:[data1Dict objectForKey:@"data"]];
                    
                    
                    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [self reloadTableView];
                            
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
            NSString *Page = [str substringFromIndex:[str length] - 1];
            
            //     NSLog(@"String is : %@",szResult);
            NSLog(@"Page is : %@",Page);
            NSLog(@"Page is : %@",Page);
            globalVariables.filterId=@"UNASSIGNEDFilter";
            
            MyWebservices *webservices=[MyWebservices sharedInstance];
            //   [webservices getNextPageURLUnassigned:_path1 pageNo:Page  callbackHandler:^(NSError *error,id json,NSString* msg) {
            
            [webservices getNextPageURLUnassigned:url pageNo:Page  callbackHandler:^(NSError *error,id json,NSString* msg) {
                
                if (error || [msg containsString:@"Error"]) {
                    
                    if (msg) {
                        
                        [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",msg] sendViewController:self];
                        
                    }else if(error)  {
                        [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",error.localizedDescription] sendViewController:self];
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
                    
                    NSDictionary *data1Dict=[json objectForKey:@"data"];
                    
                    self->_nextPageUrl =[data1Dict objectForKey:@"next_page_url"];
                    self->_path1=[data1Dict objectForKey:@"path"];
                    self->_currentPage=[[data1Dict objectForKey:@"current_page"] integerValue];
                    self->_totalTickets=[[data1Dict objectForKey:@"total"] integerValue];
                    self->_totalPages=[[data1Dict objectForKey:@"last_page"] integerValue];
                    
                    self->_mutableArray= [self->_mutableArray mutableCopy];
                    
                    [self->_mutableArray addObjectsFromArray:[data1Dict objectForKey:@"data"]];
                    
                    
                    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [self reloadTableView];
                            
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
            NSString *Page = [str substringFromIndex:[str length] - 1];
            
            //     NSLog(@"String is : %@",szResult);
            NSLog(@"Page is : %@",Page);
            NSLog(@"Page is : %@",Page);
            globalVariables.filterId=@"CLOSEDFilter";
            
            MyWebservices *webservices=[MyWebservices sharedInstance];
            //  [webservices getNextPageURLClosed:_path1 pageNo:Page  callbackHandler:^(NSError *error,id json,NSString* msg) {
            
            [webservices getNextPageURLClosed:url pageNo:Page  callbackHandler:^(NSError *error,id json,NSString* msg) {
                
                if (error || [msg containsString:@"Error"]) {
                    
                    if (msg) {
                        
                        [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",msg] sendViewController:self];
                        
                    }else if(error)  {
                        [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",error.localizedDescription] sendViewController:self];
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
                    
                    NSDictionary *data1Dict=[json objectForKey:@"data"];
                    
                    self->_nextPageUrl =[data1Dict objectForKey:@"next_page_url"];
                    self->_path1=[data1Dict objectForKey:@"path"];
                    self->_currentPage=[[data1Dict objectForKey:@"current_page"] integerValue];
                    self->_totalTickets=[[data1Dict objectForKey:@"total"] integerValue];
                    self->_totalPages=[[data1Dict objectForKey:@"last_page"] integerValue];
                    
                    self->_mutableArray= [self->_mutableArray mutableCopy];
                    
                    [self->_mutableArray addObjectsFromArray:[data1Dict objectForKey:@"data"]];
                    
                    
                    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [self reloadTableView];
                            
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
            NSString *Page = [str substringFromIndex:[str length] - 1];
            
            //     NSLog(@"String is : %@",szResult);
            NSLog(@"Page is : %@",Page);
            NSLog(@"Page is : %@",Page);
            globalVariables.filterId=@"TRASHFilter";
            
            MyWebservices *webservices=[MyWebservices sharedInstance];
            //   [webservices getNextPageURLTrash:_path1 pageNo:Page  callbackHandler:^(NSError *error,id json,NSString* msg) {
            
            [webservices getNextPageURLTrash:url pageNo:Page  callbackHandler:^(NSError *error,id json,NSString* msg) {
                
                if (error || [msg containsString:@"Error"]) {
                    
                    if (msg) {
                        
                        [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",msg] sendViewController:self];
                        
                    }else if(error)  {
                        [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",error.localizedDescription] sendViewController:self];
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
                    
                    NSDictionary *data1Dict=[json objectForKey:@"data"];
                    
                    self->_nextPageUrl =[data1Dict objectForKey:@"next_page_url"];
                    self->_path1=[data1Dict objectForKey:@"path"];
                    self->_currentPage=[[data1Dict objectForKey:@"current_page"] integerValue];
                    self->_totalTickets=[[data1Dict objectForKey:@"total"] integerValue];
                    self->_totalPages=[[data1Dict objectForKey:@"last_page"] integerValue];
                    
                    self->_mutableArray= [self->_mutableArray mutableCopy];
                    
                    [self->_mutableArray addObjectsFromArray:[data1Dict objectForKey:@"data"]];
                    
                    
                    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [self reloadTableView];
                            
                        });
                    });
                    
                }
                
                
            }];
        }
    }
}



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
        
        // tempDict= [_mutableArray objectAtIndex:indexPath.row];
        
        
        @try{
            
            //last replier
            NSString *replyer12=[finaldic objectForKey:@"last_replier"];
            [Utils isEmpty:replyer12];
            
            if  (![Utils isEmpty:replyer12] || ![replyer12 isEqualToString:@""])
            {
                if([replyer12 isEqualToString:@"client"])
                {
                    cell.viewMain.backgroundColor=[UIColor hx_colorWithHexRGBAString:@"#F2F2F2"];
                }else
                {
                    NSLog(@"I am in else condition..!");
                }
                
            }else
            {
                NSLog(@"I am in else condition..!");
            }
            
            
            //ticket number
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
            
            
            //agent info
            NSDictionary *assigneeDict=[finaldic objectForKey:@"assignee"];
            
            NSString *assigneeFirstName= [assigneeDict objectForKey:@"first_name"];
            NSString *assigneeLaststName= [assigneeDict objectForKey:@"last_name"];
            NSString *assigneeUserName= [assigneeDict objectForKey:@"user_name"];
            
            [Utils isEmpty:assigneeFirstName];
            [Utils isEmpty:assigneeLaststName];
            [Utils isEmpty:assigneeUserName];
            
            if (![Utils isEmpty:assigneeFirstName] || ![Utils isEmpty:assigneeLaststName])
            {
                if  (![Utils isEmpty:assigneeFirstName] && ![Utils isEmpty:assigneeLaststName])
                {
                    cell.agentLabel.text=[NSString stringWithFormat:@"%@ %@",assigneeFirstName,assigneeLaststName];
                }
                else
                {
                    cell.agentLabel.text=[NSString stringWithFormat:@"%@ %@",assigneeFirstName,assigneeLaststName];
                }
            }  else if(![Utils isEmpty:assigneeUserName])
            {
                cell.agentLabel.text= assigneeUserName;
            }else
            {
                cell.agentLabel.text= NSLocalizedString(@"Unassigned", nil);
            }
            
            
            //ticket owner/customer info
            
            NSDictionary *customerDict=[finaldic objectForKey:@"from"];
            
            NSString *fname= [customerDict objectForKey:@"first_name"];
            NSString *lname= [customerDict objectForKey:@"last_name"];
            NSString*userName=[customerDict objectForKey:@"user_name"];
            
            [Utils isEmpty:fname];
            [Utils isEmpty:lname];
            [Utils isEmpty:userName];
            
            
            if  (![Utils isEmpty:fname] || ![Utils isEmpty:lname])
            {
                if (![Utils isEmpty:fname] && ![Utils isEmpty:lname])
                {   cell.mailIdLabel.text=[NSString stringWithFormat:@"%@ %@",fname,lname];
                }
                else{
                    cell.mailIdLabel.text=[NSString stringWithFormat:@"%@ %@",fname,lname];
                }
            }
            else if(![Utils isEmpty:userName])
            {
                cell.mailIdLabel.text=userName;
            }
            else
            {
                cell.mailIdLabel.text=NSLocalizedString(@"Not Available", nil);
            }
            
            //Image view
            if([[customerDict objectForKey:@"profile_pic"] hasSuffix:@"system.png"] || [[customerDict objectForKey:@"profile_pic"] hasSuffix:@".jpg"] || [[customerDict objectForKey:@"profile_pic"] hasSuffix:@".jpeg"] || [[customerDict objectForKey:@"profile_pic"] hasSuffix:@".png"] )
            {
                [cell setUserProfileimage:[customerDict objectForKey:@"profile_pic"]];
            }
            else if(![Utils isEmpty:fname])
            {
                [cell.profilePicView setImageWithString:fname color:nil ];
            }
            else
            {
                [cell.profilePicView setImageWithString:userName color:nil ];
            }
            
            
            //updated time of ticket
            cell.timeStampLabel.text=[utils getLocalDateTimeFromUTC:[finaldic objectForKey:@"updated_at"]];
            
            
        } @catch (NSException *exception)
        {
            NSLog( @"Name: %@", exception.name);
            NSLog( @"Reason: %@", exception.reason );
            [utils showAlertWithMessage:exception.name sendViewController:self];
            // return;
        }
        @finally
        {
            NSLog( @" I am in cellForRowAtIndexPath method in Leftmenu ViewController" );
            
        }
        // ______________________________________________________________________________________________________
        ////////////////for UTF-8 data encoding ///////
        //   cell.ticketSubLabel.text=[finaldic objectForKey:@"title"];
        
        
        
        // NSString *encodedString = @"=?UTF-8?Q?Re:_Robin_-_Implementing_Faveo_H?= =?UTF-8?Q?elp_Desk._Let=E2=80=99s_get_you_started.?=";
        
        
        
        
        
        // NSString *encodedString =[finaldic objectForKey:@"ticket_title"];
        
        //NSString *encodedString =@"Sample Ticket Titile";
        
        NSString *encodedString =[finaldic objectForKey:@"title"];
        
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
                
                //   cell.ticketSubLabel.text= decodedString; //countthread
                cell.ticketSubLabel.text= [NSString stringWithFormat:@"%@ (%@)",decodedString,[finaldic objectForKey:@"thread_count"]];
            }
            else{
                
                // cell.ticketSubLabel.text= encodedString;
                cell.ticketSubLabel.text= [NSString stringWithFormat:@"%@ (%@)",encodedString,[finaldic objectForKey:@"thread_count"]];
                
            }
            
        }
        ///////////////////////////////////////////////////
        //____________________________________________________________________________________________________
        
        
        // [cell setUserProfileimage:[finaldic objectForKey:@"profile_pic"]];
        @try{
            
            //                if (  ![[finaldic objectForKey:@"profile_pic"] isEqual:[NSNull null]]   )
            //                {
            //                    [cell setUserProfileimage:[finaldic objectForKey:@"profile_pic"]];
            //
            //                }
            //                else
            //                {
            //                    [cell setUserProfileimage:@"default_pic.png"];
            //                }
            
            
            if ( ( ![[finaldic objectForKey:@"status"] isEqual:[NSNull null]] ) && ( [[finaldic objectForKey:@"status"] length] != 0 ) ) {
                
                if ([[finaldic objectForKey:@"status"] isEqualToString:@"Halt_SLA"]) {
                    
                    [cell.overDueLabel setHidden:YES];
                    [cell.today setHidden:YES];
                }
                else
                {
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
                    
                }
            }
            
            
            
            
            NSString * source1=[finaldic objectForKey:@"source"];
            
            NSString *cc= [NSString stringWithFormat:@"%@",[finaldic objectForKey:@"countcollaborator"]];
            
            NSString *attachment1= [NSString stringWithFormat:@"%@",[finaldic objectForKey:@"attachment_count"]];
            
            
            if([source1 isEqualToString:@"web"] || [source1 isEqualToString:@"Web"])
            {
                cell.sourceImgView.image=[UIImage imageNamed:@"internert"];
            }else  if([source1 isEqualToString:@"email"] ||[source1 isEqualToString:@"Email"] )
            {
                cell.sourceImgView.image=[UIImage imageNamed:@"agentORmail"];
            }else  if([source1 isEqualToString:@"agent"] || [source1 isEqualToString:@"Agent"])
            {
                cell.sourceImgView.image=[UIImage imageNamed:@"agentORmail"];
            }else  if([source1 isEqualToString:@"facebook"] || [source1 isEqualToString:@"Facebook"])
            {
                cell.sourceImgView.image=[UIImage imageNamed:@"fb"];
            }else  if([source1 isEqualToString:@"twitter"] || [source1 isEqualToString:@"Twitter"])
            {
                cell.sourceImgView.image=[UIImage imageNamed:@"twitter"];
            }else  if([source1 isEqualToString:@"call"] || [source1 isEqualToString:@"Call"])
            {
                cell.sourceImgView.image=[UIImage imageNamed:@"call"];
            }else if([source1 isEqualToString:@"chat"] || [source1 isEqualToString:@"Chat"])
            {
                cell.sourceImgView.image=[UIImage imageNamed:@"chat"];
            }
            
            
            
            
            
            if(![cc isEqualToString:@"<null>"] && ![attachment1 isEqualToString:@"0"])
            {
                cell.ccImgView.image=[UIImage imageNamed:@"cc1"];
                cell.attachImgView.image=[UIImage imageNamed:@"attach"];
            }
            else if(![cc isEqualToString:@"<null>"] && [attachment1 isEqualToString:@"0"])
            {
                cell.ccImgView.image=[UIImage imageNamed:@"cc1"];
            }
            else if([cc isEqualToString:@"<null>"] && ![attachment1 isEqualToString:@"0"])
            {
                cell.ccImgView.image=[UIImage imageNamed:@"attach"];
            }
            
            
            //priority color
            NSDictionary *priorityDict=[finaldic objectForKey:@"priority"];
            cell.indicationView.layer.backgroundColor=[[UIColor hx_colorWithHexRGBAString:[priorityDict objectForKey:@"color"]] CGColor];
            
            
            
        }@catch (NSException *exception)
        {
            NSLog( @"Name: %@", exception.name);
            NSLog( @"Reason: %@", exception.reason );
            [utils showAlertWithMessage:exception.name sendViewController:self];
            //return;
        }
        @finally
        {
            NSLog( @" I am in cellForAtIndexPath method in Inobx ViewController" );
            
        }
        
        // }
        return cell;
    }
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 3;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    self.selectedPath = indexPath;
    
    NSDictionary *finaldic=[_mutableArray objectAtIndex:indexPath.row];
    
    if ([tableView isEditing]) {
        
        //taking id from selected rows
        [selectedArray addObject:[finaldic objectForKey:@"id"]];
        
        //taking ticket title from selected rows
        [selectedSubjectArray addObject:[[_mutableArray objectAtIndex:indexPath.row] valueForKey:@"title"]];
        
        //taking email id
        [selectedTicketOwner addObject:[[[_mutableArray objectAtIndex:indexPath.row] objectForKey:@"from"] valueForKey:@"email"]];
        
        count1=(int)[selectedArray count];
        NSLog(@"Selected count is :%i",count1);
        NSLog(@"Slected Array Id : %@",selectedArray);
        NSLog(@"Slected Owner Emails are : %@",selectedTicketOwner);
        
        selectedIDs = [selectedArray componentsJoinedByString:@","];
        NSLog(@"Slected Ticket Id are : %@",selectedIDs);
        
        NSLog(@"Slected Ticket Subjects are : %@",selectedSubjectArray);
        
        
    }else{
        
        
        TicketDetailViewController *td=[self.storyboard instantiateViewControllerWithIdentifier:@"TicketDetailVCID"];
        
        
        NSDictionary *finaldic=[_mutableArray objectAtIndex:indexPath.row];
        
        //iD  ticket id
        globalVariables.iD=[finaldic objectForKey:@"id"];
        globalVariables.Ticket_status=[finaldic objectForKey:@"status"];
        globalVariables.ticket_number=[finaldic objectForKey:@"ticket_number"];
        globalVariables.ticketStatusBool=@"ticketView";
        
        
        NSDictionary *customerDict=[finaldic objectForKey:@"from"];
        
        globalVariables.First_name=[customerDict objectForKey:@"first_name"];
        globalVariables.Last_name=[customerDict objectForKey:@"last_name"];
        globalVariables.userIdFromInbox=[customerDict objectForKey:@"id"];
        
        
        [self.navigationController pushViewController:td animated:YES];
        
        
    }
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.selectedPath = indexPath;
    
    NSDictionary *finaldic=[_mutableArray objectAtIndex:indexPath.row];
    
    
    //removing id from selected rows
    [selectedArray removeObject:[finaldic objectForKey:@"id"]];
    
    //removing ticket title from selected rows
    [selectedSubjectArray removeObject:[[_mutableArray objectAtIndex:indexPath.row] valueForKey:@"title"]];
    
    //removing email id
    [selectedTicketOwner removeObject:[[[_mutableArray objectAtIndex:indexPath.row] objectForKey:@"from"] valueForKey:@"email"]];
    
    
    count1=(int)[selectedArray count];
    NSLog(@"Selected count is :%i",count1);
    NSLog(@"Slected Id : %@",selectedArray);
    
    selectedIDs = [selectedArray componentsJoinedByString:@","];
    
    NSLog(@"Slected Ticket Id are : %@",selectedIDs);
    NSLog(@"Slected Ticket Subjects are : %@",selectedSubjectArray);
    NSLog(@"Slected Owner Emails are : %@",selectedTicketOwner);
    
    if (!selectedArray.count) {
        [self.tableView setEditing:NO animated:YES];
        navbar.hidden=YES;
    }
    
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


-(void)onNavButtonTapped:(UIBarButtonItem *)sender event:(UIEvent *)event
{
    NSLog(@"11111111*********111111111111");
    
    if (!selectedArray.count) {
        
        [utils showAlertWithMessage:@"Select The Tickets First For Changing Ticket Status" sendViewController:self];
        
    }else
    {
        
#ifdef IfMethodOne
        CGRect rect = [self.navigationController.navigationBar convertRect:[event.allTouches.anyObject view].frame toView:[[UIApplication sharedApplication] keyWindow]];
        
        [FTPopOverMenu showFromSenderFrame:rect
                             withMenuArray:@[@"MenuOne",@"MenuTwo",@"MenuThree",@"MenuFour"]
                                imageArray:@[@"Pokemon_Go_01",@"Pokemon_Go_02",@"Pokemon_Go_03",@"Pokemon_Go_04",]
                                 doneBlock:^(NSInteger selectedIndex) {
                                     NSLog(@"done");
                                 } dismissBlock:^{
                                     NSLog(@"cancel");
                                 }];
        
        
#else
        

        //taking status names array for dependecy api
        for (NSDictionary *dicc in self->ticketStatusArray) {
            if ([dicc objectForKey:@"name"]) {
                [self->statusArrayforChange addObject:[dicc objectForKey:@"name"]];
                [self->statusIdforChange addObject:[dicc objectForKey:@"id"]];
            }
            
        }
        
        
        //removing duplicated status names
        for (id obj in self->statusArrayforChange) {
            if (![uniqueStatusNameArray containsObject:obj]) {
                [uniqueStatusNameArray addObject:obj];
            }
        }
        
        [FTPopOverMenu showFromEvent:event
                       withMenuArray:uniqueStatusNameArray
                          imageArray:uniqueStatusNameArray
                           doneBlock:^(NSInteger selectedIndex) {
                               
                               
                               self->selectedStatusName=[self->uniqueStatusNameArray objectAtIndex:selectedIndex];
                               NSLog(@"Status is : %@",self->selectedStatusName);
                               
                               
                               for (NSDictionary *dic in self->ticketStatusArray)
                               {
                                   NSString *idOfStatus = dic[@"name"];
                                   
                                   if([idOfStatus isEqual:self->selectedStatusName])
                                   {
                                       self->selectedStatusId= dic[@"id"];
                                       
                                       NSLog(@"id is : %@",self->selectedStatusId);
                                   }
                               }
                               
                               if([self->selectedStatusName isEqualToString:@"Open"] || [self->selectedStatusName isEqualToString:@"open"])
                               {
                                   [self->utils showAlertWithMessage:NSLocalizedString(@"Ticket is Already Open",nil) sendViewController:self];
                                   [[AppDelegate sharedAppdelegate] hideProgressView];
                               }
                               else{
                                   [self changeStatusMethod:self->selectedStatusName idIs:self->selectedStatusId];
                               }
                               
                           }
                        dismissBlock:^{
                            
                        }];
        
#endif
    }
}




-(void)changeStatusMethod:(NSString *)nameOfStatus idIs:(NSString *)idOfStatus
{
    
    NSLog(@"Status Name is : %@",nameOfStatus);
    NSLog(@"Id is : %@",idOfStatus);
    
    if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable)
    {
        //connection unavailable
        
        [RKDropdownAlert title:APP_NAME message:NO_INTERNET backgroundColor:[UIColor hx_colorWithHexRGBAString:FAILURE_COLOR] textColor:[UIColor whiteColor]];
        
        
    }else{
        
        [[AppDelegate sharedAppdelegate] showProgressView];
        
        if ([Utils isEmpty:selectedIDs] || [selectedIDs isEqualToString:@""] ||[selectedIDs isEqualToString:@"(null)" ] )
        {
            [utils showAlertWithMessage:@"Please Select The Tickets.!" sendViewController:self];
            [[AppDelegate sharedAppdelegate] hideProgressView];
        }
        else{
            NSString *url= [NSString stringWithFormat:@"%@api/v2/helpdesk/status/change?api_key=%@&token=%@&ticket_id=%@&status_id=%@",[userDefaults objectForKey:@"baseURL"],API_KEY,[userDefaults objectForKey:@"token"],selectedIDs,idOfStatus];
            NSLog(@"URL is : %@",url);
            
            MyWebservices *webservices=[MyWebservices sharedInstance];
            
            [webservices httpResponsePOST:url parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
                [[AppDelegate sharedAppdelegate] hideProgressView];
                
                if (error || [msg containsString:@"Error"]) {
                    
                    if (msg) {
                        
                        if([msg isEqualToString:@"Error-403"])
                        {
                            [self->utils showAlertWithMessage:NSLocalizedString(@"Permission Denied - You don't have permission to change status. ", nil) sendViewController:self];
                            [[AppDelegate sharedAppdelegate] hideProgressView];
                        }
                        else{
                            [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",msg] sendViewController:self];
                            [[AppDelegate sharedAppdelegate] hideProgressView];
                        }
                        //  NSLog(@"Message is : %@",msg);
                        
                    }else if(error)  {
                        [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",error.localizedDescription] sendViewController:self];
                        NSLog(@"Thread-NO4-getTicketStausChange-Refresh-error == %@",error.localizedDescription);
                        [[AppDelegate sharedAppdelegate] hideProgressView];
                    }
                    
                    return ;
                }
                
                if ([msg isEqualToString:@"tokenRefreshed"]) {
                    
                    [self changeStatusMethod:self->selectedStatusName idIs:self->selectedStatusId];
                    NSLog(@"Thread--NO4-call-postTicketStatusChange");
                    return;
                }
                
                if (json) {
                    NSLog(@"JSON-Status-Change-Close-%@",json);
                      [[AppDelegate sharedAppdelegate] hideProgressView];
                    
                    if([[json objectForKey:@"message"] isKindOfClass:[NSArray class]])
                    {
                        [self->utils showAlertWithMessage:NSLocalizedString(@"Permission Denied - You don't have permission to change status. ", nil) sendViewController:self];
                        [[AppDelegate sharedAppdelegate] hideProgressView];
                        
                    }
                    else{
                        
                        NSString * msg=[json objectForKey:@"message"];
                        
                        if([msg hasPrefix:@"Status changed"]){
                            
                            [RKDropdownAlert title: NSLocalizedString(@"success.", nil) message:NSLocalizedString(@"Ticket Status Changed.", nil) backgroundColor:[UIColor hx_colorWithHexRGBAString:SUCCESS_COLOR] textColor:[UIColor whiteColor]];
                            
                            InboxViewController *inboxVC=[self.storyboard instantiateViewControllerWithIdentifier:@"InboxID"];
                            [self.navigationController pushViewController:inboxVC animated:YES];
                            
                        }else
                        {
                            
                            [self->utils showAlertWithMessage:NSLocalizedString(@"Permission Denied - You don't have permission to change status. ", nil) sendViewController:self];
                            
                        }
                        
                    }
                }
                
                NSLog(@"Thread-NO5-postTicketStatusChange-closed");
                
            }];
        }
        
    }
    
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
                         @[@"Ticket Title", @"Ticket Number", @"Priority", @"Updated at", @"Created at",@"Due Date"],
                         //
                         @[]
                         ];
    NSArray *rightArr = @[
                          // 对应dataSourceLeftArray
                          @[
                              
                              // @[]
                              //   @[@"Show Filter",@"Clear All",@"Exit"]
                              @[@"Show Filter",@"Exit"]
                              
                              
                              ],
                          @[
                              // 一级菜单
                              // 金额
                              @[@"ASC", @"DES",@"Exit"], @[@"ASC", @"DES",@"Exit"], @[@"ASC", @"DES",@"Exit"], @[@"ASC", @"DES",@"Exit"],@[@"ASC", @"DES",@"Exit"],@[@"ASC", @"DES",@"Exit"]
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
                                                    @"selected" : @[[UIColor blackColor], @"测试紫箭头"],
                                                    @"normal" : @[[UIColor blackColor], @"测试红箭头"]
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
    //    if(titleButtonIndex==0 && rightIndex==1 )
    //    {
    //        NSLog(@"clear All");
    //
    //        FilterLogic *fil=[self.storyboard instantiateViewControllerWithIdentifier:@"FilterLogicID"];
    //
    //        [self.navigationController pushViewController:fil animated:YES];
    //
    //    }
    
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
    
    
}


@end

