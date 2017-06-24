//
//  UIView+Shake.h
//  
//
//  Created by Narendra on 20/06/17.
//
//

/*!
 @header UIView+Shake.h
 @brief This is the header file contain variable declaration.
 @author Mallikarjun
 @copyright 2015 Ladybird Web Solution Pvt Ltd.
 @version 1.6
 */

#import <UIKit/UIKit.h>

@interface UIView (UIView_Shake)

-(void)shake;
-(void)shakeWithCallback:(void (^)(void))completeBlock;

@end
