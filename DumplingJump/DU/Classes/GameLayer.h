#import "Common.h"
#import "GLES-Render.h"

@class HeroManager;

@interface GameLayer : CCLayer
{
    GLESDebugDraw *m_debugDraw;
    b2World *world;
    BOOL isReload;
    
    CCLabelTTF *UI_scoreText;
    BOOL paused;
}
//@property (nonatomic, retain) HeroManager *heroManager;
@property (nonatomic, retain) CCSpriteBatchNode *batchNode;
+(CCScene *) scene;

@end
