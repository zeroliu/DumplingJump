#import "cocos2d.h"

@interface Hub : NSObject
{
    id gameLayer;
}
@property (nonatomic, retain) id gameLayer;

+(id) shared;

@end
