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
#import "BackgroundController.h"

@interface GameManager()
@property (nonatomic, retain) GameModel *model;
@property (nonatomic, retain) GameLayer *view;
@property (nonatomic, retain) BackgroundController *bgController;
@end

@implementation GameManager
@synthesize model = _model;
@synthesize view = _view;
@synthesize bgController = _bgController;

-(id) view
{
    return [[Hub shared] gameLayer];
}

-(id) model
{
    if (_model == nil) _model = [[GameModel alloc] init];
    return _model;
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
        [self initListener];
        [self initGame];
        [self scheduleUpdate];
    }
    
    return self;
}

-(void) update:(ccTime)deltaTime
{
    [self.bgController updateBackground:deltaTime];
    [PHYSICSMANAGER updatePhysicsBody:deltaTime];
}

-(void) initListener
{
//    [MESSAGECENTER addObserver:self selector:@selector(gameStart) name:GAMELAYER_INITIALIZED object:nil];
}

-(void) initGame
{
    self.bgController = [[BackgroundController alloc] init];
    [self.bgController setBackgroundWithName:SKY];
}

-(void) reset
{
//    ((DUGameModel *)DUGAMEMODEL).scrollSpeed = 0.1;
}
@end
