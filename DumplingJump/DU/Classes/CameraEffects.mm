//
//  CameraEffects.m
//  CastleRider
//
//  Created by zero.liu on 4/30/13.
//  Copyright (c) 2013 CMU ETC. All rights reserved.
//

#import "CameraEffects.h"
#import "Common.h"
@interface CameraEffects()
@property (nonatomic, retain) NSMutableArray *effectData;
@end

@implementation CameraEffects
@synthesize effectData = _effectData;

+ (id) shared
{
    static id shared = nil;
    if (shared == nil)
    {
        shared = [[CameraEffects alloc] init];
    }
    
    return shared;
}

- (id) init
{
    if (self = [super init])
    {
        _effectData = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void) shakeCameraWithTarget:(CCNode *)target x:(float)amountX y:(float)amountY duration:(float)time
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:target forKey:@"target"];
    [dict setObject:[NSNumber numberWithFloat:amountX] forKey:@"x"];
    [dict setObject:[NSNumber numberWithFloat:amountY] forKey:@"y"];
    [dict setObject:[NSNumber numberWithFloat:time] forKey:@"duration"];
    [dict setObject:[NSNumber numberWithFloat:0] forKey:@"runtime"];
    [dict setObject:[NSNumber numberWithFloat:target.position.x] forKey:@"origX"];
    [dict setObject:[NSNumber numberWithFloat:target.position.y] forKey:@"origY"];
    [dict setObject:@"shake" forKey:@"type"];
    [_effectData addObject:dict];
}

- (void) updateCameraEffect:(float)dt
{
    if ([_effectData count] > 0)
    {
        NSMutableArray *toDeleteEffects = [[NSMutableArray arrayWithCapacity:[_effectData count]] retain];
        for (NSMutableDictionary *effect in _effectData)
        {
            //calculate percentage
            float runtime = [[effect objectForKey:@"runtime"] floatValue];
            float duration = [[effect objectForKey:@"duration"] floatValue];
            float percentage = runtime / duration;
            
            if ([[effect objectForKey:@"type"] isEqualToString:@"shake"])
            {
                CCNode *target = [effect objectForKey:@"target"];
                
                float amountX = [[effect objectForKey:@"x"] floatValue];
                float amountY = [[effect objectForKey:@"y"] floatValue];
                float origX = [[effect objectForKey:@"origX"] floatValue];
                float origY = [[effect objectForKey:@"origY"] floatValue];
                
                float diminishingControl = 1 - percentage;
                float finalAmountX = randomFloat(-amountX * diminishingControl, amountX * diminishingControl );
                float finalAmountY = randomFloat(-amountY * diminishingControl, amountY * diminishingControl );
                
                target.position = ccp(origX+finalAmountX, origY+finalAmountY);
            }
            
            //increase percentage
            runtime += dt;
            if (runtime >= duration)
            {
                //Effect finish
                [toDeleteEffects addObject:effect];
            }
            else
            {
                [effect setObject:[NSNumber numberWithFloat:runtime] forKey:@"runtime"];
            }
        }
        
        if ([toDeleteEffects count] > 0)
        {
            for (id toDeleteEffect in toDeleteEffects)
            {
                [_effectData removeObject:toDeleteEffect];
            }
            [toDeleteEffects removeAllObjects];
        }
        [toDeleteEffects release];
        toDeleteEffects = nil;
    }
}

@end
