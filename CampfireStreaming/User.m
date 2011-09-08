//
//  User.m
//  HappyCampr
//
//  Created by Brown, Randall on 7/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "User.h"

@implementation User

@synthesize userID;
@synthesize name;
@synthesize email;
@synthesize avatarURL;
@synthesize authToken;


- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(NSString*)description
{
   return self.email;
}

@end
