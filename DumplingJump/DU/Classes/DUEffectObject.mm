//
//  DUEffectObject.mm
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-9-15.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "DUEffectObject.h"

@implementation DUEffectObject
@synthesize effectData = _effectData;

-(id) initWithName:(NSString *)theName effect:(DUEffectData *)effectData
{
    if (self = [super initWithName:theName file:[NSString stringWithFormat:@"%@_1.png", effectData.animationName]])
    {
        //DLog(@"%@", effectData.idlePictureName);
        _effectData = effectData;
    }
    
    return self;
}

@end
