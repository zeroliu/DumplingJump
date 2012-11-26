#import "cocos2d.h"
#import "GameLayer.h"
@interface Hub : NSObject

@property (nonatomic, retain) id gameLayer; //Initialized by GameLayer

+(id) shared;

@end
