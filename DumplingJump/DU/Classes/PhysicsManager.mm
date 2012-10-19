#import "PhysicsManager.h"
#import "DUContactListener.h"
#import "Hero.h"

@interface PhysicsManager()
{
    NSMutableArray *physicsToRemove;
}

@end

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

-(id) init
{
    if(self = [super init])
    {
        [self initWorld];
        physicsToRemove = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void) initWorld
{
    b2Vec2 gravity = b2Vec2(0.0,-15);
    bool doSleep = true;
    world = new b2World(gravity);
    world->SetAllowSleeping(doSleep);
    
    b2BodyDef def;
    ground = world->CreateBody(&def);
    
    DUContactListener *listener;
    listener = new DUContactListener();
    world->SetContactListener(listener);
    
}

-(b2World *) getWorld
{
    return world;
}

-(b2Body *) getGround
{
    return ground;
}

-(void) addToArchiveList:(DUPhysicsObject *)physicsObject
{
    [physicsToRemove addObject:physicsObject];
}

-(void) updatePhysicsBody:(ccTime)dt
{
    world->Step(dt,10,10);
   
    if ([physicsToRemove count] > 0)
    {
         DLog(@"%@",physicsToRemove);
        DUPhysicsObject *myObject = [physicsToRemove lastObject];
        [physicsToRemove removeLastObject];
        [myObject archive];
        
    }
    
    for (b2Body *b = world->GetBodyList(); b; b=b->GetNext()) 
    {
        if(b->GetUserData() != NULL)
        {
            
            DUPhysicsObject *physicsObject = (DUPhysicsObject *)b->GetUserData();
            CCSprite* sprite = ((DUPhysicsObject *)b->GetUserData()).sprite;
            sprite.position = ccp(b->GetPosition().x * RATIO,
                                  b->GetPosition().y * RATIO);
            sprite.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
            
//            if(physicsObject.name == @"testBall")
            if(![physicsObject isMemberOfClass:Hero.class])
            {
                if (physicsObject.sprite.position.y < -600) {
                    [physicsObject archive];
                }
            }
        }
    }
}

-(void) dealloc
{
    delete world;
	world = NULL;
    
    [super dealloc];
}

@end
