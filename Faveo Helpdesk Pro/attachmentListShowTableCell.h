//
//  attachmentListShowTableCell.h
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 30/03/18.
//  Copyright © 2018 Ladybird websolutions pvt ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface attachmentListShowTableCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *attachmentImage;
@property (weak, nonatomic) IBOutlet UILabel *attachmentName;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;

@end
