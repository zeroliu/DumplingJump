//
//  DUScrollPageView.m
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-12-8.
//  Copyright (c) 2012年 CMU ETC. All rights reserved.
//

#import "DUScrollPageView.h"
#import "DUPageControl.h"
@interface DUScrollPageView()
@property (nonatomic, retain) DUPageControl *pageControl;

@end

@implementation DUScrollPageView
@synthesize pageControl = _pageControl;
-(id) initWithViewSize:(CGSize)size viewBlock:(CCNode *(^)())block num:(int)viewNum padding:(float)thePadding bulletNormalSprite:(NSString *)normalSprite bulletSelectedSprite:(NSString *)selectedSprite
{
    if (self = [super initWithViewSize:size viewBlock:block num:viewNum padding:thePadding])
    {
        _pageControl = [[DUPageControl alloc] initWithPosition:CGPointMake(size.width/2, size.height-15) bulletsNum:viewNum normalSpriteFile:normalSprite selectedSpriteFile:selectedSprite];
        [_pageControl addMenuToNode:self z:10];
        [_pageControl moveToIndex:0];
        
        self.pageDelegate = self;
    }
    
    return self;
}

-(void) scrollToPage:(int)index
{
    [_pageControl moveToIndex:index];
}

- (void)dealloc
{
    [_pageControl release];
    [super dealloc];
}
@end
