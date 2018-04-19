//
//  ReplyTicketViewController.h
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 06/03/18.
//  Copyright © 2018 Ladybird websolutions pvt ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReplyTicketViewController : UITableViewController


@property (weak, nonatomic) IBOutlet UITextField *ccTextField;

@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (strong, nonatomic) IBOutlet UITableView *tableview1;
@property (weak, nonatomic) IBOutlet UILabel *addCCLabelButton;

- (IBAction)submitButtonClicked:(id)sender;


-(void)FetchCollaboratorAssociatedwithTicket;
@property (weak, nonatomic) IBOutlet UIButton 
*submitButton;
@property (weak, nonatomic) IBOutlet UILabel *viewCCandRemoveCCLabel;


@property (weak, nonatomic) IBOutlet UIImageView *fileImage;

@property (weak, nonatomic) IBOutlet UILabel *fileName123;


@property (weak, nonatomic) IBOutlet UILabel *fileSize123;


@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorOutlet;

@end

