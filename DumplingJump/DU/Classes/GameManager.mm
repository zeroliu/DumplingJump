//
//  GameManager.mm
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-8-3.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "GameManager.h"
#import "GameModel.h"
#import "GameLayer.h"



@interface GameManager()
@property (nonatomic, retain) GameModel *model;
@property (nonatomic, retain) GameLayer *view;
@property (nonatomic, retain) LevelManager *levelManager;
@property (nonatomic, retain) BackgroundController *bgController;
@property (nonatomic, retain) BoardManager *boardManager;

@property (nonatomic, assign) int state;
@end

@implementation GameManager
@synthesize model = _model;
@synthesize view = _view;
@synthesize levelManager = _levelManager;
@synthesize bgController = _bgController;
@synthesize boardManager = _boardManager;
@synthesize state = _state;

-(id) view
{
    return [[Hub shared] gameLayer];
}

-(id) model
{
    if (_model == nil) _model = [[GameModel alloc] init];
    return _model;
}

-(id) bgController
{
    if (_bgController == nil) _bgController = [[BackgroundController alloc] init];
    return _bgController;
}

-(id) boardManager
{
    if (_boardManager == nil) _boardManager = [[BoardManager alloc] init];
    return _boardManager;
}

-(id) levelManager
{
    if (_levelManager == nil) _levelManager = [[LevelManager alloc] init];
    return _levelManager;
}
  
+(id) shared
{
    static id shared = nil;
    if (shared == nil)
    {
        shared = [[GameManager alloc] init];
    }
    
    return shared;
}

-(id) init
{
    if (self = [super init])
    {
        self.state = GAME_INIT;
        [self initListener];
        [self initGame];
        [self scheduleUpdate];
    }
    
    return self;
}

-(void) update:(ccTime)deltaTime
{
    if (self.state == GAME_START)
    {
        [self.bgController updateBackground:deltaTime];
        [PHYSICSMANAGER updatePhysicsBody:deltaTime];
    }
}

-(void) initListener
{
//    [MESSAGECENTER addObserver:self selector:@selector(gameStart) name:GAMELAYER_INITIALIZED object:nil];
}

-(void) initGame
{
    //Init level with level name
    //TODO: select the level with a menu or something
    [self setLevelWithName:LEVEL_NORMAL];
    
    [self startGame];
}

-(void) startGame
{
    self.state = GAME_START;
}

-(void) setLevelWithName:(NSString *)levelName
{
    //Set the currentLevel by loading from levelManager
    self.model.currentLevel = [self.levelManager selectLevelWithName:LEVEL_NORMAL];
    //Set the corresponding background
    [self.bgController setBackgroundWithName:self.model.currentLevel.backgroundName];
    [self.boardManager createBoardWithBoardName:self.model.currentLevel.boardType position:ccp(160,100)];
    //TODO: set the rest of the characters or elements for the level
}

-(void) reset
{
//    ((DUGameModel *)DUGAMEMODEL).scrollSpeed = 0.1;
}
@end
