#import "DUObject.h"

@implementation DUObject
@synthesize name = _name,rebuilt = _rebuilt, archived = _archived;

-(id)initWithName:(NSString *)theName
{
    if (self = [super init])
    {
        self.name = theName;
        self.rebuilt = NO;
        self.archived = NO;
    }
    
    return self;
}

-(void) archive
{
    self.archived = YES;
    [self deactivate];
    [[DUObjectsDictionary sharedDictionary] addDUObject:self];
}

-(void) activate
{
    self.archived = NO;
}

-(void) deactivate
{
    self.rebuilt = YES;
//    NSLog(@"call DUObject deactive");
}
@end
