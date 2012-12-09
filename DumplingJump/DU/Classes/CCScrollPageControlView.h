//
//  CCScrollPageControlView.h
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-12-6.
//  Copyright (c) 2012年 CMU ETC. All rights reserved.
//

#import "cocos2d.h"
#import "CCScrollView.h"
@protocol CCSCrollPageViewDelegate

@optional
-(void) scrollToPage:(int)index;

@end

@interface CCScrollPageControlView : CCScrollView <CCScrollViewDelegate>
@property (nonatomic, retain) id pageDelegate;
//Init with the scroll view size, the node needed to be repeated and the number of repetition
-(id)initWithViewSize:(CGSize)size viewBlock:(CCNode *(^)())block num:(int)viewNum padding:(float)thePadding;
@end
