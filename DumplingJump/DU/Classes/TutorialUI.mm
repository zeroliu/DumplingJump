//
//  TutorialUI.mm
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-11-25.
//  Copyright (c) 2012年 CMU ETC. All rights reserved.
//

#import "TutorialUI.h"
#import "GameUI.h"
@interface TutorialUI()
{
    CGSize winSize;
}

typedef void (^CallbackBlock)();
@property (copy, nonatomic) CallbackBlock callbackBlock;

@end
@implementation TutorialUI
@synthesize callbackBlock = _callbackBlock;
+(id) shared
{
    static id shared = nil;
    if (shared == nil)
    {
        shared = [[TutorialUI alloc] init];
    }
    return shared;
}

-(id) init
{
    if (self = [super init])
    {
        ccbFileName = @"TutorialUI.ccbi";
        priority = Z_TUTORIALUI;
        winSize = [CCDirector sharedDirector].winSize;
        [ANIMATIONMANAGER registerTutorialAnimationForName:@"UI_tutorial_bomb"];
        [ANIMATIONMANAGER registerTutorialAnimationForName:@"UI_tutorial_sway"];
        [ANIMATIONMANAGER registerTutorialAnimationForName:@"UI_tutorial_tap"];
    }
    
    return self;
}

-(void) createUIwithParent:(CCNode *)parent
{
    [super createUIwithParent:parent];
    
    canvas.position = ccp(winSize.width/2,-winSize.height+BLACK_HEIGHT);
    bottom.position = ccp(winSize.width/2,-100+BLACK_HEIGHT);
}

-(void) playTutorialAnimation:(NSString *)animName
{
    id animate = [CCAnimate actionWithAnimation:[ANIMATIONMANAGER getAnimationWithName:animName]];
    [animationHolder stopAllActions];
    [animationHolder runAction:[CCRepeatForever actionWithAction:animate]];
}

-(void) showUIwithCallback:(void(^)())callbackBlock
{
    [self showUI];
    self.callbackBlock = callbackBlock;
}

-(void) showUI
{
    //Enable forward button
    [forwardButton setEnabled:YES];
    
    //Create mask
    [[GameUI shared] createMask];
    
    //Move cavas up
    id canvasMoveUp = [CCMoveTo actionWithDuration:0.1 position:ccp(winSize.width/2, BLACK_HEIGHT)];
    [canvas runAction:canvasMoveUp];
    
    //Move bottom up
    id bottomMoveUp = [CCMoveTo actionWithDuration:0.1 position:ccp(winSize.width/2, BLACK_HEIGHT)];
    [bottom runAction:bottomMoveUp];
}

-(void) hideUI
{
    //Move cavas up
    id canvasMoveDown = [CCMoveTo actionWithDuration:0.1 position:ccp(winSize.width/2, -winSize.height+BLACK_HEIGHT)];
    [canvas runAction:canvasMoveDown];
    
    //Move bottom up
    id bottomMoveDown = [CCMoveTo actionWithDuration:0.1 position:ccp(winSize.width/2, -100+BLACK_HEIGHT)];
    [bottom runAction:bottomMoveDown];
    [[GameUI shared] removeMask];
}

-(void) didTapForward
{
    [forwardButton setEnabled:NO];
    [self hideUI];
    self.callbackBlock();
}

- (void)dealloc
{
    [super dealloc];
}
@end
