//
//  addCCView.h
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 06/03/18.
//  Copyright © 2018 Ladybird websolutions pvt ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface addCCView : UITableViewController
@property (strong, nonatomic) IBOutlet UITableView *tablview;
@property (weak, nonatomic) IBOutlet UITextField *userSearchTextField;

- (IBAction)addCCMethod:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *addButton;

@end
