//
//  EffectManager.mm
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-9-15.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "EffectManager.h"
#import "EffectFactory.h"
#import "DUEffectObject.h"

@interface EffectManager()

@property (nonatomic, retain) EffectFactory *factory;

@end

@implementation EffectManager
@synthesize factory=_factory;
+(id) shared
{
    static id shared = nil;
    if (shared == nil)
    {
        shared = [[EffectManager alloc] init];
    }
    
    return shared;
}

-(id) init
{
    if (self = [super init])
    {
        self.factory = [[EffectFactory alloc] init];
    }
    
    return self;
}

-(void) PlayEffectWithName:(NSString *)effectName position:(CGPoint)thePosition
{
    DUEffectObject *effect = [self.factory createWithName:effectName];
    effect.sprite.position = thePosition;
    [effect addChildTo:BATCHNODE z:1];
    
    id animation = [ANIMATIONMANAGER getAnimationWithName:effect.effectData.animationName];
    
    if(animation != nil)
    {
        id animAction = [CCRepeat actionWithAction: [CCAnimate actionWithAnimation:animation] times:effect.effectData.times];
        id callbackWrapper = [CCCallFunc actionWithTarget:effect selector:@selector(archive)];  
        id sequence = [CCSequence actions:animAction, callbackWrapper, nil];
        [effect.sprite runAction:sequence];
    }
}


@end
