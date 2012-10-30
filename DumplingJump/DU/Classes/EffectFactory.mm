//
//  EffectFactory.mm
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-9-15.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "EffectFactory.h"
#import "DUEffectData.h"
#import "DUEffectObject.h"

@interface EffectFactory()

@property (nonatomic, retain) NSDictionary *effectsDictionary;

@end


@implementation EffectFactory
@synthesize effectsDictionary = _effectsDictionary;

-(id) init
{
    if (self = [super init])
    {
        [self loadEffects];
    }
    
    return self;
}

-(void) loadEffects
{
    NSMutableDictionary *tmp = [[NSMutableDictionary alloc] init ];
    DUEffectData *effect1 = [[DUEffectData alloc] initWithName: FX_EXPLOSION animation: ANIM_EXPLOSION idlePicture:@"EFFECTS/AL_E_del_1.png" times:1];
    DUEffectData *effect2 = [[DUEffectData alloc] initWithName: FX_ARROW_BREAK animation: ANIM_ARROW_BREAK idlePicture:@"EFFECTS/CA_E_arrow_1.png" times:1];
    DUEffectData *effect3 = [[DUEffectData alloc] initWithName: FX_FRONZEN animation: ANIM_ICE_EXPLODE idlePicture:@"EFFECTS/SK_E_frozen_1.png" times:1];
    DUEffectData *effect4 = [[DUEffectData alloc] initWithName: FX_STONEBREAK animation:ANIM_STONE_BREAK idlePicture:@"EFFECTS/CA_E_stone_1.png" times:1];
    DUEffectData *effect5 = [[DUEffectData alloc] initWithName: FX_POWDER animation:ANIM_POWDER_EXPLODE idlePicture:@"EFFECTS/AL_E_powder_1.png" times:1];
    
    [tmp setObject:effect1 forKey:effect1.name];
    [tmp setObject:effect2 forKey:effect2.name];
    [tmp setObject:effect3 forKey:effect3.name];
    [tmp setObject:effect4 forKey:effect4.name];
    [tmp setObject:effect5 forKey:effect5.name];
    
    self.effectsDictionary = [NSDictionary dictionaryWithDictionary:tmp];
}

-(id) createNewObjectWithName:(NSString *)objectName
{
    DUEffectObject *myObject;
    
    DUEffectData *objectData = [self.effectsDictionary objectForKey:objectName];
    if (objectData != nil)
    {
         myObject = [[DUEffectObject alloc] initWithName: objectName effect:objectData];
    } else 
    {
        DLog(@"Effect <%@> not found in the dictionary, cannot create new object", objectName);
    }
    
    return myObject;
}

@end
