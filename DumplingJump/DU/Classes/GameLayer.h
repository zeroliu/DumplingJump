#import "Common.h"
#import "PhysicsManager.h"
#import "InputManager.h"
#import "AccelerometerManager.h"
#import "AnimationManager.h"
#import "DUPhysicsObjectFactory.h"

@class BackgroundManager;
@class Board;
@class Hero;

@interface GameLayer : CCLayer
{
	Board *board;
    BackgroundManager *bgManager;
    CCSpriteBatchNode *batchNode;
    Hero *hero;
    
    //Test use
    DUPhysicsObjectFactory *ballFactory;
}
@property (nonatomic, retain) CCSpriteBatchNode *batchNode;
+(CCScene *) scene;

@end
