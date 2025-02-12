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
#import "UIImageView+Letters.h"
#import "MultpleTicketAssignTableViewController.h"
#import "TicketSearchViewController.h"
#import "TableViewAnimationKitHeaders.h"


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
    
    NSMutableArray *selectedArray;
    NSMutableArray *selectedSubjectArray;
    NSMutableArray *selectedTicketOwner;
    
    int count1;
    NSString *selectedIDs;
    NSString * assigned1;
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

@property (nonatomic, strong) CFMultistageDropdownMenuView *multistageDropdownMenuView;
@property (nonatomic, strong) CFMultistageConditionTableView *multistageConditionTableView;

@property (nonatomic, assign) NSInteger animationType;


@end

@implementation SortingViewController

//This method is called after the view controller has loaded its view hierarchy into memory. This method is called regardless of whether the view hierarchy was loaded from a nib file or created programmatically in the loadView method.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addUIRefresh];
    
    customAlert = [[BDCustomAlertView alloc] init];
    _multistageDropdownMenuView.tag=99;
    
    globalVariables=[GlobalVariables sharedInstance];
    userDefaults=[NSUserDefaults standardUserDefaults];
    
    
    statusArrayforChange = [[NSMutableArray alloc] init];
    statusIdforChange = [[NSMutableArray alloc] init];
    uniqueStatusNameArray = [[NSMutableArray alloc] init];
    
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
    
    
    _mutableArray=[[NSMutableArray alloc]init];
    selectedSubjectArray = [[NSMutableArray alloc] init];
    selectedTicketOwner = [[NSMutableArray alloc] init];
    
    utils=[[Utils alloc]init];
    
    NSLog(@"device_token %@",[userDefaults objectForKey:@"deviceToken"]);
    
    UIButton *moreButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    [moreButton setImage:[UIImage imageNamed:@"search1"] forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(searchButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    //    [moreButton setFrame:CGRectMake(46, 0, 32, 32)];
    [moreButton setFrame:CGRectMake(10, 0, 35, 35)];
    
    _animationType = 5;

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

- (void)loadAnimation {
    
    [self.tableView reloadData];
    [self starAnimationWithTableView:self.tableView];
    
}

- (void)starAnimationWithTableView:(UITableView *)tableView {
    
    [TableViewAnimationKit showWithAnimationType:self.animationType tableView:tableView];
    
}


// After clickig this button, it will naviagte to search view controller
- (IBAction)searchButtonClicked {
    
    TicketSearchViewController * search=[self.storyboard instantiateViewControllerWithIdentifier:@"TicketSearchViewControllerId"];
    [self.navigationController pushViewController:search animated:YES];
    
    
}

// After clicking this navigation button, it will navigate to the assign view controller.

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
        [[AppDelegate sharedAppdelegate] hideProgressView];
        return;
    }
    @finally
    {
        NSLog( @" I am in clickedOnAssignButton method in Sorting ViewController" );
        
    }
    
    
}

//After clickig this navigation button, it will naviaget to ticket merge view controller
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
        [[AppDelegate sharedAppdelegate] hideProgressView];
        return;
    }
    @finally
    {
        NSLog( @" I am in mergeButtonClicked method in Sorting ViewController" );
        
    }
    
    
}

//This method is called before the view controller's view is about to be added to a view hierarchy and before any animations are configured for showing the view.
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

// Handling the tableview even we reload the tablview, edit view will not vanish even we scroll
- (void)reloadTableView
{
    NSArray *indexPaths = [self.tableView indexPathsForSelectedRows];
    [self.tableView reloadData];
    for (NSIndexPath *path in indexPaths) {
        [self.tableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}


// This method calls an API for getting tickets, it will returns an JSON which contains 10 records with ticket details.
-(void)reload{
    
    if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable)
    {
        [refresh endRefreshing];
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
                if([globalVariables.sortCondition isEqualToString:@"INBOX"] && [globalVariables.filterCondition isEqualToString:@"INBOX"] && [globalVariables.filterId isEqualToString:@"INBOXFilter"] && [globalVariables.sortingValueId isEqualToString:@"sortTitleAsc"])
                {
                    NSString *strURL= [NSString stringWithFormat:@"%@",globalVariables.urlFromFilterLogicView];
                    url= [strURL stringByAppendingString:@"&sort-by=ticket_title&order=ASC"];
                }
                else{
                    url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,Alldeparatments,ticketSortByTicketTitle,orderASC];
                    NSLog(@"URL is : %@",url);
                    
                    globalVariables.sortCondtionValueToSendWebServices=@"&sort-by=ticket_title&order=ASC";
                    globalVariables.sortCondition=@"INBOX";
                }
            }
            
            else   if ([globalVariables.sortingValueId isEqualToString:@"sortTitleDsc"])
            {
                if([globalVariables.sortCondition isEqualToString:@"INBOX"] && [globalVariables.filterCondition isEqualToString:@"INBOX"] && [globalVariables.filterId isEqualToString:@"INBOXFilter"] && [globalVariables.sortingValueId isEqualToString:@"sortTitleDsc"])
                {
                    NSString *strURL= [NSString stringWithFormat:@"%@",globalVariables.urlFromFilterLogicView];
                    url= [strURL stringByAppendingString:@"&sort-by=ticket_title&order=DESC"];
                }
                else{
                    url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,Alldeparatments,ticketSortByTicketTitle,orderDESC];
                    NSLog(@"URL is : %@",url);
                    globalVariables.sortCondtionValueToSendWebServices=@"&sort-by=ticket_title&order=DESC";
                    globalVariables.sortCondition=@"INBOX";
                }
            }
            
            
            else  if ([globalVariables.sortingValueId isEqualToString:@"sortNumberAsc"])
            {
                if([globalVariables.sortCondition isEqualToString:@"INBOX"] && [globalVariables.filterCondition isEqualToString:@"INBOX"] && [globalVariables.filterId isEqualToString:@"INBOXFilter"] && [globalVariables.sortingValueId isEqualToString:@"sortNumberAsc"])
                {
                    NSString *strURL= [NSString stringWithFormat:@"%@",globalVariables.urlFromFilterLogicView];
                    url= [strURL stringByAppendingString:@"&sort-by=ticket_number&order=ASC"];
                }else{
                    url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,Alldeparatments,ticketSortByTicketNumber,orderASC];
                    NSLog(@"URL is : %@",url);
                    globalVariables.sortCondtionValueToSendWebServices=@"&sort-by=ticket_number&order=ASC";
                    globalVariables.sortCondition=@"INBOX";
                }
            }
            
            else if ([globalVariables.sortingValueId isEqualToString:@"sortNumberDsc"])
            {
                if([globalVariables.sortCondition isEqualToString:@"INBOX"] && [globalVariables.filterCondition isEqualToString:@"INBOX"] && [globalVariables.filterId isEqualToString:@"INBOXFilter"] && [globalVariables.sortingValueId isEqualToString:@"sortNumberDsc"])
                {
                    NSString *strURL= [NSString stringWithFormat:@"%@",globalVariables.urlFromFilterLogicView];
                    url= [strURL stringByAppendingString:@"&sort-by=ticket_number&order=DESC"];
                }else{
                    url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,Alldeparatments,ticketSortByTicketNumber,orderDESC];
                    NSLog(@"URL is : %@",url);
                    globalVariables.sortCondtionValueToSendWebServices=@"&sort-by=ticket_number&order=DESC";
                    globalVariables.sortCondition=@"INBOX";
                }
            }
            
            else  if ([globalVariables.sortingValueId isEqualToString:@"sortPriorityAsc"])
            {
                if([globalVariables.sortCondition isEqualToString:@"INBOX"] && [globalVariables.filterCondition isEqualToString:@"INBOX"] && [globalVariables.filterId isEqualToString:@"INBOXFilter"] && [globalVariables.sortingValueId isEqualToString:@"sortPriorityAsc"])
                {
                    NSString *strURL= [NSString stringWithFormat:@"%@",globalVariables.urlFromFilterLogicView];
                    url= [strURL stringByAppendingString:@"&sort-by=priority&order=ASC"];
                }else{
                    url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,Alldeparatments,ticketSortByPriority,orderASC];
                    NSLog(@"URL is : %@",url);
                    globalVariables.sortCondtionValueToSendWebServices=@"&sort-by=priority&order=ASC";
                    globalVariables.sortCondition=@"INBOX";
                }
            }
            
            else  if ([globalVariables.sortingValueId isEqualToString:@"sortPriorityDsc"])
            {
                if([globalVariables.sortCondition isEqualToString:@"INBOX"] && [globalVariables.filterCondition isEqualToString:@"INBOX"] && [globalVariables.filterId isEqualToString:@"INBOXFilter"] && [globalVariables.sortingValueId isEqualToString:@"sortPriorityDsc"])
                {
                    NSString *strURL= [NSString stringWithFormat:@"%@",globalVariables.urlFromFilterLogicView];
                    url= [strURL stringByAppendingString:@"&sort-by=priority&order=DESC"];
                }else{
                    url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,Alldeparatments,ticketSortByPriority,orderDESC];
                    NSLog(@"URL is : %@",url);
                    globalVariables.sortCondtionValueToSendWebServices=@"&sort-by=priority&order=DESC";
                    globalVariables.sortCondition=@"INBOX";
                }
            }
            
            else  if ([globalVariables.sortingValueId isEqualToString:@"sortUpdatedAsc"])
            {
                if([globalVariables.sortCondition isEqualToString:@"INBOX"] && [globalVariables.filterCondition isEqualToString:@"INBOX"] && [globalVariables.filterId isEqualToString:@"INBOXFilter"] && [globalVariables.sortingValueId isEqualToString:@"sortUpdatedAsc"])
                {
                    NSString *strURL= [NSString stringWithFormat:@"%@",globalVariables.urlFromFilterLogicView];
                    url= [strURL stringByAppendingString:@"&sort-by=updated_at&order=ASC"];
                }else{
                    url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,Alldeparatments,ticketSortByUpdatedAt,orderASC];
                    NSLog(@"URL is : %@",url);
                    globalVariables.sortCondtionValueToSendWebServices=@"&sort-by=updated_at&order=ASC";
                    globalVariables.sortCondition=@"INBOX";
                }
            }
            
            else if ([globalVariables.sortingValueId isEqualToString:@"sortUpdatedDsc"])
            {
                if([globalVariables.sortCondition isEqualToString:@"INBOX"] && [globalVariables.filterCondition isEqualToString:@"INBOX"] && [globalVariables.filterId isEqualToString:@"INBOXFilter"] && [globalVariables.sortingValueId isEqualToString:@"sortUpdatedDsc"])
                {
                    NSString *strURL= [NSString stringWithFormat:@"%@",globalVariables.urlFromFilterLogicView];
                    url= [strURL stringByAppendingString:@"&sort-by=updated_at&order=DESC"];
                }else{
                    url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,Alldeparatments,ticketSortByUpdatedAt,orderDESC];
                    NSLog(@"URL is : %@",url);
                    globalVariables.sortCondtionValueToSendWebServices=@"&sort-by=updated_at&order=DESC";
                    globalVariables.sortCondition=@"INBOX";
                }
            }
            
            else if ([globalVariables.sortingValueId isEqualToString:@"sortCreatedAsc"])
            {
                if([globalVariables.sortCondition isEqualToString:@"INBOX"] && [globalVariables.filterCondition isEqualToString:@"INBOX"] && [globalVariables.filterId isEqualToString:@"INBOXFilter"] && [globalVariables.sortingValueId isEqualToString:@"sortCreatedAsc"])
                {
                    NSString *strURL= [NSString stringWithFormat:@"%@",globalVariables.urlFromFilterLogicView];
                    url= [strURL stringByAppendingString:@"&sort-by=created_at&order=ASC"];
                }else{
                    url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,Alldeparatments,ticketSortByCreatedAt,orderASC];
                    NSLog(@"URL is : %@",url);
                    globalVariables.sortCondtionValueToSendWebServices=@"&sort-by=created_at&order=ASC";
                    globalVariables.sortCondition=@"INBOX";
                }
            }
            
            else if ([globalVariables.sortingValueId isEqualToString:@"sortCreatedDsc"])
            {
                if([globalVariables.sortCondition isEqualToString:@"INBOX"] && [globalVariables.filterCondition isEqualToString:@"INBOX"] && [globalVariables.filterId isEqualToString:@"INBOXFilter"] && [globalVariables.sortingValueId isEqualToString:@"sortCreatedDsc"])
                {
                    NSString *strURL= [NSString stringWithFormat:@"%@",globalVariables.urlFromFilterLogicView];
                    url= [strURL stringByAppendingString:@"&sort-by=created_at&order=DESC"];
                }else{
                    url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,Alldeparatments,ticketSortByCreatedAt,orderDESC];
                    NSLog(@"URL is : %@",url);
                    globalVariables.sortCondtionValueToSendWebServices=@"&sort-by=created_at&order=DESC";
                    globalVariables.sortCondition=@"INBOX";
                }
            }
            //
            else   if ([globalVariables.sortingValueId isEqualToString:@"sortDueAsc"])
            {
                if([globalVariables.sortCondition isEqualToString:@"INBOX"] && [globalVariables.filterCondition isEqualToString:@"INBOX"] && [globalVariables.filterId isEqualToString:@"INBOXFilter"] && [globalVariables.sortingValueId isEqualToString:@"sortDueAsc"])
                {
                    NSString *strURL= [NSString stringWithFormat:@"%@",globalVariables.urlFromFilterLogicView];
                    url= [strURL stringByAppendingString:@"&sort-by=due&order=ASC"];
                }else{
                    url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,Alldeparatments,ticketSortByDue,orderASC];
                    NSLog(@"URL is : %@",url);
                    globalVariables.sortCondtionValueToSendWebServices=@"&sort-by=due&order=ASC";
                    globalVariables.sortCondition=@"INBOX";
                }
            }
            
            else if ([globalVariables.sortingValueId isEqualToString:@"sortDueDsc"])
            {
                if([globalVariables.sortCondition isEqualToString:@"INBOX"] && [globalVariables.filterCondition isEqualToString:@"INBOX"] && [globalVariables.filterId isEqualToString:@"INBOXFilter"] && [globalVariables.sortingValueId isEqualToString:@"sortDueAsc"])
                {
                    NSString *strURL= [NSString stringWithFormat:@"%@",globalVariables.urlFromFilterLogicView];
                    url= [strURL stringByAppendingString:@"&sort-by=due&order=DESC"];
                }else{
                    url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,Alldeparatments,ticketSortByDue,orderDESC];
                    NSLog(@"URL is : %@",url);
                    globalVariables.sortCondtionValueToSendWebServices=@"&sort-by=due&order=DESC";
                    globalVariables.sortCondition=@"INBOX";
                }
            }
            else
            { //
            }
            
            //   }
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
            
            assigned1 = [NSString stringWithFormat:@"%i",0];
            
            NSLog(@"Value of globalsort i s: %@",globalVariables.sortingValueId);
            
            
            if ([globalVariables.sortingValueId isEqualToString:@"sortTitleAsc"])
            {
                if([globalVariables.sortCondition isEqualToString:@"UNASSIGNED"] && [globalVariables.filterCondition isEqualToString:@"UNASSIGNED"] && [globalVariables.filterId isEqualToString:@"UNASSIGNEDFilter"] && [globalVariables.sortingValueId isEqualToString:@"sortTitleAsc"])
                {
                    NSString *strURL= [NSString stringWithFormat:@"%@",globalVariables.urlFromFilterLogicView];
                    url= [strURL stringByAppendingString:@"&sort-by=ticket_title&order=ASC"];
                }
                else{
                    url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@&assigned=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,Alldeparatments,ticketSortByTicketTitle,orderASC,assigned1];
                    NSLog(@"URL is : %@",url);
                    globalVariables.sortCondtionValueToSendWebServices=@"&sort-by=ticket_title&order=ASC";
                    globalVariables.sortCondition=@"UNASSIGNED";
                }
            }
            
            else   if ([globalVariables.sortingValueId isEqualToString:@"sortTitleDsc"])
            {
                if([globalVariables.sortCondition isEqualToString:@"UNASSIGNED"] && [globalVariables.filterCondition isEqualToString:@"UNASSIGNED"] && [globalVariables.filterId isEqualToString:@"UNASSIGNEDFilter"] && [globalVariables.sortingValueId isEqualToString:@"sortTitleDsc"])
                {
                    NSString *strURL= [NSString stringWithFormat:@"%@",globalVariables.urlFromFilterLogicView];
                    url= [strURL stringByAppendingString:@"&sort-by=ticket_title&order=DESC"];
                }
                else{
                    url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@&assigned=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,Alldeparatments,ticketSortByTicketTitle,orderDESC,assigned1];
                    NSLog(@"URL is : %@",url);
                    globalVariables.sortCondtionValueToSendWebServices=@"&sort-by=ticket_title&order=DESC";
                    globalVariables.sortCondition=@"UNASSIGNED";
                }
            }
            
            
            else  if ([globalVariables.sortingValueId isEqualToString:@"sortNumberAsc"])
            {
                if([globalVariables.sortCondition isEqualToString:@"UNASSIGNED"] && [globalVariables.filterCondition isEqualToString:@"UNASSIGNED"] && [globalVariables.filterId isEqualToString:@"UNASSIGNEDFilter"] && [globalVariables.sortingValueId isEqualToString:@"sortNumberAsc"])
                {
                    NSString *strURL= [NSString stringWithFormat:@"%@",globalVariables.urlFromFilterLogicView];
                    url= [strURL stringByAppendingString:@"&sort-by=ticket_number&order=ASC"];
                }else{
                    url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@&assigned=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,Alldeparatments,ticketSortByTicketNumber,orderASC,assigned1];
                    NSLog(@"URL is : %@",url);
                    globalVariables.sortCondtionValueToSendWebServices=@"&sort-by=ticket_number&order=ASC";
                    globalVariables.sortCondition=@"UNASSIGNED";
                }
                
            }
            
            else if ([globalVariables.sortingValueId isEqualToString:@"sortNumberDsc"])
            {
                if([globalVariables.sortCondition isEqualToString:@"UNASSIGNED"] && [globalVariables.filterCondition isEqualToString:@"UNASSIGNED"] && [globalVariables.filterId isEqualToString:@"UNASSIGNEDFilter"] && [globalVariables.sortingValueId isEqualToString:@"sortNumberDsc"])
                {
                    NSString *strURL= [NSString stringWithFormat:@"%@",globalVariables.urlFromFilterLogicView];
                    url= [strURL stringByAppendingString:@"&sort-by=ticket_number&order=DESC"];
                    
                }else{
                    url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@&assigned=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,Alldeparatments,ticketSortByTicketNumber,orderDESC,assigned1];
                    NSLog(@"URL is : %@",url);
                    globalVariables.sortCondtionValueToSendWebServices=@"&sort-by=ticket_number&order=DESC";
                    globalVariables.sortCondition=@"UNASSIGNED";
                }
            }
            
            else  if ([globalVariables.sortingValueId isEqualToString:@"sortPriorityAsc"])
            {
                if([globalVariables.sortCondition isEqualToString:@"UNASSIGNED"] && [globalVariables.filterCondition isEqualToString:@"UNASSIGNED"] && [globalVariables.filterId isEqualToString:@"UNASSIGNEDFilter"] && [globalVariables.sortingValueId isEqualToString:@"sortPriorityAsc"])
                {
                    NSString *strURL= [NSString stringWithFormat:@"%@",globalVariables.urlFromFilterLogicView];
                    url= [strURL stringByAppendingString:@"&sort-by=priority&order=ASC"];
                }else{
                    url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@&assigned=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,Alldeparatments,ticketSortByPriority,orderASC,assigned1];
                    NSLog(@"URL is : %@",url);
                    globalVariables.sortCondtionValueToSendWebServices=@"&sort-by=priority&order=ASC";
                    globalVariables.sortCondition=@"UNASSIGNED";
                }
            }
            
            else  if ([globalVariables.sortingValueId isEqualToString:@"sortPriorityDsc"])
            {
                if([globalVariables.sortCondition isEqualToString:@"UNASSIGNED"] && [globalVariables.filterCondition isEqualToString:@"UNASSIGNED"] && [globalVariables.filterId isEqualToString:@"UNASSIGNEDFilter"] && [globalVariables.sortingValueId isEqualToString:@"sortPriorityDsc"])
                {
                    NSString *strURL= [NSString stringWithFormat:@"%@",globalVariables.urlFromFilterLogicView];
                    url= [strURL stringByAppendingString:@"&sort-by=priority&order=DESC"];
                }else{
                    url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@&assigned=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,Alldeparatments,ticketSortByPriority,orderDESC,assigned1];
                    NSLog(@"URL is : %@",url);
                    globalVariables.sortCondtionValueToSendWebServices=@"&sort-by=priority&order=DESC";
                    globalVariables.sortCondition=@"UNASSIGNED";
                }
            }
            
            else  if ([globalVariables.sortingValueId isEqualToString:@"sortUpdatedAsc"])
            {
                if([globalVariables.sortCondition isEqualToString:@"UNASSIGNED"] && [globalVariables.filterCondition isEqualToString:@"UNASSIGNED"] && [globalVariables.filterId isEqualToString:@"UNASSIGNEDFilter"] && [globalVariables.sortingValueId isEqualToString:@"sortUpdatedAsc"])
                {
                    NSString *strURL= [NSString stringWithFormat:@"%@",globalVariables.urlFromFilterLogicView];
                    url= [strURL stringByAppendingString:@"&sort-by=updated_at&order=ASC"];
                }else{
                    url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@&assigned=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,Alldeparatments,ticketSortByUpdatedAt,orderASC,assigned1];
                    NSLog(@"URL is : %@",url);
                    globalVariables.sortCondtionValueToSendWebServices=@"&sort-by=updated_at&order=ASC";
                    globalVariables.sortCondition=@"UNASSIGNED";
                }
                
            }
            
            else if ([globalVariables.sortingValueId isEqualToString:@"sortUpdatedDsc"])
            {
                if([globalVariables.sortCondition isEqualToString:@"UNASSIGNED"] && [globalVariables.filterCondition isEqualToString:@"UNASSIGNED"] && [globalVariables.filterId isEqualToString:@"UNASSIGNEDFilter"] && [globalVariables.sortingValueId isEqualToString:@"sortUpdatedDsc"])
                {
                    NSString *strURL= [NSString stringWithFormat:@"%@",globalVariables.urlFromFilterLogicView];
                    url= [strURL stringByAppendingString:@"&sort-by=updated_at&order=DESC"];
                }else{
                    url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@&assigned=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,Alldeparatments,ticketSortByUpdatedAt,orderDESC,assigned1];
                    NSLog(@"URL is : %@",url);
                    globalVariables.sortCondtionValueToSendWebServices=@"&sort-by=updated_at&order=DESC";
                    globalVariables.sortCondition=@"UNASSIGNED";
                }
            }
            
            else if ([globalVariables.sortingValueId isEqualToString:@"sortCreatedAsc"])
            {
                if([globalVariables.sortCondition isEqualToString:@"UNASSIGNED"] && [globalVariables.filterCondition isEqualToString:@"UNASSIGNED"] && [globalVariables.filterId isEqualToString:@"UNASSIGNEDFilter"] && [globalVariables.sortingValueId isEqualToString:@"sortCreatedAsc"])
                {
                    NSString *strURL= [NSString stringWithFormat:@"%@",globalVariables.urlFromFilterLogicView];
                    url= [strURL stringByAppendingString:@"&sort-by=created_at&order=ASC"];
                }else{
                    url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@&assigned=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,Alldeparatments,ticketSortByCreatedAt,orderASC,assigned1];
                    NSLog(@"URL is : %@",url);
                    globalVariables.sortCondtionValueToSendWebServices=@"&sort-by=created_at&order=ASC";
                    globalVariables.sortCondition=@"UNASSIGNED";
                }
            }
            
            else if ([globalVariables.sortingValueId isEqualToString:@"sortCreatedDsc"])
            {
                if([globalVariables.sortCondition isEqualToString:@"UNASSIGNED"] && [globalVariables.filterCondition isEqualToString:@"UNASSIGNED"] && [globalVariables.filterId isEqualToString:@"UNASSIGNEDFilter"] && [globalVariables.sortingValueId isEqualToString:@"sortCreatedDsc"])
                {
                    NSString *strURL= [NSString stringWithFormat:@"%@",globalVariables.urlFromFilterLogicView];
                    url= [strURL stringByAppendingString:@"&sort-by=created_at&order=DESC"];
                }else{
                    url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@&assigned=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,Alldeparatments,ticketSortByCreatedAt,orderDESC,assigned1];
                    NSLog(@"URL is : %@",url);
                    globalVariables.sortCondtionValueToSendWebServices=@"&sort-by=created_at&order=DESC";
                    globalVariables.sortCondition=@"UNASSIGNED";
                }
            }
            //
            else   if ([globalVariables.sortingValueId isEqualToString:@"sortDueAsc"])
            {
                if([globalVariables.sortCondition isEqualToString:@"UNASSIGNED"] && [globalVariables.filterCondition isEqualToString:@"UNASSIGNED"] && [globalVariables.filterId isEqualToString:@"UNASSIGNEDFilter"] && [globalVariables.sortingValueId isEqualToString:@"sortDueAsc"])
                {
                    NSString *strURL= [NSString stringWithFormat:@"%@",globalVariables.urlFromFilterLogicView];
                    url= [strURL stringByAppendingString:@"&sort-by=due&order=ASC"];
                }else{
                    url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@&assigned=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,Alldeparatments,ticketSortByDue,orderASC,assigned1];
                    NSLog(@"URL is : %@",url);
                    globalVariables.sortCondtionValueToSendWebServices=@"&sort-by=due&order=ASC";
                    globalVariables.sortCondition=@"UNASSIGNED";
                }
            }
            
            else if ([globalVariables.sortingValueId isEqualToString:@"sortDueDsc"])
            {
                if([globalVariables.sortCondition isEqualToString:@"UNASSIGNED"] && [globalVariables.filterCondition isEqualToString:@"UNASSIGNED"] && [globalVariables.filterId isEqualToString:@"UNASSIGNEDFilter"] && [globalVariables.sortingValueId isEqualToString:@"sortDueDsc"])
                {
                    NSString *strURL= [NSString stringWithFormat:@"%@",globalVariables.urlFromFilterLogicView];
                    url= [strURL stringByAppendingString:@"&sort-by=due&order=DESC"];
                }else{
                    url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@&assigned=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,Alldeparatments,ticketSortByDue,orderDESC,assigned1];
                    NSLog(@"URL is : %@",url);
                    globalVariables.sortCondtionValueToSendWebServices=@"&sort-by=due&order=DESC";
                    globalVariables.sortCondition=@"UNASSIGNED";
                }
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
                if([globalVariables.sortCondition isEqualToString:@"MYTICKETS"] && [globalVariables.filterCondition isEqualToString:@"MYTICKETS"] && [globalVariables.filterId isEqualToString:@"MYTICKETSFilter"] && [globalVariables.sortingValueId isEqualToString:@"sortTitleAsc"])
                {
                    NSString *strURL= [NSString stringWithFormat:@"%@",globalVariables.urlFromFilterLogicView];
                    url= [strURL stringByAppendingString:@"&sort-by=ticket_title&order=ASC"];
                }
                else{
                    url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showMyTickets,Alldeparatments,ticketSortByTicketTitle,orderASC];
                    NSLog(@"URL is : %@",url);
                    globalVariables.sortCondtionValueToSendWebServices=@"&sort-by=ticket_title&order=ASC";
                    globalVariables.sortCondition=@"MYTICKETS";
                }
            }
            
            else   if ([globalVariables.sortingValueId isEqualToString:@"sortTitleDsc"])
            {
                if([globalVariables.sortCondition isEqualToString:@"MYTICKETS"] && [globalVariables.filterCondition isEqualToString:@"MYTICKETS"] && [globalVariables.filterId isEqualToString:@"MYTICKETSFilter"] && [globalVariables.sortingValueId isEqualToString:@"sortTitleDsc"])
                {
                    NSString *strURL= [NSString stringWithFormat:@"%@",globalVariables.urlFromFilterLogicView];
                    url= [strURL stringByAppendingString:@"&sort-by=ticket_title&order=DESC"];
                }else{
                    url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showMyTickets,Alldeparatments,ticketSortByTicketTitle,orderDESC];
                    NSLog(@"URL is : %@",url);
                    globalVariables.sortCondtionValueToSendWebServices=@"&sort-by=ticket_title&order=DESC";
                    globalVariables.sortCondition=@"MYTICKETS";
                }
            }
            
            
            else  if ([globalVariables.sortingValueId isEqualToString:@"sortNumberAsc"])
            {
                if([globalVariables.sortCondition isEqualToString:@"MYTICKETS"] && [globalVariables.filterCondition isEqualToString:@"MYTICKETS"] && [globalVariables.filterId isEqualToString:@"MYTICKETSFilter"] && [globalVariables.sortingValueId isEqualToString:@"sortNumberAsc"])
                {
                    NSString *strURL= [NSString stringWithFormat:@"%@",globalVariables.urlFromFilterLogicView];
                    url= [strURL stringByAppendingString:@"&sort-by=ticket_number&order=ASC"];
                }else{
                    url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showMyTickets,Alldeparatments,ticketSortByTicketNumber,orderASC];
                    NSLog(@"URL is : %@",url);
                    globalVariables.sortCondtionValueToSendWebServices=@"&sort-by=ticket_number&order=ASC";
                    globalVariables.sortCondition=@"MYTICKETS";
                }
                
            }
            
            else if ([globalVariables.sortingValueId isEqualToString:@"sortNumberDsc"])
            {
                if([globalVariables.sortCondition isEqualToString:@"MYTICKETS"] && [globalVariables.filterCondition isEqualToString:@"MYTICKETS"] && [globalVariables.filterId isEqualToString:@"MYTICKETSFilter"] && [globalVariables.sortingValueId isEqualToString:@"sortNumberDsc"])
                {
                    NSString *strURL= [NSString stringWithFormat:@"%@",globalVariables.urlFromFilterLogicView];
                    url= [strURL stringByAppendingString:@"&sort-by=ticket_number&order=DESC"];
                }else{
                    url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showMyTickets,Alldeparatments,ticketSortByTicketNumber,orderDESC];
                    NSLog(@"URL is : %@",url);
                    globalVariables.sortCondtionValueToSendWebServices=@"&sort-by=ticket_number&order=DESC";
                    globalVariables.sortCondition=@"MYTICKETS";
                }
                
            }
            
            else  if ([globalVariables.sortingValueId isEqualToString:@"sortPriorityAsc"])
            {
                if([globalVariables.sortCondition isEqualToString:@"MYTICKETS"] && [globalVariables.filterCondition isEqualToString:@"MYTICKETS"] && [globalVariables.filterId isEqualToString:@"MYTICKETSFilter"] && [globalVariables.sortingValueId isEqualToString:@"sortPriorityAsc"])
                {
                    NSString *strURL= [NSString stringWithFormat:@"%@",globalVariables.urlFromFilterLogicView];
                    url= [strURL stringByAppendingString:@"&sort-by=priority&order=ASC"];
                }else{
                    url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showMyTickets,Alldeparatments,ticketSortByPriority,orderASC];
                    NSLog(@"URL is : %@",url);
                    globalVariables.sortCondtionValueToSendWebServices=@"&sort-by=priority&order=ASC";
                    globalVariables.sortCondition=@"MYTICKETS";
                }
                
            }
            
            else  if ([globalVariables.sortingValueId isEqualToString:@"sortPriorityDsc"])
            {
                if([globalVariables.sortCondition isEqualToString:@"MYTICKETS"] && [globalVariables.filterCondition isEqualToString:@"MYTICKETS"] && [globalVariables.filterId isEqualToString:@"MYTICKETSFilter"] && [globalVariables.sortingValueId isEqualToString:@"sortPriorityDsc"])
                {
                    NSString *strURL= [NSString stringWithFormat:@"%@",globalVariables.urlFromFilterLogicView];
                    url= [strURL stringByAppendingString:@"&sort-by=priority&order=DESC"];
                }else{
                    url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showMyTickets,Alldeparatments,ticketSortByPriority,orderDESC];
                    NSLog(@"URL is : %@",url);
                    globalVariables.sortCondtionValueToSendWebServices=@"&sort-by=priority&order=DESC";
                    globalVariables.sortCondition=@"MYTICKETS";
                }
                
            }
            
            else  if ([globalVariables.sortingValueId isEqualToString:@"sortUpdatedAsc"])
            {
                if([globalVariables.sortCondition isEqualToString:@"MYTICKETS"] && [globalVariables.filterCondition isEqualToString:@"MYTICKETS"] && [globalVariables.filterId isEqualToString:@"MYTICKETSFilter"] && [globalVariables.sortingValueId isEqualToString:@"sortUpdatedAsc"])
                {
                    NSString *strURL= [NSString stringWithFormat:@"%@",globalVariables.urlFromFilterLogicView];
                    url= [strURL stringByAppendingString:@"&sort-by=updated_at&order=ASC"];
                }else{
                    url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showMyTickets,Alldeparatments,ticketSortByUpdatedAt,orderASC];
                    NSLog(@"URL is : %@",url);
                    globalVariables.sortCondtionValueToSendWebServices=@"&sort-by=updated_at&order=ASC";
                    globalVariables.sortCondition=@"MYTICKETS";
                }
                
            }
            
            else if ([globalVariables.sortingValueId isEqualToString:@"sortUpdatedDsc"])
            {
                if([globalVariables.sortCondition isEqualToString:@"MYTICKETS"] && [globalVariables.filterCondition isEqualToString:@"MYTICKETS"] && [globalVariables.filterId isEqualToString:@"MYTICKETSFilter"] && [globalVariables.sortingValueId isEqualToString:@"sortUpdatedDsc"])
                {
                    NSString *strURL= [NSString stringWithFormat:@"%@",globalVariables.urlFromFilterLogicView];
                    url= [strURL stringByAppendingString:@"&sort-by=updated_at&order=DESC"];
                }else{
                    url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showMyTickets,Alldeparatments,ticketSortByUpdatedAt,orderDESC];
                    NSLog(@"URL is : %@",url);
                    globalVariables.sortCondtionValueToSendWebServices=@"&sort-by=updated_at&order=DESC";
                    globalVariables.sortCondition=@"MYTICKETS";
                }
                
            }
            
            else if ([globalVariables.sortingValueId isEqualToString:@"sortCreatedAsc"])
            {
                if([globalVariables.sortCondition isEqualToString:@"MYTICKETS"] && [globalVariables.filterCondition isEqualToString:@"MYTICKETS"] && [globalVariables.filterId isEqualToString:@"MYTICKETSFilter"] && [globalVariables.sortingValueId isEqualToString:@"sortCreatedAsc"])
                {
                    NSString *strURL= [NSString stringWithFormat:@"%@",globalVariables.urlFromFilterLogicView];
                    url= [strURL stringByAppendingString:@"&sort-by=created_at&order=ASC"];
                }else{
                    url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showMyTickets,Alldeparatments,ticketSortByCreatedAt,orderASC];
                    NSLog(@"URL is : %@",url);
                    globalVariables.sortCondtionValueToSendWebServices=@"&sort-by=created_at&order=ASC";
                    globalVariables.sortCondition=@"MYTICKETS";
                }
            }
            
            else if ([globalVariables.sortingValueId isEqualToString:@"sortCreatedDsc"])
            {
                if([globalVariables.sortCondition isEqualToString:@"MYTICKETS"] && [globalVariables.filterCondition isEqualToString:@"MYTICKETS"] && [globalVariables.filterId isEqualToString:@"MYTICKETSFilter"] && [globalVariables.sortingValueId isEqualToString:@"sortCreatedDsc"])
                {
                    NSString *strURL= [NSString stringWithFormat:@"%@",globalVariables.urlFromFilterLogicView];
                    url= [strURL stringByAppendingString:@"&sort-by=created_at&order=DESC"];
                }else{
                    url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showMyTickets,Alldeparatments,ticketSortByCreatedAt,orderDESC];
                    NSLog(@"URL is : %@",url);
                    globalVariables.sortCondtionValueToSendWebServices=@"&sort-by=created_at&order=DESC";
                    globalVariables.sortCondition=@"MYTICKETS";
                }
            }
            //
            else   if ([globalVariables.sortingValueId isEqualToString:@"sortDueAsc"])
            {
                if([globalVariables.sortCondition isEqualToString:@"MYTICKETS"] && [globalVariables.filterCondition isEqualToString:@"MYTICKETS"] && [globalVariables.filterId isEqualToString:@"MYTICKETSFilter"] && [globalVariables.sortingValueId isEqualToString:@"sortDueAsc"])
                {
                    NSString *strURL= [NSString stringWithFormat:@"%@",globalVariables.urlFromFilterLogicView];
                    url= [strURL stringByAppendingString:@"&sort-by=due&order=ASC"];
                }else{
                    url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showMyTickets,Alldeparatments,ticketSortByDue,orderASC];
                    NSLog(@"URL is : %@",url);
                    globalVariables.sortCondtionValueToSendWebServices=@"&sort-by=due&order=ASC";
                    globalVariables.sortCondition=@"MYTICKETS";
                }
            }
            
            else if ([globalVariables.sortingValueId isEqualToString:@"sortDueDsc"])
            {
                if([globalVariables.sortCondition isEqualToString:@"MYTICKETS"] && [globalVariables.filterCondition isEqualToString:@"MYTICKETS"] && [globalVariables.filterId isEqualToString:@"MYTICKETSFilter"] && [globalVariables.sortingValueId isEqualToString:@"sortDueDsc"])
                {
                    NSString *strURL= [NSString stringWithFormat:@"%@",globalVariables.urlFromFilterLogicView];
                    url= [strURL stringByAppendingString:@"&sort-by=due&order=DESC"];
                }else{
                    url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showMyTickets,Alldeparatments,ticketSortByDue,orderDESC];
                    NSLog(@"URL is : %@",url);
                    globalVariables.sortCondtionValueToSendWebServices=@"&sort-by=due&order=DESC";
                    globalVariables.sortCondition=@"MYTICKETS";
                }
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
                if([globalVariables.sortCondition isEqualToString:@"CLOSED"] && [globalVariables.filterCondition isEqualToString:@"CLOSED"] && [globalVariables.filterId isEqualToString:@"CLOSEDFilter"] && [globalVariables.sortingValueId isEqualToString:@"sortTitleAsc"])
                {
                    NSString *strURL= [NSString stringWithFormat:@"%@",globalVariables.urlFromFilterLogicView];
                    url= [strURL stringByAppendingString:@"&sort-by=ticket_title&order=ASC"];
                }
                else{
                    url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showClosedTickets,Alldeparatments,ticketSortByTicketTitle,orderASC];
                    NSLog(@"URL is : %@",url);
                    globalVariables.sortCondtionValueToSendWebServices=@"&sort-by=ticket_title&order=ASC";
                    globalVariables.sortCondition=@"CLOSED";
                }
            }
            
            else   if ([globalVariables.sortingValueId isEqualToString:@"sortTitleDsc"])
            {
                if([globalVariables.sortCondition isEqualToString:@"CLOSED"] && [globalVariables.filterCondition isEqualToString:@"CLOSED"] && [globalVariables.filterId isEqualToString:@"CLOSEDFilter"] && [globalVariables.sortingValueId isEqualToString:@"sortTitleDsc"])
                {
                    NSString *strURL= [NSString stringWithFormat:@"%@",globalVariables.urlFromFilterLogicView];
                    url= [strURL stringByAppendingString:@"&sort-by=ticket_title&order=DESC"];
                }
                else{
                    url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showClosedTickets,Alldeparatments,ticketSortByTicketTitle,orderDESC];
                    NSLog(@"URL is : %@",url);
                    globalVariables.sortCondtionValueToSendWebServices=@"&sort-by=ticket_title&order=DESC";
                    globalVariables.sortCondition=@"CLOSED";
                }
            }
            
            
            else  if ([globalVariables.sortingValueId isEqualToString:@"sortNumberAsc"])
            {
                if([globalVariables.sortCondition isEqualToString:@"CLOSED"] && [globalVariables.filterCondition isEqualToString:@"CLOSED"] && [globalVariables.filterId isEqualToString:@"CLOSEDFilter"] && [globalVariables.sortingValueId isEqualToString:@"sortNumberAsc"])
                {
                    NSString *strURL= [NSString stringWithFormat:@"%@",globalVariables.urlFromFilterLogicView];
                    url= [strURL stringByAppendingString:@"&sort-by=ticket_number&order=ASC"];
                }else{
                    url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showClosedTickets,Alldeparatments,ticketSortByTicketNumber,orderASC];
                    NSLog(@"URL is : %@",url);
                    globalVariables.sortCondtionValueToSendWebServices=@"&sort-by=ticket_number&order=ASC";
                    globalVariables.sortCondition=@"CLOSED";
                }
                
            }
            
            else if ([globalVariables.sortingValueId isEqualToString:@"sortNumberDsc"])
            {
                if([globalVariables.sortCondition isEqualToString:@"CLOSED"] && [globalVariables.filterCondition isEqualToString:@"CLOSED"] && [globalVariables.filterId isEqualToString:@"CLOSEDFilter"] && [globalVariables.sortingValueId isEqualToString:@"sortNumberDsc"])
                {
                    NSString *strURL= [NSString stringWithFormat:@"%@",globalVariables.urlFromFilterLogicView];
                    url= [strURL stringByAppendingString:@"&sort-by=ticket_number&order=DESC"];
                }else{
                    url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showClosedTickets,Alldeparatments,ticketSortByTicketNumber,orderDESC];
                    NSLog(@"URL is : %@",url);
                    globalVariables.sortCondtionValueToSendWebServices=@"&sort-by=ticket_number&order=DESC";
                    globalVariables.sortCondition=@"CLOSED";
                }
                
            }
            
            else  if ([globalVariables.sortingValueId isEqualToString:@"sortPriorityAsc"])
            {
                if([globalVariables.sortCondition isEqualToString:@"CLOSED"] && [globalVariables.filterCondition isEqualToString:@"CLOSED"] && [globalVariables.filterId isEqualToString:@"CLOSEDFilter"] && [globalVariables.sortingValueId isEqualToString:@"sortPriorityAsc"])
                {
                    NSString *strURL= [NSString stringWithFormat:@"%@",globalVariables.urlFromFilterLogicView];
                    url= [strURL stringByAppendingString:@"&sort-by=priority&order=ASC"];
                }else{
                    url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showClosedTickets,Alldeparatments,ticketSortByPriority,orderASC];
                    NSLog(@"URL is : %@",url);
                    globalVariables.sortCondtionValueToSendWebServices=@"&sort-by=priority&order=ASC"; globalVariables.sortCondition=@"CLOSED";
                }
                
            }
            
            else  if ([globalVariables.sortingValueId isEqualToString:@"sortPriorityDsc"])
            {
                if([globalVariables.sortCondition isEqualToString:@"CLOSED"] && [globalVariables.filterCondition isEqualToString:@"CLOSED"] && [globalVariables.filterId isEqualToString:@"CLOSEDFilter"] && [globalVariables.sortingValueId isEqualToString:@"sortPriorityDsc"])
                {
                    NSString *strURL= [NSString stringWithFormat:@"%@",globalVariables.urlFromFilterLogicView];
                    url= [strURL stringByAppendingString:@"&sort-by=priority&order=DESC"];
                }else{
                    url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showClosedTickets,Alldeparatments,ticketSortByPriority,orderDESC];
                    NSLog(@"URL is : %@",url);
                    globalVariables.sortCondtionValueToSendWebServices=@"&sort-by=priority&order=DESC";
                    globalVariables.sortCondition=@"CLOSED";
                }
                
            }
            
            else  if ([globalVariables.sortingValueId isEqualToString:@"sortUpdatedAsc"])
            {
                if([globalVariables.sortCondition isEqualToString:@"CLOSED"] && [globalVariables.filterCondition isEqualToString:@"CLOSED"] && [globalVariables.filterId isEqualToString:@"CLOSEDFilter"] && [globalVariables.sortingValueId isEqualToString:@"sortUpdatedAsc"])
                {
                    NSString *strURL= [NSString stringWithFormat:@"%@",globalVariables.urlFromFilterLogicView];
                    url= [strURL stringByAppendingString:@"&sort-by=updated_at&order=ASC"];
                }else{
                    url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showClosedTickets,Alldeparatments,ticketSortByUpdatedAt,orderASC];
                    NSLog(@"URL is : %@",url);
                    globalVariables.sortCondtionValueToSendWebServices=@"&sort-by=updated_at&order=ASC";
                    globalVariables.sortCondition=@"CLOSED";
                }
                
            }
            
            else if ([globalVariables.sortingValueId isEqualToString:@"sortUpdatedDsc"])
            {
                if([globalVariables.sortCondition isEqualToString:@"CLOSED"] && [globalVariables.filterCondition isEqualToString:@"CLOSED"] && [globalVariables.filterId isEqualToString:@"CLOSEDFilter"] && [globalVariables.sortingValueId isEqualToString:@"sortUpdatedDsc"])
                {
                    NSString *strURL= [NSString stringWithFormat:@"%@",globalVariables.urlFromFilterLogicView];
                    url= [strURL stringByAppendingString:@"&sort-by=updated_at&order=DESC"];
                }else{
                    url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showClosedTickets,Alldeparatments,ticketSortByUpdatedAt,orderDESC];
                    NSLog(@"URL is : %@",url);
                    globalVariables.sortCondtionValueToSendWebServices=@"&sort-by=updated_at&order=DESC";
                    globalVariables.sortCondition=@"CLOSED";
                }
            }
            
            else if ([globalVariables.sortingValueId isEqualToString:@"sortCreatedAsc"])
            {
                if([globalVariables.sortCondition isEqualToString:@"CLOSED"] && [globalVariables.filterCondition isEqualToString:@"CLOSED"] && [globalVariables.filterId isEqualToString:@"CLOSEDFilter"] && [globalVariables.sortingValueId isEqualToString:@"sortCreatedAsc"])
                {
                    NSString *strURL= [NSString stringWithFormat:@"%@",globalVariables.urlFromFilterLogicView];
                    url= [strURL stringByAppendingString:@"&sort-by=created_at&order=ASC"];
                }else{
                    url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showClosedTickets,Alldeparatments,ticketSortByCreatedAt,orderASC];
                    NSLog(@"URL is : %@",url);
                    globalVariables.sortCondtionValueToSendWebServices=@"&sort-by=created_at&order=ASC";
                    globalVariables.sortCondition=@"CLOSED";
                }
            }
            
            else if ([globalVariables.sortingValueId isEqualToString:@"sortCreatedDsc"])
            {
                if([globalVariables.sortCondition isEqualToString:@"CLOSED"] && [globalVariables.filterCondition isEqualToString:@"CLOSED"] && [globalVariables.filterId isEqualToString:@"CLOSEDFilter"] && [globalVariables.sortingValueId isEqualToString:@"sortCreatedDsc"])
                {
                    NSString *strURL= [NSString stringWithFormat:@"%@",globalVariables.urlFromFilterLogicView];
                    url= [strURL stringByAppendingString:@"&sort-by=created_at&order=DESC"];
                }else{
                    url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showClosedTickets,Alldeparatments,ticketSortByCreatedAt,orderDESC];
                    NSLog(@"URL is : %@",url);
                    globalVariables.sortCondtionValueToSendWebServices=@"&sort-by=created_at&order=DESC";
                    globalVariables.sortCondition=@"CLOSED";
                }
            }
            //
            else   if ([globalVariables.sortingValueId isEqualToString:@"sortDueAsc"])
            {
                if([globalVariables.sortCondition isEqualToString:@"CLOSED"] && [globalVariables.filterCondition isEqualToString:@"CLOSED"] && [globalVariables.filterId isEqualToString:@"CLOSEDFilter"] && [globalVariables.sortingValueId isEqualToString:@"sortDueAsc"])
                {
                    NSString *strURL= [NSString stringWithFormat:@"%@",globalVariables.urlFromFilterLogicView];
                    url= [strURL stringByAppendingString:@"&sort-by=due&order=ASC"];
                }else{
                    url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showClosedTickets,Alldeparatments,ticketSortByDue,orderASC];
                    NSLog(@"URL is : %@",url);
                    globalVariables.sortCondtionValueToSendWebServices=@"&sort-by=due&order=ASC";
                    globalVariables.sortCondition=@"CLOSED";
                }
            }
            
            else if ([globalVariables.sortingValueId isEqualToString:@"sortDueDsc"])
            {
                if([globalVariables.sortCondition isEqualToString:@"CLOSED"] && [globalVariables.filterCondition isEqualToString:@"CLOSED"] && [globalVariables.filterId isEqualToString:@"CLOSEDFilter"] && [globalVariables.sortingValueId isEqualToString:@"sortDueDsc"])
                {
                    NSString *strURL= [NSString stringWithFormat:@"%@",globalVariables.urlFromFilterLogicView];
                    url= [strURL stringByAppendingString:@"&sort-by=due&order=DESC"];
                }else{
                    url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showClosedTickets,Alldeparatments,ticketSortByDue,orderDESC];
                    NSLog(@"URL is : %@",url);
                    globalVariables.sortCondtionValueToSendWebServices=@"&sort-by=due&order=DESC";
                    globalVariables.sortCondition=@"CLOSED";
                }
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
                if([globalVariables.sortCondition isEqualToString:@"TRASH"] && [globalVariables.filterCondition isEqualToString:@"TRASH"] && [globalVariables.filterId isEqualToString:@"TRASHFilter"] && [globalVariables.sortingValueId isEqualToString:@"sortTitleAsc"])
                {
                    NSString *strURL= [NSString stringWithFormat:@"%@",globalVariables.urlFromFilterLogicView];
                    url= [strURL stringByAppendingString:@"&sort-by=ticket_title&order=ASC"];
                }
                else{
                    url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showTrashTickets,Alldeparatments,ticketSortByTicketTitle,orderASC];
                    NSLog(@"URL is : %@",url);
                    globalVariables.sortCondtionValueToSendWebServices=@"&sort-by=ticket_title&order=ASC";
                    globalVariables.sortCondition=@"TRASH";
                }
            }
            
            else   if ([globalVariables.sortingValueId isEqualToString:@"sortTitleDsc"])
            {
                if([globalVariables.sortCondition isEqualToString:@"TRASH"] && [globalVariables.filterCondition isEqualToString:@"TRASH"] && [globalVariables.filterId isEqualToString:@"TRASHFilter"] && [globalVariables.sortingValueId isEqualToString:@"sortTitleDsc"])
                {
                    NSString *strURL= [NSString stringWithFormat:@"%@",globalVariables.urlFromFilterLogicView];
                    url= [strURL stringByAppendingString:@"&sort-by=ticket_title&order=DESC"];
                }
                else{
                    url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showTrashTickets,Alldeparatments,ticketSortByTicketTitle,orderDESC];
                    NSLog(@"URL is : %@",url);
                    globalVariables.sortCondtionValueToSendWebServices=@"&sort-by=ticket_title&order=DESC";
                    globalVariables.sortCondition=@"TRASH";
                }
            }
            
            
            else  if ([globalVariables.sortingValueId isEqualToString:@"sortNumberAsc"])
            {
                if([globalVariables.sortCondition isEqualToString:@"TRASH"] && [globalVariables.filterCondition isEqualToString:@"TRASH"] && [globalVariables.filterId isEqualToString:@"TRASHFilter"] && [globalVariables.sortingValueId isEqualToString:@"sortNumberAsc"])
                {
                    NSString *strURL= [NSString stringWithFormat:@"%@",globalVariables.urlFromFilterLogicView];
                    url= [strURL stringByAppendingString:@"&sort-by=ticket_number&order=ASC"];
                }else{
                    url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showTrashTickets,Alldeparatments,ticketSortByTicketNumber,orderASC];
                    NSLog(@"URL is : %@",url);
                    globalVariables.sortCondtionValueToSendWebServices=@"&sort-by=ticket_number&order=ASC";
                    globalVariables.sortCondition=@"TRASH";
                }
                
            }
            
            else if ([globalVariables.sortingValueId isEqualToString:@"sortNumberDsc"])
            {
                if([globalVariables.sortCondition isEqualToString:@"TRASH"] && [globalVariables.filterCondition isEqualToString:@"TRASH"] && [globalVariables.filterId isEqualToString:@"TRASHFilter"] && [globalVariables.sortingValueId isEqualToString:@"sortNumberDsc"])
                {
                    NSString *strURL= [NSString stringWithFormat:@"%@",globalVariables.urlFromFilterLogicView];
                    url= [strURL stringByAppendingString:@"&sort-by=ticket_number&order=DESC"];
                }else{
                    url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showTrashTickets,Alldeparatments,ticketSortByTicketNumber,orderDESC];
                    NSLog(@"URL is : %@",url);
                    globalVariables.sortCondtionValueToSendWebServices=@"&sort-by=ticket_number&order=DESC";
                    globalVariables.sortCondition=@"TRASH";
                }
                
            }
            
            else  if ([globalVariables.sortingValueId isEqualToString:@"sortPriorityAsc"])
            {
                if([globalVariables.sortCondition isEqualToString:@"TRASH"] && [globalVariables.filterCondition isEqualToString:@"TRASH"] && [globalVariables.filterId isEqualToString:@"TRASHFilter"] && [globalVariables.sortingValueId isEqualToString:@"sortPriorityAsc"])
                {
                    NSString *strURL= [NSString stringWithFormat:@"%@",globalVariables.urlFromFilterLogicView];
                    url= [strURL stringByAppendingString:@"&sort-by=priority&order=ASC"];
                }else{
                    url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showTrashTickets,Alldeparatments,ticketSortByPriority,orderASC];
                    NSLog(@"URL is : %@",url);
                    globalVariables.sortCondtionValueToSendWebServices=@"&sort-by=priority&order=ASC";
                    globalVariables.sortCondition=@"TRASH";
                }
                
            }
            
            else  if ([globalVariables.sortingValueId isEqualToString:@"sortPriorityDsc"])
            {
                if([globalVariables.sortCondition isEqualToString:@"TRASH"] && [globalVariables.filterCondition isEqualToString:@"TRASH"] && [globalVariables.filterId isEqualToString:@"TRASHFilter"] && [globalVariables.sortingValueId isEqualToString:@"sortPriorityDsc"])
                {
                    NSString *strURL= [NSString stringWithFormat:@"%@",globalVariables.urlFromFilterLogicView];
                    url= [strURL stringByAppendingString:@"&sort-by=priority&order=DESC"];
                }else{
                    url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showTrashTickets,Alldeparatments,ticketSortByPriority,orderDESC];
                    NSLog(@"URL is : %@",url);
                    globalVariables.sortCondtionValueToSendWebServices=@"&sort-by=priority&order=DESC";
                    globalVariables.sortCondition=@"TRASH";
                }
                
            }
            
            else  if ([globalVariables.sortingValueId isEqualToString:@"sortUpdatedAsc"])
            {
                if([globalVariables.sortCondition isEqualToString:@"TRASH"] && [globalVariables.filterCondition isEqualToString:@"TRASH"] && [globalVariables.filterId isEqualToString:@"TRASHFilter"] && [globalVariables.sortingValueId isEqualToString:@"sortUpdatedAsc"])
                {
                    NSString *strURL= [NSString stringWithFormat:@"%@",globalVariables.urlFromFilterLogicView];
                    url= [strURL stringByAppendingString:@"&sort-by=updated_at&order=ASC"];
                }else{
                    url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showTrashTickets,Alldeparatments,ticketSortByUpdatedAt,orderASC];
                    NSLog(@"URL is : %@",url);
                    globalVariables.sortCondtionValueToSendWebServices=@"&sort-by=updated_at&order=ASC";
                    globalVariables.sortCondition=@"TRASH";
                }
                
            }
            
            else if ([globalVariables.sortingValueId isEqualToString:@"sortUpdatedDsc"])
            {
                if([globalVariables.sortCondition isEqualToString:@"TRASH"] && [globalVariables.filterCondition isEqualToString:@"TRASH"] && [globalVariables.filterId isEqualToString:@"TRASHFilter"] && [globalVariables.sortingValueId isEqualToString:@"sortUpdatedDsc"])
                {
                    NSString *strURL= [NSString stringWithFormat:@"%@",globalVariables.urlFromFilterLogicView];
                    url= [strURL stringByAppendingString:@"&sort-by=updated_at&order=DESC"];
                }else{
                    url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showTrashTickets,Alldeparatments,ticketSortByUpdatedAt,orderDESC];
                    NSLog(@"URL is : %@",url);
                    globalVariables.sortCondtionValueToSendWebServices=@"&sort-by=updated_at&order=DESC";
                    globalVariables.sortCondition=@"TRASH";
                }
            }
            
            else if ([globalVariables.sortingValueId isEqualToString:@"sortCreatedAsc"])
            {
                if([globalVariables.sortCondition isEqualToString:@"TRASH"] && [globalVariables.filterCondition isEqualToString:@"TRASH"] && [globalVariables.filterId isEqualToString:@"TRASHFilter"] && [globalVariables.sortingValueId isEqualToString:@"sortCreatedAsc"])
                {
                    NSString *strURL= [NSString stringWithFormat:@"%@",globalVariables.urlFromFilterLogicView];
                    url= [strURL stringByAppendingString:@"&sort-by=created_at&order=ASC"];
                }else{
                    url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showTrashTickets,Alldeparatments,ticketSortByCreatedAt,orderASC];
                    NSLog(@"URL is : %@",url);
                    globalVariables.sortCondtionValueToSendWebServices=@"&sort-by=created_at&order=ASC";
                    globalVariables.sortCondition=@"TRASH";
                }
            }
            
            else if ([globalVariables.sortingValueId isEqualToString:@"sortCreatedDsc"])
            {
                if([globalVariables.sortCondition isEqualToString:@"TRASH"] && [globalVariables.filterCondition isEqualToString:@"TRASH"] && [globalVariables.filterId isEqualToString:@"TRASHFilter"] && [globalVariables.sortingValueId isEqualToString:@"sortCreatedDsc"])
                {
                    NSString *strURL= [NSString stringWithFormat:@"%@",globalVariables.urlFromFilterLogicView];
                    url= [strURL stringByAppendingString:@"&sort-by=created_at&order=DESC"];
                }else{
                    url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showTrashTickets,Alldeparatments,ticketSortByCreatedAt,orderDESC];
                    NSLog(@"URL is : %@",url);
                    globalVariables.sortCondtionValueToSendWebServices=@"&sort-by=created_at&order=DESC";
                    globalVariables.sortCondition=@"TRASH";
                }
            }
            //
            else   if ([globalVariables.sortingValueId isEqualToString:@"sortDueAsc"])
            {
                if([globalVariables.sortCondition isEqualToString:@"TRASH"] && [globalVariables.filterCondition isEqualToString:@"TRASH"] && [globalVariables.filterId isEqualToString:@"TRASHFilter"] && [globalVariables.sortingValueId isEqualToString:@"sortDueAsc"])
                {
                    NSString *strURL= [NSString stringWithFormat:@"%@",globalVariables.urlFromFilterLogicView];
                    url= [strURL stringByAppendingString:@"&sort-by=due&order=ASC"];
                }else{
                    url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showTrashTickets,Alldeparatments,ticketSortByDue,orderASC];
                    NSLog(@"URL is : %@",url);
                    globalVariables.sortCondtionValueToSendWebServices=@"&sort-by=due&order=ASC";
                    globalVariables.sortCondition=@"TRASH";
                }
            }
            
            else if ([globalVariables.sortingValueId isEqualToString:@"sortDueDsc"])
            {
                if([globalVariables.sortCondition isEqualToString:@"TRASH"] && [globalVariables.filterCondition isEqualToString:@"TRASH"] && [globalVariables.filterId isEqualToString:@"TRASHFilter"] && [globalVariables.sortingValueId isEqualToString:@"sortDueDsc"])
                {
                    NSString *strURL= [NSString stringWithFormat:@"%@",globalVariables.urlFromFilterLogicView];
                    url= [strURL stringByAppendingString:@"&sort-by=due&order=DESC"];
                }else{
                    url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@&sort-by=%@&order=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showTrashTickets,Alldeparatments,ticketSortByDue,orderDESC];
                    NSLog(@"URL is : %@",url);
                    globalVariables.sortCondtionValueToSendWebServices=@"&sort-by=due&order=DESC";
                    globalVariables.sortCondition=@"TRASH";
                }
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
                    [self->refresh endRefreshing];
                   
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
                        
                        else
                            
                        if([msg isEqualToString:@"Error-402"])
                        {
                            NSLog(@"Message is : %@",msg);
                            [self->utils showAlertWithMessage:[NSString stringWithFormat:@"API is disabled in web, please enable it from Admin panel."] sendViewController:self];
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
                            [[AppDelegate sharedAppdelegate] hideProgressView];
                        }
                        
                    }else if(error)  {
                        [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",error.localizedDescription] sendViewController:self];
                        NSLog(@"Thread-sortingpage-Refresh-error == %@",error.localizedDescription);
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
                            
                            [self reloadTableView];
                            [self loadAnimation];
                            [self->refresh endRefreshing];
                            [[AppDelegate sharedAppdelegate] hideProgressView];
                            
                        });
                    });
                    
                }
                NSLog(@"Thread-Sorting-closed");
                
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
            NSLog( @" I am in reload method in SortingTickets ViewController" );
            
        }
        
    }
}

// This method used to get some values like Agents list, Ticket Status, Ticket counts, Ticket Source, SLA ..etc which are used in various places in project.
-(void)getDependencies{
    
    NSLog(@"Thread-NO1-getDependencies()-start");
    if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable)
    {
        [[AppDelegate sharedAppdelegate] hideProgressView];
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
           
            
        }
    }
    NSLog(@"Thread-NO2-getDependencies()-closed");
}


// This method used for implementing the feature of multiple ticket select, using this we can select and deselects the tableview rows and perform futher actions on that seleected rows.
-(void)EditTableView:(UIGestureRecognizer*)gesture{
    [self.tableView setEditing:YES animated:YES];
    navbar.hidden=NO;
}

//This method returns the number of rows (table cells) in a specified section.
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

//This method asks the data source to return the number of sections in the table view.

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.currentPage == self.totalPages
        || self.totalTickets == _mutableArray.count) {
        return _mutableArray.count;
    }
    
    
    return _mutableArray.count + 1;
}

//This method tells the delegate the table view is about to draw a cell for a particular row
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


// This method calls an API for getting next page tickets, it will returns an JSON which contains 10 records with ticket details.

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
            NSString *Page = [str substringFromIndex:[str length] - 1];
            
            //     NSLog(@"String is : %@",szResult);
            NSLog(@"Page is : %@",Page);
            NSLog(@"Page is : %@",Page);
            
            MyWebservices *webservices=[MyWebservices sharedInstance];
            [webservices getNextPageURLInbox:_path1 pageNo:Page  callbackHandler:^(NSError *error,id json,NSString* msg) {
                
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
                            [self->refresh endRefreshing];
                            
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
            NSString *Page = [str substringFromIndex:[str length] - 1];
            
            //     NSLog(@"String is : %@",szResult);
            NSLog(@"Page is : %@",Page);
            NSLog(@"Page is : %@",Page);
            
            MyWebservices *webservices=[MyWebservices sharedInstance];
            [webservices getNextPageURLMyTickets:_path1 pageNo:Page  callbackHandler:^(NSError *error,id json,NSString* msg) {
                
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
                    //_indexPaths=[[NSArray alloc]init];
                    //_indexPaths = [json objectForKey:@"data"];
                    self->_nextPageUrl =[json objectForKey:@"next_page_url"];
                    self->_currentPage=[[json objectForKey:@"current_page"] integerValue];
                    self->_totalTickets=[[json objectForKey:@"total"] integerValue];
                   self-> _totalPages=[[json objectForKey:@"last_page"] integerValue];
                    
                    
                    self->_mutableArray= [self->_mutableArray mutableCopy];
                    
                    [self->_mutableArray addObjectsFromArray:[json objectForKey:@"data"]];
                    
                    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            // [self.tableView reloadData];
                            [self reloadTableView];
                            
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
            NSString *Page = [str substringFromIndex:[str length] - 1];
            
            //     NSLog(@"String is : %@",szResult);
            NSLog(@"Page is : %@",Page);
            NSLog(@"Page is : %@",Page);
            
            MyWebservices *webservices=[MyWebservices sharedInstance];
            [webservices getNextPageURLUnassigned:_path1 pageNo:Page  callbackHandler:^(NSError *error,id json,NSString* msg) {
                
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
                    //_indexPaths=[[NSArray alloc]init];
                    //_indexPaths = [json objectForKey:@"data"];
                    self->_nextPageUrl =[json objectForKey:@"next_page_url"];
                   self-> _currentPage=[[json objectForKey:@"current_page"] integerValue];
                    self->_totalTickets=[[json objectForKey:@"total"] integerValue];
                    self->_totalPages=[[json objectForKey:@"last_page"] integerValue];
                    
                    
                    self->_mutableArray= [self->_mutableArray mutableCopy];
                    
                    [self->_mutableArray addObjectsFromArray:[json objectForKey:@"data"]];
                    
                    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            //  [self.tableView reloadData];
                            [self reloadTableView];
                            
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
            NSString *Page = [str substringFromIndex:[str length] - 1];
            
            //     NSLog(@"String is : %@",szResult);
            NSLog(@"Page is : %@",Page);
            NSLog(@"Page is : %@",Page);
            
            MyWebservices *webservices=[MyWebservices sharedInstance];
            [webservices getNextPageURLClosed:_path1 pageNo:Page  callbackHandler:^(NSError *error,id json,NSString* msg) {
                
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
                    //_indexPaths=[[NSArray alloc]init];
                    //_indexPaths = [json objectForKey:@"data"];
                    self->_nextPageUrl =[json objectForKey:@"next_page_url"];
                    self->_currentPage=[[json objectForKey:@"current_page"] integerValue];
                   self-> _totalTickets=[[json objectForKey:@"total"] integerValue];
                    self->_totalPages=[[json objectForKey:@"last_page"] integerValue];
                    
                    
                   self-> _mutableArray= [self->_mutableArray mutableCopy];
                    
                    [self->_mutableArray addObjectsFromArray:[json objectForKey:@"data"]];
                    
                    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            // [self.tableView reloadData];
                            [self reloadTableView];
                            
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
            NSString *Page = [str substringFromIndex:[str length] - 1];
            
            //     NSLog(@"String is : %@",szResult);
            NSLog(@"Page is : %@",Page);
            NSLog(@"Page is : %@",Page);
            
            MyWebservices *webservices=[MyWebservices sharedInstance];
            [webservices getNextPageURLTrash:_path1 pageNo:Page  callbackHandler:^(NSError *error,id json,NSString* msg) {
                
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
                    //_indexPaths=[[NSArray alloc]init];
                    //_indexPaths = [json objectForKey:@"data"];
                    self->_nextPageUrl =[json objectForKey:@"next_page_url"];
                    self->_currentPage=[[json objectForKey:@"current_page"] integerValue];
                    self->_totalTickets=[[json objectForKey:@"total"] integerValue];
                    self->_totalPages=[[json objectForKey:@"last_page"] integerValue];
                    
                    
                    self->_mutableArray= [self->_mutableArray mutableCopy];
                    
                    [self->_mutableArray addObjectsFromArray:[json objectForKey:@"data"]];
                    
                    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            //  [self.tableView reloadData];
                            [self reloadTableView];
                            
                        });
                    });
                    
                }
                NSLog(@"Thread-NO5-getInbox-closed");
                
            }];
        }
    }
}


// This method asks the data source for a cell to insert in a particular location of the table view.
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
                fname = [fname substringToIndex:2];
                [cell.profilePicView setImageWithString:fname color:nil ];
            }
            else if(![Utils isEmpty:userName])
            {
                userName = [userName substringToIndex:2];
                [cell.profilePicView setImageWithString:userName color:nil ];
            }
            else if([Utils isEmpty:fname] && [Utils isEmpty:lname] && [Utils isEmpty:userName]){
                
                [cell.profilePicView setImageWithString:@"N" color:nil ];
            }
            else{
                [cell setUserProfileimage:[customerDict objectForKey:@"profile_pic"]];
                
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
        
        // NSString *encodedString =@"Sample Ticket Titile";
        
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
            
//            NSString *cc= [NSString stringWithFormat:@"%@",[finaldic objectForKey:@"countcollaborator"]];
//
//            NSString *attachment1= [NSString stringWithFormat:@"%@",[finaldic objectForKey:@"attachment_count"]];
            
            
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
            
            
            
            
            
//            if(![cc isEqualToString:@"<null>"] && ![attachment1 isEqualToString:@"0"])
//            {
//                cell.ccImgView.image=[UIImage imageNamed:@"cc1"];
//                cell.attachImgView.image=[UIImage imageNamed:@"attach"];
//            }
//            else if(![cc isEqualToString:@"<null>"] && [attachment1 isEqualToString:@"0"])
//            {
//                cell.ccImgView.image=[UIImage imageNamed:@"cc1"];
//            }
//            else if([cc isEqualToString:@"<null>"] && ![attachment1 isEqualToString:@"0"])
//            {
//                cell.ccImgView.image=[UIImage imageNamed:@"attach"];
//            }
            
            
            //  collaborator_count_relation
            NSString *cc= [NSString stringWithFormat:@"%@",[finaldic objectForKey:@"collaborator_count"]];  //collaborator_count
            NSString *attachment1= [NSString stringWithFormat:@"%@",[finaldic objectForKey:@"attachment_count"]];
            //countcollaborator
            
            NSLog(@"CC is %@ named",cc);
            NSLog(@"CC is %@ named",cc);
            NSLog(@"CC is %@ named",cc);
            //
            NSLog(@"attachment is %@ named",attachment1);
            NSLog(@"attachment is %@ named",attachment1);
            
            if(![cc isEqualToString:@"<null>"])
            {
                cell.ccImgView.image=[UIImage imageNamed:@"cc1"];
                
            }
            
            if(![attachment1 isEqualToString:@"0"])
            {
                if([cc isEqualToString:@"<null>"])
                {
                    cell.ccImgView.image=[UIImage imageNamed:@"attach"];
                }else
                {
                    cell.attachImgView.image=[UIImage imageNamed:@"attach"];
                    
                }
                
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

// This method asks the data source to verify that the given row is editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

// This method tells the delegate that the specified row is now selected.
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

// This method tells the delegate that the specified row is now deselected.
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
// This method used to show or hide slide navigation controller icon on navigation bar
- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

// After clicking this method, it will navigate to notification view controller
-(void)NotificationBtnPressed

{
    
    globalVariables.ticket_number=[tempDict objectForKey:@"ticket_number"];
    globalVariables.Ticket_status=[tempDict objectForKey:@"ticket_status_name"];
    
    NotificationViewController *not=[self.storyboard instantiateViewControllerWithIdentifier:@"Notify"];
    
    
    [self.navigationController pushViewController:not animated:YES];
    
}


// This method used to show refresh behind the table view.
-(void)addUIRefresh{
    
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSAttributedString *refreshing = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Refreshing",nil) attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18], NSParagraphStyleAttributeName : paragraphStyle,NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    refresh=[[UIRefreshControl alloc] init];
    refresh.tintColor=[UIColor whiteColor];
    // refresh.backgroundColor = [UIColor colorWithRed:0.46 green:0.8 blue:1.0 alpha:1.0];
    refresh.backgroundColor = [UIColor hx_colorWithHexRGBAString:@"#BDBDBD"];
    refresh.attributedTitle =refreshing;
    [refresh addTarget:self action:@selector(reloadd) forControlEvents:UIControlEventValueChanged];
    [_tableView insertSubview:refresh atIndex:0];
    
}



-(void)reloadd{
    [self reload];
    //    [refresh endRefreshing];
}


// This method used to show some popuop or list which contain some menus. Here it used to change the status of ticket, after clicking this button it will show one view which contains list of status. After clicking on any row, according to its name that status will be changed.
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
                                   
                                   [self askConfirmationForStatusChange];
                                 // [self changeStatusMethod:self->selectedStatusName idIs:self->selectedStatusId];
                               }
                               
                           }
                        dismissBlock:^{
                            
                        }];
        
#endif
    }
}


-(void)askConfirmationForStatusChange
{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Ticket Status"
                                 message:@"are you sure you want to change ticket status?"
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    //Add Buttons
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"No"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    //Handle your yes please button action here
                                    
                                }];
    
    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle:@"Yes"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   //Handle no, thanks button
                                   
                                 [self changeStatusMethod:self->selectedStatusName idIs:self->selectedStatusId];
                                   
                               }];
    
    //Add your buttons to alert controller
    
    [alert addAction:yesButton];
    [alert addAction:noButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)changeStatusMethod:(NSString *)nameOfStatus idIs:(NSString *)idOfStatus
{
    
    NSLog(@"Status Name is : %@",nameOfStatus);
    NSLog(@"Id is : %@",idOfStatus);
    
    if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable)
    {
        //connection unavailable
        
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
                        
                    }
                    else{
                        
                        NSString * msg=[json objectForKey:@"message"];
                        
                        if([msg hasPrefix:@"Status changed"]){
                            
                    
                            if (self.navigationController.navigationBarHidden) {
                                [self.navigationController setNavigationBarHidden:NO];
                            }
                            
                            [RMessage showNotificationInViewController:self.navigationController
                                                                 title:NSLocalizedString(@"success.", nil)
                                                              subtitle:NSLocalizedString(@"Ticket Status Changed.", nil)
                                                             iconImage:nil
                                                                  type:RMessageTypeSuccess
                                                        customTypeName:nil
                                                              duration:RMessageDurationAutomatic
                                                              callback:nil
                                                           buttonTitle:nil
                                                        buttonCallback:nil
                                                            atPosition:RMessagePositionNavBarOverlay
                                                  canBeDismissedByUser:YES];
                            
                            SortingViewController *sort=[self.storyboard instantiateViewControllerWithIdentifier:@"sortID"];
                            [self.navigationController pushViewController:sort animated:YES];
                            
                        }else
                        {
                            
                            [self->utils showAlertWithMessage:NSLocalizedString(@"Permission Denied - You don't have permission to change status. ", nil) sendViewController:self];
                            [[AppDelegate sharedAppdelegate] hideProgressView];
                            
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
                              // @[@"Show Filter",@"Clear All",@"Exit"]
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
        
        if([globalVariables.sortCondition isEqualToString:@"INBOX"])
        {
            globalVariables.filterCondition=@"INBOX";
        }else if([globalVariables.sortCondition isEqualToString:@"MYTICKETS"])
        {
            globalVariables.filterCondition=@"MYTICKETS";
        }else if([globalVariables.sortCondition isEqualToString:@"UNASSIGNED"])
        {
            globalVariables.filterCondition=@"UNASSIGNED";
        }else if([globalVariables.sortCondition isEqualToString:@"CLOSED"])
        {
            globalVariables.filterCondition=@"CLOSED";
        }else if([globalVariables.sortCondition isEqualToString:@"TRASH"])
        {
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
    //        SortingViewController * sort=[self.storyboard instantiateViewControllerWithIdentifier:@"sortID"];
    //        [self.navigationController pushViewController:sort animated:YES];
    //
    //    }
    
    // sort by - Tciket title
    if(titleButtonIndex==1 && leftIndex==0 && rightIndex==0 )
    {
        
        NSLog(@"Ticket title - ASC");
        
        globalVariables.sortingValueId=@"sortTitleAsc";
        
        SortingViewController * sort=[self.storyboard instantiateViewControllerWithIdentifier:@"sortID"];
        [self.navigationController pushViewController:sort animated:YES];
        
    }
    else if(titleButtonIndex==1 && leftIndex==0 && rightIndex==1 )
    {
        NSLog(@"Ticket Title  - DSC");
        
        
        globalVariables.sortingValueId=@"sortTitleDsc";
        
        SortingViewController * sort=[self.storyboard instantiateViewControllerWithIdentifier:@"sortID"];
        [self.navigationController pushViewController:sort animated:YES];
        
    }
    
    //sort by - ticket number
    else  if(titleButtonIndex==1 && leftIndex==1 && rightIndex==0 )
    {
        globalVariables.sortingValueId=@"sortNumberAsc";
        
        SortingViewController * sort=[self.storyboard instantiateViewControllerWithIdentifier:@"sortID"];
        [self.navigationController pushViewController:sort animated:YES];
        
    }
    else if(titleButtonIndex==1 && leftIndex==1 && rightIndex==1 )
    {
        
        globalVariables.sortingValueId=@"sortNumberDsc";
        
        SortingViewController * sort=[self.storyboard instantiateViewControllerWithIdentifier:@"sortID"];
        [self.navigationController pushViewController:sort animated:YES];
        
    }
    // sortPriorityDscAlert
    else if(titleButtonIndex==1 && leftIndex==2 && rightIndex==0 )
    {
        NSLog(@" Ticket priority - ASC");
        
        globalVariables.sortingValueId=@"sortPriorityAsc";
        
        SortingViewController * sort=[self.storyboard instantiateViewControllerWithIdentifier:@"sortID"];
        [self.navigationController pushViewController:sort animated:YES];
        
    }
    else if(titleButtonIndex==1 && leftIndex==2 && rightIndex==1 )
    {
        NSLog(@" Ticket priority - DSC");
        
        globalVariables.sortingValueId=@"sortPriorityDsc";
        
        SortingViewController * sort=[self.storyboard instantiateViewControllerWithIdentifier:@"sortID"];
        [self.navigationController pushViewController:sort animated:YES];
        
    }
    //sortUpdatedDscAlert
    else if(titleButtonIndex==1 && leftIndex==3 && rightIndex==0 )
    {
        NSLog(@" upated at - ASC");
        
        globalVariables.sortingValueId=@"sortUpdatedAsc";
        
        SortingViewController * sort=[self.storyboard instantiateViewControllerWithIdentifier:@"sortID"];
        [self.navigationController pushViewController:sort animated:YES];
        
    }
    else if(titleButtonIndex==1 && leftIndex==3 && rightIndex==1 )
    {
        NSLog(@" upated at - DSC");
        
        globalVariables.sortingValueId=@"sortUpdatedDsc";
        
        SortingViewController * sort=[self.storyboard instantiateViewControllerWithIdentifier:@"sortID"];
        [self.navigationController pushViewController:sort animated:YES];
        
    }
    //sortCreatedAscAlert
    else if(titleButtonIndex==1 && leftIndex==4 && rightIndex==0 )
    {
        NSLog(@" created At - ASC");
        
        globalVariables.sortingValueId=@"sortCreatedAsc";
        
        SortingViewController * sort=[self.storyboard instantiateViewControllerWithIdentifier:@"sortID"];
        [self.navigationController pushViewController:sort animated:YES];
        
    }
    else if(titleButtonIndex==1 && leftIndex==4 && rightIndex==1 )
    {
        NSLog(@" created At - DSC");
        
        globalVariables.sortingValueId=@"sortCreatedDsc";
        
        SortingViewController * sort=[self.storyboard instantiateViewControllerWithIdentifier:@"sortID"];
        [self.navigationController pushViewController:sort animated:YES];
        
    }
    // due on // sortDueAscAlert
    else if(titleButtonIndex==1 && leftIndex==5 && rightIndex==0 )
    {
        NSLog(@" due on - ASC");
        
        globalVariables.sortingValueId=@"sortDueAsc";
        
        SortingViewController * sort=[self.storyboard instantiateViewControllerWithIdentifier:@"sortID"];
        [self.navigationController pushViewController:sort animated:YES];
        
    }
    else if(titleButtonIndex==1 && leftIndex==5 && rightIndex==1 )
    {
        NSLog(@" due on - DSC");
        
        globalVariables.sortingValueId=@"sortDueDsc";
        
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

