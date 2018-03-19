//
//  userSearchDataCell.m
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 10/03/18.
//  Copyright © 2018 Ladybird websolutions pvt ltd. All rights reserved.
//

#import "userSearchDataCell.h"
#import "HexColors.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation userSearchDataCell

-(void)setUserProfileimage:(NSString*)imageUrl
{
   
    self.userProfileImage.layer.borderColor=[[UIColor hx_colorWithHexRGBAString:@"#0288D1"] CGColor];
    [self.userProfileImage sd_setImageWithURL:[NSURL URLWithString:imageUrl]
                           placeholderImage:[UIImage imageNamed:@"default_pic.png"]];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.userProfileImage.layer.cornerRadius = 25;
    self.userProfileImage.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
