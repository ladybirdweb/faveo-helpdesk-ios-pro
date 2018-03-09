//
//  TicketSearchViewController.h
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 09/03/18.
//  Copyright © 2018 Ladybird websolutions pvt ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TicketSearchViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *seachTextField;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControlObject;

- (IBAction)segmentedControlAction:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *tableview1;
@property (nonatomic, strong) NSString *path1;

@property (nonatomic) NSInteger page;

@end
