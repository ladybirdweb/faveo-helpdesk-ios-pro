//
//  ClientListViewController.m
//  SideMEnuDemo
//
//  Created by Narendra on 01/09/16.
//  Copyright © 2016 Ladybird websolutions pvt ltd. All rights reserved.
//

#import "ClientListViewController.h"
#import "ClientListTableViewCell.h"
#import "ClientDetailViewController.h"
#import "Utils.h"
#import "Reachability.h"
#import "AppConstanst.h"
#import "MyWebservices.h"
#import "AppDelegate.h"
#import "LoadingTableViewCell.h"
#import "RKDropdownAlert.h"
#import "HexColors.h"
#import "GlobalVariables.h"
#import "RMessage.h"
#import "RMessageView.h"


@interface ClientListViewController ()<RMessageProtocol>{

    Utils *utils;
    UIRefreshControl *refresh;
    NSUserDefaults *userDefaults;
GlobalVariables *globalVariables;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *mutableArray;
@property (nonatomic, assign) NSInteger totalPages;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) NSInteger totalTickets;
@property (nonatomic, strong) NSString *nextPageUrl;
@end

@implementation ClientListViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:NSLocalizedString(@"Client List",nil)];
    
    [self addUIRefresh];
    utils=[[Utils alloc]init];
    userDefaults=[NSUserDefaults standardUserDefaults];
    globalVariables=[GlobalVariables sharedInstance];
    [[AppDelegate sharedAppdelegate] showProgressViewWithText:NSLocalizedString(@"Getting Data",nil)];
    [self reload];

    // Do any additional setup after loading the view.
}


-(void)reload{
    
    if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable)
    { [refresh endRefreshing];
        //connection unavailable
        [[AppDelegate sharedAppdelegate] hideProgressView];
     //  [RKDropdownAlert title:APP_NAME message:NO_INTERNET backgroundColor:[UIColor hx_colorWithHexRGBAString:FAILURE_COLOR] textColor:[UIColor whiteColor]];
        
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
        
        //        [[AppDelegate sharedAppdelegate] showProgressView];
        NSString *url=[NSString stringWithFormat:@"%@helpdesk/customers-custom?api_key=%@&ip=%@&token=%@",[userDefaults objectForKey:@"companyURL"],API_KEY,IP,[userDefaults objectForKey:@"token"]];
        
        MyWebservices *webservices=[MyWebservices sharedInstance];
        [webservices httpResponseGET:url parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
            
            if (error || [msg containsString:@"Error"]) {
                [refresh endRefreshing];
                [[AppDelegate sharedAppdelegate] hideProgressView];
                
                if (msg) {
                    
                    [utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",msg] sendViewController:self];
                    
                }else if(error)  {
                    [utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",error.localizedDescription] sendViewController:self];
                    NSLog(@"Thread-NO4-getInbox-Refresh-error == %@",error.localizedDescription);
                }
                return ;
            }
            
            if ([msg isEqualToString:@"tokenRefreshed"]) {
                
                [self reload];
                NSLog(@"Thread--NO4-call-getClients");
                return;
            }
            
            if (json) {
                //NSError *error;
                _mutableArray=[[NSMutableArray alloc]initWithCapacity:11];
                NSLog(@"Thread-NO4--getClientsAPI--%@",json);
                _mutableArray = [json objectForKey:@"data"];
                _nextPageUrl =[json objectForKey:@"next_page_url"];
                _currentPage=[[json objectForKey:@"current_page"] integerValue];
                _totalTickets=[[json objectForKey:@"total"] integerValue];
                _totalPages=[[json objectForKey:@"last_page"] integerValue];
                dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [[AppDelegate sharedAppdelegate] hideProgressView];
                        [refresh endRefreshing];
                        [self.tableView reloadData];
                    });
                });
               
            }
            NSLog(@"Thread-NO5-getClients-closed");
            
        }];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
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

-(void)loadMore{
    
    if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable)
    {
        //connection unavailable
     // [RKDropdownAlert title:APP_NAME message:NO_INTERNET backgroundColor:[UIColor hx_colorWithHexRGBAString:FAILURE_COLOR] textColor:[UIColor whiteColor]];
        
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
        
        MyWebservices *webservices=[MyWebservices sharedInstance];
        [webservices getNextPageURL:_nextPageUrl callbackHandler:^(NSError *error,id json,NSString* msg) {
            
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


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.currentPage == self.totalPages
        || self.totalTickets == _mutableArray.count) {
        return _mutableArray.count;
    }
    return _mutableArray.count + 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger numOfSections = 0;
    if ([_mutableArray count]==0)
    {
        UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, tableView.bounds.size.height)];
        noDataLabel.text             =  NSLocalizedString(@"",nil);
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

    
    ClientListTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"ClientListCellID"];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ClientListTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    NSDictionary *finaldic=[_mutableArray objectAtIndex:indexPath.row];

   // NSString *email=[finaldic objectForKey:@"email"];
        
   /* NSString *phone=[finaldic objectForKey:@"phone_number"];
        if ([email isEqualToString:@""]) {
        email=NSLocalizedString(@"Not Available",nil);
    }
    if ([phone isEqualToString:@""]) {
        phone=NSLocalizedString(@"Not Available",nil);
    } */
        
        NSString *email=[finaldic objectForKey:@"email"];
        NSString *mobile=[finaldic objectForKey:@"mobile"];
        NSString *phone=[finaldic objectForKey:@"phone_number"];
        NSString *telephone=[finaldic objectForKey:@"telephone"];


        
      
        
        [Utils isEmpty:email];
        [Utils isEmpty:mobile];
        [Utils isEmpty:phone];
        [Utils isEmpty:telephone];
        
        if(![Utils isEmpty:email])
        {
            cell.emailIdLabel.text=email;
        }
        else{
            cell.emailIdLabel.text=NSLocalizedString(@"Not Available",nil);
        }
        
        
        if( ![Utils isEmpty:mobile])
        {
            cell.phoneNumberLabel.text=mobile;
        }
        else if(! [Utils isEmpty:phone])
        {
            cell.phoneNumberLabel.text=phone;
        }
        else if(![Utils isEmpty:telephone])
        {
             cell.phoneNumberLabel.text=telephone;
        }
        else
        {
            cell.phoneNumberLabel.text=NSLocalizedString(@"Not Available",nil);
        }
            
 
        NSString *clientFirstName=[finaldic objectForKey:@"first_name"];
        NSString *clientLastName=[finaldic objectForKey:@"last_name"];
        
        [Utils isEmpty:clientFirstName];
        [Utils isEmpty:clientLastName];
        
        if(![Utils isEmpty:clientFirstName] && ![Utils isEmpty:clientLastName])
        {
            cell.clientNameLabel.text=[NSString stringWithFormat:@"%@ %@",clientFirstName,clientLastName];
        }
        else if (![Utils isEmpty:clientFirstName] || ![Utils isEmpty:clientLastName])
        {
            cell.clientNameLabel.text=[NSString stringWithFormat:@"%@ %@",clientFirstName,clientLastName];
        }
        else
        {
            cell.clientNameLabel.text=NSLocalizedString(@"Not Available",nil);
        }
            
        
   // [cell setUserProfileimage:[finaldic objectForKey:@"profile_pic"]];
        
        if (  ![[finaldic objectForKey:@"profile_pic"] isEqual:[NSNull null]]   )
        {
            [cell setUserProfileimage:[finaldic objectForKey:@"profile_pic"]];
            
        }
        else
        {
            [cell setUserProfileimage:@"default_pic.png"];
        }
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *finaldic=[_mutableArray objectAtIndex:indexPath.row];
    NSString *client_id=[finaldic objectForKey:@"id"];
    
    ClientDetailViewController *td=[self.storyboard instantiateViewControllerWithIdentifier:@"ClientDetailVCID"];
    globalVariables.iD=@([client_id intValue]);
    globalVariables.First_name=[finaldic objectForKey:@"first_name"];
    globalVariables.Last_name=[finaldic objectForKey:@"last_name"];

//    td.clientName=[NSString stringWithFormat:@"%@ %@",clientName,[finaldic objectForKey:@"last_name"]];
    
    [self.navigationController pushViewController:td animated:YES];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - SlideNavigationController Methods -

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}



@end
