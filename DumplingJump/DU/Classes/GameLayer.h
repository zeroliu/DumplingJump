#import "Common.h"
#import "GLES-Render.h"
@class GameModel;
@class HeroManager;

@interface GameLayer : CCLayer
{
    GLESDebugDraw *m_debugDraw;
    b2World *world;
    BOOL isReload;
}
@property (nonatomic, retain) GameModel *model;
@property (nonatomic, retain) CCSpriteBatchNode *batchNode;
+(CCScene *) scene;

-(void) gameOver;
-(void) pauseGame;
-(void) resumeGame;
@end
