#import "GameLayer.h"

@interface BoardManager : CCNode
{
    b2Body *boardBody;
    CCSprite *boardCostume;
    
    CCSprite *ballCostume;
    b2Body *ballBody;
    int count;
}

-(id) initWithFile:(NSString *)fileName z:(int)zValue;
-(void) createNewBall;
@end
