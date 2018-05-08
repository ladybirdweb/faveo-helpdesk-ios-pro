//
//  EditDetailTableViewController.h
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 23/09/17.
//  Copyright © 2017 Ladybird websolutions pvt ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditDetailTableViewController : UITableViewController<UITextFieldDelegate>



@property (weak, nonatomic) IBOutlet UITextField *helpTopicTextField;

@property (weak, nonatomic) IBOutlet UITextField *slaTextField;

@property (weak, nonatomic) IBOutlet UITextField *deptTextField;

@property (weak, nonatomic) IBOutlet UITextField *subjectTextField;

@property (weak, nonatomic) IBOutlet UITextField *statusTextField;

@property (weak, nonatomic) IBOutlet UITextField *typeTextField;

@property (weak, nonatomic) IBOutlet UITextField *priorityTextField;

@property (weak, nonatomic) IBOutlet UITextField *sourceTextField;


@property (nonatomic, strong) NSArray * helptopicsArray;

@property (nonatomic, strong) NSArray * slaPlansArray;

@property (nonatomic, strong) NSArray * deptArray;

@property (nonatomic, strong) NSArray * priorityArray;

@property (nonatomic, strong) NSArray * sourceArray;

@property (nonatomic, strong) NSArray * statusArray;

@property (nonatomic, strong) NSArray * typeArray;


@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@property (nonatomic, assign) NSInteger selectedIndex;



- (IBAction)sourceClicked:(id)sender;

- (IBAction)typeClicked:(id)sender;

- (IBAction)statusClicked:(id)sender;
- (IBAction)helpTopicClicked:(id)sender;



- (IBAction)assignClicked:(id)sender;

- (IBAction)saveClicked:(id)sender;

- (IBAction)priorityClicked:(id)sender;




//@property (nonatomic, strong) NSMutableArray * assignArray;


@property (weak, nonatomic) IBOutlet UITextField *assinTextField;

@property (weak, nonatomic) IBOutlet UITextView *subjectTextView;


@end
