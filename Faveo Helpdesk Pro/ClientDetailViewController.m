 //
//  ClientDetailViewController.m
//  SideMEnuDemo
//
//  Created on 08/09/16.
//  Copyright © 2016 Ladybird websolutions pvt ltd. All rights reserved.
//

#import "ClientDetailViewController.h"
#import "HexColors.h"
#import "AppDelegate.h"
#import "Utils.h"
#import "Reachability.h"
#import "AppConstanst.h"
#import "MyWebservices.h"
#import "TicketDetailViewController.h"
#import "OpenCloseTableViewCell.h"
#import "GlobalVariables.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "RKDropdownAlert.h"
#import "RMessage.h"
#import "RMessageView.h"
#import "EditClientDetail.h"
#import "UIImageView+Letters.h"

@interface ClientDetailViewController ()<RMessageProtocol>
{
    Utils *utils;
    NSUserDefaults *userDefaults;
    NSMutableArray *mutableArray;
    UIRefreshControl *refresh;
    GlobalVariables *globalVariables;
    NSDictionary *requesterTempDict;
    NSString *code2;
    
}

@property (nonatomic,retain) UIActivityIndicatorView *activityIndicatorObject;
@property (nonatomic,strong) UILabel *noDataLabel;

@end

@implementation ClientDetailViewController

//This method is called after the view controller has loaded its view hierarchy into memory. This method is called regardless of whether the view hierarchy was loaded from a nib file or created programmatically in the loadView method.
- (void)viewDidLoad {
    [super viewDidLoad];
    
   // self.title=@"Client Details";
    
    self.profileImageView.clipsToBounds = YES;
  //  self.profileImageView.layer.borderWidth=1.3f;
    self.profileImageView.layer.borderColor=[[UIColor hx_colorWithHexRGBAString:@"#0288D1"] CGColor];
    //  self.profileImageView.layer.borderColor=[[UIColor blackColor] CGColor];
    
   // [self setUserProfileimage:_imageURL];
    
    _activityIndicatorObject = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activityIndicatorObject.center =CGPointMake(self.view.frame.size.width/2,(self.view.frame.size.height/2)-50);
    _activityIndicatorObject.color=[UIColor hx_colorWithHexRGBAString:@"#00aeef"];
    [self.view addSubview:_activityIndicatorObject];
    [self addUIRefresh];
    utils=[[Utils alloc]init];
    
    globalVariables=[GlobalVariables sharedInstance];
    _clientId=[NSString stringWithFormat:@"%@",globalVariables.userID];
    
    userDefaults=[NSUserDefaults standardUserDefaults];
    
    UIButton *edit =  [UIButton buttonWithType:UIButtonTypeCustom];
    [edit setImage:[UIImage imageNamed:@"pencileEdit"] forState:UIControlStateNormal];
    [edit addTarget:self action:@selector(EditClientProfileMethod) forControlEvents:UIControlEventTouchUpInside];
    
    [edit setFrame:CGRectMake(50, 6, 20, 20)];
    
    UIView *rightBarButtonItems = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 76, 32)];
    [rightBarButtonItems addSubview:edit];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarButtonItems];
   
    _testingLAbel.backgroundColor=[UIColor lightGrayColor];
    _testingLAbel.layer.cornerRadius=8;
    _testingLAbel.layer.masksToBounds=true;
    _testingLAbel.userInteractionEnabled=YES;
    
    _rolLabel.backgroundColor=[UIColor lightGrayColor];
    _rolLabel.layer.cornerRadius=8;
    _rolLabel.layer.masksToBounds=true;
    _rolLabel.userInteractionEnabled=YES;
    
  @try{
 
        NSString *email1= [NSString stringWithFormat:@"%@",globalVariables.emailInUserList];
        
        [Utils isEmpty:email1];
        
        if (![Utils isEmpty:email1])
        {
            
           _emailLabel.text= [NSString stringWithFormat:@"%@",email1];
        }
        else
        {
            _mobileLabel.text= @"Not Available";
        }
        
        NSString *fname= [NSString stringWithFormat:@"%@",globalVariables.First_name];
         NSString *lname= [NSString stringWithFormat:@"%@",globalVariables.Last_name];
     NSString *userName= [NSString stringWithFormat:@"%@",globalVariables.userNameInUserList];
        
        [Utils isEmpty:fname];
        [Utils isEmpty:lname];
        [Utils isEmpty:userName];
    
        
        if (![Utils isEmpty:fname] || ! [Utils isEmpty:lname] )
        {
            
            if (![Utils isEmpty:fname] && ! [Utils isEmpty:lname] )
            {
             _clientNameLabel.text= [NSString stringWithFormat:@"%@ %@",globalVariables.First_name,globalVariables.Last_name];
            }
            else  if (![Utils isEmpty:fname] || ! [Utils isEmpty:lname] )
            {
                _clientNameLabel.text= [NSString stringWithFormat:@"%@ %@",globalVariables.First_name,globalVariables.Last_name];
            }
          
        }else if(![Utils isEmpty:userName])
        
        {
             _clientNameLabel.text= [NSString stringWithFormat:@"%@",globalVariables.userNameInUserList];
        }
         else
         {
           _clientNameLabel.text= @"Not Available";
           
          }
       
        
        NSString *phone1= [NSString stringWithFormat:@"%@",globalVariables.phoneNumberInUserList];
        NSString *mobile1= [NSString stringWithFormat:@"%@", globalVariables.mobileNumberInUserList];
        NSString *code1= [NSString stringWithFormat:@"%@",globalVariables.mobileCode1];
      
        [Utils isEmpty:phone1];
        [Utils isEmpty:mobile1];
        [Utils isEmpty:code1];
        
       if (![Utils isEmpty:phone1])
       {
          if(![Utils isEmpty:phone1] && ![Utils isEmpty:code1])
          {
              _phoneLabel.text= [NSString stringWithFormat:@"+%@ %@",code1,phone1];
          }
           else
           {
               
               _phoneLabel.text= [NSString stringWithFormat:@"%@",phone1];
           }
       }else
        {
            _phoneLabel.text= @"Not Available";
        }
        
        if (![Utils isEmpty:mobile1])
        {
            
            _mobileLabel.text= [NSString stringWithFormat:@"%@",mobile1];
        }
        else
        {
              _mobileLabel.text= @"Not Available";
        }
      
      //Image view
      
          if([globalVariables.customerImage hasSuffix:@".jpg"] || [globalVariables.customerImage hasSuffix:@".jpeg"] || [globalVariables.customerImage hasSuffix:@".png"] )
          {
              [self setUserProfileimage:globalVariables.customerImage];
          }else if(![Utils isEmpty:fname])
          {
              // [cell.profilePicView setImageWithString:fname color:nil ];
              
              [_profileImageView setImageWithString:fname color:nil];
          }
         else
          {
               [_profileImageView setImageWithString:userName color:nil];
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
        NSLog( @" I am in viedDidLoad method in Client Detail ViewController" );
        
    }
    
    
    @try{
         NSString *role=[NSString stringWithFormat:@"%@",globalVariables.userRole];
    
        if (![Utils isEmpty:role]) {
         if([role isEqualToString:@"user"])
         {
              _rolLabel.textColor=[UIColor whiteColor];
             _rolLabel.text=@"USER";
         }else  if([role isEqualToString:@"agent"])
         {
             _rolLabel.textColor=[UIColor whiteColor];
             _rolLabel.text=@"AGENT";
         }
        }else
        {
            _rolLabel.hidden=YES;
        }
         NSString *isClientActive= [NSString stringWithFormat:@"%@",globalVariables.UserState];
         NSString *isClientDeactive= [NSString stringWithFormat:@"%@",globalVariables.ActiveDeactiveStateOfUser1];
        [Utils isEmpty:isClientActive];
         [Utils isEmpty:isClientDeactive];
        
        if(![Utils isEmpty:isClientDeactive])
        {
            if ([isClientDeactive isEqualToString:@"1"])
            {
                _testingLAbel.textColor=[UIColor whiteColor];
                _testingLAbel.text=@"DEACTIVE";
            }
            else if (![Utils isEmpty:isClientActive]) {
                
                if ([isClientActive isEqualToString:@"1"])
                {
                    _testingLAbel.textColor=[UIColor whiteColor];
                    _testingLAbel.text=@"ACTIVE";
                }else
                {
                    _testingLAbel.textColor=[UIColor whiteColor];
                    _testingLAbel.text=@"INACTIVE";
                }
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
        NSLog( @" I am in vidDidLoad method in ClinetDetail ViewController" );
        
    }
    
    
    self.tableView.tableFooterView=[[UIView alloc] initWithFrame:CGRectZero];
    
    [[AppDelegate sharedAppdelegate] showProgressView];
    [self reload];
    
}

//This method is called before the view controller's view is about to be added to a view hierarchy and before any animations are configured for showing the view.
-(void)viewWillAppear:(BOOL)animated
{
    globalVariables=[GlobalVariables sharedInstance];
    [self viewDidLoad];
}


// This method calls an API for getting user data, it will returns an JSON which contains 10 records with user details.
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

         [[AppDelegate sharedAppdelegate] hideProgressView];
        
    }else{
        
        NSString *url=[NSString stringWithFormat:@"%@helpdesk/my-tickets-user?api_key=%@&ip=%@&token=%@&user_id=%@",[userDefaults objectForKey:@"companyURL"],API_KEY,IP,[userDefaults objectForKey:@"token"],_clientId];
        NSLog(@"URL is : %@",url);
        
 @try{
        MyWebservices *webservices=[MyWebservices sharedInstance];
        [webservices httpResponseGET:url parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
            
           
            if (error || [msg containsString:@"Error"]) {
                
                 [[AppDelegate sharedAppdelegate] hideProgressView];
                [self->refresh endRefreshing];
                
                if([msg isEqualToString:@"Error-402"])
                {
                    NSLog(@"Message is : %@",msg);
                    [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Access denied - Either your role has been changed or your login credential has been changed."] sendViewController:self];
                }
                else if([msg isEqualToString:@"Error-500"] ||[msg isEqualToString:@"500"])
                {
                    NSLog(@"Message is : %@",msg);
                    [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Internal Server Error.Something has gone wrong on the website's server."] sendViewController:self];
                }
                else{
                    [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",msg] sendViewController:self];
                }
            }
            
            if ([msg isEqualToString:@"tokenRefreshed"]) {
                
                [self reload];
                NSLog(@"Thread--NO4-call-getClientTickets");
                return;
            }
            
            if (json) {
                
                self->mutableArray=[[NSMutableArray alloc]initWithCapacity:10];
                NSLog(@"Thread-NO4--getClientTickets111--%@",json);
                
                NSString * str= [json objectForKey:@"error"];
                if([str isEqualToString:@"This is not a client"])
                {
                   
            
                  //   [utils showAlertWithMessage:@"This is not a Client" sendViewController:self];
                }
                
                self->mutableArray = [[json objectForKey:@"tickets"] copy];
                
                if ( [self->mutableArray count] == 0){
                    
                  //   [utils showAlertWithMessage:@"User have no Tickets" sendViewController:self];
                }
                
                NSDictionary *requester=[json objectForKey:@"requester"];
                
                self->requesterTempDict= [json objectForKey:@"requester"];
                

                     NSString *isDelete= [NSString stringWithFormat:@"%@",[requester objectForKey:@"is_delete"]];

                    [Utils isEmpty:isDelete];
                    if(![Utils isEmpty:isDelete])
                    {

                        if([isDelete isEqualToString:@"1"])
                        {
                            self->globalVariables.ActiveDeactiveStateOfUser1=@"deActive";
                        }

                        if([isDelete isEqualToString:@"0"])
                        {
                            self->globalVariables.ActiveDeactiveStateOfUser1=@"Active";
                        }
                    }
                    else
                    {
                        NSLog(@"is_delete parameter is empty");
                    }
//
//

                
                dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [self.tableView reloadData];
                        [self->refresh endRefreshing];
                        [[AppDelegate sharedAppdelegate] hideProgressView];
                        
                    });
                });
            }
            
           [[AppDelegate sharedAppdelegate] hideProgressView];
            NSLog(@"Thread-NO5-getClientTickets-closed");
            
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
            NSLog( @" I am in reload method in ClinetDetail ViewController" );
            
        }

    }
}


#pragma mark - Table view data source

//This method returns the number of rows (table cells) in a specified section.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger numOfSections = 0;
    
    if ([mutableArray count]==0)
    {
        self.noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, tableView.bounds.size.height)];
      //  self.noDataLabel.text             =  @"User is Inactive or Deactivated.";
        self.noDataLabel.text             =  @"";
        
        self.noDataLabel.textColor        = [UIColor blackColor];
        self.noDataLabel.textAlignment    = NSTextAlignmentCenter;
        tableView.backgroundView = self.noDataLabel;
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
//This method tells the delegate the table view is about to draw a cell for a particular row
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
}

//This method asks the data source to return the number of sections in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [mutableArray count];
}



// This method asks the data source for a cell to insert in a particular location of the table view.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    OpenCloseTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"OpenCloseTableViewID"];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"OpenCloseTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
 
    NSDictionary *finaldic=[mutableArray objectAtIndex:indexPath.row];
    
    NSLog(@"Dictionary is : %@",finaldic);
    
 
@try{
    // cell.ticketNumberLbl.text=[finaldic objectForKey:@"ticket_number"];
    
    if ( ( ![[finaldic objectForKey:@"ticket_number"] isEqual:[NSNull null]] ) && ( [[finaldic objectForKey:@"ticket_number"] length] != 0 ) )
    {
        cell.ticketNumberLbl.text=[finaldic objectForKey:@"ticket_number"];
    }
    else
    {
         cell.ticketNumberLbl.text= NSLocalizedString(@"Not Available",nil);
    }
    
   // cell.ticketSubLbl.text=[finaldic objectForKey:@"title"];
    
    if ( ( ![[finaldic objectForKey:@"title"] isEqual:[NSNull null]] ) && ( [[finaldic objectForKey:@"title"] length] != 0 ) )
    {
        cell.ticketSubLbl.text=[finaldic objectForKey:@"title"];
    }
    else
    {
        cell.ticketSubLbl.text= NSLocalizedString(@"Not Available",nil);
    }
    
 
    if ([[finaldic objectForKey:@"ticket_status_name"] isEqualToString:@"Open"]) {
        cell.indicationView.layer.backgroundColor=[[UIColor hx_colorWithHexRGBAString:SUCCESS_COLOR] CGColor];
    }else{
        cell.indicationView.layer.backgroundColor=[[UIColor hx_colorWithHexRGBAString:FAILURE_COLOR] CGColor];
        
    }
}@catch (NSException *exception)
    {
        
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        [utils showAlertWithMessage:exception.name sendViewController:self];
       // return;
    }
    @finally
    {
        NSLog( @" I am in CellForAtIndexPath method in CLinetDetail ViewController" );
        
    }

    return cell;
}

// After clicking on edit button, it will naviagte to edit user details page
-(void)EditClientProfileMethod
{
    
    EditClientDetail *edit=[self.storyboard instantiateViewControllerWithIdentifier:@"editClientID"];
    
    [self.navigationController pushViewController:edit animated:YES];
    
    
}

// This method tells the delegate that the specified row is now deselected.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TicketDetailViewController *td=[self.storyboard instantiateViewControllerWithIdentifier:@"TicketDetailVCID"];
    NSDictionary *finaldic=[mutableArray objectAtIndex:indexPath.row];
    
 
    
    globalVariables.iD=[finaldic objectForKey:@"id"];
    globalVariables.ticket_number=[finaldic objectForKey:@"ticket_number"];
    
    //globalVariables.title=[finaldic objectForKey:@"title"];  // ticket_status_name  // Ticket_status
    
    globalVariables.Ticket_status= [finaldic objectForKey:@"ticket_status_name"];
    
       //requesterTempDict
    globalVariables.First_name= [requesterTempDict objectForKey:@"first_name"];
    globalVariables.Last_name= [requesterTempDict objectForKey:@"last_name"];
    
    
    [self.navigationController pushViewController:td animated:YES];
    
}

// This method used to show refresh behind the table view.
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
    //[refresh endRefreshing];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //TODO: Calculate cell height
    return 65.0f;
}

-(void)setUserProfileimage:(NSString*)imageUrl
{
    
    [self.profileImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl]
                             placeholderImage:[UIImage imageNamed:@"default_pic.png"]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
