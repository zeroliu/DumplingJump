//
//  BackgroundManager.m
//  CastleRider
//
//  Created by zero.liu on 4/19/13.
//  Copyright (c) 2013 CMU ETC. All rights reserved.
//

#import "BackgroundManager.h"
#import "XMLHelper.h"
@interface BackgroundManager()
{
    NSMutableDictionary *_backgroundData;
    NSMutableDictionary *_backgroundObjectData;
}

@end

@implementation BackgroundManager

#pragma mark -
#pragma mark public static
+ (id) shared
{
    static id shared = nil;
    
    if (shared == nil)
    {
        shared = [[BackgroundManager alloc] init];
    }
    
    return shared;
}

#pragma mark -
#pragma mark initialization
- (id) init
{
    if (self = [super init])
    {
        _backgroundData = [[XMLHelper shared] loadBackgroundData];
        _backgroundObjectData = [[XMLHelper shared] loadBackgroundObjectData];
        NSLog(@"%@", _backgroundObjectData);
    }
    
    return self;
}

#pragma mark -
#pragma mark public


#pragma mark -
#pragma mark private


@end
