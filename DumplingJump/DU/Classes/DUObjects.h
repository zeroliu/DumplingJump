#import "Common.h"

@interface DUObjects : CCNode
{
    NSString *name;
    CCSprite *sprite;
}

-(id) initWithName:(NSString *)theName sprite:(CCSprite *)theSprite;
@end