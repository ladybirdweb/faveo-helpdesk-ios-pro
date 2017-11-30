 //
//  ClientDetailViewController.m
//  SideMEnuDemo
//
//  Created by Narendra on 08/09/16.
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

- (void)viewDidLoad {
    [super viewDidLoad];
    
   // self.title=@"Client Details";
    
    self.profileImageView.clipsToBounds = YES;
    self.profileImageView.layer.borderWidth=1.3f;
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
    _clientId=[NSString stringWithFormat:@"%@",globalVariables.iD];
    
    userDefaults=[NSUserDefaults standardUserDefaults];
    
    UIButton *edit =  [UIButton buttonWithType:UIButtonTypeCustom];
    [edit setImage:[UIImage imageNamed:@"pencileEdit"] forState:UIControlStateNormal];
    [edit addTarget:self action:@selector(NotificationBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [edit setFrame:CGRectMake(50, 6, 20, 20)];
    
    UIView *rightBarButtonItems = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 76, 32)];
    [rightBarButtonItems addSubview:edit];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarButtonItems];
   
    _testingLAbel.backgroundColor=[UIColor lightGrayColor];
    _testingLAbel.layer.cornerRadius=8;
    _testingLAbel.layer.masksToBounds=true;
    _testingLAbel.userInteractionEnabled=YES;
    
  //  NSString *str=[NSString stringWithFormat:@"%@",globalVariables.customerFromView];
    
//    if ([str isEqualToString:@"normalView"])
//    {
//
        NSString *email1= [NSString stringWithFormat:@"%@",globalVariables.emailInUserList];
        
        [Utils isEmpty:email1];
        
        if (![Utils isEmpty:email1])
        {
            
           _emailLabel.text= [NSString stringWithFormat:@"%@",email1];
        }
        else
        {
            _mobileLabel.text= @"Not Availabel";
        }
        
        NSString *fname= [NSString stringWithFormat:@"%@",globalVariables.First_name];
         NSString *lname= [NSString stringWithFormat:@"%@",globalVariables.Last_name];
        
        [Utils isEmpty:fname];
        [Utils isEmpty:lname];
        
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
          
        }
        else
        {
            _mobileLabel.text= @"Not Availabel";
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
            _phoneLabel.text= @"Not Availabel";
        }
        
        if (![Utils isEmpty:mobile1])
        {
            
            _mobileLabel.text= [NSString stringWithFormat:@"%@",mobile1];
        }
        else
        {
              _mobileLabel.text= @"Not Availabel";
        }
       
        
    
         [self setUserProfileimage:globalVariables.customerImage];
        
         NSString *isClientActive= [NSString stringWithFormat:@"%@",globalVariables.UserState];
        [Utils isEmpty:isClientActive];
        
        if (![Utils isEmpty:isClientActive]) {
            
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
   // }
    
    [_activityIndicatorObject startAnimating];
    [self reload];
    self.tableView.tableFooterView=[[UIView alloc] initWithFrame:CGRectZero];
    // Do any additional setup after loading the view.
}


-(void)reload{
    
    if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable)
    {
        [refresh endRefreshing];
        //connection unavailable
        [_activityIndicatorObject stopAnimating];
        //[RKDropdownAlert title:APP_NAME message:NO_INTERNET backgroundColor:[UIColor hx_colorWithHexRGBAString:FAILURE_COLOR] textColor:[UIColor whiteColor]];
        
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
        
        NSString *url=[NSString stringWithFormat:@"%@helpdesk/my-tickets-user?api_key=%@&ip=%@&token=%@&user_id=%@",[userDefaults objectForKey:@"companyURL"],API_KEY,IP,[userDefaults objectForKey:@"token"],_clientId];
        NSLog(@"URL is : %@",url);
        
 @try{
        MyWebservices *webservices=[MyWebservices sharedInstance];
        [webservices httpResponseGET:url parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
            
            if (error || [msg containsString:@"Error"]) {
                
                [refresh endRefreshing];
                
                [utils showAlertWithMessage:@"Error" sendViewController:self];
                NSLog(@"Thread-NO4-getClientTickets-Refresh-error == %@",error.localizedDescription);
                return ;
            }
            
            if ([msg isEqualToString:@"tokenRefreshed"]) {
                
                [self reload];
                NSLog(@"Thread--NO4-call-getClientTickets");
                return;
            }
            
            if (json) {
                // NSError *error;
                mutableArray=[[NSMutableArray alloc]initWithCapacity:10];
                NSLog(@"Thread-NO4--getClientTickets111--%@",json);
                
                NSString * str= [json objectForKey:@"error"];
                if([str isEqualToString:@"This is not a client"])
                {
                   
            
                  //   [utils showAlertWithMessage:@"This is not a Client" sendViewController:self];
                }
                
                mutableArray = [[json objectForKey:@"tickets"] copy];
                
                if ( [mutableArray count] == 0){
                    
                  //   [utils showAlertWithMessage:@"User have no Tickets" sendViewController:self];
                }
                
                NSDictionary *requester=[json objectForKey:@"requester"];
                
                requesterTempDict= [json objectForKey:@"requester"];
                
                //[requester objectForKey:@"company"];
             
//                if(( ![[json objectForKey:@"requester"] isEqual:[NSNull null]] ) )
//
//                { /////////
//
//                    if (( ![[requester objectForKey:@"email"] isEqual:[NSNull null]] )) {
//
//                         _emailID= [requester objectForKey:@"email"];
//                    }
//                    else
//                    {
//                         _emailID=NSLocalizedString(@"Not Available",nil);
//                    }
//
//                    if (( ![[requester objectForKey:@"active"] isEqual:[NSNull null]] )) {
//                        // _isClientActive=[requester objectForKey:@"active"];
//                         _isClientActive= [NSString stringWithFormat:@"%@",[requester objectForKey:@"active"]];
//
//                        if ([_isClientActive isEqualToString:@"1"]) {
//                            _isClientActive=@"ACTIVE";
//                        }else  _isClientActive=@"INACTIVE";
//                    }
//                    else
//                    {
//                        _isClientActive= NSLocalizedString(@"Not Available",nil);
//                    }
//
//                    if (( ![[requester objectForKey:@"first_name"] isEqual:[NSNull null]] )) {
//                        _clientName=[NSString stringWithFormat:@"%@ %@ ", [requester objectForKey:@"first_name"], [requester objectForKey:@"last_name"]];
//                    }
//                    else
//                    {
//                        _clientName=NSLocalizedString(@"Not Available",nil);
//                    }
//
//
//
//
//                    if (( ![[requester objectForKey:@"phone_number"] isEqual:[NSNull null]] ) && ![[requester objectForKey:@"phone_number"] isEqualToString:@""]) {
//
//                         _phone=[requester objectForKey:@"phone_number"];
//                    }else
//                    {
//                        _phone=NSLocalizedString(@"Not Available",nil);
//                    }
//
//                    if( ![[requester objectForKey:@"mobile"] isEqual:[NSNull null]] && ![[requester objectForKey:@"mobile"] isEqualToString:@""])
//                    {
//                        _mobileLabel=[requester objectForKey:@"mobile"];
//                    }
//                    else
//                    {
//                        _mobileLabel.text =NSLocalizedString(@"Not Available",nil);
//                    }
//
//
//
//
                     NSString *isDelete= [NSString stringWithFormat:@"%@",[requester objectForKey:@"is_delete"]];

                    [Utils isEmpty:isDelete];
                    if(![Utils isEmpty:isDelete])
                    {

                        if([isDelete isEqualToString:@"1"])
                        {
                            globalVariables.ActiveDeactiveStateOfUser1=@"deActive";
                        }

                        if([isDelete isEqualToString:@"0"])
                        {
                            globalVariables.ActiveDeactiveStateOfUser1=@"Active";
                        }
                    }
                    else
                    {
                        NSLog(@"is_delete parameter is empty");
                    }
//
//
//
//                    NSString *code1= [NSString stringWithFormat:@"%@",[requester objectForKey:@"country_code"]];
//
//                    [Utils isEmpty:code1];
//                    if(![Utils isEmpty:code1])
//                    {
//                        if([code1 isEqualToString:@"0"])
//                        {
//                            code2=@"";
//
//                        }
//                        else
//                        {
//                        code2=[NSString stringWithFormat:@"+%@",[requester objectForKey:@"country_code"]];
//                        }
//                    }
//                    else
//                    {
//                        code2=@"";
//                    }
//
//                   [requester objectForKey:@"profile_pic"];
//
//
//                } ///////
//
                
                dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_activityIndicatorObject stopAnimating];
                        [refresh endRefreshing];
                            //self.testingLAbel.text=self.isClientActive;
   //                         self.emailLabel.text=self.emailID;
    //                        self.clientNameLabel.text=self.clientName;
                           // self.phoneLabel.text=self.phone;
                        
                      //  self.phoneLabel.text=[NSString stringWithFormat:@"%@  %@",code2,self.phone];
                        
     //                    [self setUserProfileimage:[requester objectForKey:@"profile_pic"]];
                       // self.testingLAbel.text=self.isClientActive;
                        
//                        if ([_isClientActive isEqualToString:@"ACTIVE"])
//                        {
//                            self.testingLAbel.textColor=[UIColor whiteColor];
//                            self.testingLAbel.text=@"ACTIVE";
//                            
//                        }else
//                        {
//                    
//                            self.testingLAbel.textColor=[UIColor whiteColor];
//                            self.testingLAbel.text=@"INACTIVE";
//
//                        }
//                        
                        [self.tableView reloadData];
                    });
                });
            }
            
            [_activityIndicatorObject stopAnimating];
            NSLog(@"Thread-NO5-getClientTickets-closed");
            
        }];
 }@catch (NSException *exception)
        {
            // Print exception information
//            NSLog( @"NSException caught in reload method in Client ViewController\n" );
//            NSLog( @"Name: %@", exception.name);
//            NSLog( @"Reason: %@", exception.reason );
            return ;
        }
        @finally
        {
            // Cleanup, in both success and fail cases
          //  NSLog( @"In finally block");
            
        }

    }
}


#pragma mark - Table view data source

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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [mutableArray count];
}




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
        // Print exception information
//        NSLog( @"NSException caught in CellForRowAtIndexPath method in Client-Detail ViewController\n" );
//        NSLog( @"Name: %@", exception.name);
//        NSLog( @"Reason: %@", exception.reason );
        return cell;
    }
    @finally
    {
        // Cleanup, in both success and fail cases
      //  NSLog( @"In finally block");
        
    }

    return cell;
}

-(void)NotificationBtnPressed
{
    
    EditClientDetail *edit=[self.storyboard instantiateViewControllerWithIdentifier:@"editClientID"];
    
    [self.navigationController pushViewController:edit animated:YES];
    
    
}

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
    //    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    //    dispatch_async(queue, ^(void) {
    //
    //        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
    //
    //        UIImage* image = [[UIImage alloc] initWithData:imageData];
    //        if (image) {
    //            dispatch_async(dispatch_get_main_queue(), ^{
    //                self.profileImageView.image = image;
    //            });
    //        }
    //    });
    
    [self.profileImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl]
                             placeholderImage:[UIImage imageNamed:@"default_pic.png"]];
}

//- (void)addSubview:(UIView *)subView toView:(UIView*)parentView {
//    [parentView addSubview:subView];
//
//    NSDictionary * views = @{@"subView" : subView,};
//    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[subView]|"
//                                                                   options:0
//                                                                   metrics:0
//                                                                     views:views];
//    [parentView addConstraints:constraints];
//    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[subView]|"
//                                                          options:0
//                                                          metrics:0
//                                                            views:views];
//    [parentView addConstraints:constraints];
//}

//- (void)cycleFromViewController:(UIViewController*) oldViewController
//               toViewController:(UIViewController*) newViewController {
//    [oldViewController willMoveToParentViewController:nil];
//    [self addChildViewController:newViewController];
//    [self addSubview:newViewController.view toView:self.containerView];
//    newViewController.view.alpha = 0;
//    [newViewController.view layoutIfNeeded];
//
//    [UIView animateWithDuration:0.5
//                     animations:^{
//                         newViewController.view.alpha = 1;
//                         oldViewController.view.alpha = 0;
//                     }
//                     completion:^(BOOL finished) {
//                         [oldViewController.view removeFromSuperview];
//                         [oldViewController removeFromParentViewController];
//                         [newViewController didMoveToParentViewController:self];
//                     }];
//}

//- (IBAction)indexChanged:(id)sender {
//
//    if (self.segmentedControl.selectedSegmentIndex == 0) {
//        UIViewController *newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"OpenClient"];
//        newViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
//        [self cycleFromViewController:self.currentViewController toViewController:newViewController];
//        self.currentViewController = newViewController;
//        // self.testingLAbel.text = @"Open Ticket";
//    } else {
//        UIViewController *newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CloseClient"];
//        newViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
//        [self cycleFromViewController:self.currentViewController toViewController:newViewController];
//        self.currentViewController = newViewController;
//        //self.testingLAbel.text = @"Closed Ticket";
//    }
//
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
