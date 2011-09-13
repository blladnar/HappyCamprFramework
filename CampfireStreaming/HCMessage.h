//
//  Message.h
//  HappyCampr
//
//  Created by Brown, Randall on 7/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HCMessage : NSObject {
@private
   
}

+(HCMessage*)messageWithJSON:(NSString*)jsonString;
+(HCMessage*)messageWithDictionary:(NSDictionary*)dictionary;

@property (retain) NSDate *timeStamp;
@property (assign) NSInteger messageId;
@property (assign) NSInteger roomID;
@property (assign) NSInteger userID;
@property (retain) NSString* messageBody;
@property (retain) NSString* messageType;
@property (retain) NSString* userName;


@end