//
//  FilterViewController.m
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 13/11/17.
//  Copyright © 2017 Ladybird websolutions pvt ltd. All rights reserved.
//

#import "FilterViewController.h"
#import "AddRequester.h"
#import "InboxViewController.h"
#import "CreateTicketViewController.h"
#import "LeftMenuViewController.h"
#import "ActionSheetStringPicker.h"
#import "HexColors.h"
#import "Utils.h"
#import "Reachability.h"
#import "AppConstanst.h"
#import "MyWebservices.h"
#import "AppDelegate.h"
#import "RKDropdownAlert.h"
#import "IQKeyboardManager.h"
#import "Dat.h"
#import "RMessage.h"
#import "RMessageView.h"
#import "AddRequester.h"
#import "GlobalVariables.h"
#import "BDCustomAlertView.h"
#import "DropDownListView.h"
#import "FilterLogic.h"

@import FirebaseInstanceID;
@import FirebaseMessaging;

@interface FilterViewController ()<RMessageProtocol,UITextViewDelegate,kDropDownListViewDelegate>{
    
    Utils *utils;
    UIRefreshControl *refresh;
    NSUserDefaults *userDefaults;
    NSMutableArray *array1;
    NSDictionary *priDicc1;
    GlobalVariables *globalVariables;
    
    DropDownListView * Dropobj;
    
    NSNumber *sla_id;
    NSNumber *type_id;
    NSNumber *help_topic_id;
    NSNumber *dept_id;
    NSNumber *priority_id;
    NSNumber *source_id;
    NSNumber *status_id;
    NSNumber *staff_id;
    
    
    NSMutableArray * sla_idArray;
    NSMutableArray * type_idArray;
    NSMutableArray * dept_idArray;
    NSMutableArray * pri_idArray;
    NSMutableArray * helpTopic_idArray;
    NSMutableArray * status_idArray;
    NSMutableArray * source_idArray;
    NSMutableArray * staff_idArray;
    
    NSArray * assignee;
    NSArray *statusArray1;
    
}



@end

@implementation FilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    assignee=@[@"Yes",@"No"];
    statusArray1=@[@"Open",@"Resolved",@"Closed",@"Deleted"];
    
    _departmentTextField.delegate=self;
    _priorityTextField.delegate=self;
    _typeTextField.delegate=self;
    _statusTextField.delegate=self;
    _sourceTextField.delegate=self;
    _assignTextField.delegate=self;
    
    globalVariables=[GlobalVariables sharedInstance];
    userDefaults=[NSUserDefaults standardUserDefaults];
    
    
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:false];
    
    utils=[[Utils alloc]init];
    
    userDefaults=[NSUserDefaults standardUserDefaults];
    
    
    //    UIBarButtonItem *clearButton = [[UIBarButtonItem alloc]
    //                                    initWithTitle:@"Clear"
    //                                    style:UIBarButtonItemStylePlain
    //                                    target:self
    //                                    action:@selector(flipView)];
    //    self.navigationItem.rightBarButtonItem = clearButton;
    UIButton *clearButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    [clearButton setImage:[UIImage imageNamed:@"clearAll"] forState:UIControlStateNormal];
    [clearButton addTarget:self action:@selector(flipView) forControlEvents:UIControlEventTouchUpInside];
    [clearButton setFrame:CGRectMake(44, 0, 32, 32)];
    
    UIView *rightBarButtonItems = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 76, 32)];
    [rightBarButtonItems addSubview: clearButton];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarButtonItems];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _submitButton.backgroundColor=[UIColor hx_colorWithHexRGBAString:@"#00aeef"];
    
    
    self.tableView.tableFooterView=[[UIView alloc] initWithFrame:CGRectZero];
    
    
    
    _departmentTextField.text= globalVariables.departmentTextFiled1;
    _priorityTextField.text= globalVariables.priorityTextFiled1;
    _typeTextField.text= globalVariables.typeTextFiled1;
    _sourceTextField.text= globalVariables.sourceTextFiled1;
    _statusTextField.text= globalVariables.statusTextField;
    _assignTextField.text= globalVariables.assignedTextFiled1;
    
    [self readFromPlist];
    
    
    // Do any additional setup after loading the view.
}



-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    // _submitButton.userInteractionEnabled = false;
    
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:true];
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)readFromPlist{
    // Read plist from bundle and get Root Dictionary out of it
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"faveoData.plist"];
    
    @try{
        if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath])
        {
            plistPath = [[NSBundle mainBundle] pathForResource:@"faveoData" ofType:@"plist"];
        }
        NSDictionary *resultDic = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        //    NSLog(@"resultDic--%@",resultDic);
        NSArray *deptArray=[resultDic objectForKey:@"departments"];
        NSArray *helpTopicArray=[resultDic objectForKey:@"helptopics"];
        NSArray *prioritiesArray=[resultDic objectForKey:@"priorities"];
        NSArray *slaArray=[resultDic objectForKey:@"sla"];
        NSArray *sourcesArray=[resultDic objectForKey:@"sources"];
        NSMutableArray *staffsArray=[resultDic objectForKey:@"staffs"];
        // NSArray *statusArray=[resultDic objectForKey:@"status"];
        
        NSArray *typeArray=[resultDic objectForKey:@"type"];
        
        //    NSLog(@"resultDic2--%@,%@,%@,%@,%@,%@,%@,%@",deptArray,helpTopicArray,prioritiesArray,slaArray,sourcesArray,staffsArray,statusArray,teamArray);
        
        NSMutableArray *deptMU=[[NSMutableArray alloc]init];
        NSMutableArray *slaMU=[[NSMutableArray alloc]init];
        NSMutableArray *helptopicMU=[[NSMutableArray alloc]init];
        NSMutableArray *priMU=[[NSMutableArray alloc]init];
        //   NSMutableArray *statusMU=[[NSMutableArray alloc]init];
        
        NSMutableArray *sourceMU=[[NSMutableArray alloc]init];
        NSMutableArray *typeMU=[[NSMutableArray alloc]init];
        NSMutableArray *staffMU=[[NSMutableArray alloc]init];
        
        
        dept_idArray=[[NSMutableArray alloc]init];
        sla_idArray=[[NSMutableArray alloc]init];
        helpTopic_idArray=[[NSMutableArray alloc]init];
        pri_idArray=[[NSMutableArray alloc]init];
        status_idArray=[[NSMutableArray alloc]init];
        source_idArray=[[NSMutableArray alloc]init];
        type_idArray=[[NSMutableArray alloc]init];
        
        
        for (NSMutableDictionary *dicc in staffsArray) {
            if ([dicc objectForKey:@"email"]) {
                [staffMU addObject:[dicc objectForKey:@"email"]];
                [staff_idArray addObject:[dicc objectForKey:@"id"]];
            }
            
        }
        
        for (NSDictionary *dicc in deptArray) {
            if ([dicc objectForKey:@"name"]) {
                [deptMU addObject:[dicc objectForKey:@"name"]];
                [dept_idArray addObject:[dicc objectForKey:@"id"]];
            }
            
        }
        
        for (NSDictionary *dicc in prioritiesArray) {
            if ([dicc objectForKey:@"priority"]) {
                [priMU addObject:[dicc objectForKey:@"priority"]];
                [pri_idArray addObject:[dicc objectForKey:@"priority_id"]];
            }
            
        }
        
        for (NSDictionary *dicc in slaArray) {
            if ([dicc objectForKey:@"name"]) {
                [slaMU addObject:[dicc objectForKey:@"name"]];
                [sla_idArray addObject:[dicc objectForKey:@"id"]];
            }
            
        }
        
        for (NSDictionary *dicc in helpTopicArray) {
            if ([dicc objectForKey:@"topic"]) {
                [helptopicMU addObject:[dicc objectForKey:@"topic"]];
                [helpTopic_idArray addObject:[dicc objectForKey:@"id"]];
            }
        }
        
        for (NSDictionary *dicc in typeArray) {
            if ([dicc objectForKey:@"name"]) {
                [typeMU addObject:[dicc objectForKey:@"name"]];
                [type_idArray addObject:[dicc objectForKey:@"id"]];
            }
        }
        
        
        
        for (NSDictionary *dicc in sourcesArray) {
            if ([dicc objectForKey:@"name"]) {
                [sourceMU addObject:[dicc objectForKey:@"name"]];
                [source_idArray addObject:[dicc objectForKey:@"id"]];
            }
        }
        
        _deptArray=[deptMU copy];
        _helptopicsArray=[helptopicMU copy];
        _slaPlansArray=[slaMU copy];
        _priorityArray=[priMU copy];
        _sourceArray=[sourceMU copy];
        _typeArray=[typeMU copy];
        //  _statusArray=[statusMU copy];
        
        
        
    }@catch (NSException *exception)
    {
        [utils showAlertWithMessage:exception.name sendViewController:self];
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    @finally
    {
        NSLog( @" I am in readFromPlist method in FilterView ViewController" );
        
    }
    
}
// select departent
- (IBAction)SelectDepartment:(id)sender {
    
    [self.view endEditing:YES];
    self.departmentTextField.tintColor = [UIColor clearColor];
    
    [Dropobj fadeOut];
    [self showPopUpWithTitle:NSLocalizedString(@"Select Department",nil) withOption:_deptArray xy:CGPointMake(16, 58) size:CGSizeMake(287, 330) isMultiple:YES];
}

//select priotty
- (IBAction)SelectPriority:(id)sender {
    
    [ self.view endEditing:YES];
    self.priorityTextField.tintColor = [UIColor clearColor];
    
    [Dropobj fadeOut];
    [self showPopUpWithTitle:NSLocalizedString(@"Select Priority",nil) withOption:_priorityArray xy:CGPointMake(16, 58) size:CGSizeMake(287, 330) isMultiple:YES];
}

//select ticket types
- (IBAction)SelectTicketTypes:(id)sender {
    
    [self.view endEditing:YES];
    self.typeTextField.tintColor = [UIColor clearColor];
    
    [Dropobj fadeOut];
    [self showPopUpWithTitle:NSLocalizedString(@"Select Ticket Types",nil) withOption:_typeArray xy:CGPointMake(16, 58) size:CGSizeMake(287, 330) isMultiple:YES];
    
}
//select ticket source
- (IBAction)SelectTicketSource:(id)sender {
    
    [self.view endEditing:YES];
    self.sourceTextField.tintColor = [UIColor clearColor];
    
    [Dropobj fadeOut];
    [self showPopUpWithTitle:NSLocalizedString(@"Select Ticket Source",nil) withOption:_sourceArray xy:CGPointMake(16, 58) size:CGSizeMake(287, 330) isMultiple:YES];
}

//select ticket status
- (IBAction)SelectTicketStatus:(id)sender {
    
    [self.view endEditing:YES];
    self.statusTextField.tintColor = [UIColor clearColor];
    
    [Dropobj fadeOut];
    [self showPopUpWithTitle:NSLocalizedString(@"Select Ticket Source",nil) withOption:statusArray1 xy:CGPointMake(16, 58) size:CGSizeMake(287, 330) isMultiple:YES];
    
}

//select asignee
- (IBAction)SelectAssignee:(id)sender {
    
    [self.view endEditing:YES];
    self.assignTextField.tintColor = [UIColor clearColor];
    
    [Dropobj fadeOut];
    [self showPopUpWithTitle:NSLocalizedString(@"Select Department",nil) withOption:assignee xy:CGPointMake(16, 58) size:CGSizeMake(287, 330) isMultiple:NO];
}

-(void)showPopUpWithTitle:(NSString*)popupTitle withOption:(NSArray*)arrOptions xy:(CGPoint)point size:(CGSize)size isMultiple:(BOOL)isMultiple{
    
    
    Dropobj = [[DropDownListView alloc] initWithTitle:popupTitle options:arrOptions xy:point size:size isMultiple:isMultiple];
    Dropobj.delegate = self;
    [Dropobj showInView:self.view animated:YES];
    
    /*----------------Set DropDown backGroundColor-----------------*/
    [Dropobj SetBackGroundDropDown_R:0.0 G:108.0 B:194.0 alpha:0.70];
    
}

- (void)DropDownListView:(DropDownListView *)dropdownListView didSelectedIndex:(NSInteger)anIndex{
    /*----------------Get Selected Value[Single selection]-----------------*/
    
    // _textf1.text= [arryList objectAtIndex:anIndex];
    _assignTextField.text= [assignee objectAtIndex:anIndex];
    
}


- (void)DropDownListView:(DropDownListView *)dropdownListView Datalist:(NSArray*)ArryData{
    
    /*----------------Get Selected Value[Multiple selection]-----------------*/
    
    if([ArryData containsObject:@"Sales"] || [ArryData containsObject:@"Support"] || [ArryData containsObject:@"Operation"])
        
    {
        _departmentTextField.text= [ArryData componentsJoinedByString:@","];
    }
    
    
    if([ArryData containsObject:@"Low"] || [ArryData containsObject:@"High"] || [ArryData containsObject:@"Emergency"] || [ArryData containsObject:@"Normal"] || [ArryData containsObject:@"Test"]|| [ArryData containsObject:@"checkin"])
    {
        _priorityTextField.text= [ArryData componentsJoinedByString:@","];
    }
    
    
    if([ArryData containsObject:@"Question"] || [ArryData containsObject:@"Incident"] || [ArryData containsObject:@"Problem"] || [ArryData containsObject:@"Feature Request"])
    {
        _typeTextField.text= [ArryData componentsJoinedByString:@","];
    }
    
    if([ArryData containsObject:@"email"] || [ArryData containsObject:@"agent"] || [ArryData containsObject:@"facebook"] || [ArryData containsObject:@"twitter"] || [ArryData containsObject:@"call"]|| [ArryData containsObject:@"chat"] || [ArryData containsObject:@"web"])
    {
        _sourceTextField.text= [ArryData componentsJoinedByString:@","];
    }
    
    if([ArryData containsObject:@"Open"] || [ArryData containsObject:@"Resolved"] || [ArryData containsObject:@"Closed"] || [ArryData containsObject:@"Deleted"])
    {
        _statusTextField.text= [ArryData componentsJoinedByString:@","];
    }
    
    
}

- (void)DropDownListViewDidCancel{
    
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    
    if ([touch.view isKindOfClass:[UIView class]]) {
        [Dropobj fadeOut];
    }
}





- (IBAction)submitClicked:(id)sender {
    
    NSLog(@"Clicked");
    
    globalVariables.departmentTextFiled1=_departmentTextField.text;
    globalVariables.priorityTextFiled1=_priorityTextField.text;
    globalVariables.typeTextFiled1=_typeTextField.text;
    globalVariables.sourceTextFiled1=_sourceTextField.text;
    globalVariables.statusTextField=_statusTextField.text;
    globalVariables.assignedTextFiled1=_assignTextField.text;
    
    if([globalVariables.filterCondition isEqualToString:@"INBOX"])
    {
        globalVariables.deptt1=_departmentTextField.text;
        globalVariables.prioo1=_priorityTextField.text;
        globalVariables.typee1=_typeTextField.text;
        globalVariables.sourcee1=_sourceTextField.text;
        globalVariables.statuss1=_statusTextField.text;
        globalVariables.assignn1=_assignTextField.text;
        
        globalVariables.filterId=@"INBOXFilter";
        FilterLogic *fil=[self.storyboard instantiateViewControllerWithIdentifier:@"FilterLogicID"];
        
        [self.navigationController pushViewController:fil animated:YES];
    }
    else if([globalVariables.filterCondition isEqualToString:@"MYTICKETS"])
    {
        globalVariables.deptt1=_departmentTextField.text;
        globalVariables.prioo1=_priorityTextField.text;
        globalVariables.typee1=_typeTextField.text;
        globalVariables.sourcee1=_sourceTextField.text;
        globalVariables.statuss1=_statusTextField.text;
        globalVariables.assignn1=_assignTextField.text;
        
        globalVariables.filterId=@"MYTICKETSFilter";
        FilterLogic *fil=[self.storyboard instantiateViewControllerWithIdentifier:@"FilterLogicID"];
        
        [self.navigationController pushViewController:fil animated:YES];
    }
    else if([globalVariables.filterCondition isEqualToString:@"UNASSIGNED"])
    {
        globalVariables.deptt1=_departmentTextField.text;
        globalVariables.prioo1=_priorityTextField.text;
        globalVariables.typee1=_typeTextField.text;
        globalVariables.sourcee1=_sourceTextField.text;
        globalVariables.statuss1=_statusTextField.text;
        globalVariables.assignn1=_assignTextField.text;
        
        globalVariables.filterId=@"UNASSIGNEDFilter";
        FilterLogic *fil=[self.storyboard instantiateViewControllerWithIdentifier:@"FilterLogicID"];
        
        [self.navigationController pushViewController:fil animated:YES];
    }
    else if([globalVariables.filterCondition isEqualToString:@"CLOSED"])
    {
        globalVariables.deptt1=_departmentTextField.text;
        globalVariables.prioo1=_priorityTextField.text;
        globalVariables.typee1=_typeTextField.text;
        globalVariables.sourcee1=_sourceTextField.text;
        globalVariables.statuss1=_statusTextField.text;
        globalVariables.assignn1=_assignTextField.text;
        
        globalVariables.filterId=@"CLOSEDFilter";
        FilterLogic *fil=[self.storyboard instantiateViewControllerWithIdentifier:@"FilterLogicID"];
        
        [self.navigationController pushViewController:fil animated:YES];
    }
    else if([globalVariables.filterCondition isEqualToString:@"TRASH"])
    {
        globalVariables.deptt1=_departmentTextField.text;
        globalVariables.prioo1=_priorityTextField.text;
        globalVariables.typee1=_typeTextField.text;
        globalVariables.sourcee1=_sourceTextField.text;
        globalVariables.statuss1=_statusTextField.text;
        globalVariables.assignn1=_assignTextField.text;
        
        globalVariables.filterId=@"TRASHFilter";
        FilterLogic *fil=[self.storyboard instantiateViewControllerWithIdentifier:@"FilterLogicID"];
        
        [self.navigationController pushViewController:fil animated:YES];
    }
    else
    {
        NSLog(@"I am in FilterView Controller");
        NSLog(@" I am i elase part......No Condition is Executed");
    }
    
}


-(IBAction)flipView
{
    NSLog(@"Clciked");
    _departmentTextField.text=@"";
    _priorityTextField.text=@"";
    _typeTextField.text=@"";
    _sourceTextField.text=@"";
    _statusTextField.text=@"";
    _assignTextField.text=@"";
}

#pragma mark - UITextFieldDelegate
//
//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
//    return NO;
//}



-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}







@end



