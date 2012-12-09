//
//  CCScrollPageControlView.m
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-12-6.
//  Copyright (c) 2012年 CMU ETC. All rights reserved.
//


#import "CCScrollPageControlView.h"
#import "CCBReader.h"
@interface CCScrollPageControlView()
{
    float _nodeOffset;
    int _currentPageIndex;
    BOOL _isAnimating;
}

@property (nonatomic, retain) NSMutableArray *viewArray;
@end

@implementation CCScrollPageControlView
@synthesize viewArray = _viewArray, pageDelegate = _pageDelegate;

-(id)initWithViewSize:(CGSize)size viewBlock:(CCNode *(^)())block num:(int)viewNum padding:(float)thePadding
{
    if (self = [super initWithViewSize:size])
    {
        //Configure params to make scrollview work with page control
        [self configParams];
        //Retain content container to the container property
        self.container = [self createContentContainerWithBlock:block num:viewNum padding:thePadding];
        
        //self.container = [CCBReader nodeGraphFromFile:@"MissionNode.ccbi"];
        //[self addChild:container_];
        minScale_ = maxScale_ = 1.0f;
        
        //Set delegate
        self.delegate = self;
        self.pageDelegate = nil;
    }
    
    return self;
}

-(void) scrollSpeedExceedLimit:(CCScrollView *)view
{
//    NSLog(@"scrollSpeedExceedLimit");
    if (scrollDistance_.x > 0)
    {
        _currentPageIndex = MAX(_currentPageIndex - 1, 0);
    } else
    {
        _currentPageIndex = MIN(_currentPageIndex + 1, [_viewArray count] - 1);
    }
    [self stopDeaccelerateScrolling];
    if ([_pageDelegate respondsToSelector:@selector(scrollToPage:)])
    {
        [_pageDelegate scrollToPage:_currentPageIndex];
    }
    [self setContentOffset:CGPointMake(-_currentPageIndex*_nodeOffset, 0) animated:YES];
}

-(void) scrollViewScrollEnd:(CCScrollView *)view
{
    if (!_isAnimating)
    {
        [self calculatePageFromNodeOffset];
        [self stopDeaccelerateScrolling];
        if ([_pageDelegate respondsToSelector:@selector(scrollToPage:)])
        {
            [_pageDelegate scrollToPage:_currentPageIndex];
        }
        [self setContentOffset:CGPointMake(-_currentPageIndex*_nodeOffset, 0) animated:YES];
    }
}

-(void) calculatePageFromNodeOffset
{
    _currentPageIndex = floor((container_.position.x - _nodeOffset/2) / -_nodeOffset);
    NSLog(@"current page index = %d", _currentPageIndex);
}

-(void) animatedScrollEnded:(CCScrollView *)view
{
    _isAnimating = NO;
}

-(void) animatedScrollPerforming:(CCScrollView *)view
{
    _isAnimating = YES;
}

-(CCNode *)createContentContainerWithBlock:(CCNode *(^)())block num:(int)viewNum padding:(float)thePadding
{
    _viewArray = [[NSMutableArray alloc] initWithCapacity:viewNum];
    
    CCNode *contentContainer = [CCNode node];
    CCNode *tmpNode = block();
    //- Store the size of the container
    float nodeWidth = tmpNode.boundingBox.size.width;
    //- Calculate the offset (Set instance variable)
    _nodeOffset = nodeWidth + thePadding;
    
    //- Add contents into contentContainer
    for(int i=0; i<viewNum; i++)
    {
        CCNode *tmpNode = block();
        [_viewArray addObject:tmpNode];
        tmpNode.position = ccp(i * _nodeOffset,0);
        [contentContainer addChild:tmpNode];
    }
    [contentContainer setContentSize: CGSizeMake((tmpNode.boundingBox.size.width + thePadding) * viewNum - thePadding, tmpNode.boundingBox.size.height)];
    return contentContainer;
}

-(void) configParams
{
    self.minZoomScale = 1;
    self.maxZoomScale = 1;
    self.direction = CCScrollViewDirectionHorizontal;
    _isAnimating = NO;
}

- (void)dealloc
{
    [_viewArray release];
    [super dealloc];
}

@end
