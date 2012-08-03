//
//  ScoreManager.m
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-8-3.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "ScoreManager.h"

@implementation ScoreManager
@synthesize distance,level,multiplyer;

+(id) shared
{
    static id shared = nil;
    if (shared == nil)
    {
        shared = [[ScoreManager alloc] init];
    }
    
    return shared;
}

-(id) init
{
    if (self = [super init])
    {
        distance = 0;
        level = 0;
        //TODO: Read multiplyer from plist
        multiplyer = 1;
    }
    
    return self;
}

-(int) increaseDistance
{
    distance += multiplyer * [DUGAMEMODEL scrollSpeed];
//    NSDictionary *params = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:distance] forKey:@"distance"];
//    [MESSAGECENTER postNotificationName:DISTANCEUPDATED object:self];
    return distance;
}

-(void) reset
{
    distance = 0;
    level = 0;
}
@end
