#import "cocos2d.h"
#import "DUObjectsDictionary.h"
#import "DUObject.h"
#import "DUSprite.h"

#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif

// ALog always displays output regardless of the DEBUG setting
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);


@interface DUObjectsFactory: CCNode
+(id) createObjectWithName:(NSString *)theName;
+(id) createSpriteWithName:(NSString *)theName sprite:(CCSprite *)theSprite;

@end
