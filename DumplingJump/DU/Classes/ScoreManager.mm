//
//  ScoreManager.m
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-8-3.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "ScoreManager.h"

@implementation ScoreManager
@synthesize distance = _distance, level = _level, multiplyer = _multiplyer;

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
        self.distance = 0;
        self.level = 0;
        //TODO: Read multiplyer from plist
        self.multiplyer = 1;
    }
    
    return self;
}

-(int) increaseDistance
{
//    self.distance += self.multiplyer * [DUGAMEMODEL scrollSpeed];
//    NSDictionary *params = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:distance] forKey:@"distance"];
//    [MESSAGECENTER postNotificationName:DISTANCEUPDATED object:self];
    return self.distance;
}

-(void) reset
{
    self.distance = 0;
    self.level = 0;
}
@end
