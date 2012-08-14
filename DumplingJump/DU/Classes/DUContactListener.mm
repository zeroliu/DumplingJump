//
//  MyContactListener.m
//  Box2DPong
//
//  Created by Ray Wenderlich on 2/18/10.
//  Copyright 2010 Ray Wenderlich. All rights reserved.
//

#import "DUContactListener.h"

DUContactListener::DUContactListener() : _contacts() {
}

DUContactListener::~DUContactListener() {
}

void DUContactListener::BeginContact(b2Contact* contact) {
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
}

void DUContactListener::EndContact(b2Contact* contact) {
    MyContact myContact = { contact->GetFixtureA(), contact->GetFixtureB() };
    std::vector<MyContact>::iterator pos;
    pos = std::find(_contacts.begin(), _contacts.end(), myContact);
    if (pos != _contacts.end()) {
        _contacts.erase(pos);
    }
}

void DUContactListener::PreSolve(b2Contact* contact, const b2Manifold* oldManifold) {
}

void DUContactListener::PostSolve(b2Contact* contact, const b2ContactImpulse* impulse) {
}

