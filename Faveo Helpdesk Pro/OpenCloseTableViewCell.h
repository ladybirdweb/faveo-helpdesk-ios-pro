//
//  OpenCloseTableViewCell.h
//  SideMEnuDemo
//
//  Created by Narendra on 25/10/16.
//  Copyright © 2016 Ladybird websolutions pvt ltd. All rights reserved.
//

/*!
 @header OpenCloseTableViewCell
 @brief This is the header file contain open or close ticket process.
 @author Mallikarjun
 @copyright 2015 Ladybird Web Solution Pvt Ltd.
 @version 1.6
 */

#import <UIKit/UIKit.h>

@interface OpenCloseTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *ticketNumberLbl;
@property (weak, nonatomic) IBOutlet UILabel *ticketSubLbl;
@property (weak, nonatomic) IBOutlet UIView *indicationView;

@end
