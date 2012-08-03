//
//  DUGameModel.h
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-8-3.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "Common.h"

@interface DUGameModel : CCNode
{
    float scrollSpeed;
}
@property (assign, nonatomic) float scrollSpeed;

+(id) shared;
@end
