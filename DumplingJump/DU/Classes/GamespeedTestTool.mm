//
//  GamespeedTestTool.m
//  CastleRider
//
//  Created by zero.liu on 4/5/13.
//  Copyright (c) 2013 CMU ETC. All rights reserved.
//

#import "GamespeedTestTool.h"
#import "Common.h"
#import "GameModel.h"
@interface GamespeedTestTool()
{
    BOOL isEnable;
    CCLabelTTF *gameSpeedDisplay;
    float scrollSpeed;
    float dropRate;
    float objectInitialSpeed;
}
@end

@implementation GamespeedTestTool
+(id) shared
{
    static id shared = nil;
    
    if (shared == nil)
    {
        shared = [[GamespeedTestTool alloc] init];
    }
    
    return shared;
}

-(id) init
{
    if (self = [super init])
    {
        isEnable = NO;
        [self reset];
    }
    
    return self;
}

-(void) setEnable:(BOOL)isEnabled
{
    isEnable = isEnabled;
}

-(void) reset
{
    if (gameSpeedDisplay != nil)
    {
        [gameSpeedDisplay removeFromParentAndCleanup:NO];
        [gameSpeedDisplay release];
        gameSpeedDisplay = nil;
    }
    [self createUI];
}

-(void) updateUI
{
    if (isEnable)
    {
        NSString *displayText = @"";
        //add scrollspeed info
        displayText = [NSString stringWithFormat:@" scroll speed: %g", GAMEMODEL.scrollSpeedIncrease];
        //add droprate info
        displayText = [NSString stringWithFormat:@"%@\n drop rate:%g %g",displayText, [[[[WorldData shared] loadDataWithAttributName:@"common"] objectForKey:@"dropRate"] floatValue] * GAMEMODEL.dropRateIncrease, GAMEMODEL.dropRateIncrease];
        //add initial speed info
        displayText = [NSString stringWithFormat:@"%@\n initial drop speed:%g %g",displayText, -GAMEMODEL.objectInitialSpeed * GAMEMODEL.objectInitialIncrease, GAMEMODEL.objectInitialIncrease];
        [gameSpeedDisplay setString:displayText];
    }
}

#pragma mark -
#pragma mark private
-(void) createUI
{
    if (isEnable)
    {
        gameSpeedDisplay = [[CCLabelTTF labelWithString:@"test" fontName:@"Helvetica" fontSize:12] retain];
        gameSpeedDisplay.anchorPoint = ccp(0,1);
        gameSpeedDisplay.position = ccp(100, [CCDirector sharedDirector].winSize.height - BLACK_HEIGHT);
        [GAMELAYER addChild:gameSpeedDisplay z:5];
    }
}

- (void)dealloc
{
    [gameSpeedDisplay release];
    [super dealloc];
}
@end
