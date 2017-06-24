//
//  GlobalVariables.h
//  SideMEnuDemo
//
//  Created by Narendra on 30/11/16.
//  Copyright © 2016 Ladybird websolutions pvt ltd. All rights reserved.
//

/*!
 @header GlobalVariables.h
 @brief This is the header file contain Global variable declaration.
 @author Mallikarjun
 @copyright 2015 Ladybird Web Solution Pvt Ltd.
 @version 1.6
 */

#import <Foundation/Foundation.h>

/**
 @class GlobalVariables
 
 @brief This class contains Global variable declaration
 
 @discussion It contains variable declaration that are commonly used throughout the app so that accessing and calling is very easy.
       Also it cointans Singleton class that contains global variables and global functions.It’s an extremely powerful way to share data between different parts of code without having to pass the data around manually.
 
 @superclass NSObject
 
 */
@interface GlobalVariables : NSObject

@property (strong, nonatomic) NSNumber *iD;
@property (strong, nonatomic) NSString *ticket_number;
//@property (strong, nonatomic) NSString *title;

@property (strong, nonatomic) NSString *OpenCount;
@property (strong, nonatomic) NSString *DeletedCount;
@property (strong, nonatomic) NSString *ClosedCount;
@property (strong, nonatomic) NSString *UnassignedCount;
@property (strong, nonatomic) NSString *MyticketsCount;
+ (instancetype)sharedInstance;

@end
