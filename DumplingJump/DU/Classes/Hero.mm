#import "Hero.h"

@implementation Hero
@synthesize heroSprite;

-(id)initHeroWithFile:(NSString *)fileName position:(CGPoint)thePosition
{
    if(self = [super init])
    {
        heroSprite = [CCSprite spriteWithSpriteFrameName:fileName];
        heroSprite.position = thePosition;
        [[[[Hub shared] gameLayer] batchNode] addChild:heroSprite];
        [self setHeroAnimation];
        [self setHeroPhysicsWithPosition:thePosition];
    }
    
    return self;
}

-(void) setHeroAnimation
{
    NSMutableArray *frameArray = [NSMutableArray array];
    for (int i=1; i<=10; i++)
    {
        NSString *frameName = [NSString stringWithFormat:@"HERO/AL_H_hero_%d.png",i];
        id frameObject = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
        [frameArray addObject:frameObject];
    }
    
    id animObject = [CCAnimation animationWithFrames:frameArray delay:0.3];
    id animAction = [CCAnimate actionWithAnimation:animObject restoreOriginalFrame:NO];
    animAction = [CCRepeatForever actionWithAction:animAction];
    
    [heroSprite runAction:animAction];
}

-(void) setHeroPhysicsWithPosition:(CGPoint)thePosition
{
    b2BodyDef heroBodyDef;
    heroBodyDef.type = b2_dynamicBody;
    heroBodyDef.position.Set(thePosition.x/RATIO, thePosition.y/RATIO);
    heroBodyDef.userData = heroSprite;
    
    heroBody = [[PhysicsManager sharedPhysicsManager] getWorld]->CreateBody(&heroBodyDef);
    
    b2PolygonShape heroShape;
    heroShape.SetAsBox(heroSprite.contentSize.width/2/RATIO, heroSprite.contentSize.height/2/RATIO);
    
    b2CircleShape circle;
    circle.m_radius = 25.0/RATIO;
    
    b2FixtureDef heroFixtureDef;
    heroFixtureDef.shape = &heroShape;
    heroFixtureDef.density = 1.0f;
    heroFixtureDef.friction = 0.3f;
    heroFixtureDef.restitution = 0.6f;
    
    heroBody->CreateFixture(&heroFixtureDef);
    
    b2MassData massData;
    massData.center = heroBody->GetLocalCenter();
    massData.mass = 100;
    massData.I = 1;
    heroBody->SetMassData(&massData);
}
@end
