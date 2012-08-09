//
//  BackgroundModel.mm
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-8-9.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "BackgroundModel.h"
@interface BackgroundModel()

@property (nonatomic, retain) NSMutableDictionary *bgDictionary;

@end

@implementation BackgroundModel
@synthesize bgDictionary = _bgDictionary;

-(id) bgDictionary
{
    if (_bgDictionary == nil) _bgDictionary = [[NSMutableDictionary alloc] init];
    return _bgDictionary;
}

-(void) addBackgroundWithFileName:(NSString *)theBGSpritesheetFileName bgLayers:(BgLayer *)layer1, ...
{
    //Add background plist to the frame cache if not exist
    if (![[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@.plist",theBGSpritesheetFileName]])
    {
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"%@.plist",theBGSpritesheetFileName]];
    }
    
    if (![self.bgDictionary objectForKey:theBGSpritesheetFileName]) 
    {
        NSMutableArray *newArray = [NSMutableArray array];
        va_list args;
        va_start(args, layer1);
        for (BgLayer *arg = layer1; arg != nil; arg = va_arg(args, BgLayer *))
        {
            arg->sprite = [CCSprite spriteWithSpriteFrameName:arg->fileName];
            arg->swapSprite = [CCSprite spriteWithSpriteFrameName:arg->fileName];
            NSValue *anLayer = [NSValue value:arg withObjCType:@encode(BgLayer)];
            [newArray addObject:anLayer];
        }
        va_end(args);
        [self.bgDictionary setObject:newArray forKey:theBGSpritesheetFileName];
    }
}

-(NSMutableArray *) getBGArrayByName:(NSString *)theName
{
    NSMutableArray *myArray = [self.bgDictionary objectForKey:theName];
    if (myArray == nil)
    {
        DLog(@"Warning! The background name <%@> does not exist.", theName);
    }
    return myArray;
}

@end
