#import "Common.h"
@class BackgroundManager;

@interface GameLayer : CCLayer
{
	b2World *world;
    BackgroundManager *bgManager;
}

+(CCScene *) scene;

@end
