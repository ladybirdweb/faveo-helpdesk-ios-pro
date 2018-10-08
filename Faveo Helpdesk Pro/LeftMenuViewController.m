//
//  LeftMenuViewController.m
//  SideMEnuDemo
//
//  Created  on 17/08/16.
//  Copyright © 2016 Ladybird websolutions pvt ltd. All rights reserved.
//

#import "LeftMenuViewController.h"
#import "HexColors.h"
#import "AppConstanst.h"
#import "GlobalVariables.h"
#import "MyWebservices.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "RMessage.h"
#import "RMessageView.h"
#import "Reachability.h"
#import "Utils.h"
#import "AppDelegate.h"
#import "UIImageView+Letters.h"
#import "LoginViewController.h"

@import Firebase;

@interface LeftMenuViewController ()<RMessageProtocol>{
    NSUserDefaults *userDefaults;
    GlobalVariables *globalVariables;
    Utils *utils;
    UIRefreshControl *refresh;
}




@end

@implementation LeftMenuViewController

//following method provided by SlideMenuViewController to enable side-menu
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self.slideOutAnimationEnabled = YES;
    
    return [super initWithCoder:aDecoder];
}

//Following method is called after the view controller has loaded its view hierarchy into memory. This method is called regardless of whether the view hierarchy was loaded from a nib file or created programmatically in the loadView() method.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"Naaa-LeftMENU");
    
    [self addUIRefresh];
    
    
    utils=[[Utils alloc]init];
    globalVariables=[GlobalVariables sharedInstance];
    userDefaults=[NSUserDefaults standardUserDefaults];
    
    NSLog(@"device_token %@",[userDefaults objectForKey:@"deviceToken"]);
    
   
    [[AppDelegate sharedAppdelegate] showProgressViewWithText:NSLocalizedString(@"Getting Data",nil)];
   
    [self getDependencies];
    [self.tableView reloadData];
    [self update];

    
}




-(void)viewWillAppear:(BOOL)animated{
    [self.tableView reloadData];
    //[self.tableView reloadData]
}


-(void)update{

    
    [self getDependencies];
    userDefaults=[NSUserDefaults standardUserDefaults];
    globalVariables=[GlobalVariables sharedInstance];
    
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
    else if([[userDefaults objectForKey:@"msgFromRefreshToken"] isEqualToString:@"user"])
    {   NSString *msg=@"";
        [utils showAlertWithMessage:@"Your role has beed changed to user. Contact to your Admin and try to login again." sendViewController:self];
        [self->userDefaults setObject:msg forKey:@"msgFromRefreshToken"];
        [[AppDelegate sharedAppdelegate] hideProgressView];
    }
    else if([[userDefaults objectForKey:@"msgFromRefreshToken"] isEqualToString:@"Methon not allowed"] || [[userDefaults objectForKey:@"msgFromRefreshToken"] isEqualToString:@"urlchanged"])
    {   NSString *msg=@"";
        [utils showAlertWithMessage:@"Your HELPDESK URL or Your Login credentials were changed, contact to Admin and please log back in." sendViewController:self];
        [self->userDefaults setObject:msg forKey:@"msgFromRefreshToken"];
        [[AppDelegate sharedAppdelegate] hideProgressView];
    }
    
    NSLog(@"Role : %@",[userDefaults objectForKey:@"role"]);
    _user_role.text=[[userDefaults objectForKey:@"role"] uppercaseString];
    
    _user_nameLabel.text=[userDefaults objectForKey:@"profile_name"];
    _url_label.text=[userDefaults objectForKey:@"baseURL"];
    
    
    if([[userDefaults objectForKey:@"profile_pic"] hasSuffix:@".jpg"] || [[userDefaults objectForKey:@"profile_pic"] hasSuffix:@".jpeg"] || [[userDefaults objectForKey:@"profile_pic"] hasSuffix:@".png"] )
    {
        [_user_profileImage sd_setImageWithURL:[NSURL URLWithString:[userDefaults objectForKey:@"profile_pic"]]
                              placeholderImage:[UIImage imageNamed:@"default_pic.png"]];
    }else
    {
     //   NSString * name = [NSString];
        NSString * name = [NSString stringWithFormat:@"%@",[userDefaults objectForKey:@"profile_name"]];
        [_user_profileImage setImageWithString:[name substringToIndex:2] color:nil ];
    }
    


//    [_user_profileImage sd_setImageWithURL:[NSURL URLWithString:[userDefaults objectForKey:@"profile_pic"]]
//                          placeholderImage:[UIImage imageNamed:@"default_pic.png"]];
    _user_profileImage.layer.borderColor=[[UIColor hx_colorWithHexRGBAString:@"#0288D1"] CGColor];
    
    _user_profileImage.layer.cornerRadius = _user_profileImage.frame.size.height /2;
    _user_profileImage.layer.masksToBounds = YES;
    _user_profileImage.layer.borderWidth = 0;
    
    
    _view1.alpha=0.5;
    _view1.layer.cornerRadius = 20; // #A9BCF5 //  #bb99ff
    _view1.backgroundColor = [UIColor hx_colorWithHexRGBAString:@"#884dff"];
    
    _view2.alpha=0.5;
    _view2.layer.cornerRadius = 20;
    _view2.backgroundColor =  [UIColor hx_colorWithHexRGBAString:@"#884dff"];
    
    
    _view3.alpha=0.5;
    _view3.layer.cornerRadius = 20;
    _view3.backgroundColor =  [UIColor hx_colorWithHexRGBAString:@"#884dff"];
    
    
    _view4.alpha=0.5;
    _view4.layer.cornerRadius = 20;
    _view4.backgroundColor =[UIColor hx_colorWithHexRGBAString:@"#884dff"];
    
    _view5.alpha=0.5;
    _view5.layer.cornerRadius = 20;
    _view5.backgroundColor = [UIColor hx_colorWithHexRGBAString:@"#884dff"];
    
    
    NSInteger open =  [globalVariables.OpenCount integerValue];
    NSInteger closed = [globalVariables.ClosedCount integerValue];
    NSInteger trash = [globalVariables.DeletedCount integerValue];
    NSInteger unasigned = [globalVariables.UnassignedCount integerValue];
    NSInteger my_tickets = [globalVariables.MyticketsCount integerValue];
    
    NSLog(@"My tickets are : %ld",(long)my_tickets);
    
    if(open>99){
        _c1.text=@"99+";
    }else if(open<10){
        _c1.text=[NSString stringWithFormat:@"0%ld",(long)open];
    }
    else{
        _c1.text=@(open).stringValue; }
    
    if(closed>99){
        _c4.text=@"99+";
    }
    else if(closed<10){
        _c4.text=[NSString stringWithFormat:@"0%ld",(long)closed];
    }else{
        _c4.text=@(closed).stringValue; }
    
    if(trash>99){
        _c5.text=@"99+";
    }
    else if(trash<10){
        _c5.text=[NSString stringWithFormat:@"0%ld",(long)trash];
    }else
        _c5.text=@(trash).stringValue;
    
    if(unasigned>99){
        _c3.text=@"99+";
    }else if(unasigned<10){
        _c3.text=[NSString stringWithFormat:@"0%ld",(long)unasigned];
    }
    else
        _c3.text=@(unasigned).stringValue;
    
    if(my_tickets>99){
        _c2.text=@"99+";
    }
    else if(my_tickets<10){
        _c2.text=[NSString stringWithFormat:@"0%ld",(long)my_tickets];
    }
    else
        _c2.text=@(my_tickets).stringValue;
    
    [self.tableView reloadData];
     [[AppDelegate sharedAppdelegate] hideProgressView];
    
}


-(void)getDependencies{
    

     [[AppDelegate sharedAppdelegate] hideProgressView];
    
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
              //  NSLog(@"Thread-NO3-getDependencies-start-error-%@-json-%@-msg-%@",error,json,msg);
               
                if (error || [msg containsString:@"Error"]) {
                    
                    if([msg isEqualToString:@"Error-401"])
                    {
                        NSLog(@"Message is : %@",msg);
                        [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Access Denied.  Your credentials has been changed. Contact to Admin and try to login again."] sendViewController:self];
                    }
                    else
                        
                    if( [msg containsString:@"Error-429"])
                        
                    {
                        [self->utils showAlertWithMessage:[NSString stringWithFormat:@"your request counts exceed our limit"] sendViewController:self];
                        
                    }
                    if( [msg containsString:@"Error-403"])
                        
                    {
                        [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Access Denied.  Your credentials/Role has been changed. Contact to Admin and try to login again."] sendViewController:self];
                        
                    }
                    else if([msg isEqualToString:@"Error-404"])
                    {
                        NSLog(@"Message is : %@",msg);
                        [self->utils showAlertWithMessage:[NSString stringWithFormat:@"The requested URL was not found on this server."] sendViewController:self];
                    }
                    
                    else{
                        
                        NSLog(@"Message Error in Left-Menu View : %@",msg); //Error-403
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
                
                if ([msg isEqualToString:@"tokenNotRefreshed"]) {
                    
                    [self showMessageForLogout:@"Your HELPDESK URL or Your Login credentials were changed, contact to Admin and please log back in." sendViewController:self];
                    
                    [[AppDelegate sharedAppdelegate] hideProgressView];
                    
                    return;
                }
                
                if (json) {
                    
                    [[AppDelegate sharedAppdelegate] hideProgressView];
                    
                    //    NSLog(@"Thread-NO4-getDependencies-dependencyAPI--%@",json);
                    NSDictionary *resultDic = [json objectForKey:@"data"];
                    
                     self->globalVariables.dependencyDataDict=[json objectForKey:@"data"];
                    
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
                    
                    NSArray *ticketStatusArray=[resultDic objectForKey:@"status"];
                    
                    for (int i = 0; i < ticketStatusArray.count; i++) {
                        NSString *statusName = [[ticketStatusArray objectAtIndex:i]objectForKey:@"name"];
                        NSString *statusId = [[ticketStatusArray objectAtIndex:i]objectForKey:@"id"];
                        
                        if ([statusName isEqualToString:@"Open"]) {
                            self->globalVariables.OpenStausId=statusId;
                            self->globalVariables.OpenStausLabel=statusName;
                        }else if ([statusName isEqualToString:@"Resolved"]) {
                            self->globalVariables.ResolvedStausId=statusId;
                           self-> globalVariables.ResolvedStausLabel=statusName;
                        }else if ([statusName isEqualToString:@"Closed"]) {
                            self->globalVariables.ClosedStausId=statusId;
                            self->globalVariables.ClosedStausLabel=statusName;
                        }else if ([statusName isEqualToString:@"Deleted"]) {
                           self-> globalVariables.DeletedStausId=statusId;
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
            return;
        }
        @finally
        {
            NSLog( @" I am in getDependencies method in LeftMenu ViewController" );
            
        }
    }
    NSLog(@"Thread-NO2-getDependencies()-closed");
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    
    // UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    UIViewController *vc ;
    
    @try{
        switch (indexPath.row)
        {
            case 1:
                vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"CreateTicket"];
                break;
                
            case 2:
                [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
                break;
            case 3:
                vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"InboxID"];
                break;
            case 4:
                vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"MyTicketsID"];
                break;
            case 5:
                vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"UnassignedTicketsID"];
                break;
            case 6:
                vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"ClosedTicketsID"];
                break;
                
            case 7:
                vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"TrashTicketsID"];
                break;
                
            case 8:
                vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"ClientListID"];
                globalVariables.userFilterId=@"ALLUSERS";
                break;
                
            case 10:
                vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"HelpSectionHomePageId"];
                break;
                
            case 11:
                vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"AboutVCID"];
                break;
                
                
            case 12:
                
                [self wipeDataInLogout];
                
                if (self.navigationController.navigationBarHidden) {
                    [self.navigationController setNavigationBarHidden:NO];
                }
                
                [RMessage showNotificationInViewController:self.navigationController
                                                     title:NSLocalizedString(@" Faveo Helpdesk ", nil)
                                                  subtitle:NSLocalizedString(@"You've logged out, successfully...!", nil)
                                                 iconImage:nil
                                                      type:RMessageTypeSuccess
                                            customTypeName:nil
                                                  duration:RMessageDurationAutomatic
                                                  callback:nil
                                               buttonTitle:nil
                                            buttonCallback:nil
                                                atPosition:RMessagePositionNavBarOverlay
                                      canBeDismissedByUser:YES];
                
            
                vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"Login"];
                // (vc.view.window!.rootViewController?).dismissViewControllerAnimated(false, completion: nil);
                break;
            
            default:
                break;
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
        NSLog( @" I am in did-deselect method in Leftmenu ViewController" );
        
    }
    
    [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
                                                             withSlideOutAnimation:self.slideOutAnimationEnabled
                                                                     andCompletion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 9) {
        return 0;
    } else {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    
}

-(void)wipeDataInLogout{
    
    [self sendDeviceToken];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:[[NSBundle mainBundle] bundleIdentifier]];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    // get documents path
    NSString *documentsPath = [paths objectAtIndex:0];
    // get the path to our Data/plist file
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"faveoData.plist"];
    NSError *error;
    @try{
        if(![[NSFileManager defaultManager] removeItemAtPath:plistPath error:&error])
        {
            NSLog(@"Error while removing the plist %@", error.localizedDescription);
            //TODO: Handle/Log error
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
        NSLog( @" I am in LogOut method in Leftmenu ViewController" );
        
    }
    
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *each in cookieStorage.cookies) {
        [cookieStorage deleteCookie:each];
    }
    
}

-(void)sendDeviceToken{
    
    // NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSString *url=[NSString stringWithFormat:@"%@fcmtoken?user_id=%@&fcm_token=%s&os=%@",[userDefaults objectForKey:@"companyURL"],[userDefaults objectForKey:@"user_id"],"0",@"ios"];
    @try{
        MyWebservices *webservices=[MyWebservices sharedInstance];
        [webservices httpResponsePOST:url parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg){
            if (error || [msg containsString:@"Error"]) {
                if (msg) {
                
                    NSLog(@"Thread-postAPNS-toserver-error == %@",error.localizedDescription);
                }else if(error)  {

                    NSLog(@"Thread-postAPNS-toserver-error == %@",error.localizedDescription);
                }
                return ;
            }
            if (json) {
                
                NSLog(@"Thread-sendAPNS-token-json-%@",json);
                 [[AppDelegate sharedAppdelegate] hideProgressView];
            }
            
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
        NSLog( @" I am in sendDeveiceToken method in Leftmenu ViewController" );
        
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    // first 3 rows in any section should not be selectable
    if ( (indexPath.row ==0) || (indexPath.row==2) ) return nil;
    
    // By default, allow row to be selected
    return indexPath;
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
    [self.tableView insertSubview:refresh atIndex:0];
    
}

-(void)reloadd{
    //[self getDependencies];
    [self update];
    [self.tableView reloadData];
    
    [refresh endRefreshing];
     [[AppDelegate sharedAppdelegate] hideProgressView];
}


-(void)showMessageForLogout:(NSString*)message sendViewController:(UIViewController *)viewController
{
    UIAlertController *alertController = [UIAlertController   alertControllerWithTitle:APP_NAME message:message  preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction  actionWithTitle:@"Logout"
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction *action)
                                   {
                                    
                                       [self wipeDataInLogout];
                                       
                                       if (self.navigationController.navigationBarHidden) {
                                           [self.navigationController setNavigationBarHidden:NO];
                                       }
                                       
                                       [RMessage showNotificationInViewController:self.navigationController
                                                                            title:NSLocalizedString(@" Faveo Helpdesk ", nil)
                                                                         subtitle:NSLocalizedString(@"You've logged out, successfully...!", nil)
                                                                        iconImage:nil
                                                                             type:RMessageTypeSuccess
                                                                   customTypeName:nil
                                                                         duration:RMessageDurationAutomatic
                                                                         callback:nil
                                                                      buttonTitle:nil
                                                                   buttonCallback:nil
                                                                       atPosition:RMessagePositionNavBarOverlay
                                                             canBeDismissedByUser:YES];
                                       
                                       UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                                                bundle: nil];
                                       UIViewController *vc ;
                                       
                                       vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"Login"];
                                       
                                       [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
                                                                                                withSlideOutAnimation:self.slideOutAnimationEnabled
                                                                                                        andCompletion:nil];
                                       
                                   }];
    [alertController addAction:cancelAction];
    
    [viewController presentViewController:alertController animated:YES completion:nil];
    
}



@end

