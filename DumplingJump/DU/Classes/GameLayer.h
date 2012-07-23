#import "Common.h"
#import "PhysicsManager.h"
#import "InputManager.h"
#import "AccelerometerManager.h"
#import "DUObjectsManager.h"9
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
