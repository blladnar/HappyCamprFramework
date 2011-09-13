//
//  Message.m
//  HappyCampr
//
//  Created by Brown, Randall on 7/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HCMessage.h"
#import "SBJSON.h"

@implementation HCMessage

@synthesize timeStamp;
@synthesize messageId;
@synthesize roomID;
@synthesize userID;
@synthesize messageBody;
@synthesize messageType;
@synthesize userName;


+(HCMessage*)messageWithJSON:(NSString*)jsonString
{
   SBJsonParser *jsonParser = [[[SBJsonParser alloc] init] autorelease];
   
   id messageDict = [jsonParser objectWithString:jsonString];
   
   return [HCMessage messageWithDictionary:messageDict];
}

+(HCMessage*)messageWithDictionary:(NSDictionary*)dictionary
{   
   HCMessage *message = [[[HCMessage alloc] init] autorelease];
   
   message.messageBody = [dictionary objectForKey:@"body"];
   message.timeStamp = [NSDate dateWithString:[dictionary objectForKey:@"created_at"]];
   
   if( [dictionary objectForKey:@"id"] != [NSNull null])
   {
      message.messageId = [[dictionary objectForKey:@"id"] intValue];
   }

   message.messageType = [dictionary objectForKey:@"type"];

   if( [dictionary objectForKey:@"user_id"] != [NSNull null])
   {
      message.userID = [[dictionary objectForKey:@"user_id"] intValue];
   }

   return message;   
}

-(NSString*)description
{
   return [NSString stringWithFormat:@"%@ %@", self.timeStamp, self.messageBody];
}

@end
