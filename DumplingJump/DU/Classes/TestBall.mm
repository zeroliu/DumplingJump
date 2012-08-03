#import "TestBall.h"

@implementation TestBall

+(id) shared
{
    static id shared = nil;
    if (shared == nil)
    {
        shared = [[TestBall alloc] init];
    }
    return shared;
}

-(id) init
{
    if (self = [super initWithName:@"testBall"]) {
        
    }
    
    return self;
}

-(id) createNewObject
{
    CCSprite *herosprite = [CCSprite spriteWithSpriteFrameName:@"HERO/AL_H_hero_1.png"];
    
    b2BodyDef heroBodyDef;
    heroBodyDef.type = b2_dynamicBody;
    b2Body *heroBody = WORLD->CreateBody(&heroBodyDef);
         
    b2CircleShape heroShape;
    heroShape.m_radius = (herosprite.contentSize.height/2-7) /RATIO; 
    b2FixtureDef heroFixtureDef;
    heroFixtureDef.shape = &heroShape;
    heroFixtureDef.density = 1.0f;
    heroFixtureDef.friction = 0.3f;
    heroFixtureDef.restitution = 0.6f;      
    heroBody->CreateFixture(&heroFixtureDef);
    b2MassData massData;
    massData.center = heroBody->GetLocalCenter();
    massData.mass = 10;
    massData.I = 1;
    heroBody->SetMassData(&massData);

    DUPhysicsObject *ball;
    ball= [[DUPhysicsObject alloc] initWithName: name file:@"HERO/AL_H_hero_1.png" body:heroBody]; 
    
    return ball;
}

@end
