//
//  Message.h
//  HappyCampr
//
//  Created by Brown, Randall on 7/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Message : NSObject {
@private
   
}

@property (retain) NSDate *timeStamp;
@property (assign) NSInteger messageId;
@property (assign) NSInteger roomID;
@property (assign) NSInteger userID;
@property (retain) NSString* messageBody;
@property (retain) NSString* messageType;
@property (retain) NSString* userName;


@end