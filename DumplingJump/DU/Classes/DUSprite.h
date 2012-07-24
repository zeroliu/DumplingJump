#import "DUObject.h"

@interface DUSprite : DUObject
{
    CCSprite *sprite;
}
@property (nonatomic, assign) CCSprite *sprite;

-(id) initWithName:(NSString *)theName file:(NSString *)fileName;
-(BOOL) addChildTo: (CCNode *)node;
-(BOOL) addChildTo:(CCNode *)node z:(int)zLayer;
@end
