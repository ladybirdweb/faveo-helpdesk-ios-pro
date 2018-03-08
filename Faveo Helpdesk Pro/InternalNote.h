//
//  InternalNote.h
//  Faveo Helpdesk Pro
//
//  Created by Mallikarjun on 08/03/18.
//  Copyright © 2018 Ladybird websolutions pvt ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InternalNote : UIViewController


@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UIButton *addButton;

- (IBAction)addButtonAction:(id)sender;

@end
