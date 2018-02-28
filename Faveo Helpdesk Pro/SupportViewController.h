//
//  SupportViewController.h
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 27/02/18.
//  Copyright © 2018 Ladybird websolutions pvt ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SupportViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UITextView *emailTextView;

@property (weak, nonatomic) IBOutlet UITextView *subjectTextView;

@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (strong, nonatomic) IBOutlet UITableView *tableView1;

@property (weak, nonatomic) IBOutlet UIButton *submitButton;


- (IBAction)ButtonClicked:(id)sender;

@end
