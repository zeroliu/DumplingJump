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
@property (nonatomic, retain) NSDictionary *addthingDictionary;
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
    //TODO: attach to the xml file
    //Fake loading here
    NSMutableDictionary *tmp = [NSMutableDictionary dictionary];
    AddthingObjectData *tub = [[AddthingObjectData alloc] initWithName:TUB shape:CIRCLE spriteName:@"CA_tub_1" radius:35 width:0 length:0 I:1 mass:100 restitution:0.4 friction:2 gravity:80 blood:1 reactionName:nil animationName:nil];
    AddthingObjectData *vat = [[AddthingObjectData alloc] initWithName:VAT shape:CIRCLE spriteName:@"CA_vat_1" radius:30 width:0 length:0 I:1 mass:200 restitution:0.1 friction:2 gravity:100 blood:1 reactionName:@"arrow" animationName:nil];
    AddthingObjectData *bomb = [[AddthingObjectData alloc] initWithName:BOMB shape:CIRCLE spriteName:@"SK_bomber_1" radius:25 width:0 length:0 I:1 mass:100 restitution:0.1 friction:20 gravity:50 blood:1 reactionName:@"bomb" animationName:nil];
    AddthingObjectData *arrow = [[AddthingObjectData alloc] initWithName:ARROW shape:BOX spriteName:@"CA_arrow_1" radius:0 width:30 length:50 I:1 mass:5 restitution:0.1 friction:1 gravity:100 blood:1 reactionName:@"arrow" animationName:nil];
    AddthingObjectData *star = [[AddthingObjectData alloc] initWithName:STAR shape:CIRCLE spriteName:@"SK_star_1" radius:30 width:0 length:0 I:1 mass:5 restitution:0.1 friction:1 gravity:100 blood:1 reactionName:@"ice" animationName:ANIM_STAR];
 
    [tmp setObject:tub forKey:TUB];
    [tmp setObject:vat forKey:VAT];
    [tmp setObject:bomb forKey:BOMB];
    [tmp setObject:arrow forKey:ARROW];
    [tmp setObject:star forKey:STAR];
//    [tmp setObject:arrow forKey:ICE];
    self.addthingDictionary = [NSDictionary dictionaryWithDictionary:tmp];
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
        
        if(selectedObject.gravity != 100)
        {
            //objectBody->ApplyForce(b2Vec2(0,15*(100-selectedObject.gravity)/100),objectBody->GetPosition());
            objectBody->SetGravityScale((selectedObject.gravity)/100.0f);
        }
        
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
