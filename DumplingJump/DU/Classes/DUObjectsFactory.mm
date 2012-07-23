#import "DUObjectsFactory.h"

@implementation DUObjectsFactory

+(id) createObjectWithName:(NSString *)theName
{
    DUObjectsDictionary *dict = [DUObjectsDictionary sharedDictionary];
    DUObject *myObject;
    
    if ([dict containsDUObject:theName] == NO)
    {
        DLog(@"Key <%@> not found in the DUObjectsDictionary, add a new object.", theName);        
        myObject= [[DUObject alloc] initWithName: theName];

    } else {
        DLog(@"Key <%@> found, get the value from the dictionary", theName);
        myObject = [dict getDUObjectbyName:theName];
    }
    return myObject;
}

+(id) createSpriteWithName:(NSString *)theName sprite:(CCSprite *)theSprite
{
    DUObjectsDictionary *dict = [DUObjectsDictionary sharedDictionary];
    id mySprite;
    
    if ([dict containsDUObject:theName] == NO)
    {
        DLog(@"Key <%@> not found in the DUObjectsDictionary, add a new sprite.", theName);        
        mySprite= [[DUSprite alloc] initWithName: theName sprite:theSprite];
        
    } else {
        DLog(@"Key <%@> found, get the value from the dictionary", theName);
        mySprite = [dict getDUObjectbyName:theName];
    }
    return mySprite;
}
@end
