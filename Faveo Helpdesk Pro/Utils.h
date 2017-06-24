//
//  Utils.h
//  SideMEnuDemo
//
//  Created by Narendra on 07/11/16.
//  Copyright © 2016 Ladybird websolutions pvt ltd. All rights reserved.
//

/*!
 @header Utils.h
 @brief This is the header file where validation of super-code is contained.
        This file contains the validation and their implementation code.
 @author Mallikarjun
 @copyright  2015 Ladybird Web Solution Pvt Ltd.
 @version  1.6
 */

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

/**
 @class AppDelegate
 
 @brief This class contains validation methods.
 
 @discussion This file contains the <b>validation</b>code used for this project.Like username validation, e-mail validation, phone number validation, URL validation of a company. Also it contains <b>sliding</b>or <b>Animating</b> code so that one view move to another direction i.e view will slide to right to left, left to right , top to bottom or bottom to top
 
 @superclass NSObject
 
 */
@interface Utils : NSObject

+(BOOL)userNameValidation:(NSString *)strUsername;
+(BOOL)emailValidation:(NSString *)strEmail;
+(BOOL)phoneNovalidation:(NSString *)strPhonr;
+(BOOL)validateUrl: (NSString *) url ;
-(BOOL)compareDates:(NSString*)date1;

+(BOOL)isEmpty:(NSString *)str;


-(void)viewSlideInFromRightToLeft:(UIView *)views;
-(void)viewSlideInFromLeftToRight:(UIView *)views;
-(void)viewSlideInFromTopToBottom:(UIView *)views;
-(void)viewSlideInFromBottomToTop:(UIView *)views;

-(void)showAlertWithMessage:(NSString*)message sendViewController:(UIViewController *)viewController;
-(NSString *)getLocalDateTimeFromUTC:(NSString *)strDate;
-(NSString *)getLocalDateTimeFromUTCDueDate:(NSString *)strDate;




@end
