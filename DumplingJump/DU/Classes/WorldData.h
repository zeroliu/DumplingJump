//
//  WorldData.h
//  DumplingJump
//
//  Created by LIU Xiyuan on 13-1-27.
//  Copyright (c) 2013年 CMU ETC. All rights reserved.
//

#import "CCNode.h"

@interface WorldData : NSObject

+(id) shared;
-(id) loadDataWithAttributName:(NSString *)name;
@end
