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
    
   // [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:[[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleDone target:self action:@selector(onNavButtonTapped:event:)],[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(replyBtnPressed)],[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(internalNotePressed)], nil] animated:YES];
    
    // [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"verticle"] style:UIBarButtonItemStyleDone target:self action:@selector(onNavButtonTapped:event:)],[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(replyBtnPressed)],[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(internalNotePressed)], nil] animated:YES];
    
   // [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"verticle"] style:UIBarButtonItemStyleDone target:self action:@selector(onNavButtonTapped:event:)],[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"editTicket"] style:UIBarButtonItemStyleDone target:self action:@selector(editTicketTapped)], nil] animated:YES];

    
    
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
    else{
    
    [[AppDelegate sharedAppdelegate] showProgressViewWithText:NSLocalizedString(@"Getting data",nil)];
    [self getDependencies];
    }
    
}

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
    [_plusButtonsViewMain setButtonAtIndex:1 backgroundColor:[UIColor colorWithRed:1.f green:0.2 blue:0.6 alpha:1.f] forState:UIControlStateHighlighted];
  //  [_plusButtonsViewMain setButtonAtIndex:2 backgroundColor:[UIColor colorWithRed:1.f green:0.5 blue:0.f alpha:1.f] forState:UIControlStateNormal];
    [_plusButtonsViewMain setButtonAtIndex:2 backgroundColor:[UIColor whiteColor] forState:UIControlStateNormal];
  [_plusButtonsViewMain setButtonAtIndex:2 backgroundColor:[UIColor colorWithRed:1.f green:0.6 blue:0.2 alpha:1.f] forState:UIControlStateHighlighted];
   
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
            [[AppDelegate sharedAppdelegate] hideProgressView];
            
        }
    }
    NSLog(@"Thread-NO2-getDependencies()-closed");
}


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
                                   [self changeStatusMethod:self->selectedStatusName idIs:self->selectedStatusId];
                               }
                               
                           }
                        dismissBlock:^{
                            
                        }];
        
#endif
    
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
                            [self->utils showAlertWithMessage:NSLocalizedString(@"Permission Denied - You don't have permission to change status. ", nil) sendViewController:self];
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

/*-(void)replyBtnPressed{

    NSLog(@"Reply Pressed");

    [self showPopupReply:CNPPopupStyleCentered];
    
    
}


-(void)internalNotePressed{
     [self showPopupInternalNote:CNPPopupStyleCentered];
    NSLog(@"Internal Pressed");
}
*/

-(void)editTicketTapped
{
    NSLog(@"EditTicket Tapped"); // EditDetailTableViewController.h
   
    EditDetailTableViewController *edit= [self.storyboard instantiateViewControllerWithIdentifier:@"editDetailVC"];
     [self.navigationController pushViewController:edit animated:YES];
    
}
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

//- (void)showPopupInternalNote:(CNPPopupStyle)popupStyle {
//
//    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
//    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
//    paragraphStyle.alignment = NSTextAlignmentCenter;
//
//    NSAttributedString *title = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Internal Notes",nil) attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:24], NSParagraphStyleAttributeName : paragraphStyle}];
//
//    NSMutableAttributedString *lineTwo = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"Message*",nil) attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18], NSForegroundColorAttributeName : [UIColor hx_colorWithHexRGBAString:@"#00aeef"]}];
//    [lineTwo addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(7,1)];
//    //    NSAttributedString *lineOne = [[NSAttributedString alloc] initWithString:@"Message" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18], NSParagraphStyleAttributeName : paragraphStyle}];
//    //    NSAttributedString *lineTwo = [[NSAttributedString alloc] initWithString:@"Message" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18], NSForegroundColorAttributeName : [UIColor colorWithRed:0.46 green:0.8 blue:1.0 alpha:1.0], NSParagraphStyleAttributeName : paragraphStyle}];
//
//    UILabel *titleLabel = [[UILabel alloc] init];
//    titleLabel.numberOfLines = 0;
//    titleLabel.attributedText = title;
//    errorMessageNote=[[UILabel alloc] initWithFrame:CGRectMake(10, 135, 250, 20)];
//    errorMessageNote.textColor=[UIColor hx_colorWithHexRGBAString:FAILURE_COLOR];
//    errorMessageNote.text=@"Field is mandatory.";
//    [errorMessageNote setFont:[UIFont systemFontOfSize:12]];
//    errorMessageNote.hidden=YES;
//    //    UILabel *lineOneLabel = [[UILabel alloc] init];
//    //    lineOneLabel.numberOfLines = 0;
//    //    lineOneLabel.attributedText = lineOne;
//    //
//    //    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon"]];
//
//    UILabel *lineTwoLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 100, 20)];
//    //    lineTwoLabel.numberOfLines = 0;
//    //lineTwoLabel.textColor=[UIColor hx_colorWithHexRGBAString:@"#00aeef"];
//    lineTwoLabel.attributedText = lineTwo;
//
//
//    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 275, 140)];
//    //customView.backgroundColor = [UIColor lightGrayColor];
//
//    textViewInternalNote = [[UITextView alloc] initWithFrame:CGRectMake(10, 35, 250, 100)];
//
//    //[ textViewInternalNote setReturnKeyType:UIReturnKeyDone];
//
//   // textViewInternalNote.inputAccessoryView.hidden =YES;
//    textViewInternalNote.autocorrectionType = YES;
//    // textViewInternalNote.autocapitalizationType=NO;
//    textViewInternalNote.textContentType = UITextContentTypeName;
//    textViewInternalNote.spellCheckingType = UITextSpellCheckingTypeYes;
//
//    textViewInternalNote.autocorrectionType = UITextAutocorrectionTypeYes;
//
//    UIToolbar *toolBar= [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
//    UIBarButtonItem *removeBtn=[[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStylePlain  target:self action:@selector(removeKeyBoard)];
//
//    UIBarButtonItem *space=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
//
//    [toolBar setItems:[NSArray arrayWithObjects:space,removeBtn, nil]];
//    [textViewInternalNote setInputAccessoryView:toolBar];
//
//
//    textViewInternalNote.layer.cornerRadius=4;
//     textViewInternalNote.layer.borderWidth=1.0F;
//     textViewInternalNote.layer.borderColor=[[UIColor lightGrayColor] CGColor];
//
//    [customView addSubview: textViewInternalNote];
//    [customView addSubview:lineTwoLabel];
//    [customView addSubview:errorMessageNote];
//
//    CNPPopupButton *button = [[CNPPopupButton alloc] initWithFrame:CGRectMake(0, 0,200
//
//                                                                              , 40)];
//    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    button.titleLabel.font = [UIFont boldSystemFontOfSize:18];
//    [button setTitle:NSLocalizedString(@"Done",nil) forState:UIControlStateNormal];
//    button.backgroundColor = [UIColor hx_colorWithHexRGBAString:@"#00aeef"];
//    button.layer.cornerRadius = 4;
//
//    CNPPopupButton *button2 = [[CNPPopupButton alloc] initWithFrame:CGRectMake(0, 0,200, 40)];
//    [button2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    button2.titleLabel.font = [UIFont boldSystemFontOfSize:18];
//    [button2 setTitle:NSLocalizedString(@"Back",nil) forState:UIControlStateNormal];
//    button2.backgroundColor = [UIColor hx_colorWithHexRGBAString:@"#00aeef"];
//    button2.layer.cornerRadius = 4;
//
//
//    button.selectionHandler = ^(CNPPopupButton *button){
//        NSString *rawString = [textViewInternalNote text];
//        NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
//        NSString *trimmed = [rawString stringByTrimmingCharactersInSet:whitespace];
//        if ([trimmed length] == 0) {
//             errorMessageNote.hidden=NO;
//            // Text was empty or only whitespace.
//        }else if ( textViewInternalNote.text.length > 0 && textViewInternalNote.text != nil && ![textViewInternalNote.text isEqual:@""]) {
//            errorMessageNote.hidden=YES;
//            [self postInternalNote];
//            [self.popupController dismissPopupControllerAnimated:YES];
//            NSLog(@"Message of InternalNote: %@",  textViewInternalNote.text);
//
//        }else {
//           errorMessageNote.hidden=NO;
//        }
//    };
//
//    button2.selectionHandler = ^(CNPPopupButton *button2)
//    {
//
//         [self.popupController dismissPopupControllerAnimated:YES];
//
//        TicketDetailViewController *td=[self.storyboard instantiateViewControllerWithIdentifier:@"TicketDetailVCID"];
//        [self.navigationController pushViewController:td animated:YES];
//    };
//
//
//    self.popupController = [[CNPPopupController alloc] initWithContents:@[titleLabel, customView, button,button2]];
//    //self.popupController = [[CNPPopupController alloc] initWithContents:@[titleLabel, customView, button2]];
//    self.popupController.theme = [CNPPopupTheme defaultTheme];
//    self.popupController.theme.popupStyle = popupStyle;
//    self.popupController.delegate = self;
//    [self.popupController presentPopupControllerAnimated:YES];
//    [self floatingButton];
//
//}

-(void)removeKeyBoard
{
    
    [textViewInternalNote resignFirstResponder]; //textViewReply
     [textViewReply resignFirstResponder];
}
//- (void)showPopupReply:(CNPPopupStyle)popupStyle {
//
//    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
//    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
//    paragraphStyle.alignment = NSTextAlignmentCenter;
//
//    NSAttributedString *title = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Ticket Reply",nil) attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:24], NSParagraphStyleAttributeName : paragraphStyle}];
//    NSAttributedString *lineOne = [[NSAttributedString alloc] initWithString:@"Cc" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18], NSForegroundColorAttributeName : [UIColor hx_colorWithHexRGBAString:@"#00aeef"]}];
//    NSMutableAttributedString *lineTwo = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"Message*",nil) attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18], NSForegroundColorAttributeName : [UIColor hx_colorWithHexRGBAString:@"#00aeef"]}];
//    [lineTwo addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(7,1)];
//
//    UILabel *titleLabel = [[UILabel alloc] init];
//    titleLabel.numberOfLines = 0;
//    titleLabel.attributedText = title;
//
//    //    UILabel *lineOneLabel = [[UILabel alloc] init];
//    //    lineOneLabel.numberOfLines = 0;
//    //    lineOneLabel.attributedText = lineOne;
//    //
//    //    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon"]];
//
//    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 270, 140)];
//    //customView.backgroundColor = [UIColor lightGrayColor];
//
//
//    UILabel *lineTwoLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 100, 20)];
//    //    lineTwoLabel.numberOfLines = 0;
//    //lineTwoLabel.textColor=[UIColor colorWithRed:0.46 green:0.8 blue:1.0 alpha:1.0];
//    lineTwoLabel.attributedText = lineOne;
//
//    textFieldCc=[[UITextField alloc]initWithFrame:CGRectMake(10, 30, 250, 30)];
//    [textFieldCc setBorderStyle:UITextBorderStyleNone];
//    textFieldCc.layer.cornerRadius=4;
//    textFieldCc.layer.borderWidth=1.0F;
//    textFieldCc.layer.borderColor=[[UIColor lightGrayColor] CGColor];
//
//    errorMessageReply=[[UILabel alloc] initWithFrame:CGRectMake(10, 130, 250, 20)];
//     errorMessageReply.textColor=[UIColor hx_colorWithHexRGBAString:FAILURE_COLOR];
//    errorMessageReply.text=@"Field is mandatory.";
//    [errorMessageReply setFont:[UIFont systemFontOfSize:12]];
//     errorMessageReply.hidden=YES;
//
//    UILabel *lineTwoLabe2 = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 100, 20)];
//    //    lineTwoLabel.numberOfLines = 0;
//    //lineTwoLabe2.textColor=[UIColor colorWithRed:0.46 green:0.8 blue:1.0 alpha:1.0];
//    lineTwoLabe2.attributedText = lineTwo;
//
//    textViewReply = [[UITextView alloc] initWithFrame:CGRectMake(10, 30, 250, 100)];
//
////    textViewReply.delegate=self;
////    [textViewReply setReturnKeyType:UIReturnKeyDone];
////
//
//    UIToolbar *toolBar= [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
//    UIBarButtonItem *removeBtn=[[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStylePlain  target:self action:@selector(removeKeyBoard)];
//
//    UIBarButtonItem *space=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
//
//    [toolBar setItems:[NSArray arrayWithObjects:space,removeBtn, nil]];
//    [textViewReply setInputAccessoryView:toolBar];
//
//
//   // textViewReply.inputAccessoryView.hidden =YES;
//    textViewReply.autocorrectionType = YES;
//    textViewReply.textContentType = UITextContentTypeName;
//    textViewReply.spellCheckingType = UITextSpellCheckingTypeYes;
//
//   // textViewReply.autocapitalizationType=NO;
//    textViewReply.autocorrectionType = UITextAutocorrectionTypeYes;
//
//
//    textViewReply.layer.cornerRadius=4;
//    textViewReply.layer.borderWidth=1.0F;
//    textViewReply.layer.borderColor=[[UIColor grayColor] CGColor];
//
//    [customView addSubview:textViewReply];
//    //[customView addSubview:textFieldCc];
//   // [customView addSubview:lineTwoLabel];
//    [customView addSubview:lineTwoLabe2];
//    [customView addSubview:errorMessageReply];
//
//
//    CNPPopupButton *button = [[CNPPopupButton alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
//    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    button.titleLabel.font = [UIFont boldSystemFontOfSize:18];
//    [button setTitle:NSLocalizedString(@"Done",nil) forState:UIControlStateNormal];
//    button.backgroundColor = [UIColor hx_colorWithHexRGBAString:@"#00aeef"];
//    button.layer.cornerRadius = 4;
//
//    CNPPopupButton *button2 = [[CNPPopupButton alloc] initWithFrame:CGRectMake(0, 0,200, 40)];
//    [button2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    button2.titleLabel.font = [UIFont boldSystemFontOfSize:18];
//    [button2 setTitle:NSLocalizedString(@"Back",nil) forState:UIControlStateNormal];
//    button2.backgroundColor = [UIColor hx_colorWithHexRGBAString:@"#00aeef"];
//    button2.layer.cornerRadius = 4;
//
//
//    button.selectionHandler = ^(CNPPopupButton *button){
//
//        NSString *rawString = [textViewReply text];
//        NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
//        NSString *trimmed = [rawString stringByTrimmingCharactersInSet:whitespace];
//        if ([trimmed length] == 0) {
//            errorMessageReply.hidden=NO;
//            // Text was empty or only whitespace.
//        }else if (textViewReply.text.length > 0 && textViewReply.text != nil && ![textViewReply.text isEqual:@""]) {
//            [self postReply];
//            errorMessageReply.hidden=YES;
//            [self.popupController dismissPopupControllerAnimated:YES];
//            NSLog(@"Reply Message: %@, Cc: %@", textViewReply.text,textFieldCc.text);
//
//        }else {
//           errorMessageReply.hidden=NO;
//        }
//    };
//
//    button2.selectionHandler = ^(CNPPopupButton *button2)
//    {
//
//        [self.popupController dismissPopupControllerAnimated:YES];
//
//        TicketDetailViewController *td=[self.storyboard instantiateViewControllerWithIdentifier:@"TicketDetailVCID"];
//        [self.navigationController pushViewController:td animated:YES];
//    };
//
//    self.popupController = [[CNPPopupController alloc] initWithContents:@[titleLabel, customView, button,button2]];
//    self.popupController.theme = [CNPPopupTheme defaultTheme];
//    self.popupController.theme.popupStyle = popupStyle;
//    self.popupController.delegate = self;
//    [self.popupController presentPopupControllerAnimated:YES];
//    [self floatingButton];
//
//}


//
//-(void)postInternalNote{
//
//    if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable)
//    {
//        //connection unavailable
//       // [RKDropdownAlert title:APP_NAME message:NO_INTERNET backgroundColor:[UIColor hx_colorWithHexRGBAString:FAILURE_COLOR] textColor:[UIColor whiteColor]];
//
//        if (self.navigationController.navigationBarHidden) {
//            [self.navigationController setNavigationBarHidden:NO];
//        }
//
//        [RMessage showNotificationInViewController:self.navigationController
//                                             title:NSLocalizedString(@"Error..!", nil)
//                                          subtitle:NSLocalizedString(@"There is no Internet Connection...!", nil)
//                                         iconImage:nil
//                                              type:RMessageTypeError
//                                    customTypeName:nil
//                                          duration:RMessageDurationAutomatic
//                                          callback:nil
//                                       buttonTitle:nil
//                                    buttonCallback:nil
//                                        atPosition:RMessagePositionNavBarOverlay
//                              canBeDismissedByUser:YES];
//
//    }else{
//
//        [[AppDelegate sharedAppdelegate] showProgressView];
//
//
//        NSString *url=[NSString stringWithFormat:@"%@helpdesk/internal-note?api_key=%@&ip=%@&token=%@&user_id=%@&body=%@&ticket_id=%@",[userDefaults objectForKey:@"companyURL"],API_KEY,IP,[userDefaults objectForKey:@"token"],[userDefaults objectForKey:@"user_id"],textViewInternalNote.text,globalVariables.iD];
//
// @try{
//        MyWebservices *webservices=[MyWebservices sharedInstance];
//
//        [webservices httpResponsePOST:url parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
//            [[AppDelegate sharedAppdelegate] hideProgressView];
//            if (error || [msg containsString:@"Error"]) {
//
//                if (msg) {
//
//                    [utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",msg] sendViewController:self];
//
//                }else if(error)  {
//                    [utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",error.localizedDescription] sendViewController:self];
//                    NSLog(@"Thread-NO4-getInbox-Refresh-error == %@",error.localizedDescription);
//                }
//
//                return ;
//            }
//
//            if ([msg isEqualToString:@"tokenRefreshed"]) {
//
//                [self postInternalNote];
//                NSLog(@"Thread--NO4-call-postCreateTicket");
//                return;
//            }
//
//            if (json) {
//                NSLog(@"JSON-CreateTicket-%@",json);
//                if ([json objectForKey:@"thread"]) {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [RKDropdownAlert title:NSLocalizedString(@"success", nil) message:NSLocalizedString(@"Posted your note.", nil) backgroundColor:[UIColor hx_colorWithHexRGBAString:SUCCESS_COLOR] textColor:[UIColor whiteColor]];
//
//                        [[NSNotificationCenter defaultCenter] postNotificationName:@"reload_data" object:self];
//
//                       TicketDetailViewController *td=[self.storyboard instantiateViewControllerWithIdentifier:@"TicketDetailVCID"];
//                        [self.navigationController pushViewController:td animated:YES];
//
//
//
//
//                       // [utils showAlertWithMessage:@"Kindly Refresh!!" sendViewController:self];
//                    });
//                }
//            }
//            NSLog(@"Thread-NO5-postCreateTicket-closed");
//
//        }];
// }@catch (NSException *exception)
//        {
//            [utils showAlertWithMessage:exception.name sendViewController:self];
//            NSLog( @"Name: %@", exception.name);
//            NSLog( @"Reason: %@", exception.reason );
//            return;
//        }
//        @finally
//        {
//            NSLog( @" I am in InternalNote method in TicketDetail ViewController" );
//
//        }
//
//
//    }
//}




        
//-(void)postReply{
//    
//    if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable)
//    {
//        //connection unavailable
//        // [RKDropdownAlert title:APP_NAME message:NO_INTERNET backgroundColor:[UIColor hx_colorWithHexRGBAString:FAILURE_COLOR] textColor:[UIColor whiteColor]];
//        
//        if (self.navigationController.navigationBarHidden) {
//            [self.navigationController setNavigationBarHidden:NO];
//        }
//        
//        [RMessage showNotificationInViewController:self.navigationController
//                                             title:NSLocalizedString(@"Error..!", nil)
//                                          subtitle:NSLocalizedString(@"There is no Internet Connection...!", nil)
//                                         iconImage:nil
//                                              type:RMessageTypeError
//                                    customTypeName:nil
//                                          duration:RMessageDurationAutomatic
//                                          callback:nil
//                                       buttonTitle:nil
//                                    buttonCallback:nil
//                                        atPosition:RMessagePositionNavBarOverlay
//                              canBeDismissedByUser:YES];
//        
//    }else{
//        
//        [[AppDelegate sharedAppdelegate] showProgressView];
//        
//        
//        //   NSString *url=[NSString stringWithFormat:@"%@helpdesk/reply?api_key=%@&ip=%@&ticket_id=%@&reply_content=%@&token=%@",[userDefaults objectForKey:@"companyURL"],API_KEY,IP,globalVariables.iD,textViewReply.text,[userDefaults objectForKey:@"token"]];
//        
//        // NSString *url=[NSString stringWithFormat:@"%@helpdesk/reply?api_key=%@&ip=%@&ticket_id=%@&reply_content=%@&token=%@",[userDefaults objectForKey:@"companyURL"],API_KEY,IP,globalVariables.iD,textViewReply.text,[userDefaults objectForKey:@"token"]];
//        
//         NSString *url=[NSString stringWithFormat:@"%@helpdesk/reply?api_key=%@&ip=%@&ticket_id=%@&reply_content=%@&token=%@",[userDefaults objectForKey:@"companyURL"],API_KEY,IP,globalVariables.iD,textViewReply.text,[userDefaults objectForKey:@"token"]];
//        
//        
//        NSLog(@"URL is : %@",url);
//  @try{
//        MyWebservices *webservices=[MyWebservices sharedInstance];
//        
//        [webservices httpResponsePOST:url parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
//            
//            
//            
//            [[AppDelegate sharedAppdelegate] hideProgressView];
//            
//            if (error || [msg containsString:@"Error"]) {
//                
//                if (msg) {
//                    
//                    [utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",msg] sendViewController:self];
//                    
//                }else if(error)  {
//                    [utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",error.localizedDescription] sendViewController:self];
//                    NSLog(@"Thread-NO4-getInbox-Refresh-error == %@",error.localizedDescription);
//                }
//                
//                return ;
//            }
//            
//            if ([msg isEqualToString:@"tokenRefreshed"]) {
//                
//                [self postReply];
//                NSLog(@"Thread--NO4-call-postCreateTicket");
//                return;
//            }
//            
//            if (json) {
//                NSLog(@"JSON-CreateTicket-%@",json);
//                if ([json objectForKey:@"result"]) {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                         [RKDropdownAlert title:NSLocalizedString(@"success", nil) message:NSLocalizedString(@"Posted your reply.", nil)backgroundColor:[UIColor hx_colorWithHexRGBAString:SUCCESS_COLOR] textColor:[UIColor whiteColor]];
//                        
//                        
//                        [[NSNotificationCenter defaultCenter] postNotificationName:@"reload_data" object:self];
//                        
//                       TicketDetailViewController *td=[self.storyboard instantiateViewControllerWithIdentifier:@"TicketDetailVCID"];
//                       [self.navigationController pushViewController:td animated:YES];
//                        // [utils showAlertWithMessage:@"Kindly Refresh!!" sendViewController:self];
//                    });
//                }
//            }
//            NSLog(@"Thread-NO5-postCreateTicket-closed");
//            
//        }];
//  }@catch (NSException *exception)
//        {
//            [utils showAlertWithMessage:exception.name sendViewController:self];
//            NSLog( @"Name: %@", exception.name);
//            NSLog( @"Reason: %@", exception.reason );
//            return;
//        }
//        @finally
//        {
//            NSLog( @" I am in replatTicket method in TicketDetail ViewController" );
//            
//        }
//
//
//    }
//    
//}



- (BOOL)textFieldShouldReturn:(UITextField *)aTextField
{
    [aTextField resignFirstResponder];
    return YES;
}




@end
