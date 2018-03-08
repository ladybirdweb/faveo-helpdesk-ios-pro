//
//  UIView+Shake.h
//  
//
//  Created by Narendra on 20/06/17.
//
//



#import <UIKit/UIKit.h>

@interface UIView (UIView_Shake)

-(void)shake;
-(void)shakeWithCallback:(void (^)(void))completeBlock;

@end
