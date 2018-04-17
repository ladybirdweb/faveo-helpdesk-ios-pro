//
//  TicketSearchViewController.m
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 09/03/18.
//  Copyright © 2018 Ladybird websolutions pvt ltd. All rights reserved.
//

#import "TicketSearchViewController.h"
#import "Utils.h"
#import "GlobalVariables.h"
#import "MyWebservices.h"
#import "AppDelegate.h"
#import "RKDropdownAlert.h"
#import "HexColors.h"
#import "RMessage.h"
#import "RMessageView.h"
#import "Reachability.h"
#import "LoadingTableViewCell.h"
#import "TicketTableViewCell.h"
#import "ClientListTableViewCell.h"
#import "userSearchDataCell.h"
#import "TicketDetailViewController.h"
#import "ClientDetailViewController.h"
#import "UIImageView+Letters.h"

@interface TicketSearchViewController ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>
{
    Utils *utils;
    UIRefreshControl *refresh;
    NSUserDefaults *userDefaults;
    GlobalVariables *globalVariables;
    NSDictionary *tempDict;
    NSString * dataFromSearchTextField;
    NSString * ticketidIs;
    
    
}

@property (nonatomic, strong) NSMutableArray *mutableArray;
@property (nonatomic, strong) NSArray *indexPaths;
@property (nonatomic, assign) NSInteger totalPages;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) NSInteger totalTickets; //
@property (nonatomic, strong) NSString *nextPageUrl;

@property (strong, nonatomic) NSMutableArray *sampleDataArray;
@property (strong, nonatomic) NSMutableArray *filteredSampleDataArray;

@property (strong, nonatomic) NSMutableArray *userDataArray;


@end

@implementation TicketSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    utils=[[Utils alloc]init];
    globalVariables=[GlobalVariables sharedInstance];
    userDefaults=[NSUserDefaults standardUserDefaults];
    
    _mutableArray=[[NSMutableArray alloc]init];
    _filteredSampleDataArray = [[NSMutableArray alloc] init];
    _userDataArray = [[NSMutableArray alloc] init];
    
    _tableview1.hidden=YES;
    _tableview2.hidden=YES;
    
    // [[AppDelegate sharedAppdelegate] showProgressViewWithText:NSLocalizedString(@"Getting Data",nil)];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    NSLog(@"Search String is : %@",_seachTextField.text);
    dataFromSearchTextField=[NSString stringWithFormat:@"%@",_seachTextField.text];
    
    
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_seachTextField resignFirstResponder];
    return YES;
}

- (IBAction)segmentedControlAction:(id)sender {
    if(_segmentedControlObject.selectedSegmentIndex==0)
    {
        _tableview1.hidden=NO;
        _tableview2.hidden=YES;
        
        
        NSLog(@"Ticket Search API Called.");
        [self ticketSearchApiCall:_seachTextField.text];
        [_seachTextField resignFirstResponder];
        [[AppDelegate sharedAppdelegate] showProgressViewWithText:NSLocalizedString(@"Getting Ticket Data",nil)];
    }
    else if(_segmentedControlObject.selectedSegmentIndex==1)
    {
        _tableview1.hidden=YES;
        _tableview2.hidden=NO;
        
        
        NSLog(@"User Search API Called.");
        [self userSearchApiCall:_seachTextField.text];
        [_seachTextField resignFirstResponder];
        [[AppDelegate sharedAppdelegate] showProgressViewWithText:NSLocalizedString(@"Getting User Data",nil)];
        
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [self.seachTextField becomeFirstResponder];
    
    
}

-(void)ticketSearchApiCall:(NSString *)searchText
{
    
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
    //a   NSString *numberOFRecord=@"100";
    // NSString * url= [NSString stringWithFormat:@"%@api/v1/helpdesk/ticket-search?token=%@&search=%@&records_per_page=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],searchText,numberOFRecord];
    
    // NSString *urlString = [searchText stringByReplacingOccurancesOfString:@" " withString:@"%20"];
    NSString *urlString=[searchText stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    NSString * url= [NSString stringWithFormat:@"%@api/v1/helpdesk/ticket-search?token=%@&search=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],urlString];
    NSLog(@"URL is : %@",url);
    
    
    MyWebservices *webservices=[MyWebservices sharedInstance];
    [webservices httpResponseGET:url parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
        
        
        
        if (error || [msg containsString:@"Error"]) {
            [self->refresh endRefreshing];
            [[AppDelegate sharedAppdelegate] hideProgressView];
            if (msg) {
                
                [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",msg] sendViewController:self];
                
            }else if(error)  {
                [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",error.localizedDescription] sendViewController:self];
                NSLog(@"Thread-Ticket-Search-Refresh-error == %@",error.localizedDescription);
            }
            return ;
        }
        
        if ([msg isEqualToString:@"tokenRefreshed"]) {
            
            [self ticketSearchApiCall:searchText];
            NSLog(@"Thread-Ticket-Search-call");
            return;
        }
        
        if (json) {
            //NSError *error;
            //   NSLog(@"Thread-Ticket-SearchAPI-Json-%@",json);
            
            self->_filteredSampleDataArray=[[NSMutableArray alloc]initWithCapacity:11];
            
            NSDictionary * dict1 = [json objectForKey:@"result"];
            
            self->_filteredSampleDataArray = [dict1 objectForKey:@"data"];
            
            //  NSLog(@"Mutable Array is--%@",_filteredSampleDataArray);
            
            
            self->_nextPageUrl =[dict1 objectForKey:@"next_page_url"];
            // NSLog(@"Next page url is : %@",_nextPageUrl);
            
            self->_path1=[dict1 objectForKey:@"path"];
            
            self->_currentPage=[[dict1 objectForKey:@"current_page"] integerValue];
            self->_totalTickets=[[dict1 objectForKey:@"total"] integerValue];
            self->_totalPages=[[dict1 objectForKey:@"last_page"] integerValue];
            
            
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[AppDelegate sharedAppdelegate] hideProgressView];
                    [self.tableview1 reloadData];
                    
                });
            });
            
        }
        
    }];
    
    
}

- (void)reloadTableView
{
    
    [self.tableview1 reloadData];
    [self.tableview2 reloadData];
    
}


-(void)userSearchApiCall:(NSString *)searchText
{
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
    
    NSString *urlString=[searchText stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    NSString * url= [NSString stringWithFormat:@"%@api/v1/helpdesk/ticket-search?token=%@&search=%@",[userDefaults objectForKey:@"baseURL"],[userDefaults objectForKey:@"token"],urlString];
    NSLog(@"URL is : %@",url);
    
    
    MyWebservices *webservices=[MyWebservices sharedInstance];
    [webservices httpResponseGET:url parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
        
        
        
        if (error || [msg containsString:@"Error"]) {
            [self->refresh endRefreshing];
            [[AppDelegate sharedAppdelegate] hideProgressView];
            if (msg) {
                
                [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",msg] sendViewController:self];
                
            }else if(error)  {
                [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",error.localizedDescription] sendViewController:self];
                NSLog(@"Thread-user-Search-Refresh-error == %@",error.localizedDescription);
            }
            return ;
        }
        
        if ([msg isEqualToString:@"tokenRefreshed"]) {
            
            [self userSearchApiCall:searchText];
            NSLog(@"Thread-user-Search-call");
            return;
        }
        
        if (json) {
            //NSError *error;
            NSLog(@"Thread-user-SearchAPI-Json-%@",json);
            
            
            self->_userDataArray=[[NSMutableArray alloc]initWithCapacity:11];
            
            NSDictionary * dict1 = [json objectForKey:@"result"];
            
            self->_userDataArray = [dict1 objectForKey:@"data"];
            
            //  NSLog(@"Mutable User Array is--%@",_userDataArray);
            
            
            self->_nextPageUrl =[dict1 objectForKey:@"next_page_url"];
            // NSLog(@"Next page url is : %@",_nextPageUrl);
            
            self->_path1=[dict1 objectForKey:@"path"];
            
            self->_currentPage=[[dict1 objectForKey:@"current_page"] integerValue];
            self->_totalTickets=[[dict1 objectForKey:@"total"] integerValue];
            self->_totalPages=[[dict1 objectForKey:@"last_page"] integerValue];
            
            
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[AppDelegate sharedAppdelegate] hideProgressView];
                    
                    [self.tableview2 reloadData];
                    //  [self.tableview1 reloadData];
                });
            });
            
        }
        NSLog(@"Thread-NO5-Search-closed");
        
    }];
    
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    if(tableView==_tableview1){
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
    
    NSInteger numOfSections = 0;
    if ([_userDataArray count]==0)
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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView==_tableview1){
        if (self.currentPage == self.totalPages
            || self.totalTickets == _filteredSampleDataArray.count) {
            return _filteredSampleDataArray.count;
        }
        
        return _filteredSampleDataArray.count + 1;
    }
    
    if(tableView==_tableview2){
        if (self.currentPage == self.totalPages
            || self.totalTickets == _userDataArray.count) {
            return _userDataArray.count;
        }
        
        return _userDataArray.count + 1;
    }
    
    else
        return 1;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(tableView==_tableview1){
        if (indexPath.row == [_filteredSampleDataArray count] - 1 ) {
            NSLog(@"nextURL111  %@",_nextPageUrl);
            
            if (( ![_nextPageUrl isEqual:[NSNull null]] ) && ( [_nextPageUrl length] != 0 )) {
                
                [self loadMoreforSearchResults];
                
                
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
    
        if (indexPath.row == [_userDataArray count] - 1 ) {
            NSLog(@"nextURL111  %@",_nextPageUrl);
    
            if (( ![_nextPageUrl isEqual:[NSNull null]] ) && ( [_nextPageUrl length] != 0 )) {
    
              [self loadMoreforSearchResults2];
    
    
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


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(tableView==_tableview1)
    {
        //
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
            
            @try{
                //user name deatils
                NSDictionary *searchDictionary=[_filteredSampleDataArray objectAtIndex:indexPath.row];
                //  NSLog(@"searchDictionary is : %@",searchDictionary);
                
                
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
                
                //Image view
                if([profilPic hasSuffix:@"system.png"] || [profilPic hasSuffix:@".jpg"] || [profilPic hasSuffix:@".jpeg"] || [profilPic hasSuffix:@".png"] )
                {
                    [cell setUserProfileimage:profilPic];
                }
                else if(![Utils isEmpty:fname])
                {
                    [cell.profilePicView setImageWithString:fname color:nil ];
                }
                else
                {
                    [cell.profilePicView setImageWithString:userName color:nil ];
                }
                
                
                //priority
                //   if(( ![[searchDictionary objectForKey:@"priority"] isEqual:[NSNull null]] ) )
                NSDictionary *priorityDict=[searchDictionary objectForKey:@"priority"];
                NSString * color=[priorityDict objectForKey:@"priority_color"];
                
                if(![Utils isEmpty:color])
                {
                    cell.indicationView.layer.backgroundColor=[[UIColor hx_colorWithHexRGBAString:color]CGColor];
                }
                else{
                    // cell.indicationView.layer.backgroundColor=[UIColor clea];
                    NSLog(@"I am in else condition");
                    
                }
                
                // ticket
                
                NSMutableArray * ticketThredArray= [searchDictionary objectForKey:@"thread"];
                //
                if(( ![[searchDictionary objectForKey:@"thread"] isEqual:[NSNull null]] ) )
                {
                    NSDictionary *ticketDict=[ticketThredArray objectAtIndex:0];
                    
                    NSLog(@"ticket dict 111111 is : %@",ticketDict);
                    NSLog(@"ticket dict 111111 is : %@",ticketDict);
                    
                    if(( ![[ticketDict objectForKey:@"ticket_id"] isEqual:[NSNull null]] ) )
                        
                    {
                        NSString * ticketidIs= [NSString stringWithFormat:@"%@",[ticketDict objectForKey:@"ticket_id"]];
                        NSLog(@"Ticket id is : %@",ticketidIs);
                        
                    }
                    
                    if(( ![[ticketDict objectForKey:@"title"] isEqual:[NSNull null]] ) )
                    {
                        NSString * ticketTitle= [NSString stringWithFormat:@"%@",[ticketDict objectForKey:@"title"]];
                        NSLog(@"Ticket Title is : %@",ticketTitle);
                        
                        
                        NSString *encodedString =[NSString stringWithFormat:@"%@",[ticketDict objectForKey:@"title"]];
                        
                        
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
                                
                                cell.ticketSubLabel.text= decodedString; //countthread
                                //   cell.ticketSubLabel.text= [NSString stringWithFormat:@"%@ (%@)",decodedString,[finaldic objectForKey:@"countthread"]];
                            }
                            else{
                                
                                cell.ticketSubLabel.text= encodedString;
                                //  cell.ticketSubLabel.text= [NSString stringWithFormat:@"%@ (%@)",encodedString,[finaldic objectForKey:@"countthread"]];
                                
                            }
                            
                        }
                        
                        
                        
                        //   cell.ticketSubLabel.text=ticketTitle;
                    }
                    
                }else
                {
                    cell.ticketSubLabel.text=@"No Title - EMPTY JSON ";
                    
                }//end ticket thread
                
                
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
                else{
                    NSLog(@"due date is empty");
                }
                
                
                // updated at
                
                if(( ![[searchDictionary objectForKey:@"updated_at"] isEqual:[NSNull null]] ) )
                {
                    NSString *str1=[searchDictionary objectForKey:@"updated_at"];
                    
                    cell.timeStampLabel.text=[utils getLocalDateTimeFromUTC:str1];
                }else{
                    cell.timeStampLabel.text=@"";
                    NSLog(@"updated date is empty");
                }
                
                
                //Agent info
                if(( ![[searchDictionary objectForKey:@"assigned"] isEqual:[NSNull null]] ) )
                    
                {
                    NSObject *obj=[searchDictionary objectForKey:@"assigned"];
                    if([obj isKindOfClass:[NSArray class]])
                    {
                        cell.agentLabel.text=@"Unassigned";
                    }else{
                        
                        NSDictionary *userDict=[searchDictionary objectForKey:@"assigned"];
                        NSString*firstName=[userDict objectForKey:@"first_name"];
                        NSString*laststName=[userDict objectForKey:@"last_name"];
                        NSString*userName=[userDict objectForKey:@"user_name"];
                        
                        [Utils isEmpty:firstName];
                        [Utils isEmpty:laststName];
                        [Utils isEmpty:userName];
                        
                        if(![Utils isEmpty:firstName] || ![Utils isEmpty:firstName])
                        {
                            if(![Utils isEmpty:firstName] && ![Utils isEmpty:firstName])
                            {
                                cell.agentLabel.text=[NSString stringWithFormat:@"%@ %@",firstName,laststName];
                            }else
                            {
                                cell.agentLabel.text=[NSString stringWithFormat:@"%@ %@",firstName,laststName];
                            }
                            
                        }
                        else if(![Utils isEmpty:userName])
                        {
                            cell.agentLabel.text=[NSString stringWithFormat:@"%@",userName];
                        }
                        else
                        {
                            cell.agentLabel.text=@"Unassigned";
                        }
                    }
                } //end userDict
            }@catch (NSException *exception)
            {
                NSLog( @"Name: %@", exception.name);
                NSLog( @"Reason: %@", exception.reason );
                [utils showAlertWithMessage:exception.name sendViewController:self];
                // return;
            }
            @finally
            {
                NSLog( @" I am in CellForRowAtIndexPath method for Ticket Search ViewController" );
                
            }
            
            return cell;
        }
        
    }
    //segmened 1  user
    userSearchDataCell *cell=[tableView dequeueReusableCellWithIdentifier:@"userSearchDataCellId"];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"userSearchDataCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    @try{
        //user name deatils
        NSDictionary *searchUserDictionary=[_userDataArray objectAtIndex:indexPath.row];
        // NSLog(@"userSearchDictionary is : %@",searchUserDictionary);
        
        
        // first name, last name, user name owner name
        NSDictionary * userDict= [searchUserDictionary objectForKey:@"user"];
        
        NSString *fname= [userDict objectForKey:@"first_name"];
        
        NSString *lname= [userDict objectForKey:@"last_name"];
        
        NSString*userName=[userDict objectForKey:@"user_name"];
        
        NSString*profilPic=[userDict objectForKey:@"profile_pic"];
        
        NSString*emailId=[userDict objectForKey:@"email"];
        
        
        [Utils isEmpty:fname]; //email
        [Utils isEmpty:lname];
        [Utils isEmpty:userName];
        [Utils isEmpty:profilPic];
        [Utils isEmpty:emailId];
        
        
        if  (![Utils isEmpty:fname] || ![Utils isEmpty:lname])
        {
            if (![Utils isEmpty:fname] && ![Utils isEmpty:lname])
            {   cell.userNameLabel.text=[NSString stringWithFormat:@"%@ %@",fname,lname];
            }
            else{
                cell.userNameLabel.text=[NSString stringWithFormat:@"%@ %@",fname,lname];
            }
        }
        else
        {
            if(![Utils isEmpty:userName])
            {
                cell.userNameLabel.text=userName;
            }
            else{
                cell.userNameLabel.text=NSLocalizedString(@"Not Available", nil);
            }
            
        }
        
        if(![Utils isEmpty:emailId])
        {
            
            cell.emalLabel.text=emailId;
        }
        else
        {
            cell.emalLabel.text=@"";
        }
        
        //Image view
        if([profilPic hasSuffix:@"system.png"] || [profilPic hasSuffix:@".jpg"] || [profilPic hasSuffix:@".jpeg"] || [profilPic hasSuffix:@".png"] )
        {
            [cell setUserProfileimage:profilPic];
        }
        else if(![Utils isEmpty:fname])
        {
            [cell.userProfileImage setImageWithString:fname color:nil ];
        }
        else
        {
            [cell.userProfileImage setImageWithString:userName color:nil ];
        }
        
        
    }@catch (NSException *exception)
    {
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        [utils showAlertWithMessage:exception.name sendViewController:self];
        //return;
    }
    @finally
    {
        NSLog( @" I am in CellForRowAtIndexPath method for User Search ViewController" );
        
    }
    return cell;
    
}

-(void)loadMoreforSearchResults
{
    
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
        
        self.page = _page + 1;
        // NSLog(@"Page is : %ld",(long)_page);
        
        NSString *str=_nextPageUrl;
        NSString *Page = [str substringFromIndex:[str length] - 1];
        
        //     NSLog(@"String is : %@",szResult);
        NSLog(@"Page is : %@",Page);
        NSLog(@"Page is : %@",Page);
        
        MyWebservices *webservices=[MyWebservices sharedInstance];
        
        NSString *searcText=[_seachTextField.text stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        [webservices getNextPageURLInboxSearchResults:_path1 searchString:searcText  pageNo:Page  callbackHandler:^(NSError *error,id json,NSString* msg) {
            
            if (error || [msg containsString:@"Error"]) {
                
                if (msg) {
                    
                    [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",msg] sendViewController:self];
                    
                }else if(error)  {
                    [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",error.localizedDescription] sendViewController:self];
                    NSLog(@"Thread-TicketSearch-Load-more-Refresh-error == %@",error.localizedDescription);
                }
                return ;
            }
            
            if ([msg isEqualToString:@"tokenRefreshed"]) {
                
                [self loadMoreforSearchResults];
                //NSLog(@"Thread--NO4-call-getInbox");
                return;
            }
            
            if (json) {
                NSLog(@"Thread-TicketSearch-Load-more-jSON--%@",json);
                
                NSDictionary * dict1 = [json objectForKey:@"result"];
                
                self->_nextPageUrl =[dict1 objectForKey:@"next_page_url"];
                self->_currentPage=[[dict1 objectForKey:@"current_page"] integerValue];
                self->_totalTickets=[[dict1 objectForKey:@"total"] integerValue];
                self->_totalPages=[[dict1 objectForKey:@"last_page"] integerValue];
                self->_path1=[dict1 objectForKey:@"path"];
                
                self->_filteredSampleDataArray= [self->_filteredSampleDataArray mutableCopy];
                [self->_filteredSampleDataArray addObjectsFromArray:[dict1 objectForKey:@"data"]];
                //   _filteredSampleDataArray = [dict1 objectForKey:@"data"];
                
                
                dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // [self.tableview reloadData];
                        //                        [self reloadTableView];
                        [self.tableview1 reloadData];
                        
                    });
                });
                
            }
            
            
        }];
        
    }
    
    
}

-(void)loadMoreforSearchResults2
{

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

        self.page = _page + 1;
        // NSLog(@"Page is : %ld",(long)_page);

        NSString *str=_nextPageUrl;
        NSString *Page = [str substringFromIndex:[str length] - 1];

        //     NSLog(@"String is : %@",szResult);
        NSLog(@"Page is : %@",Page);
        NSLog(@"Page is : %@",Page);

        MyWebservices *webservices=[MyWebservices sharedInstance];


        [webservices getNextPageURLInboxSearchResults:_path1 searchString:_seachTextField.text  pageNo:Page  callbackHandler:^(NSError *error,id json,NSString* msg) {

            if (error || [msg containsString:@"Error"]) {

                if (msg) {

                    [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",msg] sendViewController:self];

                }else if(error)  {
                    [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",error.localizedDescription] sendViewController:self];
                    NSLog(@"Thread-userSearch-Load-more-Refresh-error == %@",error.localizedDescription);
                }
                return ;
            }

            if ([msg isEqualToString:@"tokenRefreshed"]) {

                [self loadMoreforSearchResults2];
                //NSLog(@"Thread--NO4-call-getInbox");
                return;
            }

            if (json) {
              //  NSLog(@"Thread-TicketSearch-Load-more-jSON--%@",json);

                NSDictionary * dict1 = [json objectForKey:@"result"];

                self->_nextPageUrl =[dict1 objectForKey:@"next_page_url"];
                self->_currentPage=[[dict1 objectForKey:@"current_page"] integerValue];
                self->_totalTickets=[[dict1 objectForKey:@"total"] integerValue];
                self->_totalPages=[[dict1 objectForKey:@"last_page"] integerValue];
                self->_path1=[dict1 objectForKey:@"path"];


                self->_userDataArray= [self->_userDataArray mutableCopy];
                
                [self->_userDataArray addObjectsFromArray:[dict1 objectForKey:@"data"]];


                dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // [self.tableview reloadData];
                        //                        [self reloadTableView];
                        [self.tableview2 reloadData];

                    });
                });

            }


        }];

    }


}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(tableView==_tableview1)
    {
        
        NSDictionary *searchDictionary=[_filteredSampleDataArray objectAtIndex:indexPath.row];
        
        NSDictionary * statusValueDict=[searchDictionary objectForKey:@"statuses"];
        
        globalVariables.Ticket_status=[statusValueDict objectForKey:@"name"];
        
        NSMutableArray * ticketThredArray= [searchDictionary objectForKey:@"thread"];
        //
        if(( ![[searchDictionary objectForKey:@"thread"] isEqual:[NSNull null]] ) )
        {
            NSDictionary *ticketDict=[ticketThredArray objectAtIndex:0];
            
            if(( ![[ticketDict objectForKey:@"ticket_id"] isEqual:[NSNull null]] ) )
                
            {
                ticketidIs= [NSString stringWithFormat:@"%@",[ticketDict objectForKey:@"ticket_id"]];
                
                NSLog(@"Ticket id is : %@",ticketidIs);
                
            }
            
        }
        
        
        // first name, last name, user name owner name
        NSDictionary * userDict= [searchDictionary objectForKey:@"user"];
        
        NSString *fname= [userDict objectForKey:@"first_name"];
        
        NSString *lname= [userDict objectForKey:@"last_name"];
        
        NSString*userName=[userDict objectForKey:@"user_name"];
        
        
        
        [Utils isEmpty:fname];
        [Utils isEmpty:lname];
        [Utils isEmpty:userName];
        
        
        
        if  (![Utils isEmpty:fname] || ![Utils isEmpty:lname])
        {
            if (![Utils isEmpty:fname] && ![Utils isEmpty:lname])
            {    globalVariables.First_name=fname;
                globalVariables.Last_name=lname;
            }
            else if (![Utils isEmpty:fname]){
                globalVariables.First_name=[NSString stringWithFormat:@"%@",fname];
                globalVariables.Last_name=@"";
            }
        }
        else
        {
            if(![Utils isEmpty:userName])
            {
                globalVariables.First_name=userName;
                globalVariables.Last_name=@"";
            }
            else{
                globalVariables.First_name=NSLocalizedString(@"", nil);
                globalVariables.Last_name=@"";
            }
            
        }
        
        
        // ticket numbner
        NSString *ticketNumber=[searchDictionary objectForKey:@"ticket_number"];
        
        [Utils isEmpty:ticketNumber];
        if  (![Utils isEmpty:ticketNumber] && ![ticketNumber isEqualToString:@""])
        {
            globalVariables.ticket_number=ticketNumber;
        }
        else
        {
            globalVariables.ticket_number=NSLocalizedString(@"", nil);
        }
        
        
        
        globalVariables.iD=(NSNumber*)ticketidIs;
        
        TicketDetailViewController *td=[self.storyboard instantiateViewControllerWithIdentifier:@"TicketDetailVCID"];
        [self.navigationController pushViewController:td animated:YES];
        
    }
    else if(tableView==_tableview2)
    {
        
        //user name deatils
        NSDictionary *searchDictionary=[_userDataArray objectAtIndex:indexPath.row];
        NSLog(@"searchDictionary is : %@",searchDictionary);
        
        
        // first name, last name, user name owner name
        NSDictionary * userDict= [searchDictionary objectForKey:@"user"];
        
        NSString *fname= [userDict objectForKey:@"first_name"];
        
        NSString *lname= [userDict objectForKey:@"last_name"];
        
        NSString*userName=[userDict objectForKey:@"user_name"];
        
        NSString*profilPic=[userDict objectForKey:@"profile_pic"];
        
        NSString*userID1=[userDict objectForKey:@"id"];
        
        NSString*email=[userDict objectForKey:@"email"];
        
        [Utils isEmpty:fname];
        [Utils isEmpty:lname];
        [Utils isEmpty:userName];
        [Utils isEmpty:profilPic];
        
        if  (![Utils isEmpty:fname] || ![Utils isEmpty:lname])
        {
            if (![Utils isEmpty:fname] && ![Utils isEmpty:lname])
            {   globalVariables.First_name=fname;
                globalVariables.Last_name=lname;
            }
            else if (![Utils isEmpty:fname]){
                globalVariables.First_name=fname;
                globalVariables.Last_name=@"";
            }
        }
        else
        {
            if(![Utils isEmpty:userName])
            {
                globalVariables.First_name=userName;
                globalVariables.Last_name=@"";
            }
            else{
                globalVariables.First_name=@"";
                globalVariables.Last_name=@"";
            }
            
        }
        
        globalVariables.customerImage=profilPic;
        globalVariables.customerFromView=@"normalView";
        globalVariables.userRole=@"";
        globalVariables.userID=userID1;
        
        if (![Utils isEmpty:email])
        {
            globalVariables.emailInUserList=email;
        }
        else
        {
            globalVariables.emailInUserList=@"";
        }
        globalVariables.phoneNumberInUserList=@"";
        globalVariables.mobileNumberInUserList=@"";
        globalVariables.UserState=@"1";
        globalVariables.mobileCode1=@"";
        //
        ClientDetailViewController *td=[self.storyboard instantiateViewControllerWithIdentifier:@"ClientDetailVCID"];
        [self.navigationController pushViewController:td animated:YES];
        
        
        
        
    }
}

@end

