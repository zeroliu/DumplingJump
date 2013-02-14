#import "GLES-Render.h"
@class GameModel;

@interface GameLayer : CCLayer
{
    GLESDebugDraw *m_debugDraw;
    b2World *world;
    BOOL isReload;
}
@property (nonatomic, retain) GameModel *model;
@property (nonatomic, retain) CCSpriteBatchNode *batchNode;
@property (nonatomic, assign) BOOL isDebug;
@property (nonatomic, assign) float timeScale;

+(CCScene *) scene;

-(void) gameOver;
-(void) pauseGame;
-(void) resumeGame;
@end
