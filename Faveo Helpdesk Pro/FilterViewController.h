//
//  FilterViewController.h
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 13/11/17.
//  Copyright © 2017 Ladybird websolutions pvt ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DropDownListView.h"

@interface FilterViewController : UITableViewController<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>



@property (weak, nonatomic) IBOutlet UITextField *departmentTextField;

@property (weak, nonatomic) IBOutlet UITextField *priorityTextField;

@property (weak, nonatomic) IBOutlet UITextField *typeTextField;

@property (weak, nonatomic) IBOutlet UITextField *sourceTextField;

@property (weak, nonatomic) IBOutlet UITextField *statusTextField;

@property (weak, nonatomic) IBOutlet UITextField *assignTextField;

@property (weak, nonatomic) IBOutlet UIButton *submitButton;


- (IBAction)submitClicked:(id)sender;

@property (nonatomic, strong) NSArray * sourceArray;
@property (nonatomic, strong) NSArray * helptopicsArray;
@property (nonatomic, strong) NSArray * slaPlansArray;
@property (nonatomic, strong) NSArray * deptArray;
@property (nonatomic, strong) NSArray * priorityArray;
@property (nonatomic, strong) NSArray * typeArray; // _statusArray
@property (nonatomic, strong) NSArray * statusArray;
- (IBAction)SelectDepartment:(id)sender;

- (IBAction)SelectPriority:(id)sender;
- (IBAction)SelectTicketTypes:(id)sender;


- (IBAction)SelectTicketSource:(id)sender;
- (IBAction)SelectTicketStatus:(id)sender;

- (IBAction)SelectAssignee:(id)sender;


@end
