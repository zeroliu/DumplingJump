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
        myObject.rebuilt = YES;
    }
    return myObject;
}

+(id) createSpriteWithName:(NSString *)theName file:(NSString *)theFile
{
    DUObjectsDictionary *dict = [DUObjectsDictionary sharedDictionary];
    DUSprite *mySprite;
    
    if ([dict containsDUObject:theName] == NO)
    {
        DLog(@"Key <%@> not found in the DUObjectsDictionary, add a new sprite.", theName);        
        mySprite= [[DUSprite alloc] initWithName: theName file:theFile];
        
    } else {
        DLog(@"Key <%@> found, get the value from the dictionary", theName);
        mySprite = [dict getDUObjectbyName:theName];
        mySprite.sprite.visible = YES;
        mySprite.rebuilt = YES;
    }
    return mySprite;
}

+(id) createPhysicsWithName:(NSString *)theName file:(NSString *)theFile body:(b2Body *)theBody
{
    DUObjectsDictionary *dict = [DUObjectsDictionary sharedDictionary];
    DUPhysicsObject *myPhysics;
    
    if ([dict containsDUObject:theName] == NO)
    {
        DLog(@"Key <%@> not found in the DUObjectsDictionary, add a new DUPhysicsObject.", theName);        
        myPhysics= [[DUPhysicsObject alloc] initWithName: theName file:theFile body:theBody];
        
    } else {
        DLog(@"Key <%@> found, get the value from the dictionary", theName);
        myPhysics = [dict getDUObjectbyName:theName];
        myPhysics.sprite.visible = YES;
        myPhysics.rebuilt = YES;
        [myPhysics activate];
    }
    return myPhysics;
}
@end
