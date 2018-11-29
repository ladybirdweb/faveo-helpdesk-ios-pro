//
//  attachmentListShowTableCell.h
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 30/03/18.
//  Copyright © 2018 Ladybird websolutions pvt ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 @class attachmentListShowTableCell
 
 @brief This used show attachment data.
 
 @discussion This is used show attachment details in the form of cells which contains baic information of the attachment like attachment type, attachment name and size of the attachment. This cell used in showAttachments.
 
 */
@interface attachmentListShowTableCell : UITableViewCell

/*!
 @property attachmentImage
 
 @brief This is an image property
 
 @discussion It used to show/display an image of attachment type
 */
@property (weak, nonatomic) IBOutlet UIImageView *attachmentImage;

/*!
 @property attachmentName
 
 @brief This is an label property
 
 @discussion It used to show/display attachment name.
 */
@property (weak, nonatomic) IBOutlet UILabel *attachmentName;

/*!
 @property sizeLabel
 
 @brief This is an label  property
 
 @discussion It used to show/display size of an attachment.
 */
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;

@end
