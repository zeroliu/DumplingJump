//
//  MyContactListener.m
//  Box2DPong
//
//  Created by Ray Wenderlich on 2/18/10.
//  Copyright 2010 Ray Wenderlich. All rights reserved.
//

#import "DUContactListener.h"

DUContactListener::DUContactListener() : _contacts()
{
}

DUContactListener::~DUContactListener()
{
}

//void DUContactListener::setDelegate(id<DUContactListenerDelegate> delegate)
//{
//    _delegate = delegate;
//}

void DUContactListener::BeginContact(b2Contact* contact)
{
    // We need to copy out the data because the b2Contact passed in
    // is reused.
//    MyContact myContact = { contact->GetFixtureA(), contact->GetFixtureB() };
//    _contacts.push_back(myContact);
    
    b2Fixture* fixtureA = contact->GetFixtureA();
	b2Fixture* fixtureB = contact->GetFixtureB();
    
	b2Body *bodyA = fixtureA->GetBody();
	b2Body *bodyB = fixtureB->GetBody();
    
	id userDataA = (id)bodyA->GetUserData();
	id userDataB = (id)bodyB->GetUserData();
    
    if ([userDataA isKindOfClass:[DUPhysicsObject class]] && [userDataB isKindOfClass:[DUPhysicsObject class]])
    {
        //Everytime where there is a contact, system will send two messages
        //to both objects and attach the information of the other one.
        [MESSAGECENTER postNotificationName:
         [NSString stringWithFormat:@"%@Contact",((DUPhysicsObject *)userDataA).ID] object:nil userInfo:[NSDictionary dictionaryWithObject:userDataB forKey:@"object"]];
        
        [MESSAGECENTER postNotificationName:
         [NSString stringWithFormat:@"%@Contact",((DUPhysicsObject *)userDataB).ID] object:nil userInfo:[NSDictionary dictionaryWithObject:userDataA forKey:@"object"]];
    }
    
//    DLog(@"Contact between %@ and %@",((DUPhysicsObject *)userDataA).ID, ((DUPhysicsObject *)userDataB).ID);
}

void DUContactListener::EndContact(b2Contact* contact)
{
//    MyContact myContact = { contact->GetFixtureA(), contact->GetFixtureB() };
//    std::vector<MyContact>::iterator pos;
//    pos = std::find(_contacts.begin(), _contacts.end(), myContact);
//    if (pos != _contacts.end()) {
//        _contacts.erase(pos);
//    }
    b2Fixture* fixtureA = contact->GetFixtureA();
	b2Fixture* fixtureB = contact->GetFixtureB();
    
	b2Body *bodyA = fixtureA->GetBody();
	b2Body *bodyB = fixtureB->GetBody();
    
	id userDataA = (id)bodyA->GetUserData();
	id userDataB = (id)bodyB->GetUserData();
    if ([userDataA isKindOfClass:[DUPhysicsObject class]] && [userDataB isKindOfClass:[DUPhysicsObject class]])
    {
        //Everytime where there is a contact, system will send two messages
        //to both object and attach the information of the other one.
        [MESSAGECENTER postNotificationName:
         [NSString stringWithFormat:@"%@EndContact",((DUPhysicsObject *)userDataA).ID] object:nil userInfo:[NSDictionary dictionaryWithObject:userDataB forKey:@"object"]];
        
        [MESSAGECENTER postNotificationName:
         [NSString stringWithFormat:@"%@EndContact",((DUPhysicsObject *)userDataB).ID] object:nil userInfo:[NSDictionary dictionaryWithObject:userDataA forKey:@"object"]];
    }
    
}

void DUContactListener::PreSolve(b2Contact* contact, const b2Manifold* oldManifold)
{
}

void DUContactListener::PostSolve(b2Contact* contact, const b2ContactImpulse* impulse)
{
}

//void DUContactListener::test()
//{
//    if ([_delegate respondsToSelector:@selector(heroLandOnBoard)])
//    {
//        [_delegate heroLandOnBoard];
//    }
//}
