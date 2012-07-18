#import "Common.h"
#import "PhysicsManager.h"
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
