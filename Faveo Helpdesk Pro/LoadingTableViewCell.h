//
//  LoadingTableViewCell.h
//  SideMEnuDemo
//
//  Created by Narendra on 05/12/16.
//  Copyright © 2016 Ladybird websolutions pvt ltd. All rights reserved.
//

/*!
 @header LoadingTableViewCell
 @brief This is the header file conatins  Activity Indicator i.e Loader.
 @author Mallikarjun
 @copyright 2015 Ladybird Web Solution Pvt Ltd.
 @version 1.6
 */
#import <UIKit/UIKit.h>

@interface LoadingTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *loadingLbl;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@end
