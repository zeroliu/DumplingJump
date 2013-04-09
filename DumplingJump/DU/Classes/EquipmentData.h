//
//  EquipmentData.h
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-12-9.
//  Copyright (c) 2012年 CMU ETC. All rights reserved.
//

#import "CCNode.h"

@interface EquipmentData : CCNode
@property (nonatomic, retain) NSDictionary *dataDictionary;
@property (nonatomic, retain) NSMutableDictionary *structedDictionary;
+(id) shared;
-(NSDictionary *) findEquipmentWithGroupID:(int)groupID;
-(int) isAffordable:(int)starNum; //Check if player can buy anything with the starNum
//-(void) saveEquipmentData;

@end
