//
//  TicketDetailViewController.m
//  SideMEnuDemo
//
//  Created  on 07/09/16.
//  Copyright © 2016 Ladybird websolutions pvt ltd. All rights reserved.
//

#import "TicketDetailViewController.h"
#import "CNPPopupController.h"
#import "Utils.h"
#import "HexColors.h"
#import "AppDelegate.h"
#import "AppConstanst.h"
#import "Reachability.h"
#import "MyWebservices.h"
#import "GlobalVariables.h"
#import "RKDropdownAlert.h"
#import "RMessage.h"
#import "RMessageView.h" 
#import "NotificationViewController.h"
#import "FTPopOverMenu.h"
#import "InboxViewController.h"
#import "LGPlusButtonsView.h"
#import "ConversationViewController.h"
#import "EditDetailTableViewController.h"
#import "ReplyTicketViewController.h"
#import "InternalNoteViewController.h"
#import "LoginViewController.h"

//#import "ReplyViewController.h"

@interface TicketDetailViewController () <CNPPopupControllerDelegate,RMessageProtocol>{
    Utils *utils;
    NSUserDefaults *userDefaults;
    UITextField *textFieldCc;
    UITextView *textViewInternalNote;
    UITextView *textViewReply;
    UILabel *errorMessageReply;
     UILabel *errorMessageNote;
    GlobalVariables *globalVariables;
    
    
    NSArray *ticketStatusArray;
    
    
    NSMutableArray *statusArrayforChange;
    NSMutableArray *statusIdforChange;
    NSMutableArray *uniqueStatusNameArray;
    NSString *selectedStatusName;
    NSString *selectedStatusId;
}

//-(void)replyBtnPressed;
//-(void)internalNotePressed;
@property (nonatomic, strong) CNPPopupController *popupController;
@property (strong, nonatomic) LGPlusButtonsView *plusButtonsViewMain;


@end

@implementation TicketDetailViewController

//This method is called after the view controller has loaded its view hierarchy into memory. This method is called regardless of whether the view hierarchy was loaded from a nib file or created programmatically in the loadView method.
- (void)viewDidLoad {
     [super viewDidLoad];
    
    self.currentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ConversationVC"];
    self.currentViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addChildViewController:self.currentViewController];
    [self addSubview:self.currentViewController.view toView:self.containerView];
    utils=[[Utils alloc]init];
    
  //  self.view.translatesAutoresizingMaskIntoConstraints = NO;

    
    globalVariables=[GlobalVariables sharedInstance];
    
    userDefaults=[NSUserDefaults standardUserDefaults];
    
    statusArrayforChange = [[NSMutableArray alloc] init];
    statusIdforChange = [[NSMutableArray alloc] init];
    uniqueStatusNameArray = [[NSMutableArray alloc] init];
    
    self.segmentedControl.tintColor=[UIColor hx_colorWithHexRGBAString:@"#00aeef"];

        UIButton *editTicket =  [UIButton buttonWithType:UIButtonTypeCustom]; // editTicket
        [editTicket setImage:[UIImage imageNamed:@"pencileEdit"] forState:UIControlStateNormal];
        [editTicket addTarget:self action:@selector(editTicketTapped) forControlEvents:UIControlEventTouchUpInside];
       // [editTicket setFrame:CGRectMake(0, 0, 32, 32)];
    [editTicket setFrame:CGRectMake(10, 7, 20, 20)];
    
    UIButton *moreButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    [moreButton setImage:[UIImage imageNamed:@"verticle"] forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(onNavButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
    [moreButton setFrame:CGRectMake(44, 0, 32, 32)];
    
    UIView *rightBarButtonItems = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 76, 32)];
    [rightBarButtonItems addSubview:moreButton];
    [rightBarButtonItems addSubview:editTicket];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarButtonItems];

    
    NSLog(@"Ticket Id isssss : %@",globalVariables.iD);
    
    if([[userDefaults objectForKey:@"msgFromRefreshToken"] isEqualToString:@"Invalid credentials"])
    {
        NSString *msg=@"";
        [self showMessageForLogout:@"Access Denied.  Your credentials has been changed. Contact to Admin and try to login again." sendViewController:self];
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
       
        [self showMessageForLogout:@"Your role has beed changed to user. Contact to your Admin and try to login again." sendViewController:self];
        [self->userDefaults setObject:msg forKey:@"msgFromRefreshToken"];
        [[AppDelegate sharedAppdelegate] hideProgressView];
    }
    else if([[userDefaults objectForKey:@"msgFromRefreshToken"] isEqualToString:@"Methon not allowed"])
    {   NSString *msg=@"";
        [self showMessageForLogout:@"Your HELPDESK URL or Your Login credentials were changed, contact to Admin and please log back in." sendViewController:self];
        [self->userDefaults setObject:msg forKey:@"msgFromRefreshToken"];
        [[AppDelegate sharedAppdelegate] hideProgressView];
    }
    else{
    
   // [[AppDelegate sharedAppdelegate] showProgressViewWithText:NSLocalizedString(@"Getting data",nil)];
    [self getDependencies];
    }
    
}


//This method is called before the view controller's view is about to be added to a view hierarchy and before any animations are configured for showing the view.
-(void)viewWillAppear:(BOOL)animated
{
    
    globalVariables=[GlobalVariables sharedInstance];
    userDefaults=[NSUserDefaults standardUserDefaults];
    
    _ticketLabel.text=globalVariables.ticket_number;
    
    _nameLabel.text=[NSString stringWithFormat:@"%@ %@",globalVariables.First_name,globalVariables.Last_name];
    
    _statusLabel.text=globalVariables.Ticket_status;
    
    
    [super viewWillAppear:animated];
    
    [self floatingButton];
}


-(void)floatingButton
{
    
    _plusButtonsViewMain = [LGPlusButtonsView plusButtonsViewWithNumberOfButtons:3
                                                         firstButtonIsPlusButton:YES
                                                                   showAfterInit:YES
                                                                   actionHandler:^(LGPlusButtonsView *plusButtonView, NSString *title, NSString *description, NSUInteger index)
                            {
                                if(index==1)
                                {
                                    NSLog(@"One Index : Reply Pressed");
                                    
//                                    [self showPopupReply:CNPPopupStyleCentered];
                                   plusButtonView.hidden=YES;
                                    
                                    ReplyTicketViewController *reply=[self.storyboard instantiateViewControllerWithIdentifier:@"replayId"];
                                    [self.navigationController pushViewController:reply animated:YES];
                                    
                                }
                                if(index==2)
                                {
                                    NSLog(@"Two Index : Internal Pressed");
                                   // [self showPopupInternalNote:CNPPopupStyleCentered];
                                    plusButtonView.hidden=YES;
                            
                                    
                                    InternalNoteViewController * note=[self.storyboard instantiateViewControllerWithIdentifier:@"InternalNoteViewControllerId"];
                                    [self.navigationController pushViewController:note animated:YES];
                                }
                                
                                
                                
                            }];
    
    
    _plusButtonsViewMain.coverColor = [UIColor colorWithWhite:1.f alpha:0.7];
    // _plusButtonsViewMain.coverColor = [UIColor clearColor];
    _plusButtonsViewMain.position = LGPlusButtonsViewPositionBottomRight;
    _plusButtonsViewMain.plusButtonAnimationType = LGPlusButtonAnimationTypeRotate;
    
    [_plusButtonsViewMain setButtonsTitles:@[@"+", @"", @""] forState:UIControlStateNormal];
    [_plusButtonsViewMain setDescriptionsTexts:@[@"", NSLocalizedString(@"Ticket Reply", nil), NSLocalizedString(@"Internal Notes", nil)]];
    [_plusButtonsViewMain setButtonsImages:@[[NSNull new], [UIImage imageNamed:@"reply1"], [UIImage imageNamed:@"note3"]]
                                  forState:UIControlStateNormal
                            forOrientation:LGPlusButtonsViewOrientationAll];
    
    [_plusButtonsViewMain setButtonsAdjustsImageWhenHighlighted:NO];
   
    [_plusButtonsViewMain setButtonsBackgroundColor:[UIColor colorWithRed:0.f green:0.5 blue:1.f alpha:1.f] forState:UIControlStateNormal];
   [_plusButtonsViewMain setButtonsBackgroundColor:[UIColor colorWithRed:0.2 green:0.6 blue:1.f alpha:1.f] forState:UIControlStateHighlighted];
    [_plusButtonsViewMain setButtonsBackgroundColor:[UIColor colorWithRed:0.2 green:0.6 blue:1.f alpha:1.f] forState:UIControlStateHighlighted|UIControlStateSelected];
   
    [_plusButtonsViewMain setButtonsSize:CGSizeMake(44.f, 44.f) forOrientation:LGPlusButtonsViewOrientationAll];
    [_plusButtonsViewMain setButtonsLayerCornerRadius:44.f/2.f forOrientation:LGPlusButtonsViewOrientationAll];
    [_plusButtonsViewMain setButtonsTitleFont:[UIFont boldSystemFontOfSize:24.f] forOrientation:LGPlusButtonsViewOrientationAll];
    [_plusButtonsViewMain setButtonsLayerShadowColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.f]];
    [_plusButtonsViewMain setButtonsLayerShadowOpacity:0.5];
    [_plusButtonsViewMain setButtonsLayerShadowRadius:3.f];
    [_plusButtonsViewMain setButtonsLayerShadowOffset:CGSizeMake(0.f, 2.f)];
    
    [_plusButtonsViewMain setButtonAtIndex:0 size:CGSizeMake(56.f, 56.f)
                            forOrientation:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? LGPlusButtonsViewOrientationPortrait : LGPlusButtonsViewOrientationAll)];
    [_plusButtonsViewMain setButtonAtIndex:0 layerCornerRadius:56.f/2.f
                            forOrientation:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? LGPlusButtonsViewOrientationPortrait : LGPlusButtonsViewOrientationAll)];
    [_plusButtonsViewMain setButtonAtIndex:0 titleFont:[UIFont systemFontOfSize:40.f]
                            forOrientation:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? LGPlusButtonsViewOrientationPortrait : LGPlusButtonsViewOrientationAll)];
    [_plusButtonsViewMain setButtonAtIndex:0 titleOffset:CGPointMake(0.f, -3.f) forOrientation:LGPlusButtonsViewOrientationAll];
    
  //  [_plusButtonsViewMain setButtonAtIndex:1 backgroundColor:[UIColor colorWithRed:1.f green:0.f blue:0.5 alpha:1.f] forState:UIControlStateNormal];
    [_plusButtonsViewMain setButtonAtIndex:1 backgroundColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_plusButtonsViewMain setButtonAtIndex:1 backgroundColor:[UIColor colorWithRed:0.f green:0 blue:0 alpha:0.f] forState:UIControlStateHighlighted];
  //  [_plusButtonsViewMain setButtonAtIndex:2 backgroundColor:[UIColor colorWithRed:1.f green:0.5 blue:0.f alpha:1.f] forState:UIControlStateNormal];
    [_plusButtonsViewMain setButtonAtIndex:2 backgroundColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_plusButtonsViewMain setButtonAtIndex:2 backgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.f] forState:UIControlStateHighlighted];
   
    [_plusButtonsViewMain setDescriptionsBackgroundColor:[UIColor whiteColor]];
    [_plusButtonsViewMain setDescriptionsTextColor:[UIColor blackColor]];
    [_plusButtonsViewMain setDescriptionsLayerShadowColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.f]];
    [_plusButtonsViewMain setDescriptionsLayerShadowOpacity:0.25];
    [_plusButtonsViewMain setDescriptionsLayerShadowRadius:1.f];
    [_plusButtonsViewMain setDescriptionsLayerShadowOffset:CGSizeMake(0.f, 1.f)];
    [_plusButtonsViewMain setDescriptionsLayerCornerRadius:6.f forOrientation:LGPlusButtonsViewOrientationAll];
    [_plusButtonsViewMain setDescriptionsContentEdgeInsets:UIEdgeInsetsMake(4.f, 8.f, 4.f, 8.f) forOrientation:LGPlusButtonsViewOrientationAll];
    
    for (NSUInteger i=1; i<=2; i++)
        [_plusButtonsViewMain setButtonAtIndex:i offset:CGPointMake(-6.f, 0.f)
                                forOrientation:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? LGPlusButtonsViewOrientationPortrait : LGPlusButtonsViewOrientationAll)];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [_plusButtonsViewMain setButtonAtIndex:0 titleOffset:CGPointMake(0.f, -2.f) forOrientation:LGPlusButtonsViewOrientationLandscape];
        [_plusButtonsViewMain setButtonAtIndex:0 titleFont:[UIFont systemFontOfSize:32.f] forOrientation:LGPlusButtonsViewOrientationLandscape];
    }
    
    [self.view addSubview:_plusButtonsViewMain];
    
    
    

    
}
- (void)addSubview:(UIView *)subView toView:(UIView*)parentView {
    [parentView addSubview:subView];
    
    NSDictionary * views = @{@"subView" : subView,};
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[subView]|"
                                                                   options:0
                                                                   metrics:0
                                                                     views:views];
    [parentView addConstraints:constraints];
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[subView]|"
                                                          options:0
                                                          metrics:0
                                                            views:views];
    [parentView addConstraints:constraints];
}

- (void)cycleFromViewController:(UIViewController*) oldViewController
               toViewController:(UIViewController*) newViewController {
    [oldViewController willMoveToParentViewController:nil];
    [self addChildViewController:newViewController];
    [self addSubview:newViewController.view toView:self.containerView];
    newViewController.view.alpha = 0;
    [newViewController.view layoutIfNeeded];
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         newViewController.view.alpha = 1;
                         oldViewController.view.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [oldViewController.view removeFromSuperview];
                         [oldViewController removeFromParentViewController];
                         [newViewController didMoveToParentViewController:self];
                     }];
}

// This method used to get some values like Agents list, Ticket Status, Ticket counts, Ticket Source, SLA ..etc which are used in various places in project.
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
                    
                     [[AppDelegate sharedAppdelegate] hideProgressView];
                    
                    if( [msg containsString:@"Error-401"])
                        
                    {
                        [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Your Credential Has been changed"] sendViewController:self];
                       
                        
                    }
                    else
                        if( [msg containsString:@"Error-429"])
                            
                        {
                            [self->utils showAlertWithMessage:[NSString stringWithFormat:@"your request counts exceed our limit"] sendViewController:self];
                           
                            
                        }
                    
                        else if( [msg isEqualToString:@"Error-403"] && [self->globalVariables.roleFromAuthenticateAPI isEqualToString:@"user"])
                            
                        {
                            [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Access Denied.  Your credentials/Role has been changed. Contact to Admin and try to login again."] sendViewController:self];
                           
                            
                        }
                    
                        else if( [msg containsString:@"Error-403"])
                            
                        {
                            [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Access Denied.  Your credentials/Role has been changed. Contact to Admin and try to login again."] sendViewController:self];
                            
                            
                        }
                    
                        else if([msg isEqualToString:@"Error-404"])
                        {
                            NSLog(@"Message is : %@",msg);
                            [self->utils showAlertWithMessage:[NSString stringWithFormat:@"The requested URL was not found on this server."] sendViewController:self];
                            
                        }
                    
                    
                        else{
                            NSLog(@"Error message is %@",msg);
                            NSLog(@"Thread-NO4-getdependency-Refresh-error == %@",error.localizedDescription);
                            [self->utils showAlertWithMessage:msg sendViewController:self];
                           
                            
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
                    
                    NSLog(@"Thread-NO4-getDependencies-dependencyAPI--%@",json);
                    NSLog(@"Thread-NO4-getDependencies-dependencyAPI--%@",json);
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
            NSLog( @" I am in getDependencies method in ticket detail ViewController" );
           
            
        }
    }
    NSLog(@"Thread-NO2-getDependencies()-closed");
}


// This method used to show some popuop or list which contain some menus. Here it used to change the status of ticket, after clicking this button it will show one view which contains list of status. After clicking on any row, according to its name that status will be changed.
-(void)onNavButtonTapped:(UIBarButtonItem *)sender event:(UIEvent *)event
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
                               
                               if([self->selectedStatusName isEqualToString:self->globalVariables.Ticket_status])
                               {
                                   NSString * msg=[NSString stringWithFormat:@"Ticket is Already %@.",self->globalVariables.Ticket_status];
                                   [self->utils showAlertWithMessage:msg sendViewController:self];
                                   [[AppDelegate sharedAppdelegate] hideProgressView];
                               }
                        
                               else{
                                   [self askConfirmationForStatusChange];
                                 //  [self changeStatusMethod:self->selectedStatusName idIs:self->selectedStatusId];
                               }
                               
                           }
                        dismissBlock:^{
                            
                        }];
        
#endif
    
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
        
        [RKDropdownAlert title:APP_NAME message:NO_INTERNET backgroundColor:[UIColor hx_colorWithHexRGBAString:FAILURE_COLOR] textColor:[UIColor whiteColor]];
        
        
    }else{
        
        [[AppDelegate sharedAppdelegate] showProgressView];
        
    
            NSString *url= [NSString stringWithFormat:@"%@api/v2/helpdesk/status/change?api_key=%@&token=%@&ticket_id=%@&status_id=%@",[userDefaults objectForKey:@"baseURL"],API_KEY,[userDefaults objectForKey:@"token"],globalVariables.iD,idOfStatus];
            NSLog(@"URL is : %@",url);
            
            MyWebservices *webservices=[MyWebservices sharedInstance];
            
            [webservices httpResponsePOST:url parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
                [[AppDelegate sharedAppdelegate] hideProgressView];
                
                if (error || [msg containsString:@"Error"]) {
                    
                    if (msg) {
                        
                        if([msg isEqualToString:@"Error-403"])
                        {
                            [self->utils showAlertWithMessage:NSLocalizedString(@"Permission Denied - You don't have permission to change ticket status. ", nil) sendViewController:self];
                        }
                        else{
                            [self->utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",msg] sendViewController:self];
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
                    
                    
                    if([[json objectForKey:@"message"] isKindOfClass:[NSArray class]])
                    {
                        [self->utils showAlertWithMessage:NSLocalizedString(@"Permission Denied - You don't have permission to change status. ", nil) sendViewController:self];
                        
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



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// After clicking this button, it will nviagte to edit ticket view controller
-(void)editTicketTapped
{
    NSLog(@"EditTicket Tapped"); // EditDetailTableViewController.h
   
    EditDetailTableViewController *edit= [self.storyboard instantiateViewControllerWithIdentifier:@"editDetailVC"];
     [self.navigationController pushViewController:edit animated:YES];
    
}

// It will handle segmented control selection
- (IBAction)indexChanged:(id)sender {
    
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        UIViewController *newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ConversationVC"];
        newViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
        [self cycleFromViewController:self.currentViewController toViewController:newViewController];
        self.currentViewController = newViewController;
         } else {
        UIViewController *newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailVC"];
        newViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
        [self cycleFromViewController:self.currentViewController toViewController:newViewController];
        self.currentViewController = newViewController;
           }
}


-(void)removeKeyBoard
{
    
    [textViewInternalNote resignFirstResponder]; //textViewReply
     [textViewReply resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)aTextField
{
    [aTextField resignFirstResponder];
    return YES;
}



//below 3 methods are used to logout a agent or admin when his login creadentials will change or there role will be changed or HELPDESL URL will change in these scenarious we have to move our from app so these 3 methods are used to achieve it.
-(void)showMessageForLogout:(NSString*)message sendViewController:(UIViewController *)viewController
{
    UIAlertController *alertController = [UIAlertController   alertControllerWithTitle:APP_NAME message:message  preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction  actionWithTitle:@"Logout"
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction *action)
                                   {
                                       [self logout];
                                       
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
                                       
                                       LoginViewController *login=[self.storyboard instantiateViewControllerWithIdentifier:@"Login"];
                                       [self.navigationController pushViewController: login animated:YES];
                                   }];
    [alertController addAction:cancelAction];
    
    [viewController presentViewController:alertController animated:YES completion:nil];
    
}

-(void)logout
{
    
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
            [[AppDelegate sharedAppdelegate] hideProgressView];
        }
        
    }];
    
}



@end
