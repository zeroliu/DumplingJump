//
//  EffectFactory.mm
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-9-15.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "EffectFactory.h"
#import "DUEffectData.h"
#import "DUEffectObject.h"

@interface EffectFactory()

@property (nonatomic, retain) NSDictionary *effectsDictionary;

@end


@implementation EffectFactory
@synthesize effectsDictionary = _effectsDictionary;

-(id) init
{
    if (self = [super init])
    {
        [self loadEffects];
    }
    
    return self;
}

-(void) loadEffects
{
    self.effectsDictionary = [[XMLHelper shared] loadEffectWithXML:@"DU_effect"];
}

-(id) createNewObjectWithName:(NSString *)objectName
{
    DUEffectObject *myObject;
    
    DUEffectData *objectData = (DUEffectData *)[self.effectsDictionary objectForKey:objectName];
    //DLog(@"%@", ((DUEffectData *)[self.effectsDictionary objectForKey:FX_ARROW_BREAK]).idlePictureName);
    if (objectData != nil)
    {
         myObject = [[[DUEffectObject alloc] initWithName: objectName effect:objectData] autorelease];
    } else 
    {
        DLog(@"Effect <%@> not found in the dictionary, cannot create new object", objectName);
    }
    
    return myObject;
}

@end
