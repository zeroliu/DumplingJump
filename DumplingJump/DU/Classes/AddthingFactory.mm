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
#import "GameModel.h"

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
    self.addthingDictionary = [[XMLHelper shared] loadAddthingWithXML:@"Editor_addthing"];
}

-(id) createNewObjectWithName:(NSString *)objectName
{
    AddthingObjectData *selectedObject = [self.addthingDictionary objectForKey:objectName];
    
    if (selectedObject != nil)
    {
        b2BodyDef objectBodyDef;
        objectBodyDef.type = b2_dynamicBody; //Need to define whether configurable
        b2Body *objectBody = WORLD->CreateBody(&objectBodyDef);
        
        b2FixtureDef objectFixtureDef;
        objectFixtureDef.density = 1.0f;
        objectFixtureDef.friction = selectedObject.friction;
        objectFixtureDef.restitution = selectedObject.restitution;      
        if ([objectName isEqualToString:@"SLASH"])
        {
            objectFixtureDef.filter.categoryBits = C_SLASH;
            objectFixtureDef.filter.maskBits = C_ADDTHING;
        } else if ([objectName isEqualToString:@"STAR"] || [objectName isEqualToString:@"MEGA"] || [objectName isEqualToString:@"ROYALSTAR"])
        {
            objectFixtureDef.filter.categoryBits = C_STAR;
            objectFixtureDef.filter.maskBits = C_HERO | C_SLASH | C_ABSORB;
        } else if ([objectName isEqualToString:@"SPRING"] ||
                   [objectName isEqualToString:@"SHELTER"] ||
                   [objectName isEqualToString:@"MAGIC"] ||
                   [objectName isEqualToString:@"BOOSTER"])
        {
            objectFixtureDef.filter.categoryBits = C_STAR;
            objectFixtureDef.filter.maskBits = C_HERO | C_SLASH | C_ABSORB;
        } else
        {
            objectFixtureDef.filter.categoryBits = C_ADDTHING;
            objectFixtureDef.filter.maskBits = EVERYTHING;
        }
        
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
        
        objectBody->SetLinearVelocity(b2Vec2(0,-GAMEMODEL.objectInitialSpeed*GAMEMODEL.objectInitialIncrease));
        
        b2MassData massData;
        massData.center = objectBody->GetLocalCenter();
        massData.mass = selectedObject.mass;
        massData.I = selectedObject.i;
        objectBody->SetMassData(&massData);
        
        NSString *ID = [NSString stringWithFormat:@"%@_%d",selectedObject.name, self.idCounter];
        
        AddthingObject *newObject;
        newObject = [[[AddthingObject alloc] initWithID:ID name: selectedObject.name file:[NSString stringWithFormat: @"%@.png", selectedObject.spriteName] body:objectBody canResize:YES reaction:selectedObject.reactionName animation:selectedObject.animationName wait:selectedObject.wait warningTime:selectedObject.warningTime] autorelease];
        
        NSString *animName = [NSString stringWithFormat:@"A_%@", [selectedObject.name lowercaseString]];

        if ([selectedObject.shape isEqualToString: BOX])
        {
            newObject.sprite.flipY = YES;
        }
        
        id animation = [ANIMATIONMANAGER getAnimationWithName:animName];
        
        if(animation != nil)
        {
//            DLog(@"%@", [((CCAnimation *) animation).frames description]);
            id animAction = [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:animation]];
            [newObject.sprite runAction:animAction];
        }
        
        self.idCounter ++;
        if (self.idCounter >= INT_MAX)
        {
            self.idCounter = 0;
        }
        
        return newObject;
    } else 
    {
        DLog(@"Warning! Addthing name <%@> is not found in the dictionary.", objectName);
        b2BodyDef objectBodyDef;
        objectBodyDef.type = b2_dynamicBody; //Need to define whether configurable
        b2Body *objectBody = WORLD->CreateBody(&objectBodyDef);
        
        b2FixtureDef objectFixtureDef;
        objectFixtureDef.density = 1.0f;
        objectFixtureDef.friction = 1;
        objectFixtureDef.restitution = 1;
        objectFixtureDef.filter.categoryBits = C_ADDTHING;
        objectFixtureDef.filter.maskBits = EVERYTHING;
        
        b2CircleShape objectShape;
        objectShape.m_radius = 20.0 /RATIO;
        objectFixtureDef.shape = &objectShape;
                
        objectBody->CreateFixture(&objectFixtureDef);
        
        objectBody->SetGravityScale(1);
        
        b2MassData massData;
        massData.center = objectBody->GetLocalCenter();
        massData.mass = 1;
        massData.I = 1;
        objectBody->SetMassData(&massData);
        
        NSString *ID = [NSString stringWithFormat:@"wrongObject_%d", self.idCounter];
        
        AddthingObject *newObject;
        newObject = [[[AddthingObject alloc] initWithID:ID name: @"wrongObject" file:[NSString stringWithFormat: @"%@.png", @"A_wrongObject"] body:objectBody canResize:YES reaction:nil animation:nil wait:0 warningTime:0] autorelease];
        
        self.idCounter ++;
        if (self.idCounter >= INT_MAX)
        {
            self.idCounter = 0;
        }
        
        return newObject;
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

- (NSString *) getCustomDataByName:(NSString *)objectName
{
    return ((AddthingObjectData *)[self.addthingDictionary objectForKey:objectName]).customData;
}

@end
