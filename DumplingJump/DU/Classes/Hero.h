#import "GameLayer.h"

@interface Hero : CCNode
{
    CCSprite *heroSprite;
    b2Body *heroBody;
    
    float x,y;
    b2Vec2 speed;
    b2Vec2 acc;
}
@property (nonatomic, retain) CCSprite *heroSprite; 

-(id)initHeroWithFile:(NSString *)fileName position:(CGPoint)thePosition;
-(void) updateHeroPosition;
@end
