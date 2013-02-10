//
//  UserData.m
//  CastleRider
//
//  Created by LIU Xiyuan on 13-1-31.
//  Copyright (c) 2013年 CMU ETC. All rights reserved.
//

#import "UserData.h"

@implementation UserData
@synthesize isMusicMuted = _isMusicMuted, isSFXMuted = _isSFXMuted;

+(id) shared
{
    static id shared = nil;
    
    if (shared == nil)
    {
        shared = [[UserData alloc] init];
    }
    
    return shared;
}

-(id) init
{
    if (self = [super init])
    {
        _isMusicMuted = YES;
        _isSFXMuted = NO;
    }
    
    return self;
}


@end
