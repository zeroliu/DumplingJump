#import "PhysicsManager.h"
#import "Hero.h"
#import "HeroManager.h"
#import "BoardManager.h"
#import "LevelManager.h"
#import "GameUI.h"

@interface PhysicsManager()
{
    NSMutableArray *physicsToRemove;
    NSMutableArray *physicsToDisactive;
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
        physicsToDisactive = [[NSMutableArray alloc] init];
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

-(void) addToDisactiveList:(DUPhysicsObject *)physicsObject
{
    [physicsToDisactive addObject:physicsObject];
}

-(void) removeFromListIfNeeded:(DUPhysicsObject *)object
{
    if ([physicsToRemove containsObject:object])
    {
        [physicsToRemove removeObject:object];
    }
}

-(void) updatePhysicsBody:(ccTime)dt
{
    [[[HeroManager shared] getHero] updateHeroForce];
    [[[BoardManager shared] getBoard] updateBoardForce];
    [[[BoardManager shared] getBoard] updateEnginePosition];
    world->Step(dt,10,10);
   
    while ([physicsToRemove count] > 0)
    {
        DUPhysicsObject *myObject = [physicsToRemove lastObject];
        [physicsToRemove removeLastObject];
        if ([((LevelManager *)[LevelManager shared]).generatedObjects containsObject:myObject])
        {
            [((LevelManager *)[LevelManager shared]).generatedObjects removeObject:myObject];
        }
        [myObject archive];
    }
    
    while ([physicsToDisactive count] > 0)
    {
        DUPhysicsObject *myObject = [physicsToDisactive lastObject];
        [physicsToDisactive removeLastObject];
        myObject.body->SetActive(false);
        
    }
    
    for (b2Body *b = world->GetBodyList(); b; b=b->GetNext()) 
    {
        if(b->GetUserData() != NULL && b->IsActive())
        {
            DUPhysicsObject *physicsObject = (DUPhysicsObject *)b->GetUserData();
            
            CCSprite* sprite = ((DUPhysicsObject *)b->GetUserData()).sprite;
            if (!([physicsObject.name isEqualToString: BOARD] && [((Hero *)[[HeroManager shared] getHero]).heroState isEqualToString: @"booster"] && (((Hero *)[[HeroManager shared] getHero]).boostStatus == 1 || ((Hero *)[[HeroManager shared] getHero]).boostStatus == 2)))
            {
                sprite.position = ccp(b->GetPosition().x * RATIO,
                                      b->GetPosition().y * RATIO);
                physicsObject.position = ccp(b->GetPosition().x * RATIO,
                                             b->GetPosition().y * RATIO);
            }
            sprite.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
            if (physicsObject.sprite.position.y < -600 || physicsObject.sprite.position.y > 2000)
            {
                if([physicsObject isMemberOfClass:[Hero class]] && physicsObject.body->IsActive())
                {
                    DLog(@"Hero before die will be called");
                    //When hero hits bottom
                    [[[HeroManager shared] getHero] beforeDie];

                } else
                {
                    if ([((LevelManager *)[LevelManager shared]).generatedObjects containsObject:physicsObject])
                    {
                        [((LevelManager *)[LevelManager shared]).generatedObjects removeObject:physicsObject];
                    }
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
