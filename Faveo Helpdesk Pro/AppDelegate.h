//
//  AppDelegate.h
//  SideMEnuDemo
//
//  Created by Narendra on 17/08/16.
//  Copyright © 2016 Ladybird websolutions pvt ltd. All rights reserved.
//



#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
#import "SlideNavigationController.h"
#import "LeftMenuViewController.h"
#import "MBProgressHUD.h"

/**
 @class AppDelegate
 
 @brief This is a class class that receives application-level messages, including the applicationDidFinishLaunching message most commonly used to initiate the creation of other views.
 
 @discussion The app delegate works alongside the app object to ensure your app interacts properly with the system and with other apps. Specifically, the methods of the app delegate give you a chance to respond to important changes. For example, you use the methods of the app delegate to respond to state transitions, such as when your app moves from foreground to background execution, and to respond to incoming notifications. 
     In many cases, the methods of the app delegate are the only way to receive these important notifications.
 
 @superclass UIResponder
 
 @helper MBProgressHUD,LeftMenuViewController,SlideNavigationController,TicketDetailViewController,LoginViewController,InboxViewController,
 */

@interface AppDelegate : UIResponder <UIApplicationDelegate,UNUserNotificationCenterDelegate>

@property (strong, nonatomic) UIWindow *window;

+(AppDelegate*)sharedAppdelegate;

//MBProgreehud
- (void)showProgressView;
- (void)showProgressViewWithText:(NSString *)text;
- (void)hideProgressView;

@end

