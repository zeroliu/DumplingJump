#import "PhysicsManager.h"
#import "Hero.h"
#import "HeroManager.h"
#import "LevelManager.h"

@interface PhysicsManager()
{
    NSMutableArray *physicsToRemove;
    DUContactListener *listener;
}

@end

@implementation PhysicsManager
@synthesize mass_multiplier = _mass_multiplier;

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
        self.mass_multiplier = MASS_MULTIPLIER;
        [self initWorld];
        physicsToRemove = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void) initWorld
{
    b2Vec2 gravity = b2Vec2(0.0,-12.0f);
    bool doSleep = true;
    world = new b2World(gravity);
    world->SetAllowSleeping(doSleep);
    
    b2BodyDef def;
    ground = world->CreateBody(&def);
    
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
    [[[HeroManager shared] getHero] updateHeroForce];
    world->Step(dt,10,10);
   
    if ([physicsToRemove count] > 0)
    {
        //DLog(@"%@",physicsToRemove);
        DUPhysicsObject *myObject = [physicsToRemove lastObject];
        [physicsToRemove removeLastObject];
        if (!myObject.archived) [myObject archive];
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
            
            
            if (physicsObject.sprite.position.y < -600 || physicsObject.sprite.position.y > 2000)
            {
                if([physicsObject isMemberOfClass:Hero.class])
                {
                    [[[Hub shared]gameLayer] gameOver];
                } else
                {
                    [[LevelManager shared] removeObjectFromList:physicsObject];
                    [physicsObject archive];
                }
            }
        }
    }
}

-(void) setCustomGravity:(float)newGravity
{
    world->SetGravity(b2Vec2(0.0, -newGravity));
}

-(void) dealloc
{
    delete listener;
    delete world;
	world = NULL;
    //[physicsToRemove release];
    physicsToRemove = nil;
    [super dealloc];
}

@end
