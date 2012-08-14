//
//  AddthingFactory.mm
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-8-12.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "AddthingFactory.h"
#import "AddthingObject.h"

@interface AddthingFactory()
@property (nonatomic, retain) NSDictionary *addthingDictionary;
@end

@implementation AddthingFactory
@synthesize addthingDictionary = _addthingDictionary;

-(id) initFactory
{
    if (self = [super initWithName:@"AddthingFacotry"])
    {
        [self loadAddthingInfo];
    }
    
    return self;
}

-(void) loadAddthingInfo
{
    //TODO: attach to the xml file
    //Fake loading here
    NSMutableDictionary *tmp = [NSMutableDictionary dictionary];
    AddthingObject *tub = [[AddthingObject alloc] initWithName:TUB shape:CIRCLE spriteName:@"CA_tub_1" radius:15 width:0 length:0 I:1 mass:100 restitution:0.4 friction:2 gravity:80 blood:1];
    AddthingObject *vat = [[AddthingObject alloc] initWithName:VAT shape:CIRCLE spriteName:@"CA_vat_1" radius:30 width:0 length:0 I:2 mass:200 restitution:0.1 friction:2 gravity:100 blood:1];
    [tmp setObject:tub forKey:TUB];
    [tmp setObject:vat forKey:VAT];
    self.addthingDictionary = [tmp copy];
}

-(id) createNewObjectWithName:(NSString *)objectName
{
    AddthingObject *selectedObject = [self.addthingDictionary objectForKey:objectName];
    
    if (selectedObject != nil)
    {
//        CCSprite *objectSprite = [CCSprite spriteWithSpriteFrameName: [NSString stringWithFormat: @"ADDTHING/%@.png", selectedObject.spriteName]];
        
        //TODO: Maybe resize the sprite
        
        b2BodyDef objectBodyDef;
        objectBodyDef.type = b2_dynamicBody; //Need to define whether configurable
        b2Body *objectBody = WORLD->CreateBody(&objectBodyDef);
        
        b2FixtureDef objectFixtureDef;
        objectFixtureDef.density = 1.0f;
        objectFixtureDef.friction = selectedObject.friction;
        objectFixtureDef.restitution = selectedObject.restitution;      
        
        if (selectedObject.shape == CIRCLE)
        {
            b2CircleShape objectShape;
            objectShape.m_radius = (selectedObject.radius) /RATIO; 
            //Maybe use the sprite size as a reference
            //EX: sprite.contentSize.x/2 - 7
            
            objectFixtureDef.shape = &objectShape;
        } else if (selectedObject.shape == BOX)
        {
            b2PolygonShape objectShape;
            objectShape.SetAsBox(selectedObject.width/2/RATIO, selectedObject.length/2/RATIO);            
            objectFixtureDef.shape = &objectShape;
        }
        
        objectBody->CreateFixture(&objectFixtureDef);
        
        b2MassData massData;
        massData.center = objectBody->GetLocalCenter();
        massData.mass = selectedObject.mass;
        massData.I = selectedObject.i;
        objectBody->SetMassData(&massData);
        
        DUPhysicsObject *newObject;
        newObject= [[DUPhysicsObject alloc] initWithName: selectedObject.name file:[NSString stringWithFormat: @"ADDTHING/%@.png", selectedObject.spriteName] body:objectBody canResize:YES];
        
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
