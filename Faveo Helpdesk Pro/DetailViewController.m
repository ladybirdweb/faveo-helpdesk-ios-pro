//
//  DetailViewController.m
//  SideMEnuDemo
//
//  Created by Narendra on 16/09/16.
//  Copyright © 2016 Ladybird websolutions pvt ltd. All rights reserved.
//

#import "DetailViewController.h"
#import "ActionSheetStringPicker.h"
#import "HexColors.h"
#import "Utils.h"
#import "AppConstanst.h"
#import "MyWebservices.h"
#import "Reachability.h"
#import "AppDelegate.h"
#import "GlobalVariables.h"
#import "RKDropdownAlert.h"
#import "IQKeyboardManager.h"

@interface DetailViewController (){
    
    Utils *utils;
    NSUserDefaults *userDefaults;
    GlobalVariables *globalVariables;
    
    NSNumber *sla_id;
    NSNumber *type_id;
    NSNumber *help_topic_id;
    NSNumber *dept_id;
    NSNumber *priority_id;
    NSNumber *source_id;
    NSNumber *status_id;
    
    NSMutableArray * sla_idArray;
    NSMutableArray * type_idArray;
    NSMutableArray * dept_idArray;
    NSMutableArray * pri_idArray;
    NSMutableArray * helpTopic_idArray;
    NSMutableArray * status_idArray;
    NSMutableArray * source_idArray;
    
}
@property (nonatomic,retain) UIImageView *imgViewLoading;
//@property (nonatomic,retain) UIActivityIndicatorView *activityIndicatorObject;

- (void)helpTopicWasSelected:(NSNumber *)selectedIndex element:(id)element;
- (void)slaWasSelected:(NSNumber *)selectedIndex element:(id)element;
- (void)deptWasSelected:(NSNumber *)selectedIndex element:(id)element;
- (void)priorityWasSelected:(NSNumber *)selectedIndex element:(id)element;

- (void)actionPickerCancelled:(id)sender;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:false];
    sla_id=[[NSNumber alloc]init];
    dept_id=[[NSNumber alloc]init];
    help_topic_id=[[NSNumber alloc]init];
    priority_id=[[NSNumber alloc]init];
    source_id=[[NSNumber alloc]init];
    status_id=[[NSNumber alloc]init];
    type_id=[[NSNumber alloc]init];
    
    _saveButton.backgroundColor=[UIColor hx_colorWithHexRGBAString:@"#00aeef"];
    _imgViewLoading = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 78, 78)];
    _imgViewLoading.image=[UIImage imageNamed:@"loading_imgBlue_78x78"];
    _imgViewLoading.center=CGPointMake(self.view.frame.size.width/2,(self.view.frame.size.height/2)-100);
    [self.view addSubview:_imgViewLoading];
    [self.imgViewLoading.layer addAnimation:[self imageAnimationForEmptyDataSet] forKey:@"transform"];
    //_activityIndicatorObject = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    //_activityIndicatorObject.center =CGPointMake(self.view.frame.size.width/2,(self.view.frame.size.height/2)-100);
    // _activityIndicatorObject.color=[UIColor hx_colorWithHexRGBAString:@"#00aeef"];
    //[self.view addSubview:_activityIndicatorObject];
    
    utils=[[Utils alloc]init];
    globalVariables=[GlobalVariables sharedInstance];
   // _subjectTextField.text=globalVariables.title;
    userDefaults=[NSUserDefaults standardUserDefaults];
    //[_activityIndicatorObject startAnimating];
    [self reload];
    
    [self readFromPlist];
    self.tableView.tableFooterView=[[UIView alloc] initWithFrame:CGRectZero];
    // Do any additional setup after loading the view.
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:true];
}

-(void)reload{
    
    if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable)
    {
        //connection unavailable
        [_imgViewLoading setHidden:YES];
        // [_activityIndicatorObject stopAnimating];
        [RKDropdownAlert title:APP_NAME message:NO_INTERNET backgroundColor:[UIColor hx_colorWithHexRGBAString:FAILURE_COLOR] textColor:[UIColor whiteColor]];
        
    }else{
        
        NSString *url=[NSString stringWithFormat:@"%@helpdesk/ticket?api_key=%@&ip=%@&token=%@&id=%@",[userDefaults objectForKey:@"companyURL"],API_KEY,IP,[userDefaults objectForKey:@"token"],globalVariables.iD];
        
        MyWebservices *webservices=[MyWebservices sharedInstance];
        [webservices httpResponseGET:url parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
            
            if (error) {
                
                [utils showAlertWithMessage:@"Error" sendViewController:self];
                NSLog(@"Thread-NO4-getDetail-Refresh-error == %@",error.localizedDescription);
                
                return ;
            }
            if (error || [msg containsString:@"Error"]) {
                
                [self.refreshControl endRefreshing];
                //[_activityIndicatorObject stopAnimating];
                [_imgViewLoading setHidden:YES];
                
                if (msg) {
                    [utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",msg] sendViewController:self];
                    
                }else if(error)  {
                    [utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",error.localizedDescription] sendViewController:self];
                    NSLog(@"Thread-NO4-getInbox-Refresh-error == %@",error.localizedDescription);
                }
                
                return ;
            }
            
            if ([msg isEqualToString:@"tokenRefreshed"]) {
                
                [self reload];
                NSLog(@"Thread--NO4-call-getDetail");
                return;
            }
            
            if (json) {
                //NSError *error;
                
                NSLog(@"Thread-NO4--getDetailAPI--%@",json);
                NSDictionary *dic= [json objectForKey:@"result"];
                dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        //                        _clientNameTextField.text=[NSString stringWithFormat:@"%@ %@",[dic objectForKey:@"first_name"],[dic objectForKey:@"last_name"]];
                        _createdDateTextField.text= [utils getLocalDateTimeFromUTC:[dic objectForKey:@"created_at"]];
                        
                        if (([[dic objectForKey:@"first_name"] isEqual:[NSNull null]] ) || ( [[dic objectForKey:@"first_name"] length] == 0 )) {
                            _firstnameTextField.text=NSLocalizedString(@"Not Available",nil);
                        }else _firstnameTextField.text=[dic objectForKey:@"first_name"];
                        
//                        if (([[dic objectForKey:@"last_name"] isEqual:[NSNull null]] ) || ( [[dic objectForKey:@"last_name"] length] == 0 )) {
//                            _lastnameTextField.text=NSLocalizedString(@"Not Available",nil);
//                        }else _lastnameTextField.text= [dic objectForKey:@"last_name"];
                        
                        globalVariables.ticket_number=[dic objectForKey:@"ticket_number"];
                        //globalVariables.title=[dic objectForKey:@"title"];
                        _subjectTextField.text=[dic objectForKey:@"title"];
                        _emailTextField.text=[dic objectForKey:@"email"];
                        _lastResponseDateTextField.text=[utils getLocalDateTimeFromUTC:[dic objectForKey:@"updated_at"]];
                        
                        
                        // _deptTextField.text= [dic objectForKey:@"dept_name"];
                        // _slaTextField.text=[dic objectForKey:@"sla_name"];
                        
                        if (([[dic objectForKey:@"type_name"] isEqual:[NSNull null]] ) || ( [[dic objectForKey:@"type_name"] length] == 0 )) {
                            
                        }else _typeTextField.text=[dic objectForKey:@"type_name"];
                        
                        if (([[dic objectForKey:@"helptopic_name"] isEqual:[NSNull null]] ) || ( [[dic objectForKey:@"helptopic_name"] length] == 0 )) {
                            _helpTopicTextField.text=@"Nil";
                            
                        }else _helpTopicTextField.text=[dic objectForKey:@"helptopic_name"];
                        
                        
                        if (([[dic objectForKey:@"source_name"] isEqual:[NSNull null]] ) || ( [[dic objectForKey:@"source_name"] length] == 0 )) {
                           _sourceTextField.text=@"Nil";
                            
                        }else _sourceTextField.text=[dic objectForKey:@"source_name"];
                        
                        if (([[dic objectForKey:@"priority_name"] isEqual:[NSNull null]] ) || ( [[dic objectForKey:@"priority_name"] length] == 0 )) {
                           _priorityTextField.text=@"Nil";
                            
                        }else _priorityTextField.text=[dic objectForKey:@"priority_name"];
                        
                       
                     
                        
                       // _statusTextField.text= [dic objectForKey:@"status_name"];
                        
                        _dueDateTextField.text= [utils getLocalDateTimeFromUTCDueDate:[dic objectForKey:@"duedate"]];
                        
                        [self.refreshControl endRefreshing];
                        [_imgViewLoading setHidden:YES];
                        //[_activityIndicatorObject stopAnimating];
                        [self.tableView reloadData];
                        
                    });
                });
            }
            
            NSLog(@"Thread-NO5-getDetail-closed");
            
        }];
    }
}


-(void)readFromPlist{
    // Read plist from bundle and get Root Dictionary out of it
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"faveoData.plist"];
    
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
    //NSArray *staffsArray=[resultDic objectForKey:@"staffs"];
    NSArray *statusArray=[resultDic objectForKey:@"status"];
    NSArray *typeArray=[resultDic objectForKey:@"type"];
    
    //    NSLog(@"resultDic2--%@,%@,%@,%@,%@,%@,%@,%@",deptArray,helpTopicArray,prioritiesArray,slaArray,sourcesArray,staffsArray,statusArray,teamArray);
    
    NSMutableArray *deptMU=[[NSMutableArray alloc]init];
    NSMutableArray *slaMU=[[NSMutableArray alloc]init];
    NSMutableArray *helptopicMU=[[NSMutableArray alloc]init];
    NSMutableArray *priMU=[[NSMutableArray alloc]init];
    NSMutableArray *statusMU=[[NSMutableArray alloc]init];
    NSMutableArray *sourceMU=[[NSMutableArray alloc]init];
    NSMutableArray *typeMU=[[NSMutableArray alloc]init];
    
    
    dept_idArray=[[NSMutableArray alloc]init];
    sla_idArray=[[NSMutableArray alloc]init];
    helpTopic_idArray=[[NSMutableArray alloc]init];
    pri_idArray=[[NSMutableArray alloc]init];
    status_idArray=[[NSMutableArray alloc]init];
    source_idArray=[[NSMutableArray alloc]init];
    type_idArray=[[NSMutableArray alloc]init];
    
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
    
    for (NSDictionary *dicc in statusArray) {
        if ([dicc objectForKey:@"name"]) {
            [statusMU addObject:[dicc objectForKey:@"name"]];
            [status_idArray addObject:[dicc objectForKey:@"id"]];
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
    _statusArray=[statusMU copy];
    _sourceArray=[sourceMU copy];
    _typeArray=[typeMU copy];
    
}


- (IBAction)sourceClicked:(id)sender {
    [_subjectTextField resignFirstResponder];
    if (!_sourceArray||!_sourceArray.count) {
        _sourceTextField.text=NSLocalizedString(@"Not Available",nil);
        source_id=0;
    }else{
        [ActionSheetStringPicker showPickerWithTitle:@"Select Source" rows:_sourceArray initialSelection:0 target:self successAction:@selector(sourceWasSelected:element:) cancelAction:@selector(actionPickerCancelled:) origin:sender];
    }
}



- (IBAction)statusClicked:(id)sender {
    [_subjectTextField resignFirstResponder];
    if (!_statusArray||!_statusArray.count) {
        _statusTextField.text=NSLocalizedString(@"Not Available",nil);
        status_id=0;
    }else{
        [ActionSheetStringPicker showPickerWithTitle:@"Select Status" rows:_statusArray initialSelection:0 target:self successAction:@selector(statusWasSelected:element:) cancelAction:@selector(actionPickerCancelled:) origin:sender];
    }
}


- (IBAction)helpTopicClicked:(id)sender {
    [_subjectTextField resignFirstResponder];
    
    if (!_helptopicsArray||!_helptopicsArray.count) {
        _helpTopicTextField.text=NSLocalizedString(@"Not Available",nil);
        help_topic_id=0;
    }else{
        [ActionSheetStringPicker showPickerWithTitle:@"Select Helptopic" rows:_helptopicsArray initialSelection:0 target:self successAction:@selector(helpTopicWasSelected:element:) cancelAction:@selector(actionPickerCancelled:) origin:sender];
    }
    
}

- (IBAction)slaClicked:(id)sender {
    [_subjectTextField resignFirstResponder];
    
    if (!_slaPlansArray||!_slaPlansArray.count) {
        _slaTextField.text=NSLocalizedString(@"Not Available",nil);
        sla_id=0;
        
    }else{
        [ActionSheetStringPicker showPickerWithTitle:@"Select SLA" rows:_slaPlansArray initialSelection:0 target:self successAction:@selector(slaWasSelected:element:) cancelAction:@selector(actionPickerCancelled:) origin:sender];
    }
    
}

- (IBAction)deptClicked:(id)sender {
    [_subjectTextField resignFirstResponder];
    
    if (!_deptArray||!_deptArray.count) {
        _deptTextField.text=NSLocalizedString(@"Not Available",nil);
        dept_id=0;
    }else{
        [ActionSheetStringPicker showPickerWithTitle:@"Select Department" rows:_deptArray initialSelection:0 target:self successAction:@selector(deptWasSelected:element:) cancelAction:@selector(actionPickerCancelled:) origin:sender];
    }
    
}

- (IBAction)typeClicked:(id)sender{
    [_subjectTextField resignFirstResponder];
    if (!_typeArray||![_typeArray count]) {
        _typeTextField.text=NSLocalizedString(@"Not Available",nil);
        type_id=0;
        
    }else{
        [ActionSheetStringPicker showPickerWithTitle:@"Select Ticket Type" rows:_typeArray initialSelection:0 target:self successAction:@selector(typeWasSelected:element:) cancelAction:@selector(actionPickerCancelled:) origin:sender];
    }
    
}

- (IBAction)priorityClicked:(id)sender {
    [_subjectTextField resignFirstResponder];
    if (!_priorityArray||![_priorityArray count]) {
        _priorityTextField.text=NSLocalizedString(@"Not Available",nil);
        priority_id=0;
        
    }else{
        [ActionSheetStringPicker showPickerWithTitle:@"Select Priority" rows:_priorityArray initialSelection:0 target:self successAction:@selector(priorityWasSelected:element:) cancelAction:@selector(actionPickerCancelled:) origin:sender];
    }
    
}

- (IBAction)saveClicked:(id)sender {
    
    //    if (self.statusTextField.text.length==0){
    //        [RKDropdownAlert title:APP_NAME message:@"Please enter STATUS" backgroundColor:[UIColor hx_colorWithHexRGBAString:ALERT_COLOR] textColor:[UIColor whiteColor]];
    //        //[utils showAlertWithMessage:@"Please select STATUS" sendViewController:self];
    //    }else
    //    if (self.slaTextField.text.length==0){
    //        [RKDropdownAlert title:APP_NAME message:@"Please enter SLA" backgroundColor:[UIColor hx_colorWithHexRGBAString:ALERT_COLOR] textColor:[UIColor whiteColor]];
    //        //[utils showAlertWithMessage:@"Please select SLA" sendViewController:self];
    //    }else
    //
//    if (self.typeTextField.text.length==0){
//        [RKDropdownAlert title:APP_NAME message:@"Please enter TICKET TYPE" backgroundColor:[UIColor hx_colorWithHexRGBAString:ALERT_COLOR] textColor:[UIColor whiteColor]];
//    }else
    if (self.subjectTextField.text.length==0) {
        [RKDropdownAlert title:APP_NAME message:NSLocalizedString(@"Please enter SUBJECT",nil) backgroundColor:[UIColor hx_colorWithHexRGBAString:ALERT_COLOR] textColor:[UIColor whiteColor]];
        // [utils showAlertWithMessage:@"Please enter SUBJECT" sendViewController:self];
    }else if (self.helpTopicTextField.text.length==0) {
        [RKDropdownAlert title:APP_NAME message:NSLocalizedString(@"Please select HELP-TOPIC",nil) backgroundColor:[UIColor hx_colorWithHexRGBAString:ALERT_COLOR] textColor:[UIColor whiteColor]];
        // [utils showAlertWithMessage:@"Please select HELP-TOPIC" sendViewController:self];
    }else if (self.priorityTextField.text.length==0){
        [RKDropdownAlert title:APP_NAME message:NSLocalizedString(@"Please select PRIORITY" ,nil) backgroundColor:[UIColor hx_colorWithHexRGBAString:ALERT_COLOR] textColor:[UIColor whiteColor]];
        //[utils showAlertWithMessage:@"Please select PRIORITY" sendViewController:self];
    }else  if (self.sourceTextField.text.length==0){
        [RKDropdownAlert title:APP_NAME message:NSLocalizedString(@"Please select SOURCE" ,@"Please select SOURCE") backgroundColor:[UIColor hx_colorWithHexRGBAString:ALERT_COLOR] textColor:[UIColor whiteColor]];
        //[utils showAlertWithMessage:@"Please select SOURCE" sendViewController:self];
    }else  {
        [self save];
    }
    
}

-(void)save{
    if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable)
    {
        //connection unavailable
        [RKDropdownAlert title:APP_NAME message:NO_INTERNET backgroundColor:[UIColor hx_colorWithHexRGBAString:FAILURE_COLOR] textColor:[UIColor whiteColor]];
    }else{
        if (_typeTextField.text.length!=0) {
             type_id=[NSNumber numberWithInteger:1+[_typeArray indexOfObject:_typeTextField.text]];
        }else type_id=0;
       
        priority_id=[NSNumber numberWithInteger:1+[_priorityArray indexOfObject:_priorityTextField.text]];
        help_topic_id = [NSNumber numberWithInteger:1+[_helptopicsArray indexOfObject:_helpTopicTextField.text]];
        sla_id = [NSNumber numberWithInteger:1+[_slaPlansArray indexOfObject:_slaTextField.text]];
        source_id = [NSNumber numberWithInteger:1+[_sourceArray indexOfObject:_sourceTextField.text]];
        status_id = [NSNumber numberWithInteger:1+[_statusArray indexOfObject:_statusTextField.text]];
        
        sla_id=[NSNumber numberWithInt:1];
        [[AppDelegate sharedAppdelegate] showProgressView];
        
        NSString *url=[NSString stringWithFormat:@"%@helpdesk/edit?api_key=%@&ip=%@&token=%@&ticket_id=%@&help_topic=%@&ticket_type=%@&ticket_priority=%@&ticket_source=%@&subject=%@",[userDefaults objectForKey:@"companyURL"],API_KEY,IP,[userDefaults objectForKey:@"token"],globalVariables.iD,help_topic_id,type_id,priority_id,source_id,_subjectTextField.text];
        
        MyWebservices *webservices=[MyWebservices sharedInstance];
        
        [webservices httpResponsePOST:url parameter:@"" callbackHandler:^(NSError *error,id json,NSString* msg) {
            [[AppDelegate sharedAppdelegate] hideProgressView];
            
            if (error || [msg containsString:@"Error"]) {
                
                if (msg) {
                    
                    [utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",msg] sendViewController:self];
                    
                }else if(error)  {
                    [utils showAlertWithMessage:[NSString stringWithFormat:@"Error-%@",error.localizedDescription] sendViewController:self];
                    NSLog(@"Thread-NO4-getInbox-Refresh-error == %@",error.localizedDescription);
                }
                
                return ;
            }
            
            if ([msg isEqualToString:@"tokenRefreshed"]) {
                
                [self save];
                NSLog(@"Thread--NO4-call-postCreateTicket");
                return;
            }
            
            if (json) {
                NSLog(@"JSON-CreateTicket-%@",json);
                if ([json objectForKey:@"result"]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [RKDropdownAlert title:APP_NAME message:@"Updated successfully!" backgroundColor:[UIColor hx_colorWithHexRGBAString:SUCCESS_COLOR] textColor:[UIColor whiteColor]];
                        
                        //[utils showAlertWithMessage:@"Updated successfully!" sendViewController:self];
                    });
                }
            }
            NSLog(@"Thread-NO5-postCreateTicket-closed");
            
        }];
    }
}

- (void)actionPickerCancelled:(id)sender {
    NSLog(@"Delegate has been informed that ActionSheetPicker was cancelled");
}
- (void)sourceWasSelected:(NSNumber *)selectedIndex element:(id)element {
    source_id=(source_idArray)[(NSUInteger) [selectedIndex intValue]];
    // self.selectedIndex = [selectedIndex intValue];
    
    //may have originated from textField or barButtonItem, use an IBOutlet instead of element
    self.sourceTextField.text = (_sourceArray)[(NSUInteger) [selectedIndex intValue]];
}
- (void)typeWasSelected:(NSNumber *)selectedIndex element:(id)element {
    type_id=(type_idArray)[(NSUInteger) [selectedIndex intValue]];
    // self.selectedIndex = [selectedIndex intValue];
    
    //may have originated from textField or barButtonItem, use an IBOutlet instead of element
    self.typeTextField.text = (_typeArray)[(NSUInteger) [selectedIndex intValue]];
}

- (void)statusWasSelected:(NSNumber *)selectedIndex element:(id)element {
    status_id=(status_idArray)[(NSUInteger) [selectedIndex intValue]];
    
    //self.selectedIndex = [selectedIndex intValue];
    
    //may have originated from textField or barButtonItem, use an IBOutlet instead of element
    self.statusTextField.text = (_statusArray)[(NSUInteger) [selectedIndex intValue]];
}

- (void)helpTopicWasSelected:(NSNumber *)selectedIndex element:(id)element {
    help_topic_id=(helpTopic_idArray)[(NSUInteger) [selectedIndex intValue]];
    // self.selectedIndex = [selectedIndex intValue];
    
    //may have originated from textField or barButtonItem, use an IBOutlet instead of element
    self.helpTopicTextField.text = (_helptopicsArray)[(NSUInteger) [selectedIndex intValue]];
}

- (void)slaWasSelected:(NSNumber *)selectedIndex element:(id)element {
    sla_id=(sla_idArray)[(NSUInteger) [selectedIndex intValue]];
    // self.selectedIndex = [selectedIndex intValue];
    
    //may have originated from textField or barButtonItem, use an IBOutlet instead of element
    self.slaTextField.text = (_slaPlansArray)[(NSUInteger) [selectedIndex intValue]];
}
- (void)deptWasSelected:(NSNumber *)selectedIndex element:(id)element {
    dept_id=(dept_idArray)[(NSUInteger) [selectedIndex intValue]];
    // self.selectedIndex = [selectedIndex intValue];
    
    //may have originated from textField or barButtonItem, use an IBOutlet instead of element
    self.deptTextField.text = (_deptArray)[(NSUInteger) [selectedIndex intValue]];
}
- (void)priorityWasSelected:(NSNumber *)selectedIndex element:(id)element {
    priority_id=(pri_idArray)[(NSUInteger) [selectedIndex intValue]];
    
    //self.selectedIndex = [selectedIndex intValue];
    
    //may have originated from textField or barButtonItem, use an IBOutlet instead of element
    self.priorityTextField.text = (_priorityArray)[(NSUInteger) [selectedIndex intValue]];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if (textField.tag==2) {
        
        [_priorityTextField resignFirstResponder];
        if (!_priorityArray||![_priorityArray count]) {
            _priorityTextField.text=NSLocalizedString(@"Not Available",nil);
            priority_id=0;
            
        }else{
            [ActionSheetStringPicker showPickerWithTitle:@"Select Priority" rows:_priorityArray initialSelection:0 target:self successAction:@selector(priorityWasSelected:element:) cancelAction:@selector(actionPickerCancelled:) origin:self.view];
        }
        
        // return NO;
    }else if(textField.tag==3){
        //[_subjectTextField resignFirstResponder];
        [_helpTopicTextField resignFirstResponder];
        if (!_helptopicsArray||!_helptopicsArray.count) {
            _helpTopicTextField.text=NSLocalizedString(@"Not Available",nil);
            help_topic_id=0;
        }else{
            [ActionSheetStringPicker showPickerWithTitle:@"Select Helptopic" rows:_helptopicsArray initialSelection:0 target:self successAction:@selector(helpTopicWasSelected:element:) cancelAction:@selector(actionPickerCancelled:) origin:self.view];
        }
        // return NO;
    }else if(textField.tag==4){
        [_sourceTextField resignFirstResponder];
        //[_subjectTextField resignFirstResponder];
        if (!_sourceArray||!_sourceArray.count) {
            _sourceTextField.text=NSLocalizedString(@"Not Available",nil);
            source_id=0;
        }else{
            [ActionSheetStringPicker showPickerWithTitle:@"Select Source" rows:_sourceArray initialSelection:0 target:self successAction:@selector(sourceWasSelected:element:) cancelAction:@selector(actionPickerCancelled:) origin:self.view];
        }
        // return  NO;
    }else if(textField.tag==5){
        [_typeTextField resignFirstResponder];
        
        if (!_typeArray||!_typeArray.count) {
            _typeTextField.text=NSLocalizedString(@"Not Available",nil);
            type_id=0;
        }else{
            [ActionSheetStringPicker showPickerWithTitle:@"Select Ticket Type" rows:_typeArray initialSelection:0 target:self successAction:@selector(typeWasSelected:element:) cancelAction:@selector(actionPickerCancelled:) origin:self.view];
        }
        // return  NO;
    }else{
        
    }
    // return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CAAnimation *)imageAnimationForEmptyDataSet{
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    animation.toValue = [NSValue valueWithCATransform3D: CATransform3DMakeRotation(M_PI_2, 0.0, 0.0, 1.0) ];
    animation.duration = 0.25;
    animation.cumulative = YES;
    animation.repeatCount = MAXFLOAT;
    
    return animation;
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    // verify the text field you wanna validate
    if (textField == _subjectTextField) {
        
        // do not allow the first character to be space | do not allow more than one space
        if ([string isEqualToString:@" "]) {
            if (!textField.text.length)
                return NO;
        }
        
        // allow backspace
        if ([textField.text stringByReplacingCharactersInRange:range withString:string].length < textField.text.length) {
            return YES;
        }
        
        // limit the input to only the stuff in this character set, so no emoji or cirylic or any other insane characters
        NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890 "];
        
        if ([string rangeOfCharacterFromSet:set].location == NSNotFound) {
            return NO;
        }
        
    }
    
    return YES;
}

@end
