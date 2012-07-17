#import "Common.h"
#import "PhysicsManager.h"
@class BackgroundManager;
@class BoardManager;

@interface GameLayer : CCLayer
{
	BoardManager *boardManager;
    BackgroundManager *bgManager;
    CCSpriteBatchNode *batchNode;
}
@property (nonatomic, retain) CCSpriteBatchNode *batchNode;
+(CCScene *) scene;

@end
