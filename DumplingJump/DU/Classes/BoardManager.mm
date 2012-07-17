#import "BoardManager.h"

@implementation BoardManager
-(id) initWithFile:(NSString *)fileName z:(int)zValue
{
    if(self = [super init])
    {
        boardCostume = [CCSprite spriteWithFile:fileName];
        boardCostume.position = ccp(160,100);
        [[[Hub shared] gameLayer] addChild:boardCostume z:zValue];
        [self initBoard];
        
        //[self createNewBall];
        //[self scheduleUpdate];
        [[CCScheduler sharedScheduler] scheduleSelector:@selector(createNewBall) forTarget:self interval:1.0 paused:NO];
        count = 1;
    }
    
    return self;
}

-(void) createBallCostume:(CGPoint)point
{
    ballCostume = [CCSprite spriteWithFile:@"Icon-Small-50.png"];
    ballCostume.position = ccp(point.x,point.y);
    [[[Hub shared]gameLayer] addChild:ballCostume z:10];
}

-(void)createBall:(CGPoint)point
{
    [self createBallCostume:point];
    
    b2BodyDef ballDef;
    ballDef.type = b2_dynamicBody;
    ballDef.position.Set(point.x/RATIO,point.y/RATIO);
    ballDef.userData = ballCostume;
    
    ballBody = [[PhysicsManager sharedPhysicsManager] getWorld]->CreateBody(&ballDef);
    
    b2CircleShape circle;
    circle.m_radius = 25.0/RATIO;
    
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &circle;
    fixtureDef.density = 1.0f;
    fixtureDef.friction = 0.3f;
    fixtureDef.restitution = 0.6f;
    
    ballBody->CreateFixture(&fixtureDef);
    
    b2MassData massData;
    massData.center = ballBody->GetLocalCenter();
    massData.mass = 100;
    massData.I = 1;
    ballBody->SetMassData(&massData);
}

-(void) createNewBall
{
    count++;
    CGPoint ballPos = ccp(0+10*count,450);
    [self createBall:ballPos];
}

-(void) initBoard
{
    [self createBoardBody];
    [self createBoardJoints];
}


-(void) createBoardBody
{
    b2BodyDef boardDef;
    boardDef.position.Set(160/RATIO,100/RATIO);
    boardDef.type = b2_dynamicBody;
    boardDef.userData = boardCostume;
    
    boardBody = [[PhysicsManager sharedPhysicsManager] getWorld]->CreateBody(&boardDef);
    
    b2PolygonShape boardShape;
    boardShape.SetAsBox(boardCostume.boundingBox.size.width/2/RATIO, boardCostume.boundingBox.size.height/2/RATIO);
    
    b2FixtureDef boardFixtureDef;
    
    //TODO: NEED CHANGE TO THE REAL VALUE
    boardFixtureDef.friction = 10;
    boardFixtureDef.restitution = 0.8;
    boardFixtureDef.density = 10;
    boardFixtureDef.shape = &boardShape;
    
    boardBody->CreateFixture(&boardFixtureDef);
}

-(void) createBoardJoints
{
    int plateWidth = boardCostume.boundingBox.size.width;
    b2World *world = [[PhysicsManager sharedPhysicsManager] getWorld];
    b2Body *ground = [[PhysicsManager sharedPhysicsManager] getGround];
    
    b2Vec2 anchor_L = b2Vec2(boardBody->GetPosition().x - plateWidth/2/RATIO,
                             boardBody->GetPosition().y);
    b2Vec2 ground_L = b2Vec2(boardBody->GetPosition().x - plateWidth/2/RATIO,
                             boardBody->GetPosition().y - 100);
    b2DistanceJointDef rocketDisJointDef_L;
    rocketDisJointDef_L.Initialize(ground, boardBody, ground_L, anchor_L);
    rocketDisJointDef_L.collideConnected = true;
    rocketDisJointDef_L.frequencyHz = 1;
    rocketDisJointDef_L.dampingRatio = 1;
    world->CreateJoint(&rocketDisJointDef_L);
    
    b2Vec2 anchor_R = b2Vec2(boardBody->GetPosition().x + plateWidth/2/RATIO,
                             boardBody->GetPosition().y);
    b2Vec2 ground_R = b2Vec2(boardBody->GetPosition().x + plateWidth/2/RATIO,
                             boardBody->GetPosition().y - 100);
    b2DistanceJointDef rocketDisJointDef_R;
    rocketDisJointDef_R.Initialize(ground, boardBody, ground_R, anchor_R);
    rocketDisJointDef_R.collideConnected = true;
    rocketDisJointDef_R.frequencyHz = 1;
    rocketDisJointDef_R.dampingRatio = 1;
    world->CreateJoint(&rocketDisJointDef_R);
    
    b2Vec2 anchor_MR = b2Vec2(boardBody->GetPosition().x,
                              boardBody->GetPosition().y);
    b2Vec2 ground_MR = b2Vec2(boardBody->GetPosition().x + (plateWidth/2+100)/RATIO,
                              boardBody->GetPosition().y);
    b2DistanceJointDef rocketDisjointDef_MR;
    rocketDisjointDef_MR.Initialize(ground, boardBody, ground_MR, anchor_MR);
    rocketDisjointDef_MR.collideConnected = true;
    rocketDisjointDef_MR.frequencyHz = 1;
    rocketDisjointDef_MR.dampingRatio = 1;
    world->CreateJoint(&rocketDisjointDef_MR);
    
    b2Vec2 anchor_LR = b2Vec2(boardBody->GetPosition().x,
                              boardBody->GetPosition().y);
    b2Vec2 ground_LR = b2Vec2(boardBody->GetPosition().x - (plateWidth/2+100)/RATIO,
                              boardBody->GetPosition().y);
    b2DistanceJointDef rocketDisjointDef_LR;
    rocketDisjointDef_LR.Initialize(ground, boardBody, ground_LR, anchor_LR);
    rocketDisjointDef_LR.collideConnected = true;
    rocketDisjointDef_LR.frequencyHz = 1;
    rocketDisjointDef_LR.dampingRatio = 1;
    world->CreateJoint(&rocketDisjointDef_LR);
    
    ground = NULL;
    world = NULL;
}


-(void) dealloc
{
    boardBody = NULL;
    [boardCostume release];
    [super dealloc];
}
@end
