//
//  MultpleTicketAssignTableViewController.h
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 04/01/18.
//  Copyright © 2018 Ladybird websolutions pvt ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MultpleTicketAssignTableViewController : UITableViewController<UITableViewDataSource,UITableViewDelegate>


- (IBAction)selectAssignee:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *cancelLabel;

@property (weak, nonatomic) IBOutlet UILabel *assignLabel;

@property (weak, nonatomic) IBOutlet UITextField *assinTextField;

@end
