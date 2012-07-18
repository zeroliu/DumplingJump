#import "GameLayer.h"

@interface Hero : CCNode
{
    CCSprite *heroSprite;
    b2Body *heroBody;
    
    float x,y;
    float vx,vy;
}
@property (nonatomic, retain) CCSprite *heroSprite;

-(id)initHeroWithFile:(NSString *)fileName position:(CGPoint)thePosition;
@end
