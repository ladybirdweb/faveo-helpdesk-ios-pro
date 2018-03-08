//
//  HelpSectionHomePageCell.m
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 14/02/18.
//  Copyright © 2018 Ladybird websolutions pvt ltd. All rights reserved.
//

#import "HelpSectionHomePageCell.h"

@implementation HelpSectionHomePageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    CGRect rect = CGRectMake(0,0,20,20);
    UIGraphicsBeginImageContext( rect.size );
    [_image drawRect:rect];
  //  [image drawInRect:rect];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
