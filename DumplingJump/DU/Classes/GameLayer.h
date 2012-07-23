#import "Common.h"
#import "PhysicsManager.h"
#import "InputManager.h"
#import "AccelerometerManager.h"
#import "DUObjectsFactory.h"
@class BackgroundManager;
@class BoardManager;
@class Hero;

@interface GameLayer : CCLayer
{
	BoardManager *boardManager;
    BackgroundManager *bgManager;
    CCSpriteBatchNode *batchNode;
    Hero *hero;
    
}
@property (nonatomic, retain) CCSpriteBatchNode *batchNode;
+(CCScene *) scene;

@end
