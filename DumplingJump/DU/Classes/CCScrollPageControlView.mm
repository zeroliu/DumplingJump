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
    UISwipeGestureRecognizer *_recognizer;
}

@property (nonatomic, retain) NSMutableArray *viewArray;

@end

@implementation CCScrollPageControlView
@synthesize viewArray = _viewArray;

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
    
    return contentContainer;
}

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
        //Make this view listen to horizontal swipe events
        [self initSwipeListener];
    }
    
    return self;
}


-(void) configParams
{
    self.minZoomScale = 1;
    self.maxZoomScale = 1;
    self.direction = CCScrollViewDirectionHorizontal;
}

-(void) initSwipeListener
{
    _recognizer = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDetected:)] autorelease];
    _recognizer.numberOfTouchesRequired = 1;
    _recognizer.direction = UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight;
    
    [[[CCDirector sharedDirector] view] addGestureRecognizer:_recognizer];
}

-(void)swipeDetected:(UISwipeGestureRecognizer *)recognizer
{
    NSLog(@"Swipe received. %u", recognizer.direction);
}
/*
-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    
}
*/

@end
