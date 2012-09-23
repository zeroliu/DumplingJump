#import "Common.h"

@class HeroManager;

@interface GameLayer : CCLayer

@property (nonatomic, retain) HeroManager *heroManager;
@property (nonatomic, retain) CCSpriteBatchNode *batchNode;
+(CCScene *) scene;

@end
