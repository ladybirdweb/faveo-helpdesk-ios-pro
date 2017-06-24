//
//  Data.h
//  SideMEnuDemo
//
//  Created by Narendra on 29/11/16.
//  Copyright © 2016 Ladybird websolutions pvt ltd. All rights reserved.
//

/*!
 @header Data.h
 @brief This is the header file contain common variable declaration.
 @author Mallikarjun
 @copyright  2015 Ladybird Web Solution Pvt Ltd.
 @version    1.6
 */
#import <Foundation/Foundation.h>

/**
 @class Data
 
 @brief This class contains common variable declaration
 
 @discussion It contains variable declaration that are commonly used throughout the app so that accessing and calling is very easy.
 
 @superclass NSObject
 
 */

@interface Data : NSObject

@property (strong, nonatomic) NSNumber *iD;
@property (strong, nonatomic) NSString *ticket_number;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *first_name;
@property (strong, nonatomic) NSString *last_name;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *profile_pic;
@property (strong, nonatomic) NSString *created_at;

- (id)initWithJSONDictionary:(NSDictionary *)jsonDictionary;

@end
