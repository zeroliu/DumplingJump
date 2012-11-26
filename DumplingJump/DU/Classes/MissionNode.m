//
//  MissionNode.m
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-11-25.
//  Copyright (c) 2012年 CMU ETC. All rights reserved.
//

#import "MissionNode.h"

@implementation MissionNode
@synthesize missionArray;


-(void)didLoadFromCCB
{
    missionArray = [NSArray arrayWithObjects:mission0, mission1, mission2, mission3, nil];
}

@end
