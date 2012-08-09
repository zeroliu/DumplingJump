#import "cocos2d.h"

@interface Hub : NSObject

@property (nonatomic, retain) id gameLayer;

+(id) shared;

@end
