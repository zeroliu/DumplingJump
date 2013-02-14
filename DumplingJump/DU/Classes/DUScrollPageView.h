//
//  DUScrollPageView.h
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-12-8.
//  Copyright (c) 2012年 CMU ETC. All rights reserved.
//

#import "CCScrollPageControlView.h"


@interface DUScrollPageView : CCScrollPageControlView <CCSCrollPageViewDelegate>

-(id) initWithViewSize:(CGSize)size viewBlock:(CCNode *(^)())block num:(int)viewNum padding:(float)thePadding bulletNormalSprite:(NSString *)normalSprite bulletSelectedSprite:(NSString *)selectedSprite;

@end
