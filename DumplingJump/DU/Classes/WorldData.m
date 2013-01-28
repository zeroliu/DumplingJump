//
//  WorldData.m
//  DumplingJump
//
//  Created by LIU Xiyuan on 13-1-27.
//  Copyright (c) 2013年 CMU ETC. All rights reserved.
//

#import "WorldData.h"

@interface WorldData()
@property (nonatomic, retain) NSDictionary *worldData;
@end


@implementation WorldData
@synthesize worldData = _worldData;

- (void)dealloc
{
    [_worldData release];
    [super dealloc];
}

+(id) shared
{
    static id shared = nil;
    if (shared == nil)
    {
        shared = [[WorldData alloc] init];
    }
    
    return shared;
}

-(id) init
{
    if (self = [super init])
    {
        [self loadWorldDataFromPlist];
    }
    
    return self;
}

-(void)loadWorldDataFromPlist
{
    NSString *path = [[NSBundle mainBundle] bundlePath];
    path = [path stringByAppendingPathComponent:@"worldData.plist"];
    self.worldData = [NSDictionary dictionaryWithContentsOfFile:path];
}

-(id) loadDataWithAttributName:(NSString *)name
{
    return [_worldData objectForKey:name];
}

@end
