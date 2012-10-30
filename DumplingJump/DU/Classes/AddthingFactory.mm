//
//  AddthingFactory.mm
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-8-12.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "AddthingFactory.h"
#import "AddthingObjectData.h"
#import "AddthingObject.h"

@interface AddthingFactory()

@property (nonatomic, assign) int idCounter;
@end

@implementation AddthingFactory
@synthesize addthingDictionary = _addthingDictionary;
@synthesize idCounter = _idCounter;

+(id) shared
{
    static id shared = nil;
    if (shared == nil)
    {
        shared = [[AddthingFactory alloc] initFactory];
    }
    
    return shared;
}

-(id) initFactory
{
    if (self = [super initWithName:@"AddthingFacotry"])
    {
        [self loadAddthingInfo];
        self.idCounter = 0;
    }
    
    return self;
}

-(void) loadAddthingInfo
{
    self.addthingDictionary = [[XMLHelper shared] loadAddthingWithXML:@"CA_addthing"];
}

-(id) createNewObjectWithName:(NSString *)objectName
{
    AddthingObjectData *selectedObject = [self.addthingDictionary objectForKey:objectName];
    
    if (selectedObject != nil)
    {
//        CCSprite *objectSprite = [CCSprite spriteWithSpriteFrameName: [NSString stringWithFormat: @"ADDTHING/%@.png", selectedObject.spriteName]];
        
        b2BodyDef objectBodyDef;
        objectBodyDef.type = b2_dynamicBody; //Need to define whether configurable
        b2Body *objectBody = WORLD->CreateBody(&objectBodyDef);
        
        b2FixtureDef objectFixtureDef;
        objectFixtureDef.density = 1.0f;
        objectFixtureDef.friction = selectedObject.friction;
        objectFixtureDef.restitution = selectedObject.restitution;      
        
        if ([selectedObject.shape isEqualToString: CIRCLE])
        {
            b2CircleShape objectShape;
            objectShape.m_radius = (selectedObject.radius) /RATIO; 
            //Maybe use the sprite size as a reference
            //EX: sprite.contentSize.x/2 - 7
            
            objectFixtureDef.shape = &objectShape;
        } else if ([selectedObject.shape isEqualToString: BOX])
        {
            b2PolygonShape objectShape;
            objectShape.SetAsBox(selectedObject.width/2/RATIO, selectedObject.length/2/RATIO);            
            objectFixtureDef.shape = &objectShape;
        }
        
        objectBody->CreateFixture(&objectFixtureDef);
        
        objectBody->SetGravityScale((selectedObject.gravity)/100.0f);
        
        b2MassData massData;
        massData.center = objectBody->GetLocalCenter();
        massData.mass = selectedObject.mass;
        massData.I = selectedObject.i;
        objectBody->SetMassData(&massData);
        
        NSString *ID = [NSString stringWithFormat:@"%@_%d",selectedObject.name, self.idCounter];
        
        AddthingObject *newObject;
        newObject = [[AddthingObject alloc] initWithID:ID name: selectedObject.name file:[NSString stringWithFormat: @"ADDTHING/%@.png", selectedObject.spriteName] body:objectBody canResize:YES reaction:selectedObject.reactionName animation:selectedObject.animationName];
        
        self.idCounter ++;
        if (self.idCounter >= INT_MAX)
        {
            self.idCounter = 0;
        }
        
        return newObject;
    } else 
    {
        DLog(@"Warning! Addthing name <%@> is not found in the dictionary.", objectName);
        return nil;
    }
}

-(id) create
{
    DLog(@"Warning! Cannot use this function in AddthingFactory");
    NSException *exception = [NSException exceptionWithName: @"No object name exception"
                                                     reason: @"Cannot use create function without name in AddthingFactory"
                                                   userInfo: nil];
    @throw exception;
    return nil;
}

@end
