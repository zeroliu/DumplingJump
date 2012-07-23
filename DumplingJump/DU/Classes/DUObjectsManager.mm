#import "DUObjectsManager.h"

@implementation DUObjectsManager

+(id) shared
{
    static id shared = nil;
    if (shared == nil)
    {
        shared = [[DUObjectsManager alloc] init];
    }
    
    return shared;
}

-(id) init
{
    if (self = [super init])
    {
        objectsDict = [NSMutableDictionary dictionary];
    }
    return self;
}

-(void) addObjectWithName:(NSString *)theName
{
    if ([objectsDict objectForKey:theName] == nil)
    {
        DLog(@"Key <%@> not found in the DUObjectDictionary, add a new one.", theName);
        
        //Create a empty array for saving the object with the given name
        NSMutableArray *myArray = [NSMutableArray array];
        //Add this array to the dictionary
        [objectsDict setObject:myArray forKey:theName];
        
        
    }
}

@end
