//
//  Campfire.h
//  CampfireStreaming
//
//  Created by Randall Brown on 8/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequestDelegate.h"
#import "HCMessage.h"
#import "HCRoom.h"
#import "HCUploadFile.h"
#import "HCUser.h"

@protocol CampfireResponseProtocol

-(void)messageReceived:(HCMessage*)message;
-(void)listeningFailed:(NSError*)error;

@end

@interface HappyCampfire : NSObject <ASIHTTPRequestDelegate, NSURLConnectionDelegate>
{
   NSString *campfireURL;
   id<CampfireResponseProtocol> delegate;
   NSString *authToken;
}

- (id)initWithCampfireURL:(NSString*)campfireURL;
-(void)startListeningForMessagesInRoom:(NSString*)roomID;
-(void)sendText:(NSString*)messageText toRoom:(NSString*)roomID completionHandler:(void (^)(HCMessage* message, NSError*error))handler;
-(void)sendSound:(NSString*)sound toRoom:(NSString*)roomID completionHandler:(void (^)(HCMessage* message, NSError*error))handler;
-(void)getMessagesFromRoom:(NSString*)roomID sinceID:(NSInteger)lastMessageID completionHandler:(void (^)(NSArray* messages))handler;

//Rooms
-(void)getVisibleRoomsWithHandler:(void (^)(NSArray* rooms))handler;
-(void)getRoomsAuthenticatedUserIsInWithHandler:(void (^)(NSArray* rooms))handler;
-(void)getRoomWithID:(NSString*)roomID completionHandler:(void (^)(HCRoom *room))handler;
-(void)postFile:(NSString*)file toRoom:(NSString*)roomID completionHandler:(void (^)(HCUploadFile *file, NSError *error))handler;
-(void)updateRoom:(NSString*)roomID topic:(NSString*)topic name:(NSString*)name completionHandler:(void (^)(NSError *error))handler;
-(void)getRecentlyUploadedFilesFromRoom:(NSString*)roomID completionHandler:(void (^)(NSArray *files, NSError *error))handler;

-(void)joinRoom:(NSString*)roomID WithCompletionHandler:(void (^)(NSError *error))handler;
-(void)leaveRoom:(NSString*)roomID WithCompletionHandler:(void (^)(NSError *error))handler;
-(void)lockRoom:(NSString*)roomID WithCompletionHandler:(void (^)(NSError *error))handler;
-(void)unlockRoom:(NSString*)roomID WithCompletionHandler:(void (^)(NSError *error))handler;

//Users
-(void)getUserWithID:(NSString*)userID withCompletionHandler:(void(^)(HCUser *user, NSError*error))handler;
-(void)getAuthenticatedUserInfo:(void(^)(HCUser *user, NSError*error))handler;
-(void)authenticateUserWithName:(NSString*)userName password:(NSString*)password completionHandler:(void(^)(HCUser *user, NSError*error))handler;


@property (assign) id<CampfireResponseProtocol> delegate;
@property (retain) NSString *authToken;

@end
