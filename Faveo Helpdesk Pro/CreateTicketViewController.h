//
//  CreateTicketViewController.h
//  SideMEnuDemo
//
//  Created by Narendra on 19/08/16.
//  Copyright © 2016 Ladybird websolutions pvt ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"

/**
 @class CreateTicketViewController
 
 @brief This class contain Ticket  create process.
 
 @discussion Here  we can create a ticket by filling some necessary information. After filling valid infomation, ticket will be crated. 
 
 @superclass UITableViewController
 
 @helper SlideNavigationController,InboxViewController,Utils,MyWebservices,AppDelegate
 */

@interface CreateTicketViewController : UITableViewController<SlideNavigationControllerDelegate,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textViewMsg;

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;
@property (weak, nonatomic) IBOutlet UITextField *mobileTextField;
@property (weak, nonatomic) IBOutlet UITextField *helpTopicTextField;
@property (weak, nonatomic) IBOutlet UITextField *slaTextField;
@property (weak, nonatomic) IBOutlet UITextField *deptTextField;
@property (weak, nonatomic) IBOutlet UITextField *subjectTextField;
//@property (weak, nonatomic) IBOutlet UITextField *msgTextField;
@property (weak, nonatomic) IBOutlet UITextField *priorityTextField;

@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@property (nonatomic, strong) NSArray * helptopicsArray;
@property (nonatomic, strong) NSArray * slaPlansArray;
@property (nonatomic, strong) NSArray * deptArray;
@property (nonatomic, strong) NSArray * priorityArray;

@property (nonatomic, strong) NSArray * countryArray;
@property (nonatomic, strong) NSArray * codeArray;

@property (nonatomic, strong) NSDictionary * countryDic;

@property (nonatomic, assign) NSInteger selectedIndex;

- (IBAction)helpTopicClicked:(id)sender;
- (IBAction)slaClicked:(id)sender;
- (IBAction)deptClicked:(id)sender;
- (IBAction)priorityClicked:(id)sender;
- (IBAction)submitClicked:(id)sender;
- (IBAction)countryCodeClicked:(id)sender;

@end
