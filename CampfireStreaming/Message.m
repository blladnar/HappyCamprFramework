//
//  Message.m
//  HappyCampr
//
//  Created by Brown, Randall on 7/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Message.h"

@implementation Message

@synthesize timeStamp;
@synthesize messageId;
@synthesize roomID;
@synthesize userID;
@synthesize messageBody;
@synthesize messageType;
@synthesize userName;

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
   return [NSString stringWithFormat:@"%@ %@", self.timeStamp, self.messageBody];
   
}

@end
