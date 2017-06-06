//
//  GlobalVariables.h
//  SideMEnuDemo
//
//  Created by Narendra on 30/11/16.
//  Copyright © 2016 Ladybird websolutions pvt ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

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
