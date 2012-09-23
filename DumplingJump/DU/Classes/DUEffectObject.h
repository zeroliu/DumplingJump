//
//  DUEffectObject.h
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-9-15.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "CCNode.h"
#import "DUSprite.h"
#import "DUEffectData.h"

@interface DUEffectObject : DUSprite
@property (nonatomic, retain) DUEffectData *effectData;

-(id) initWithName:(NSString *)theName effect:(DUEffectData *)effectData;
@end
