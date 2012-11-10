//
//  Board.mm
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-8-12.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "Board.h"
#import "GLES-Render.h"
@interface Board()
{
    BOOL isUnderMissleEffect;
    float _freq_l;
    float _freq_m;
    float _freq_r;
    float _damp_l;
    float _damp_m;
    float _damp_r;
    
    b2DistanceJointDef rocketDisJointDef_L;
    b2DistanceJointDef rocketDisJointDef_R;
    b2DistanceJointDef rocketDisjointDef_MR;
    b2DistanceJointDef rocketDisjointDef_ML;
}



@end

@implementation Board
-(id) initBoardWithBoardName:(NSString *)theName spriteName:(NSString *)fileName position:(CGPoint) pos leftFreq:(float)freq_l middleFreq:(float)freq_m rightFreq:(float)freq_r leftDamp:(float)damp_l middleDamp:(float)damp_m rightDamp:(float)damp_r
{
    if (self = [super initWithName:theName])
    {
        _freq_l = freq_l;
        _freq_m = freq_m;
        _freq_r = freq_r;
        _damp_l = damp_l;
        _damp_m = damp_m;
        _damp_r = damp_r;
        
        self.sprite = [CCSprite spriteWithSpriteFrameName:fileName];
        self.sprite.position = pos;
        float scale = 370/2 / self.sprite.boundingBox.size.width * SCALE_MULTIPLIER;
        NSLog(@"width: %g",self.sprite.boundingBox.size.width);
        self.sprite.scale = scale;
        NSLog(@"after scale width: %g",self.sprite.boundingBox.size.width);
        [self initBoardPhysics];
        isUnderMissleEffect = NO;
    }
    return self;
}

-(void) initBoardPhysics
{
    [self createBoardBody];
    [self createBoardJoints];
}

-(void) createBoardBody
{
    b2BodyDef boardDef;
    boardDef.position.Set(self.sprite.position.x/RATIO,self.sprite.position.y/RATIO);
    boardDef.type = b2_dynamicBody;
    boardDef.userData = self;
    
    self.body = WORLD->CreateBody(&boardDef);
    
    float plateWidth = 370/2*SCALE_MULTIPLIER;
    float plateHeight = 40/2*SCALE_MULTIPLIER;
    
    b2PolygonShape boardShape;
    boardShape.SetAsBox(plateWidth/2/RATIO, plateHeight/2/RATIO);
    
    b2FixtureDef boardFixtureDef;
    
    boardFixtureDef.friction = 0.3;
    boardFixtureDef.restitution = 0;
    boardFixtureDef.density = 10;
    boardFixtureDef.shape = &boardShape;
    
    self.body->CreateFixture(&boardFixtureDef);
}

-(void) createBoardJoints
{
    float plateWidth = self.sprite.boundingBox.size.width;
    b2World *world = [[PhysicsManager sharedPhysicsManager] getWorld];
    b2Body *ground = [[PhysicsManager sharedPhysicsManager] getGround];
    
    b2Vec2 anchor_L = b2Vec2(self.body->GetPosition().x - plateWidth/2/RATIO,
                             self.body->GetPosition().y);
    b2Vec2 ground_L = b2Vec2(self.body->GetPosition().x - plateWidth/2/RATIO,
                             self.body->GetPosition().y + 50*SCALE_MULTIPLIER/RATIO);
    
    rocketDisJointDef_L.Initialize(ground, self.body, ground_L, anchor_L);
    rocketDisJointDef_L.collideConnected = true;
    rocketDisJointDef_L.frequencyHz = _freq_l;
    rocketDisJointDef_L.dampingRatio = _damp_l;
    rocketDisJointDef_L.userData = @"rocketDisJointDef_L";
    world->CreateJoint(&rocketDisJointDef_L);
    
    b2Vec2 anchor_R = b2Vec2(self.body->GetPosition().x + plateWidth/2/RATIO,
                             self.body->GetPosition().y);
    b2Vec2 ground_R = b2Vec2(self.body->GetPosition().x + plateWidth/2/RATIO,
                             self.body->GetPosition().y + 50*SCALE_MULTIPLIER/RATIO);
    
    rocketDisJointDef_R.Initialize(ground, self.body, ground_R, anchor_R);
    rocketDisJointDef_R.collideConnected = true;
    rocketDisJointDef_R.frequencyHz = _freq_r;
    rocketDisJointDef_R.dampingRatio = _damp_r;
    rocketDisJointDef_R.userData = @"rocketDisJointDef_R";
    world->CreateJoint(&rocketDisJointDef_R);
    
    b2Vec2 anchor_MR = b2Vec2(self.body->GetPosition().x,
                              self.body->GetPosition().y);
    b2Vec2 ground_MR = b2Vec2(self.body->GetPosition().x + (plateWidth/2+50*SCALE_MULTIPLIER)/RATIO,
                              self.body->GetPosition().y);
    
    rocketDisjointDef_MR.Initialize(ground, self.body, ground_MR, anchor_MR);
    rocketDisjointDef_MR.collideConnected = true;
    rocketDisjointDef_MR.frequencyHz = _freq_m;
    rocketDisjointDef_MR.dampingRatio = _damp_m;
    world->CreateJoint(&rocketDisjointDef_MR);
    
    b2Vec2 anchor_LR = b2Vec2(self.body->GetPosition().x,
                              self.body->GetPosition().y);
    b2Vec2 ground_LR = b2Vec2(self.body->GetPosition().x - (plateWidth/2+50*SCALE_MULTIPLIER)/RATIO,
                              self.body->GetPosition().y);
    
    rocketDisjointDef_ML.Initialize(ground, self.body, ground_LR, anchor_LR);
    rocketDisjointDef_ML.collideConnected = true;
    rocketDisjointDef_ML.frequencyHz = _freq_m;
    rocketDisjointDef_ML.dampingRatio = _damp_m;
    world->CreateJoint(&rocketDisjointDef_ML);
}

-(void) missleEffectWithDirection:(int)direction
{
    if (!isUnderMissleEffect)
    {
        b2World *world = [[PhysicsManager sharedPhysicsManager] getWorld];
        isUnderMissleEffect = YES;
        if (direction == 0)
        {
            for ( b2Joint *joint = world->GetJointList(); joint; joint = joint->GetNext() )
            {
                if (dynamic_cast<b2DistanceJoint *>(joint))
                {
                    if ([(NSString *)joint->GetUserData() isEqualToString:@"rocketDisJointDef_L"])
                    {
                        (dynamic_cast<b2DistanceJoint *>(joint))->SetFrequency(0.1f);
                    }
                }
            }
        } else if (direction == 1)
        {
            for ( b2Joint *joint = world->GetJointList(); joint; joint = joint->GetNext() )
            {
                if (dynamic_cast<b2DistanceJoint *>(joint))
                {
                    if ([(NSString *)joint->GetUserData() isEqualToString:@"rocketDisJointDef_R"])
                    {
                        (dynamic_cast<b2DistanceJoint *>(joint))->SetFrequency(0.1f);
                    }
                }
            }
        }
    }
}

-(void) recover
{
    DLog(@"recover");
    b2World *world = [[PhysicsManager sharedPhysicsManager] getWorld];
    isUnderMissleEffect = NO;
    for ( b2Joint *joint = world->GetJointList(); joint; joint = joint->GetNext() )
    {
        if (dynamic_cast<b2DistanceJoint *>(joint))
        {
            if ([(NSString *)joint->GetUserData() isEqualToString:@"rocketDisJointDef_L"])
            {
                (dynamic_cast<b2DistanceJoint *>(joint))->SetFrequency(0.7f);
            }
            if ([(NSString *)joint->GetUserData() isEqualToString:@"rocketDisJointDef_R"])
            {
                (dynamic_cast<b2DistanceJoint *>(joint))->SetFrequency(0.7f);
            }
        }
    }
}

-(void) dealloc
{
    [super dealloc];
}

@end
