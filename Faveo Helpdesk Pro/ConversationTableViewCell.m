//
//  ConversationTableViewCell.m
//  SideMEnuDemo
//
//  Created by Narendra on 25/10/16.
//  Copyright © 2016 Ladybird websolutions pvt ltd. All rights reserved.
//
#import "HexColors.h"
#import "ConversationTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation ConversationTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
//        NSURL *url = [NSURL URLWithString:@"http://www.amazon.com"];
//        [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setUserProfileimage:(NSString*)imageUrl
{
   // self.profilePicView.layer.borderWidth=1.25f;
    self.profilePicView.layer.borderColor=[[UIColor hx_colorWithHexRGBAString:@"#0288D1"] CGColor];
    [self.profilePicView sd_setImageWithURL:[NSURL URLWithString:imageUrl]
                           placeholderImage:[UIImage imageNamed:@"default_pic.png"]];
    
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
//    dispatch_async(queue, ^(void) {
//        
//        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
//        
//        UIImage* image = [[UIImage alloc] initWithData:imageData];
//        if (image) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                self.profilePicView.image = image;
//                [self setNeedsLayout];
//                
//            });
//        }
//    });
}

@end
