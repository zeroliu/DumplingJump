//
//  ScoreManager.h
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-8-3.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "Common.h"

@interface ScoreManager : CCNode
{
    float distance;
    int level;
    int multiplyer;
}
@property (readonly, nonatomic) float distance;
@property (assign, nonatomic) int level;
@property (assign, nonatomic) int multiplyer;

+(id) shared;
-(void) reset;
-(int) increaseDistance;
@end
