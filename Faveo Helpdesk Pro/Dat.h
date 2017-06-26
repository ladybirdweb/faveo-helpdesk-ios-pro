//
//  Dat.h
//  Faveo Helpdesk Pro
//
//  Created by Narendra on 29/05/17.
//  Copyright © 2017 Ladybird websolutions pvt ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 @class Dat
 
 @brief This class contains common variable declaration
 
 @discussion It contains variable declaration that are commonly used throughout the app so that accessing and calling is very easy.
 
 @superclass NSObject
 */
@interface Dat : NSObject

/**
 @property name
 @brief It is used for defining is name of a user.
 */
@property (nonatomic,strong) NSString *name;

/**
 @property id1
 @brief It is used for defining is id of a user.
 */
@property (nonatomic,strong) NSString *id1;
@end
