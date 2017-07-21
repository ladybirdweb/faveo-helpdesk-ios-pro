//
//  LeftMenuViewController.m
//  SideMEnuDemo
//
//  Created by Narendra on 17/08/16.
//  Copyright © 2016 Ladybird websolutions pvt ltd. All rights reserved.
//

#import "LeftMenuViewController.h"
#import "RKDropdownAlert.h"
#import "HexColors.h"
#import "AppConstanst.h"
#import "GlobalVariables.h"
#import "MyWebservices.h"
#import <SDWebImage/UIImageView+WebCache.h>
@import Firebase;
@interface LeftMenuViewController (){
    NSUserDefaults *userDefaults;
    GlobalVariables *globalVariables;
}
@end

@implementation LeftMenuViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self.slideOutAnimationEnabled = YES;
    
    return [super initWithCoder:aDecoder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"Naaa-LeftMENU");
    
    
    
   /* userDefaults=[NSUserDefaults standardUserDefaults];
    globalVariables=[GlobalVariables sharedInstance];
  //  NSLog(@"Role : %@",[userDefaults objectForKey:@"role"]);
    //_user_role.text=[[userDefaults objectForKey:@"role"] uppercaseString];
    
    _user_nameLabel.text=[userDefaults objectForKey:@"profile_name"];
   // _url_label.text=[userDefaults objectForKey:@"baseURL"];
    
    [_user_profileImage sd_setImageWithURL:[NSURL URLWithString:[userDefaults objectForKey:@"profile_pic"]]
                          placeholderImage:[UIImage imageNamed:@"default_pic.png"]];
    _user_profileImage.layer.borderColor=[[UIColor hx_colorWithHexRGBAString:@"#0288D1"] CGColor];
    
    _user_profileImage.layer.cornerRadius = _user_profileImage.frame.size.height /2;
    _user_profileImage.layer.masksToBounds = YES;
    _user_profileImage.layer.borderWidth = 0; */
    
    self.tableView.tableFooterView=[[UIView alloc] initWithFrame:CGRectZero];
    
    // Do any additional setup after loading the view from its nib.
       // Do any additional setup after loading the view from its nib.
}



-(void)viewWillAppear:(BOOL)animated{
    
    userDefaults=[NSUserDefaults standardUserDefaults];
    globalVariables=[GlobalVariables sharedInstance];
     NSLog(@"Role : %@",[userDefaults objectForKey:@"role"]);
    _user_role.text=[[userDefaults objectForKey:@"role"] uppercaseString];
    
    _user_nameLabel.text=[userDefaults objectForKey:@"profile_name"];
    _url_label.text=[userDefaults objectForKey:@"baseURL"];
    
    [_user_profileImage sd_setImageWithURL:[NSURL URLWithString:[userDefaults objectForKey:@"profile_pic"]]
                          placeholderImage:[UIImage imageNamed:@"default_pic.png"]];
    _user_profileImage.layer.borderColor=[[UIColor hx_colorWithHexRGBAString:@"#0288D1"] CGColor];
    
    _user_profileImage.layer.cornerRadius = _user_profileImage.frame.size.height /2;
    _user_profileImage.layer.masksToBounds = YES;
    _user_profileImage.layer.borderWidth = 0;
    
    
    
//    NSInteger open =  [globalVariables.OpenCount integerValue];
//    NSInteger closed = [globalVariables.ClosedCount integerValue];
//    NSInteger trash = [globalVariables.DeletedCount integerValue];
//    NSInteger unasigned = [globalVariables.UnassignedCount integerValue];
//    NSInteger my_tickets = [globalVariables.MyticketsCount integerValue];
//    
//    if(open>999){
//        _inbox_countLabel.text=@"999+";
//    }else
//        _inbox_countLabel.text=@(open).stringValue;
//    if(closed>999){
//        _closed_countLabel.text=@"999+";
//    }else
//        _closed_countLabel.text=@(closed).stringValue;
//    if(trash>999){
//        _trash_countLabel.text=@"999+";
//    }else
//        _trash_countLabel.text=@(trash).stringValue;
//    if(unasigned>999){
//        _unassigned_countLabel.text=@"999+";
//    }else
//        _unassigned_countLabel.text=@(unasigned).stringValue;
//    if(my_tickets>999){
//        _myTickets_countLabel.text=@"999+";
//    }else
//        _myTickets_countLabel.text=@(my_tickets).stringValue;
  [self.tableView reloadData];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    return 0;
//}
//
//// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
//// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return ;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    
    // UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    UIViewController *vc ;
    
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
            break;
            
        case 10:
            vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"AboutVCID"];
            break;
            
            
        case 11:
            
            [self wipeDataInLogout];
            //[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
            //[[SlideNavigationController sharedInstance] popToRootViewControllerAnimated:NO];
            
            [RKDropdownAlert title:@"Faveo Helpdesk" message:@"You've logged out, successfully." backgroundColor:[UIColor hx_colorWithHexRGBAString:SUCCESS_COLOR] textColor:[UIColor whiteColor]];
            vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"Login"];
            // (vc.view.window!.rootViewController?).dismissViewControllerAnimated(false, completion: nil);
            break;
            
            //        case 3:
            //            [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
            //            [[SlideNavigationController sharedInstance] popToRootViewControllerAnimated:YES];
            //            return;
            //            break;
            
        default:
            break;
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
    if(![[NSFileManager defaultManager] removeItemAtPath:plistPath error:&error])
    {
        NSLog(@"Error while removing the plist %@", error.localizedDescription);
        //TODO: Handle/Log error
    }
    
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *each in cookieStorage.cookies) {
        [cookieStorage deleteCookie:each];
    }
    
}

-(void)sendDeviceToken{

   // NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSString *url=[NSString stringWithFormat:@"%@fcmtoken?user_id=%@&fcm_token=%s&os=%@",[userDefaults objectForKey:@"companyURL"],[userDefaults objectForKey:@"user_id"],"0",@"ios"];
    MyWebservices *webservices=[MyWebservices sharedInstance];
    [webservices httpResponsePOST:url parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg){
        if (error || [msg containsString:@"Error"]) {
            if (msg) {
                
                // [utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",msg] sendViewController:self];
                NSLog(@"Thread-postAPNS-toserver-error == %@",error.localizedDescription);
            }else if(error)  {
                //                [utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",error.localizedDescription] sendViewController:self];
                NSLog(@"Thread-postAPNS-toserver-error == %@",error.localizedDescription);
            }
            return ;
        }
        if (json) {
            
            NSLog(@"Thread-sendAPNS-token-json-%@",json);
        }
        
    }];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // rows in section 0 should not be selectable
    // if ( indexPath.section == 0 ) return nil;
    
    // first 3 rows in any section should not be selectable
    if ( (indexPath.row ==0) || (indexPath.row==2) ) return nil;
    
    // By default, allow row to be selected
    return indexPath;
}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
//    [cell setUserInteractionEnabled:NO];
//
//    if (indexPath.section == 1 && indexPath.row == 2)
//    {
//        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
//        [cell setUserInteractionEnabled:YES];
//    }
//}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
