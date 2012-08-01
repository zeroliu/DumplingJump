#import "DUObject.h"

@implementation DUObject
@synthesize name,rebuilt,archived;

-(id)initWithName:(NSString *)theName
{
    if (self = [super init])
    {
        name = theName;
        rebuilt = NO;
        archived = NO;
    }
    
    return self;
}

-(void) archive
{
    archived = YES;
    [self deactivate];
    [[DUObjectsDictionary sharedDictionary] addDUObject:self];
}

-(void) activate
{
    archived = NO;
}

-(void) deactivate
{
    rebuilt = YES;
//    NSLog(@"call DUObject deactive");
}
@end
