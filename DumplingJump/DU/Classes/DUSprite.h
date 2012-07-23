#import "DUObject.h"

@interface DUSprite : DUObject
{
    CCSprite *sprite;
    NSMutableDictionary *animDict;
}
@property (nonatomic, assign) CCSprite *sprite;
@property (nonatomic, readonly) NSMutableDictionary *animDict;

-(id) initWithName:(NSString *)theName sprite:(CCSprite *)theSprite;
-(void) addAnimationWithName:(NSString *)theName file:(NSString *)theFile startFrame:(int)start endFrame:(int)end delay:(float)theDelay repeat:(BOOL)canRepeat;

@end
