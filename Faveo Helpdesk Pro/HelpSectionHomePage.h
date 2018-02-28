//
//  HelpSectionHomePage.h
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 14/02/18.
//  Copyright © 2018 Ladybird websolutions pvt ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"

@interface HelpSectionHomePage : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *DouHaveQuestionButton;

- (IBAction)DouHaveQuestionButtonAction:(id)sender;

@end
