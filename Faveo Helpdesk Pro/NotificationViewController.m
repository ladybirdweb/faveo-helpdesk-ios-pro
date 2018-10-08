//
//  NotificationViewController.m
//  Faveo Helpdesk Pro
//
//  Created on 14/07/17.
//  Copyright © 2017 Ladybird websolutions pvt ltd. All rights reserved.
//

#import "NotificationViewController.h"
#import "NotificationTableViewCell.h"
#import "Reachability.h"
#import "AppDelegate.h"
#import "AppConstanst.h"
#import "Utils.h"
#import "MyWebservices.h"
#import "GlobalVariables.h"
#import "HexColors.h"
#import "LoadingTableViewCell.h"
#import "TicketDetailViewController.h"
#import "ClientListViewController.h"
#import "ClientDetailViewController.h"
#import "RMessage.h"
#import "RMessageView.h"
#import "UIImageView+Letters.h"
#import "InboxViewController.h"
#import "TableViewAnimationKitHeaders.h"


@import FirebaseInstanceID;
@import FirebaseMessaging;



@interface NotificationViewController ()<RMessageProtocol>
{
    Utils *utils;
    UIRefreshControl *refresh;
    NSUserDefaults *userDefaults;
    GlobalVariables *globalVariables;
    NSString *notifyID;

}

@property (nonatomic, strong) NSMutableArray *mutableArray;
@property (nonatomic, strong) NSArray *indexPaths;
@property (nonatomic, assign) NSInteger totalPages;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) NSInteger totalTickets;
@property (nonatomic, strong) NSString *nextPageUrl;
@property (nonatomic, assign) NSInteger animationType;

@end

@implementation NotificationViewController

//This method is called after the view controller has loaded its view hierarchy into memory. This method is called regardless of whether the view hierarchy was loaded from a nib file or created programmatically in the loadView method.
- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"Naa-Inbox");

    NSString *refreshedToken = [[FIRInstanceID instanceID] token];
    NSLog(@"refreshed token  %@",refreshedToken);
    
    [self setTitle:NSLocalizedString(@"Notifications",nil)];
    [self addUIRefresh];
   
    _mutableArray=[[NSMutableArray alloc]init];
    
    utils=[[Utils alloc]init];
    globalVariables=[GlobalVariables sharedInstance];
    userDefaults=[NSUserDefaults standardUserDefaults];
  
    
    _animationType = 5;
    
    if([[userDefaults objectForKey:@"msgFromRefreshToken"] isEqualToString:@"Invalid credentials"])
    {
        NSString *msg=@"";
        [utils showAlertWithMessage:@"Access Denied.  Your credentials has been changed. Contact to Admin and try to login again." sendViewController:self];
        [self->userDefaults setObject:msg forKey:@"msgFromRefreshToken"];
        [[AppDelegate sharedAppdelegate] hideProgressView];
    }
    else if([[userDefaults objectForKey:@"msgFromRefreshToken"] isEqualToString:@"API disabled"])
    {   NSString *msg=@"";
        [utils showAlertWithMessage:@"API is disabled in web, please enable it from Admin panel." sendViewController:self];
        [self->userDefaults setObject:msg forKey:@"msgFromRefreshToken"];
        [[AppDelegate sharedAppdelegate] hideProgressView];
    }
    {
        [[AppDelegate sharedAppdelegate] showProgressViewWithText:NSLocalizedString(@"Please wait",nil)];
        [self reload];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)loadAnimation {
    
    [self.tableView reloadData];
    [self starAnimationWithTableView:self.tableView];
    
}
- (void)starAnimationWithTableView:(UITableView *)tableView {
    
    [TableViewAnimationKit showWithAnimationType:self.animationType tableView:tableView];
    
}

// This method calls an API for getting notifications list, it will returns an JSON which contains 10 records of notifications details.
-(void)reload
{
    if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable)
    {
        [refresh endRefreshing];
        //connection unavailable
        [[AppDelegate sharedAppdelegate] hideProgressView];
    
        if (self.navigationController.navigationBarHidden) {
            [self.navigationController setNavigationBarHidden:NO];
        }
        
        [RMessage showNotificationInViewController:self.navigationController
                                             title:NSLocalizedString(@"Error..!", nil)
                                          subtitle:NSLocalizedString(@"The internet connection seems to be down. Please check it.", nil)
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
        
        
        
        NSString *url= [NSString stringWithFormat:@"%@helpdesk/notifications?api_key=%@&user_id=%@&token=%@",[userDefaults objectForKey:@"companyURL"],API_KEY,[userDefaults objectForKey:@"user_id"],[userDefaults objectForKey:@"token"]];
        
    @try{
        MyWebservices *webservices=[MyWebservices sharedInstance];
        [webservices httpResponseGET:url parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
            
            
            
            if (error || [msg containsString:@"Error"]) {
                [self->refresh endRefreshing];
                [[AppDelegate sharedAppdelegate] hideProgressView];
                if (msg) {
                    if([msg isEqualToString:@"Error-402"])
                    {
                        NSLog(@"Message is : %@",msg);
                        [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Access denied - Either your role has been changed or your login credential has been changed."] sendViewController:self];
                    }
                    else if([msg isEqualToString:@"Error-403"] || [msg isEqualToString:@"403"])
                    {
                        NSLog(@"Message is : %@",msg);
                        [self->utils showAlertWithMessage:@"Access Denied. Either your credentials has been changed or You are not an Agent/Admin." sendViewController:self];
                    }
                    else if([msg isEqualToString:@"Error-403"])
                    {
                        NSLog(@"Message is : %@",msg);
                        [self->utils showAlertWithMessage:@"Access Denied. Either your credentials has been changed or You are not an Agent/Admin." sendViewController:self];
                    }
                    else if([msg isEqualToString:@"Error-404"])
                    {
                        NSLog(@"Message is : %@",msg);
                        [self->utils showAlertWithMessage:[NSString stringWithFormat:@"The requested URL was not found on this server."] sendViewController:self];
                    }
                    else if([msg isEqualToString:@"Error-500"] ||[msg isEqualToString:@"500"])
                    {
                        NSLog(@"Message is : %@",msg);
                        [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Internal Server Error.Something has gone wrong on the website's server."] sendViewController:self];
                    }
                    
                    else{
                        [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",msg] sendViewController:self];
                        NSLog(@"Thread-getNotificationViewController-error == %@",error.localizedDescription);
                    }
                    
                }else if(error)  {
                    [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",error.localizedDescription] sendViewController:self];
                    NSLog(@"Thread-NO4-getNotificationViewController-Refresh-error == %@",error.localizedDescription);
                     [[AppDelegate sharedAppdelegate] hideProgressView];
                }
                return ;
            }
            
            if ([msg isEqualToString:@"tokenRefreshed"]) {
                
                [self reload];
                NSLog(@"Thread--NO4-call-getNotificationViewController");
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
              //  NSLog(@"Thread-NO4--getInboxAPI--%@",json);
                self->_mutableArray = [json objectForKey:@"data"];
                
                self->_nextPageUrl =[json objectForKey:@"next_page_url"];
                self->_currentPage=[[json objectForKey:@"current_page"] integerValue];
                self->_totalTickets=[[json objectForKey:@"total"] integerValue];
                self->_totalPages=[[json objectForKey:@"last_page"] integerValue];
                
             //   NSLog(@"Thread-NO4.1getInbox-dic--%@", self->_mutableArray);
                
                dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [self.tableView reloadData];
                        [self loadAnimation];
                        [self->refresh endRefreshing];
                        [[AppDelegate sharedAppdelegate] hideProgressView];
                       
                    });
                });
                
            }
            NSLog(@"Thread-NO5-getNotificationViewController-closed");
            
        }];
    }@catch (NSException *exception)
        {
            [utils showAlertWithMessage:exception.name sendViewController:self];
            NSLog( @"Name: %@", exception.name);
            NSLog( @"Reason: %@", exception.reason );
             [[AppDelegate sharedAppdelegate] hideProgressView];
            return;
        }
        @finally
        {
            NSLog( @" I am in reload method in Notification ViewController" );
            
        }

    }

}

//This method returns the number of rows (table cells) in a specified section.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger numOfSections = 0;
    if ([_mutableArray count]==0)
    {
        UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, tableView.bounds.size.height)];
        noDataLabel.text             =  NSLocalizedString(@"Empty!!!",nil);
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
                                              subtitle:NSLocalizedString(@"All Caught Up...!)", nil)
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


// This method calls an API for getting next notifications details, it will returns an JSON which contains 10 records with notifications details.
-(void)loadMore{
    
    if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable)
    {
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
        
    @try{
        MyWebservices *webservices=[MyWebservices sharedInstance];
        [webservices getNextPageURL:_nextPageUrl callbackHandler:^(NSError *error,id json,NSString* msg) {
            
            if (error || [msg containsString:@"Error"]) {
                
                if (msg) {
                    
                    [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",msg] sendViewController:self];
                    
                }else if(error)  {
                    [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",error.localizedDescription] sendViewController:self];
                    NSLog(@"Thread-NO4-getNotificationViewController-Refresh-error == %@",error.localizedDescription);
                }
                return ;
            }
            
            if ([msg isEqualToString:@"tokenRefreshed"]) {
                
                [self loadMore];
                //NSLog(@"Thread--NO4-call-getInbox");
                return;
            }
            
            if (json) {
           //     NSLog(@"Thread-NO4--getNotifictionAPI--%@",json);
                
                self->_nextPageUrl =[json objectForKey:@"next_page_url"];
                self->_currentPage=[[json objectForKey:@"current_page"] integerValue];
                self->_totalTickets=[[json objectForKey:@"total"] integerValue];
                self->_totalPages=[[json objectForKey:@"last_page"] integerValue];
                
                
                self->_mutableArray= [self->_mutableArray mutableCopy];
                
                [self->_mutableArray addObjectsFromArray:[json objectForKey:@"data"]];
                
            
                dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [self.tableView reloadData];
                                            });
                });
                
            }
            NSLog(@"Thread-NO5-getNotifictionViewController-closed");
            
        }];
    }@catch (NSException *exception)
        {
            [utils showAlertWithMessage:exception.name sendViewController:self];
            NSLog( @"Name: %@", exception.name);
            NSLog( @"Reason: %@", exception.reason );
            return;
        }
        @finally
        {
            NSLog( @" I am in loadMore method in Notification ViewController" );
            
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
        
        
        
        NotificationTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"NotificationCellID"];
        
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"NotificationTableViewCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        
        }
        
        NSDictionary *finaldic=[_mutableArray objectAtIndex:indexPath.row];
     //   NSLog(@"Dict is : %@", finaldic);
        
    
@try{
    
    
    NSDictionary *profileDict= [finaldic objectForKey:@"requester"];
    
    NSString * seen=[NSString stringWithFormat:@"%i",1];
    
    NSString * str=[NSString stringWithFormat:@"%@",[finaldic objectForKey:@"seen"]];
    
    
    [Utils isEmpty:str];
    
    if  (![Utils isEmpty:str] && ![str isEqualToString:@""])
    {
        if([str isEqualToString:seen])
        {
            
            cell.viewMain.backgroundColor=[UIColor hx_colorWithHexRGBAString:@"#F2F2F2"];
        }else
        {
            cell.viewMain.backgroundColor=[UIColor clearColor];
            NSLog(@"I am in else condition..!");
        }
    }
    else
    {
        NSLog(@"I am in else condition..!");
    }
    
    
    // cell.msglbl.text=[finaldic objectForKey:@"message"];
    
    if ( ( ![[finaldic objectForKey:@"message"] isEqual:[NSNull null]] ) && ( [[finaldic objectForKey:@"message"] length] != 0 ) )
    {
        cell.msglbl.text=[finaldic objectForKey:@"message"];
    }
    else
    {
        cell.msglbl.text= NSLocalizedString(@"Not Available",nil);
    }
    
    
    // cell.timelbl.text=[utils getLocalDateTimeFromUTC:[finaldic objectForKey:@"created_utc"]];
    
    if ( ( ![[utils getLocalDateTimeFromUTC:[finaldic objectForKey:@"created_utc"]] isEqual:[NSNull null]] ) && ( [[utils getLocalDateTimeFromUTC:[finaldic objectForKey:@"created_utc"]] length] != 0 ) )
    {
        cell.timelbl.text=[utils getLocalDateTimeFromUTC:[finaldic objectForKey:@"created_utc"]];
    }
    else
    {
        cell.timelbl.text= NSLocalizedString(@"Not Available",nil);
    }
    
    
    //  NSDictionary *profileDict= [finaldic objectForKey:@"requester"];
    
    
    if(( ![[finaldic objectForKey:@"requester"] isEqual:[NSNull null]] ) )
    {
        // [cell setUserProfileimage:[profileDict objectForKey:@"profile_pic"]];
        
        // changed_by_user_name
        NSString *fname= [profileDict objectForKey:@"changed_by_first_name"];
        NSString *lname= [profileDict objectForKey:@"changed_by_last_name"];
        NSString *userName= [profileDict objectForKey:@"changed_by_user_name"];
        
        [Utils isEmpty:fname];
        [Utils isEmpty:lname];
        [Utils isEmpty:userName];
        
        if (![Utils isEmpty:fname] || ![Utils isEmpty:lname])
        {
            if(![Utils isEmpty:fname] && ![Utils isEmpty:lname])
            {
                cell.name.text= [NSString stringWithFormat:@"%@ %@",fname,lname];
            }
            else
            {
                cell.name.text= [NSString stringWithFormat:@"%@ %@",fname,lname];
            }
        }else if(![Utils isEmpty:userName])
        {
            cell.name.text= [profileDict objectForKey:@"changed_by_user_name"];
        }
        
        else
        {
            // cell.name.text=@"Not Availabel";
            cell.name.text= NSLocalizedString(@"Not Available",nil);
        }
        
        if([[profileDict objectForKey:@"profile_pic"] hasSuffix:@"system.png"] || [[profileDict objectForKey:@"profile_pic"] hasSuffix:@".jpg"] || [[profileDict objectForKey:@"profile_pic"] hasSuffix:@".jpeg"] || [[profileDict objectForKey:@"profile_pic"] hasSuffix:@".png"] )
        {
            [cell setUserProfileimage:[profileDict objectForKey:@"profile_pic"]];
        }
        else
        if(![Utils isEmpty:fname])
        {
            [cell.profilePicView setImageWithString:fname color:nil ];
        }
        else
        if(![Utils isEmpty:userName])
        {
            [cell.profilePicView setImageWithString:userName color:nil ];
        }
        else if( [Utils isEmpty:fname] && [Utils isEmpty:lname] && [Utils isEmpty:userName])//userName
        {
          // [cell setUserProfileimage:@"systemIcon.png"];
            cell.profilePicView.image=[UIImage imageNamed:@"systemIcon.png"];
        }
        
    }
    else{
        
        if([[finaldic objectForKey:@"by"] isEqualToString:@"System"])
        {
           // [cell setUserProfileimage:@"systemIcon.png"];
            cell.profilePicView.image=[UIImage imageNamed:@"systemIcon.png"];
            cell.name.text= NSLocalizedString(@"System",nil);//robot
        }
        else{
            
         [cell setUserProfileimage:@"default_pic.png"];
         cell.name.text= NSLocalizedString(@"Not Available",nil);
        }
    }
    
    
    
  }@catch (NSException *exception)
        {
            [utils showAlertWithMessage:exception.name sendViewController:self];
            NSLog( @"Name: %@", exception.name);
            NSLog( @"Reason: %@", exception.reason );
            
        }
        @finally
        {
            NSLog( @" I am in cellForROwAtINdexPAth method in Notification ViewController" );
            
        }
        
            //[[self.tableView didSelectRowAtIndexPath] ];
        
        return cell;
    }
}


// This method tells the delegate that the specified row is now selected.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
      NSDictionary *finaldic=[_mutableArray objectAtIndex:indexPath.row];
    NSLog(@"dict issssss : %@",finaldic);
    
         notifyID= [NSString stringWithFormat:@"%@",[finaldic objectForKey:@"id"]];
    
     NSDictionary *profileDict= [finaldic objectForKey:@"requester"];
    
    TicketDetailViewController *td=[self.storyboard instantiateViewControllerWithIdentifier:@"TicketDetailVCID"];
    
    ClientDetailViewController *clientDetail=[self.storyboard instantiateViewControllerWithIdentifier:@"ClientDetailVCID"];

@try{
    NSString *sen=[finaldic objectForKey:@"senario"];
    NSLog(@"Senario is : %@",sen);
    
    if([sen isEqualToString:@"tickets"])
    {
       
        globalVariables.iD= [finaldic objectForKey:@"row_id"];
        
        globalVariables.ticketStatusBool=@"notificationView";
        
        
        if(( ![[finaldic objectForKey:@"requester"] isEqual:[NSNull null]] ) )
        {
        globalVariables.First_name=  [profileDict objectForKey:@"changed_by_first_name"];
        globalVariables.Last_name= [profileDict objectForKey:@"changed_by_last_name"];
            globalVariables.Ticket_status=@"Open";

        
            
        [self.navigationController pushViewController:td animated:YES];
        }
        else
        {
            globalVariables.First_name= @"";
            globalVariables.Last_name=@"";
            globalVariables.Ticket_status=@"Open";
            
            [self.navigationController pushViewController:td animated:YES];
            
        }
    }
    else if ([sen isEqualToString:@"users"]){
    //globalVariables.userID
     //  globalVariables.iD=[profileDict objectForKey:@"id"];
        globalVariables.userID=[profileDict objectForKey:@"id"];
        globalVariables.First_name=  [profileDict objectForKey:@"changed_by_first_name"];
        globalVariables.Last_name= [profileDict objectForKey:@"changed_by_last_name"];
       
         globalVariables.customerImage= [profileDict objectForKey:@"profile_pic"];
         globalVariables.emailInUserList= [profileDict objectForKey:@"email"];
        globalVariables.mobileCode1=@"";
        globalVariables.phoneNumberInUserList=@"Not Available";
        globalVariables.userRole=@"";
        globalVariables.mobileNumberInUserList=@"";
        globalVariables.userNameInUserList=[profileDict objectForKey:@"changed_by_user_name"];
        [self.navigationController pushViewController:clientDetail animated:YES];
    }
    
}@catch (NSException *exception)
    {
        [utils showAlertWithMessage:exception.name sendViewController:self];
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    @finally
    {
        NSLog( @" I am in didSelectRowMethod method in Notification ViewController" );
        
    }
    
}


//This method is called before the view controller's view is about to be added to a view hierarchy and before any animations are configured for showing the view.
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
  //  [[self navigationController] setNavigationBarHidden:NO];
    
}

// This method used to show refresh behind the table view.
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



@end
