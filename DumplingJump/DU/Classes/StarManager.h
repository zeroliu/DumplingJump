//
//  StarManager.h
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-11-12.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "Common.h"
#import "Star.h"

@interface StarManager : CCNode
+(id) shared;

-(void) addStar:(Star *)star;
-(void) dropStar:(NSString *)starName AtSlot:(int)slot;
-(void) dropRandomStar;
@end
