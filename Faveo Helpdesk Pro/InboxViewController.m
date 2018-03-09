//
//  InboxViewController.m
//  SideMEnuDemo
//
//  Created on 19/08/16.
//  Copyright © 2016 Ladybird websolutions pvt ltd. All rights reserved.
//

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
#import "SortingViewController.h"
#import "FilterViewController.h"
#import "FTPopOverMenu.h"
#import "MergeViewForm.h"
#import "MultpleTicketAssignTableViewController.h"
#import "UIImageView+Letters.h"
#import "TicketSearchViewController.h"

@import FirebaseInstanceID;
@import FirebaseMessaging;

@interface InboxViewController ()<RMessageProtocol,CFMultistageDropdownMenuViewDelegate,UISearchDisplayDelegate,UISearchBarDelegate>{
    Utils *utils;
    UIRefreshControl *refresh;
    NSUserDefaults *userDefaults;
    GlobalVariables *globalVariables;
    NSDictionary *tempDict;
    
    // NSMutableArray *mutableArray;
    NSMutableArray *selectedArray;
    NSMutableArray *selectedSubjectArray;
    NSMutableArray *selectedTicketOwner;
    
    int count1;
    NSString *selectedIDs;
    UINavigationBar*  navbar;
    NSString *trimmedString;
    
    UIView *uiDisableViewOverlay;
    
}

@property (strong,nonatomic) NSIndexPath *selectedPath;

@property (nonatomic, strong) NSMutableArray *mutableArray;
@property (nonatomic, strong) NSArray *indexPaths;
@property (nonatomic, assign) NSInteger totalPages;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) NSInteger totalTickets; //
@property (nonatomic, strong) NSString *nextPageUrl;
@property (nonatomic, strong) NSString *path1;

@property (nonatomic, strong) CFMultistageDropdownMenuView *multistageDropdownMenuView;
@property (nonatomic, strong) CFMultistageConditionTableView *multistageConditionTableView;
@property (nonatomic) int pageInt;

@end


@implementation InboxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"Naa-Inbox");
    
    _searchBar.delegate = self;
    
    _filteredSampleDataArray = [[NSMutableArray alloc] init];
    
    
    _multistageDropdownMenuView.tag=99;
    
    self.view.backgroundColor=[UIColor grayColor];
    [self.view addSubview:self.multistageDropdownMenuView];
    
    userDefaults=[NSUserDefaults standardUserDefaults];
    
    NSString *refreshedToken = [[FIRInstanceID instanceID] token];
    NSLog(@"refreshed token  %@",refreshedToken);
    
    [self setTitle:NSLocalizedString(@"Inbox",nil)];
    [self addUIRefresh];
    NSLog(@"string %@",NSLocalizedString(@"Inbox",nil));
    _mutableArray=[[NSMutableArray alloc]init];
    
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
    selectedSubjectArray = [[NSMutableArray alloc] init];
    selectedTicketOwner = [[NSMutableArray alloc] init];
    
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
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected)];
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
    
    [self getDependencies];
    [self reload];
   
    [[AppDelegate sharedAppdelegate] showProgressViewWithText:NSLocalizedString(@"Getting Data",nil)];
    
}




- (IBAction)searchButtonClicked {
    
    TicketSearchViewController * search=[self.storyboard instantiateViewControllerWithIdentifier:@"TicketSearchViewControllerId"];
    [self.navigationController pushViewController:search animated:YES];
    
//    self.navigationItem.rightBarButtonItem = nil;
//    _searchBar = [[UISearchBar alloc] init];
//    _searchBar.delegate = self;
//    _searchBar.placeholder = @"Search Data";
//    [_searchBar sizeToFit];
//    self.navigationItem.titleView = _searchBar;
//    [_searchBar becomeFirstResponder];
//    [_searchBar.window makeKeyAndVisible];
    
    
    
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [_searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    
    //   [_searchBar resignFirstResponder];
    
}
- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    // [_searchBar setShowsCancelButton:YES animated:YES];
    
    if([text isEqualToString:@"\n"])
    {
        [searchBar resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searching = NO;
    [self.tableView reloadData];
    
    self.navigationItem.titleView = nil;
    //    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"about"] style:UIBarButtonItemStylePlain  target:self action:@selector(searchButtonClicked)];
    //    self.navigationItem.rightBarButtonItem = rightBarButton;
    
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
    ////
    [_searchBar setShowsCancelButton:NO];
    //  [_searchBar resignFirstResponder];
    
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    // [_filteredSampleDataArray removeAllObjects];
    
    if ([searchText length] != 0) {
        searching = YES;
        [self searchData];
        
    } else {
        searching = NO;
    }
    
    [self.tableView reloadData];
}

- (void)searchData {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", _searchBar.text];
    NSLog(@"Data is : %@",predicate);
    NSLog(@"Data is : %@",predicate);
    NSString *str1= [NSString stringWithFormat:@"%@",predicate];
    
    NSString *prefixToRemove = @"SELF CONTAINS[c] ";
    NSString *newString = [str1 copy];
    if ([str1 hasPrefix:prefixToRemove])
        newString = [str1 substringFromIndex:[prefixToRemove length]];
    
    NSLog(@"Data1111 is : %@",newString);
    NSLog(@"Data1111 is : %@",newString);
    
    NSString *str2= [NSString stringWithFormat:@"%@",newString];
    
    NSCharacterSet *quoteCharset = [NSCharacterSet characterSetWithCharactersInString:@"\""];
    trimmedString = [str2 stringByTrimmingCharactersInSet:quoteCharset];
    
    NSLog(@"Data222 is : %@",trimmedString);
    NSLog(@"Data222 is : %@",trimmedString);
    
    
    //   NSString *searchString = searchController.searchBar.text;
    if (trimmedString != nil && ![trimmedString  isEqual: @""]) {
        [self getAirports:trimmedString];
    }
    
    
    //    NSArray *tempArray = [_sampleDataArray filteredArrayUsingPredicate:predicate];
    //    NSLog(@"%@", tempArray);
    //    _filteredSampleDataArray = [NSMutableArray arrayWithArray:tempArray];
}

- (void)getAirports:(NSString *)needeedString
{
    //http://jamboreebliss.com/sayar/public/api/v1/helpdesk/ticket-search?search
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
        
    }
    NSString * url= [NSString stringWithFormat:@"%@api/v1/helpdesk/ticket-search?token=%@&search=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],needeedString];
    NSLog(@"URL is : %@",url);
    globalVariables.searchString=needeedString;
    
    MyWebservices *webservices=[MyWebservices sharedInstance];
    [webservices httpResponseGET:url parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
        
        
        
        if (error || [msg containsString:@"Error"]) {
            [refresh endRefreshing];
            [[AppDelegate sharedAppdelegate] hideProgressView];
            if (msg) {
                
                [utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",msg] sendViewController:self];
                
            }else if(error)  {
                [utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",error.localizedDescription] sendViewController:self];
                NSLog(@"Thread-NO4-Search-Refresh-error == %@",error.localizedDescription);
            }
            return ;
        }
        
        if ([msg isEqualToString:@"tokenRefreshed"]) {
            
            [self getAirports:needeedString];
            NSLog(@"Thread--NO4-call-Search");
            return;
        }
        
        if (json) {
            //NSError *error;
            NSLog(@"Thread-NO4--SearchAPI--%@",json);
            
            NSDictionary * dict1 = [json objectForKey:@"result"];
            _filteredSampleDataArray = [dict1 objectForKey:@"data"];
            
            NSLog(@"Mutable Array is--%@",_filteredSampleDataArray);
            
            
            _nextPageUrl =[dict1 objectForKey:@"next_page_url"];
            NSLog(@"Next page url is : %@",_nextPageUrl);
            
            _path1=[dict1 objectForKey:@"path"];
            
            _currentPage=[[dict1 objectForKey:@"current_page"] integerValue];
            _totalTickets=[[dict1 objectForKey:@"total"] integerValue];
            _totalPages=[[dict1 objectForKey:@"last_page"] integerValue];
            
            //    NSLog(@"Thread-Search-dic--%@", _mutableArray);
            
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    //                        [[AppDelegate sharedAppdelegate] hideProgressView];
                    //                        [refresh endRefreshing];
                    [self.tableView reloadData];
                    //                      // [self reloadTableView];
                    //
                });
            });
            
        }
        NSLog(@"Thread-NO5-Search-closed");
        
    }];
    
    
}


-(void)tapDetected{
    
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
        NSLog( @" I am in clickedOnAssignButton method in Inbox ViewController" );
        
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
        if(selectedArray.count>=2)
        {
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

        }else
        {

             [utils showAlertWithMessage:@"Select 2 or more Tickets for Merge" sendViewController:self];
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
        NSLog( @" I am in mergeButtonCicked method in Inbox ViewController" );
        
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
        //  NSString *url=[NSString stringWithFormat:@"%@helpdesk/inbox?api_key=%@&ip=%@&token=%@",[userDefaults objectForKey:@"companyURL"],API_KEY,IP,[userDefaults objectForKey:@"token"]];
        
        NSString * apiValue=[NSString stringWithFormat:@"%i",1];
        NSString * showInbox = @"inbox";
        NSString * Alldeparatments=@"All";
        
        NSString * url= [NSString stringWithFormat:@"%@api/v2/helpdesk/get-tickets?token=%@&api=%@&show=%@&departments=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],apiValue,showInbox,Alldeparatments];
        NSLog(@"URL is : %@",url);
        
        @try{
            MyWebservices *webservices=[MyWebservices sharedInstance];
            [webservices httpResponseGET:url parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
                
                
                
                if (error || [msg containsString:@"Error"]) {
                    [refresh endRefreshing];
                    [[AppDelegate sharedAppdelegate] hideProgressView];
                    if (msg) {
                        if([msg isEqualToString:@"Error-402"])
                        {
                            NSLog(@"Message is : %@",msg);
                            [utils showAlertWithMessage:[NSString stringWithFormat:@"API is disabled in web, please enable it from Admin panel."] sendViewController:self];
                        }
                        else if([msg isEqualToString:@"Error-403"])
                        {
                            [utils showAlertWithMessage:NSLocalizedString(@"Access Denied - You don't have permission.", nil) sendViewController:self];
                            [[AppDelegate sharedAppdelegate] hideProgressView];
                        }
                        else{
                            
                            NSLog(@"Message is : %@",msg);
                            [utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",msg] sendViewController:self];
                        }
                        
                    }else if(error)  {
                        NSLog(@"Error is : %@",error);
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
                
                if ([msg isEqualToString:@"tokenNotRefreshed"]) {
                    
                    [[AppDelegate sharedAppdelegate] hideProgressView];
                    [utils showAlertWithMessage:@"Your account credentials were changed, contact to Admin and please log back in." sendViewController:self];
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
                            //  [self.tableView reloadData];
                            [self reloadTableView];
                            //                        [selectedArray removeAllObjects];
                            //                        if (!selectedArray.count) {
                            //                            [self.tableView setEditing:NO animated:YES];
                            //                        }
                        });
                    });
                    
                }
                NSLog(@"Thread-NO5-getInbox-closed");
                
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
            NSLog( @" I am in reload method in Inbox ViewController" );
            
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
        
        NSLog(@"URL is : %@",url);
        @try{
            MyWebservices *webservices=[MyWebservices sharedInstance];
            [webservices httpResponseGET:url parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg){
                NSLog(@"Thread-NO3-getDependencies-start-error-%@-json-%@-msg-%@",error,json,msg);
                if (error || [msg containsString:@"Error"]) {
                    
                    if( [msg containsString:@"Error-429"])
                        
                    {
                        [utils showAlertWithMessage:[NSString stringWithFormat:@"your request counts exceed our limit"] sendViewController:self];
                        
                    }else{
                        NSLog(@"Thread-NO4-getdependency-Refresh-error == %@",error.localizedDescription);
                        return ;
                    }
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
            NSLog( @"Name: %@", exception.name);
            NSLog( @"Reason: %@", exception.reason );
            [utils showAlertWithMessage:exception.name sendViewController:self];
            return;
        }
        @finally
        {
            NSLog( @" I am in getDependencies method in Inbox ViewController" );
            
        }
    }
    NSLog(@"Thread-NO2-getDependencies()-closed");
}



-(void)EditTableView:(UIGestureRecognizer*)gesture{
    [self.tableView setEditing:YES animated:YES];
    navbar.hidden=NO;
   // [selectedTicketOwner removeAllObjects];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    if(searching)
    {
        
        NSInteger numOfSections = 0;
        if ([_filteredSampleDataArray count]==0)
        {
            // CGRectMake(0, -10, tableView.bounds.size.width, tableView.bounds.size.height)
            UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, tableView.bounds.size.height)];
            //CGPointMake(self.view.frame.size.width/2,self.view.frame.size.height/2);
            
            
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
    else{
        
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
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (searching) {
        
        if (self.currentPage == self.totalPages
            || self.totalTickets == _filteredSampleDataArray.count) {
            return _filteredSampleDataArray.count;
        }
        
        return _filteredSampleDataArray.count + 1;
        
    } else {
        
        
        if (self.currentPage == self.totalPages
            || self.totalTickets == _mutableArray.count) {
            return _mutableArray.count;
        }
        
        return _mutableArray.count + 1;
    }
    
    
    
    
}



- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    // cell.selectionStyle=UITableViewCellSelectionStyleNone;
    //  cell.selectionStyle=UITableViewCellSelectionStyleBlue;
    if(searching)
    {
        if (indexPath.row == [_filteredSampleDataArray count] - 1 ) {
            NSLog(@"nextURL111  %@",_nextPageUrl);
            
            if (( ![_nextPageUrl isEqual:[NSNull null]] ) && ( [_nextPageUrl length] != 0 )) {
                
             //   [self loadMoreforSearchResults];
                
                
            }
            else{
                
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
    else{
        if (indexPath.row == [_mutableArray count] - 1 ) {
            NSLog(@"nextURL111  %@",_nextPageUrl);
            
            if (( ![_nextPageUrl isEqual:[NSNull null]] ) && ( [_nextPageUrl length] != 0 )) {
                
                [self loadMore];
                
                
            }
            else{
                
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
}

-(void)loadMore{
    
    
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
        
        @try{
            
            self.page = _page + 1;
            // NSLog(@"Page is : %ld",(long)_page);
            
            NSString *str=_nextPageUrl;
            NSString *Page = [str substringFromIndex:[str length] - 1];
            
            //     NSLog(@"String is : %@",szResult);
            NSLog(@"Page is : %@",Page);
            NSLog(@"Page is : %@",Page);

            MyWebservices *webservices=[MyWebservices sharedInstance];
            [webservices getNextPageURLInbox:_path1 pageNo:Page  callbackHandler:^(NSError *error,id json,NSString* msg) {
                
                //[webservices getNextPageURL:_nextPageUrl  callbackHandler:^(NSError *error,id json,NSString* msg) {
                
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
                    
                    //                NSLog(@"Thread-NO4.1getInbox-dic--%@", _mutableArray);
                    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            // [self.tableView reloadData];
                            
                            [self reloadTableView];
                            
                            //                        [self.tableView beginUpdates];
                            //                        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[_mutableArray count]-[_indexPaths count] inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
                            //                        [self.tableView endUpdates];
                        });
                    });
                    
                }
                NSLog(@"Thread-NO5-getInbox-closed");
                
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
            NSLog( @" I am in loadMore method in Inobx ViewController" );
            
        }
    }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(searching)
    {
        if (indexPath.row == [_filteredSampleDataArray count])
        {
            LoadingTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"LoadingCellID"];
            if (cell == nil)
            {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"LoadingTableViewCell" owner:self options:nil];
                cell = [nib objectAtIndex:0];
                
            }
            UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[cell.contentView viewWithTag:1];
            [activityIndicator startAnimating];
            return cell;
            
        }else
        {
            TicketTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"TableViewCellID"];
            
            if (cell == nil)
            {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TicketTableViewCell" owner:self options:nil];
                cell = [nib objectAtIndex:0];
            }
            
            //agent name deatils
            NSDictionary *searchDictionary=[_filteredSampleDataArray objectAtIndex:indexPath.row];
            NSLog(@"searchDictionary is : %@",searchDictionary);
            
            
            // first name, last name, user name owner name
            NSDictionary * userDict= [searchDictionary objectForKey:@"user"];
            
            NSString *fname= [userDict objectForKey:@"first_name"];
            
            NSString *lname= [userDict objectForKey:@"last_name"];
            
            NSString*userName=[userDict objectForKey:@"user_name"];
            
            NSString*profilPic=[userDict objectForKey:@"profile_pic"];
            
            
            [Utils isEmpty:fname];
            [Utils isEmpty:lname];
            [Utils isEmpty:userName];
            [Utils isEmpty:profilPic];
            
            
            if  (![Utils isEmpty:fname] || ![Utils isEmpty:lname])
            {
                if (![Utils isEmpty:fname] && ![Utils isEmpty:lname])
                {   cell.mailIdLabel.text=[NSString stringWithFormat:@"%@ %@",fname,lname];
                }
                else{
                    cell.mailIdLabel.text=[NSString stringWithFormat:@"%@ %@",fname,lname];
                }
            }
            else
            {
                if(![Utils isEmpty:userName])
                {
                    cell.mailIdLabel.text=userName;
                }
                else{
                    cell.mailIdLabel.text=NSLocalizedString(@"Not Available", nil);
                }
                
            }
            
            // ticket numbner
            NSString *ticketNumber=[searchDictionary objectForKey:@"ticket_number"];
            
            [Utils isEmpty:ticketNumber];
            if  (![Utils isEmpty:ticketNumber] && ![ticketNumber isEqualToString:@""])
            {
                cell.ticketIdLabel.text=ticketNumber;
            }
            else
            {
                cell.ticketIdLabel.text=NSLocalizedString(@"Not Available", nil);
            }
            
            //profile picture
            if (  ![profilPic isEqual:[NSNull null]]   )
            {
                [cell setUserProfileimage:profilPic];
                
            }
            else
            {
                [cell setUserProfileimage:@"default_pic.png"];
            }
            
            //
            //   cell.timeStampLabel.text=[utils getLocalDateTimeFromUTC:[finaldic objectForKey:@"updated_at"]];
            
            //  cell.ticketSubLabel.text=@"Updating wait...";
            
            
            //Agent info
            // if(( ![[json objectForKey:@"requester"] isEqual:[NSNull null]] ) )
            NSDictionary *AgentDict= [searchDictionary objectForKey:@"assigned"];
            
            if(( ![[searchDictionary objectForKey:@"assigned"] isEqual:[NSNull null]] ) )
                
            {
                if(( ![[AgentDict objectForKey:@"first_name"] isEqual:[NSNull null]] ) || ( ![[AgentDict objectForKey:@"last_name"] isEqual:[NSNull null]] ) )
                    
                {
                    if(( ![[AgentDict objectForKey:@"first_name"] isEqual:[NSNull null]] ) && ( ![[AgentDict objectForKey:@"last_name"] isEqual:[NSNull null]] ) )
                    {
                        
                        
                        cell.agentLabel.text=[NSString stringWithFormat:@"%@ %@",[AgentDict objectForKey:@"first_name"],[AgentDict objectForKey:@"last_name"]];
                        
                    }else if(( ![[AgentDict objectForKey:@"first_name"] isEqual:[NSNull null]] ) || ( ![[AgentDict objectForKey:@"last_name"] isEqual:[NSNull null]] ) )
                    {
                        
                        
                        cell.agentLabel.text=[NSString stringWithFormat:@"%@ %@",[AgentDict objectForKey:@"first_name"],[AgentDict objectForKey:@"last_name"]];
                        
                    }
                    
                }else if(( ![[AgentDict objectForKey:@"user_name"] isEqual:[NSNull null]] ) )
                {
                    cell.agentLabel.text=[NSString stringWithFormat:@"%@",[AgentDict objectForKey:@"user_name"]];
                    
                }
                
            }else
            {
                cell.agentLabel.text=@"Unassigned";
                
            }
            
            
            
            //   NSDictionary *searchDictionary=[_filteredSampleDataArray objectAtIndex:indexPath.row];
            
            NSArray * ticketThredArray= [searchDictionary objectForKey:@"thread"];
            
            if(( ![[searchDictionary objectForKey:@"thread"] isEqual:[NSNull null]] ) )
            {
                NSDictionary *ticketDict=[ticketThredArray objectAtIndex:0];
                
                if(( ![[ticketDict objectForKey:@"ticket_id"] isEqual:[NSNull null]] ) )
                    
                {
                    NSString * ticketidIs= [NSString stringWithFormat:@"%@",[ticketDict objectForKey:@"ticket_id"]];
                    NSLog(@"Ticket id is : %@",ticketidIs);
                    
                }
                
                if(( ![[ticketDict objectForKey:@"title"] isEqual:[NSNull null]] ) )
                {
                    NSString * ticketTitle= [NSString stringWithFormat:@"%@",[ticketDict objectForKey:@"title"]];
                    NSLog(@"Ticket Title is : %@",ticketTitle);
                    
                    cell.ticketSubLabel.text=ticketTitle;
                }
                
            }else
            {
                cell.ticketSubLabel.text=@"No Title - EMPTY JSON ";
                
            }
            
            //due/oberdue
            
            if(( ![[searchDictionary objectForKey:@"duedate"] isEqual:[NSNull null]] ) )
                
            {
                
                if([utils compareDates:[searchDictionary objectForKey:@"duedate"]]){
                    [cell.overDueLabel setHidden:NO];
                    [cell.today setHidden:YES];
                }else
                {
                    [cell.overDueLabel setHidden:YES];
                    [cell.today setHidden:NO];
                }
                
            }
            
            //indication color/priority color
            
            if(( ![[searchDictionary objectForKey:@"priority"] isEqual:[NSNull null]] ) )
            {
                
                NSDictionary * priority =[searchDictionary objectForKey:@"priority"];
                
                if(( ![[priority objectForKey:@"priority_color"] isEqual:[NSNull null]] ) )
                {
                    
                    cell.indicationView.layer.backgroundColor=[[UIColor hx_colorWithHexRGBAString:[priority objectForKey:@"priority_color"]] CGColor];
                }
                else{
                    NSLog(@"I am in else condition");
                }
                
            }
            
            
            return cell;
        }
        
        
    }
    
    else{
        
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
                    cell.agentLabel.text= NSLocalizedString(@"Unassigned", nil);
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
                
                //Image view
                if([[finaldic objectForKey:@"profile_pic"] hasSuffix:@"system.png"] || [[finaldic objectForKey:@"profile_pic"] hasSuffix:@".jpg"] || [[finaldic objectForKey:@"profile_pic"] hasSuffix:@".jpeg"] || [[finaldic objectForKey:@"profile_pic"] hasSuffix:@".png"] )
                {
                    [cell setUserProfileimage:[finaldic objectForKey:@"profile_pic"]];
                }
                else if(![Utils isEmpty:fname])
                {
                    [cell.profilePicView setImageWithString:fname color:nil ];
                }
                else
                {
                    [cell.profilePicView setImageWithString:email1 color:nil ];
                }
                
                
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
                    
                    //   cell.ticketSubLabel.text= decodedString; //countthread
                    cell.ticketSubLabel.text= [NSString stringWithFormat:@"%@ (%@)",decodedString,[finaldic objectForKey:@"countthread"]];
                }
                else{
                    
                    // cell.ticketSubLabel.text= encodedString;
                    cell.ticketSubLabel.text= [NSString stringWithFormat:@"%@ (%@)",encodedString,[finaldic objectForKey:@"countthread"]];
                    
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
                
                
                
                
                
                if(![cc isEqualToString:@"0"] && ![attachment1 isEqualToString:@"0"])
                {
                    cell.ccImgView.image=[UIImage imageNamed:@"cc1"];
                    cell.attachImgView.image=[UIImage imageNamed:@"attach"];
                }
                else if(![cc isEqualToString:@"0"] && [attachment1 isEqualToString:@"0"])
                {
                    cell.ccImgView.image=[UIImage imageNamed:@"cc1"];
                }
                else if([cc isEqualToString:@"0"] && ![attachment1 isEqualToString:@"0"])
                {
                    cell.ccImgView.image=[UIImage imageNamed:@"attach"];
                }else
                {
                    
                }
                
                
                
                cell.indicationView.layer.backgroundColor=[[UIColor hx_colorWithHexRGBAString:[finaldic objectForKey:@"color"]] CGColor];
                
                
                
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
    
    if ([tableView isEditing]) {
        
        //  [selectedArray addObject:[_mutableArray objectAtIndex:indexPath.row]];
        
        //taking id from selected rows
        [selectedArray addObject:[[_mutableArray objectAtIndex:indexPath.row] valueForKey:@"id"]];
        
        //taking ticket title from selected rows
        [selectedSubjectArray addObject:[[_mutableArray objectAtIndex:indexPath.row] valueForKey:@"ticket_title"]];
        //taking email id
        [selectedTicketOwner addObject:[[_mutableArray objectAtIndex:indexPath.row] valueForKey:@"c_email"]];
        
        count1=(int)[selectedArray count];
        NSLog(@"Selected count is :%i",count1);
        NSLog(@"Slected Array Id : %@",selectedArray);
        NSLog(@"Slected Owner Emails are : %@",selectedTicketOwner);
        
        selectedIDs = [selectedArray componentsJoinedByString:@","];
        NSLog(@"Slected Ticket Id are : %@",selectedIDs);
        
        NSLog(@"Slected Ticket Subjects are : %@",selectedSubjectArray);
        
        //        globalVariables.idList=selectedArray;
        //        globalVariables.subjectList=selectedSubjectArray;
        
    }else{
        
        if(searching)
        {
            NSDictionary *searchDictionary=[_filteredSampleDataArray objectAtIndex:indexPath.row];
            NSArray * ticketThredArray = [searchDictionary objectForKey:@"thread"];
            NSDictionary *ticketDict=[ticketThredArray objectAtIndex:0];
            
            
            NSDictionary * userDict= [searchDictionary objectForKey:@"user"];
            
            globalVariables.iD= [ticketDict objectForKey:@"ticket_id"];
            globalVariables.ticket_number=[searchDictionary objectForKey:@"ticket_number"];
            
            globalVariables.First_name=[userDict objectForKey:@"first_name"];
            globalVariables.Last_name=[userDict objectForKey:@"last_name"];
            
            NSDictionary * statusDict = [searchDictionary objectForKey:@"statuses"];
            
            globalVariables.Ticket_status=[statusDict objectForKey:@"name"];
            
            
            TicketDetailViewController *td=[self.storyboard instantiateViewControllerWithIdentifier:@"TicketDetailVCID"];
            [self.navigationController pushViewController:td animated:YES];
            
        }else{
            TicketDetailViewController *td=[self.storyboard instantiateViewControllerWithIdentifier:@"TicketDetailVCID"];
            
            NSDictionary *finaldic=[_mutableArray objectAtIndex:indexPath.row];
            
            globalVariables.iD=[finaldic objectForKey:@"id"];
            globalVariables.ticket_number=[finaldic objectForKey:@"ticket_number"];
            
            globalVariables.First_name=[finaldic objectForKey:@"c_fname"];
            globalVariables.Last_name=[finaldic objectForKey:@"c_lname"];
            
            globalVariables.Ticket_status=[finaldic objectForKey:@"ticket_status_name"];
            globalVariables.userIdFromInbox=[finaldic objectForKey:@"c_uid"];;
            
            globalVariables.ticketStatusBool=@"ticketView";
            
            [self.navigationController pushViewController:td animated:YES];
            
        }
    }
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.selectedPath = indexPath;
    
    
    //   [selectedArray removeObject:[_mutableArray objectAtIndex:indexPath.row]];
    [selectedArray removeObject:[[_mutableArray objectAtIndex:indexPath.row] valueForKey:@"id"]];
    
    [selectedSubjectArray removeObject:[[_mutableArray objectAtIndex:indexPath.row] valueForKey:@"ticket_title"]];
    
    [selectedTicketOwner removeObject:[[_mutableArray objectAtIndex:indexPath.row] valueForKey:@"c_email"]];
    
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
    // refresh.backgroundColor = [UIColor colorWithRed:0.46 green:0.8 blue:1.0 alpha:1.0];
    refresh.backgroundColor = [UIColor hx_colorWithHexRGBAString:@"#BDBDBD"];
    refresh.attributedTitle =refreshing;
    [refresh addTarget:self action:@selector(reloadd) forControlEvents:UIControlEventValueChanged];
    [_tableView insertSubview:refresh atIndex:0];
    
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
    
    //    [FTPopOverMenu showFromEvent:event
    //                   withMenuArray:@[@"Change Ticket Status",@"          Open",@"          Closed",@"          Resolved",@"          Deleted"]
    
    [FTPopOverMenu showFromEvent:event
                   withMenuArray:@[NSLocalizedString(@"Change Ticket Status", nil),NSLocalizedString(@"Closed", nil), NSLocalizedString(@"Resolved", nil),NSLocalizedString(@"Deleted", nil)]
                      imageArray:@[@"Pokemon_Go_01",[UIImage imageNamed:@"doneIcon"],[UIImage imageNamed:@"resolvedIcon"],[UIImage imageNamed:@"deleteIcon"]]
                       doneBlock:^(NSInteger selectedIndex) {
                           
                           
                           
                           
                           
                           if(selectedIndex==0)
                           {
                               NSLog(@"Index 0 clicked");
                               
                           }else if(selectedIndex==1)
                           {
                               NSLog(@"Clicked on Closed");
                               
                               [self changeStaus2];
                           }else if(selectedIndex==2)
                           {
                               NSLog(@"Clicked on Resolved");
                               [self changeStaus3];
                           }else if(selectedIndex==3)
                           {
                               NSLog(@"Clicked on Deleted");
                               [self changeStaus4];
                           }
                           
                       } dismissBlock:^{
                           
                       }];
    
#endif
    }
}

-(void)changeStaus2
{
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
            NSString *url= [NSString stringWithFormat:@"%@api/v2/helpdesk/status/change?api_key=%@&token=%@&ticket_id=%@&status_id=%@",[userDefaults objectForKey:@"baseURL"],API_KEY,[userDefaults objectForKey:@"token"],selectedIDs,globalVariables.ClosedStausId];
            NSLog(@"URL is : %@",url);
            //        if([globalVariables.Ticket_status isEqualToString:@"Closed"])
            //        {
            //            [utils showAlertWithMessage:@"Ticket is Already Closed" sendViewController:self];
            //            [[AppDelegate sharedAppdelegate] hideProgressView];
            //
            //        }else{
            
            
            MyWebservices *webservices=[MyWebservices sharedInstance];
            
            [webservices httpResponsePOST:url parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
                [[AppDelegate sharedAppdelegate] hideProgressView];
                
                if (error || [msg containsString:@"Error"]) {
                    
                    if (msg) {
                        
                        if([msg isEqualToString:@"Error-403"])
                        {
                            [utils showAlertWithMessage:NSLocalizedString(@"Permission Denied - Yo don't have permission to Close a ticket", nil) sendViewController:self];
                        }
                        else{
                            [utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",msg] sendViewController:self];
                        }
                        //  NSLog(@"Message is : %@",msg);
                        
                    }else if(error)  {
                        [utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",error.localizedDescription] sendViewController:self];
                        NSLog(@"Thread-NO4-getTicketStausChange-Refresh-error == %@",error.localizedDescription);
                    }
                    
                    return ;
                }
                
                if ([msg isEqualToString:@"tokenRefreshed"]) {
                    
                    [self changeStaus2];
                    NSLog(@"Thread--NO4-call-postTicketStatusChange");
                    return;
                }
                if (json) {
                    NSLog(@"JSON-CreateTicket-%@",json);
                    if ([json objectForKey:@"response"]) {
                        
                        id object;
                        NSDictionary * dict1= [json objectForKey:@"response"];
                        object = [dict1 objectForKey:@"message"];
                        
                        NSLog(@"object is :%@",object);
                        NSLog(@"object is :%@",object);
                        
                        if(![object isKindOfClass:[NSArray class]] && [object isEqualToString:@"Status changed to Closed"]){
                            
                            [RKDropdownAlert title: NSLocalizedString(@"success.", nil) message:NSLocalizedString(@"Ticket Status Changed.", nil) backgroundColor:[UIColor hx_colorWithHexRGBAString:SUCCESS_COLOR] textColor:[UIColor whiteColor]];
                            
                            InboxViewController *inboxVC=[self.storyboard instantiateViewControllerWithIdentifier:@"InboxID"];
                            [self.navigationController pushViewController:inboxVC animated:YES];
                            
                        }else
                        {
                            
                            [utils showAlertWithMessage:NSLocalizedString(@"Permission Denied - Yo don't have permission to Close a ticket", nil) sendViewController:self];
                            
                        }
                        
                    }
                }
                //                if (json) {
                //                    NSLog(@"JSON-CreateTicket-%@",json);
                //                    if ([json objectForKey:@"response"]) {
                //                        dispatch_async(dispatch_get_main_queue(), ^{
                //
                //                            [RKDropdownAlert title: NSLocalizedString(@"Sucess.", nil) message:NSLocalizedString(@"Ticket Status Changed.", nil) backgroundColor:[UIColor hx_colorWithHexRGBAString:SUCCESS_COLOR] textColor:[UIColor whiteColor]];
                //
                //                            InboxViewController *inboxVC=[self.storyboard instantiateViewControllerWithIdentifier:@"InboxID"];
                //                            [self.navigationController pushViewController:inboxVC animated:YES];
                //                        });
                //                    }
                //                }// end json
                NSLog(@"Thread-NO5-postTicketStatusChange-closed");
                
            }];
            // }
        }
    }
}

-(void)changeStaus3
{
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
            NSString *url= [NSString stringWithFormat:@"%@api/v2/helpdesk/status/change?api_key=%@&token=%@&ticket_id=%@&status_id=%@",[userDefaults objectForKey:@"baseURL"],API_KEY,[userDefaults objectForKey:@"token"],selectedIDs,globalVariables.ResolvedStausId];
            
            
            //        if([globalVariables.Ticket_status isEqualToString:@"Resolved"])
            //        {
            //            [utils showAlertWithMessage:@"Ticket is Already Resolved" sendViewController:self];
            //            [[AppDelegate sharedAppdelegate] hideProgressView];
            //
            //        }else{
            //
            MyWebservices *webservices=[MyWebservices sharedInstance];
            
            [webservices httpResponsePOST:url parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
                [[AppDelegate sharedAppdelegate] hideProgressView];
                
                if (error || [msg containsString:@"Error"]) {
                    
                    if (msg) {
                        
                        if([msg isEqualToString:@"Error-403"])
                        {
                            [utils showAlertWithMessage:NSLocalizedString(@"Permission Denied - You don't have permission to Resolve a ticket", nil) sendViewController:self];
                        }
                        else{
                            [utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",msg] sendViewController:self];
                        }
                        //  NSLog(@"Message is : %@",msg);
                        
                    }else if(error)  {
                        [utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",error.localizedDescription] sendViewController:self];
                        NSLog(@"Thread-NO4-getTicketStaus-Refresh-error == %@",error.localizedDescription);
                    }
                    
                    return ;
                }
                
                if ([msg isEqualToString:@"tokenRefreshed"]) {
                    
                    [self changeStaus3];
                    NSLog(@"Thread--NO4-call-postTicketStatusChange");
                    return;
                }
                
                if (json) {
                    NSLog(@"JSON-CreateTicket-%@",json);
                    if ([json objectForKey:@"response"]) {
                        
                        id object;
                        NSDictionary * dict1= [json objectForKey:@"response"];
                        object = [dict1 objectForKey:@"message"];
                        
                        NSLog(@"object is :%@",object);
                        NSLog(@"object is :%@",object);
                        
                        if(![object isKindOfClass:[NSArray class]] && [object isEqualToString:@"Status changed to Resolved"]){
                            
                            [RKDropdownAlert title: NSLocalizedString(@"success.", nil) message:NSLocalizedString(@"Ticket Status Changed.", nil) backgroundColor:[UIColor hx_colorWithHexRGBAString:SUCCESS_COLOR] textColor:[UIColor whiteColor]];
                            
                            InboxViewController *inboxVC=[self.storyboard instantiateViewControllerWithIdentifier:@"InboxID"];
                            [self.navigationController pushViewController:inboxVC animated:YES];
                            
                        }else
                        {
                            
                            [utils showAlertWithMessage:NSLocalizedString(@"Permission Denied - Yo don't have permission to Resolve a ticket", nil) sendViewController:self];
                            
                        }
                        
                    }
                    
                    
                } // end json
                
                //                if (json) {
                //                    NSLog(@"JSON-CreateTicket-%@",json);
                //                    if ([json objectForKey:@"response"]) {
                //                        dispatch_async(dispatch_get_main_queue(), ^{
                //
                //                            [RKDropdownAlert title: NSLocalizedString(@"Sucess.", nil) message:NSLocalizedString(@"Ticket Status Changed.", nil) backgroundColor:[UIColor hx_colorWithHexRGBAString:SUCCESS_COLOR] textColor:[UIColor whiteColor]];
                //
                //
                //
                //                            InboxViewController *inboxVC=[self.storyboard instantiateViewControllerWithIdentifier:@"InboxID"];
                //                            [self.navigationController pushViewController:inboxVC animated:YES];
                //                        });
                //                    }
                //                }
                NSLog(@"Thread-NO5-postTicketStatusChange-closed");
                
            }];
            // }
        } }
}

-(void)changeStaus4
{
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
            NSString *url= [NSString stringWithFormat:@"%@api/v2/helpdesk/status/change?api_key=%@&token=%@&ticket_id=%@&status_id=%@",[userDefaults objectForKey:@"baseURL"],API_KEY,[userDefaults objectForKey:@"token"],selectedIDs,globalVariables.DeletedStausId];
            
            //        if([globalVariables.Ticket_status isEqualToString:@"Deleted"])
            //        {
            //            [utils showAlertWithMessage:@"Ticket is Already Deleted" sendViewController:self];
            //            [[AppDelegate sharedAppdelegate] hideProgressView];
            //
            //        }else{
            
            MyWebservices *webservices=[MyWebservices sharedInstance];
            
            [webservices httpResponsePOST:url parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
                [[AppDelegate sharedAppdelegate] hideProgressView];
                
                if (error || [msg containsString:@"Error"]) {
                    
                    if (msg) {
                        
                        if([msg isEqualToString:@"Error-403"])
                        {
                            [utils showAlertWithMessage:NSLocalizedString(@"Permission Denied - You don't have permission to Delete a ticket", nil) sendViewController:self];
                        }
                        else{
                            [utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",msg] sendViewController:self];
                        }
                        //  NSLog(@"Message is : %@",msg);
                        
                    }else if(error)  {
                        [utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",error.localizedDescription] sendViewController:self];
                        NSLog(@"Thread-NO4-getTicketStaus-Refresh-error == %@",error.localizedDescription);
                    }
                    
                    return ;
                }
                
                if ([msg isEqualToString:@"tokenRefreshed"]) {
                    
                    [self changeStaus4];
                    NSLog(@"Thread--NO4-call-postTicketStatusChange");
                    return;
                }
                
                if (json) {
                    NSLog(@"JSON-CreateTicket-%@",json);
                    if ([json objectForKey:@"response"]) {
                        
                        id object;
                        NSDictionary * dict1= [json objectForKey:@"response"];
                        object = [dict1 objectForKey:@"message"];
                        
                        NSLog(@"object is :%@",object);
                        NSLog(@"object is :%@",object);
                        
                        if(![object isKindOfClass:[NSArray class]] && [object isEqualToString:@"Status changed to Deleted"]){
                            
                            [RKDropdownAlert title: NSLocalizedString(@"success.", nil) message:NSLocalizedString(@"Ticket Status Changed.", nil) backgroundColor:[UIColor hx_colorWithHexRGBAString:SUCCESS_COLOR] textColor:[UIColor whiteColor]];
                            
                            InboxViewController *inboxVC=[self.storyboard instantiateViewControllerWithIdentifier:@"InboxID"];
                            [self.navigationController pushViewController:inboxVC animated:YES];
                            
                        }else
                        {
                            
                            [utils showAlertWithMessage:NSLocalizedString(@"Permission Denied - Yo don't have permission to Delete a ticket", nil) sendViewController:self];
                            
                        }
                        
                    }
                    
                    
                    //                }
                } // end json
                
                
                //                if (json) {
                //                    NSLog(@"JSON-CreateTicket-%@",json);
                //                    if ([json objectForKey:@"response"]) {
                //                        dispatch_async(dispatch_get_main_queue(), ^{
                //
                //                            [RKDropdownAlert title: NSLocalizedString(@"Sucess.", nil) message:NSLocalizedString(@"Ticket Status Changed.", nil) backgroundColor:[UIColor hx_colorWithHexRGBAString:SUCCESS_COLOR] textColor:[UIColor whiteColor]];
                //
                //
                //                            InboxViewController *inboxVC=[self.storyboard instantiateViewControllerWithIdentifier:@"InboxID"];
                //                            [self.navigationController pushViewController:inboxVC animated:YES];
                //                        });
                //                    }
                //                }
                NSLog(@"Thread-NO5-postTicketStatusChange-closed");
                
            }];
            //  }
        } }
}



-(void)reloadd{
    [self reload];
    //    [refresh endRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        
        globalVariables.filterCondition=@"INBOX";
        FilterViewController * filter=[self.storyboard instantiateViewControllerWithIdentifier:@"filterID1"];
        [self.navigationController pushViewController:filter animated:YES];
        
    }
//    if(titleButtonIndex==0 && rightIndex==1 )
//    {
//        NSLog(@"clear All");
//        
//        InboxViewController * vc= [self.storyboard instantiateViewControllerWithIdentifier: @"InboxID"];
//        [self.navigationController pushViewController:vc animated:YES];
//        
//    }
    // sort by - Tciket title
    if(titleButtonIndex==1 && leftIndex==0 && rightIndex==0 )
    {
        NSLog(@"Ticket title - ASC");
        //sortAlert
        globalVariables.sortingValueId=@"sortTitleAsc";
        globalVariables.sortAlert=@"sortTitleAscAlert";
        globalVariables.sortCondition=@"INBOX";
        
        SortingViewController * sort=[self.storyboard instantiateViewControllerWithIdentifier:@"sortID"];
        [self.navigationController pushViewController:sort animated:YES];
        
    }
    
    else if (titleButtonIndex==1 && leftIndex==0 && rightIndex==1 )
    {
        NSLog(@"Ticket Title  - DSC");
        globalVariables.sortingValueId=@"sortTitleDsc";
        globalVariables.sortAlert=@"sortTitleDscAlert";
        globalVariables.sortCondition=@"INBOX";
        
        SortingViewController * sort=[self.storyboard instantiateViewControllerWithIdentifier:@"sortID"];
        [self.navigationController pushViewController:sort animated:YES];
        
        
    }
    
    else if (titleButtonIndex==1 && leftIndex==0 && rightIndex==2 )
    {
        
        NSLog(@"Exit Clicked ");
    }
    
    
    //sort by - ticket number
    else  if(titleButtonIndex==1 && leftIndex==1 && rightIndex==0 )
    {
        NSLog(@" Ticket number - ASC");
        globalVariables.sortingValueId=@"sortNumberAsc";
        globalVariables.sortAlert=@"sortNumberAscAlert";
        globalVariables.sortCondition=@"INBOX";
        
        SortingViewController * sort=[self.storyboard instantiateViewControllerWithIdentifier:@"sortID"];
        [self.navigationController pushViewController:sort animated:YES];
        
        
    }
    else if(titleButtonIndex==1 && leftIndex==1 && rightIndex==1 )
    {
        NSLog(@" Ticket number - DSC");
        globalVariables.sortingValueId=@"sortNumberDsc";
        globalVariables.sortAlert=@"sortNumberDscAlert";
        globalVariables.sortCondition=@"INBOX";
        
        SortingViewController * sort=[self.storyboard instantiateViewControllerWithIdentifier:@"sortID"];
        [self.navigationController pushViewController:sort animated:YES];
        
        
        
    }
    
    else if (titleButtonIndex==1 && leftIndex==1 && rightIndex==3 )
    {
        
        NSLog(@"Exit Clicked ");
    }
    
    //ticket priority
    else if(titleButtonIndex==1 && leftIndex==2 && rightIndex==0 )
    {
        NSLog(@" Ticket priority - ASC");
        globalVariables.sortingValueId=@"sortPriorityAsc";
        globalVariables.sortAlert=@"sortPriorityAscAlert";
        globalVariables.sortCondition=@"INBOX";
        
        SortingViewController * sort=[self.storyboard instantiateViewControllerWithIdentifier:@"sortID"];
        [self.navigationController pushViewController:sort animated:YES];
        
        
    }
    else if(titleButtonIndex==1 && leftIndex==2 && rightIndex==1 )
    {
        NSLog(@" Ticket priority - DSC");
        globalVariables.sortingValueId=@"sortPriorityDsc";
        globalVariables.sortAlert=@"sortPriorityDscAlert";
        globalVariables.sortCondition=@"INBOX";
        
        SortingViewController * sort=[self.storyboard instantiateViewControllerWithIdentifier:@"sortID"];
        [self.navigationController pushViewController:sort animated:YES];
        
        
    }
    else if (titleButtonIndex==1 && leftIndex==2 && rightIndex==2 )
    {
        
        NSLog(@"Exit Clicked ");
    }
    // upated at
    else if(titleButtonIndex==1 && leftIndex==3 && rightIndex==0 )
    {
        NSLog(@" upated at - ASC");
        globalVariables.sortingValueId=@"sortUpdatedAsc";
        globalVariables.sortAlert=@"sortUpdatedAscAlert";
        globalVariables.sortCondition=@"INBOX";
        
        SortingViewController * sort=[self.storyboard instantiateViewControllerWithIdentifier:@"sortID"];
        [self.navigationController pushViewController:sort animated:YES];
        
        
    }
    else if(titleButtonIndex==1 && leftIndex==3 && rightIndex==1 )
    {
        NSLog(@" upated at - DSC");
        globalVariables.sortingValueId=@"sortUpdatedDsc";
        globalVariables.sortAlert=@"sortUpdatedDscAlert";
        globalVariables.sortCondition=@"INBOX";
        
        SortingViewController * sort=[self.storyboard instantiateViewControllerWithIdentifier:@"sortID"];
        [self.navigationController pushViewController:sort animated:YES];
        
        
    }
    else if (titleButtonIndex==1 && leftIndex==3 && rightIndex==2 )
    {
        
        NSLog(@"Exit Clicked ");
    }
    
    // created at
    else if(titleButtonIndex==1 && leftIndex==4 && rightIndex==0 )
    {
        NSLog(@" created At - ASC");
        globalVariables.sortingValueId=@"sortCreatedAsc";
        globalVariables.sortAlert=@"sortCreatedAscAlert";
        globalVariables.sortCondition=@"INBOX";
        
        SortingViewController * sort=[self.storyboard instantiateViewControllerWithIdentifier:@"sortID"];
        [self.navigationController pushViewController:sort animated:YES];
        
    }
    else if(titleButtonIndex==1 && leftIndex==4 && rightIndex==1 )
    {
        NSLog(@" created At - DSC");
        globalVariables.sortingValueId=@"sortCreatedDsc";
        globalVariables.sortAlert=@"sortCreatedDscAlert";
        globalVariables.sortCondition=@"INBOX";
        
        SortingViewController * sort=[self.storyboard instantiateViewControllerWithIdentifier:@"sortID"];
        [self.navigationController pushViewController:sort animated:YES];
        
        
    }
    else if (titleButtonIndex==1 && leftIndex==4 && rightIndex==2 )
    {
        
        NSLog(@"Exit Clicked ");
    }
    
    // due on
    else if(titleButtonIndex==1 && leftIndex==5 && rightIndex==0 )
    {
        NSLog(@" due on - ASC");
        globalVariables.sortingValueId=@"sortDueAsc";
        globalVariables.sortAlert=@"sortDueAscAlert";
        globalVariables.sortCondition=@"INBOX";
        
        SortingViewController * sort=[self.storyboard instantiateViewControllerWithIdentifier:@"sortID"];
        [self.navigationController pushViewController:sort animated:YES];
        
    }
    else if(titleButtonIndex==1 && leftIndex==5 && rightIndex==1 )
    {
        NSLog(@" due on - DSC");
        globalVariables.sortingValueId=@"sortDueDsc";
        globalVariables.sortAlert=@"sortDueDscAlert";
        globalVariables.sortCondition=@"INBOX";
        
        SortingViewController * sort=[self.storyboard instantiateViewControllerWithIdentifier:@"sortID"];
        [self.navigationController pushViewController:sort animated:YES];
        
        
    }
    else if (titleButtonIndex==1 && leftIndex==5 && rightIndex==2 )
    {
        
        NSLog(@"Exit Clicked ");
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

