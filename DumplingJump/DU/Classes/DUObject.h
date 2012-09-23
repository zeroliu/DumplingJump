#import "cocos2d.h"
#import "DUObjectsDictionary.h"

@interface DUObject : NSObject
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *ID;
@property (nonatomic, assign) BOOL rebuilt;
@property (nonatomic, assign) BOOL archived;

-(id) initWithName:(NSString *)theName;
-(void) archive;
-(void) activate;
-(void) deactivate;
@end