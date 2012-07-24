#import "PhysicsManager.h"

@implementation PhysicsManager

+(id) sharedPhysicsManager
{
    static id sharedPhysicsManager = nil;
    if(sharedPhysicsManager == nil)
    {
        sharedPhysicsManager = [[self alloc] init];
    }
    return sharedPhysicsManager;
}

-(void) initWorld
{
    b2Vec2 gravity = b2Vec2(0.0,-15);
    bool doSleep = true;
    world = new b2World(gravity,doSleep);
    
    b2BodyDef def;
    ground = world->CreateBody(&def);
}

-(b2World *) getWorld
{
    return world;
}

-(b2Body *) getGround
{
    return ground;
}

-(void) updatePhysicsBody:(ccTime)dt
{
    world->Step(dt,10,10);
    for (b2Body *b = world->GetBodyList(); b; b=b->GetNext()) 
    {
        if(b->GetUserData() != NULL)
        {
            DUPhysicsObject *physicsObject = (DUPhysicsObject *)b->GetUserData();
            CCSprite* sprite = ((DUPhysicsObject *)b->GetUserData()).sprite;
            sprite.position = ccp(b->GetPosition().x * RATIO,
                                  b->GetPosition().y * RATIO);
            sprite.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
            
            if(physicsObject.name == @"ball")
            {
                if (physicsObject.sprite.position.y < -100) {
                    [physicsObject archive];
                }
            }
        }
    }
}

-(id) init
{
    if(self = [super init])
    {
        [self initWorld];
    }
    return self;
}

-(void) dealloc
{
    delete world;
	world = NULL;
    
    [super dealloc];
}

@end
