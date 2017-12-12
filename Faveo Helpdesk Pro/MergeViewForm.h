//
//  MergeViewForm.h
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 08/12/17.
//  Copyright © 2017 Ladybird websolutions pvt ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MergeViewForm : UITableViewController<UITableViewDataSource,UITableViewDelegate>


@property (weak, nonatomic) IBOutlet UITextView *newtitleTextview;


@property (weak, nonatomic) IBOutlet UITextView *reasonTextView;

@property (weak, nonatomic) IBOutlet UITextField *parentTicketTextField;

@property (weak, nonatomic) IBOutlet UILabel *cancelLabel;

@property (weak, nonatomic) IBOutlet UILabel *mergeLabel;

- (IBAction)SelectParentTicket:(id)sender;



@end
