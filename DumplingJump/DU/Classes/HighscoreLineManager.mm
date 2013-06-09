//
//  HighscoreLineManager.m
//  CastleRider
//
//  Created by zero.liu on 5/16/13.
//  Copyright (c) 2013 CMU ETC. All rights reserved.
//

#import "HighscoreLineManager.h"
#import "GameLayer.h"
#import "Constants.h"
#import "Hub.h"

#define OFFSET 20

@implementation HighscoreLine

@synthesize
playerID        = _playerID,
nickName        = _nickName,
highDistance    = _highDistance;

- (id) initWithDistance:(int)distance playerID:(NSString *)playerID nickName:(NSString *)nickName
{
    if (self = [super init])
    {
        self.highDistance = distance;
        self.playerID = playerID;
        self.nickName = nickName;
    }
    
    return self;
}

- (void)dealloc
{
    self.playerID = nil;
    self.nickName = nil;
    [super dealloc];
}

@end

@interface HighscoreLineManager()
{
    BOOL _justShowed;
    CGSize _winsize;
}

@end

@implementation HighscoreLineManager

@synthesize
displayedlinesDictionary = _displayedlinesDictionary,
registedlinesDictionary  = _registedlinesDictionary;

+ (id) shared
{
    static id shared = nil;
    if (shared == nil)
    {
        shared = [[HighscoreLineManager alloc] init];
    }
    
    return shared;
}

- (id) init
{
    if (self = [super init])
    {
        self.displayedlinesDictionary = [NSMutableDictionary dictionary];
        self.registedlinesDictionary = [NSMutableDictionary dictionary];
        _justShowed = NO;
        _winsize = [CCDirector sharedDirector].winSize;
    }
    
    return self;
}

- (void) reset
{
    //if still has any left on the screen, remove the object from its parent
    for (NSString *key in [self.displayedlinesDictionary allKeys])
    {
        [[self.displayedlinesDictionary objectForKey:key] removeFromParentAndCleanup:NO];
    }
    
    [self.displayedlinesDictionary removeAllObjects];
    _justShowed = NO;
}

- (void) registerHighDistance:(int)distance playerID:(NSString *)playerID nickName:(NSString *)nickName
{
    HighscoreLine* lineInfo = [[[HighscoreLine alloc] initWithDistance:distance playerID:playerID nickName:nickName] autorelease];
    [self.registedlinesDictionary setObject:lineInfo forKey:[NSString stringWithFormat:@"%d",distance-OFFSET]];
    //-OFFSET is the offset for showing the score earlier so that it feels more real
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showHighScoreLine:) name:[NSString stringWithFormat:@"highdistance:%d",distance-OFFSET] object:nil];
}

- (void) removeObservers
{
    for (NSString *key in [self.registedlinesDictionary allKeys])
    {
        HighscoreLine* lineInfo = [self.registedlinesDictionary objectForKey:key];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:[NSString stringWithFormat:@"highdistance:%d",lineInfo.highDistance-OFFSET] object:nil];
    }
    
    [self.registedlinesDictionary removeAllObjects];
}

- (void) showHighScoreLine:(NSNotification *)notification
{
    NSString* highDistance = [notification.name substringFromIndex:13];
    
    if (!_justShowed && [self.displayedlinesDictionary objectForKey:highDistance] == nil)
    {
        _justShowed = YES;
        [self performSelector:@selector(resetJustShowed) withObject:nil afterDelay:0.3];
        HighscoreLine* lineInfo = [self.registedlinesDictionary objectForKey:highDistance];
//        NSLog([NSString stringWithFormat:@"(%@,%@):%d", lineInfo.playerID, lineInfo.nickName, lineInfo.highDistance]);
        
        CCNode *lineHolder = [self createHighdistanceLineWithLineInfo:lineInfo];
        id scrollDownAction = [CCMoveTo actionWithDuration:3 position:ccp(_winsize.width/2, BLACK_HEIGHT-50)];
        id selfDesctruction = [CCCallFuncND actionWithTarget:[HighscoreLineManager shared] selector:@selector(removeHighscoreLine:data:) data:highDistance];
        
        [lineHolder runAction:[CCSequence actions:scrollDownAction, selfDesctruction, nil]];
        
        [self.displayedlinesDictionary setObject:lineHolder forKey:highDistance];
    }
}

- (void) removeHighscoreLine:(id)sender data:(void *)distanceKey
{
    CCNode* lineHolder = [self.displayedlinesDictionary objectForKey:(NSString *)distanceKey];
    [lineHolder removeFromParentAndCleanup:NO];
    [self.displayedlinesDictionary removeObjectForKey:(NSString *)distanceKey];
}

- (void) resetJustShowed
{
    _justShowed = NO;
}

- (CCNode *) createHighdistanceLineWithLineInfo:(HighscoreLine *)lineInfo
{
    CCNode* holder = [CCNode node];
    
    //Create indicator line
    CCSprite* line = [CCSprite spriteWithSpriteFrameName:@"E_indicator.png"];
    line.position = CGPointZero;
    [holder addChild:line];
    
    //Create text
    CCLabelBMFont *text = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%@ %dm", lineInfo.nickName, lineInfo.highDistance] fntFile:@"ERAS_white_black_small.fnt"];
    text.anchorPoint = ccp(0, 0.5);
    text.position = ccp(-150, 15);
    text.scale = 1.2;
    [holder addChild:text];
    
    //Set holder position to top of the screen
    holder.position = ccp(_winsize.width/2, _winsize.height-BLACK_HEIGHT);
    
    [GAMELAYER addChild:holder z:Z_HIGHSCORE_LINE];
    
    return holder;
}

- (void)dealloc
{
    for (NSString *key in [self.registedlinesDictionary allKeys])
    {
        HighscoreLine* lineInfo = [self.registedlinesDictionary objectForKey:key];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:[NSString stringWithFormat:@"%d",lineInfo.highDistance] object:nil];
    }
    self.displayedlinesDictionary = nil;
    self.registedlinesDictionary = nil;
    [super dealloc];
}

@end
