#import "cocos2d.h"
#import "DUObjectsDictionary.h"

@interface DUObject : NSObject
{
    NSString *name;
    BOOL rebuilt;
    BOOL archived;
}
@property (readonly, nonatomic) NSString *name;
@property (nonatomic, assign) BOOL rebuilt;
@property (nonatomic, assign) BOOL archived;

-(id) initWithName:(NSString *)theName;
-(void) archive;
-(void) activate;
-(void) deactivate;
@end