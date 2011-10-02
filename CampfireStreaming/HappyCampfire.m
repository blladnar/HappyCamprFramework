//
//  Campfire.m
//  CampfireStreaming
//
//  Created by Randall Brown on 8/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HappyCampfire.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "SBJSON.h"
#import "HCRoom.h"
#import "HCUser.h"
#import "GDataXMLNode.h"

@interface HappyCampfire() 

-(HCUser*)userWithUserElement:(GDataXMLElement*)element;
-(ASIHTTPRequest*)requestWithURL:(NSURL*)url;

@end

@implementation HappyCampfire
@synthesize delegate;
@synthesize authToken;

- (id)initWithCampfireURL:(NSString*)aCampfireURL
{
    self = [super init];
    if (self) {
       campfireURL = [aCampfireURL retain];
    }
    
    return self;
}

-(void)dealloc
{
   [campfireURL release];
}

-(NSString*)messageWithType:(NSString*)messageType andMessage:(NSString*)message
{
   return [NSString stringWithFormat:@"<message><type>%@</type><body>%@</body></message>", messageType, message];
}

-(void)startListeningForMessagesInRoom:(NSString*)roomID
{
   NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://streaming.campfirenow.com/room/%@/live.json",  roomID]];
   ASIHTTPRequest *streamRequest = [[ASIHTTPRequest alloc] initWithURL:url];
   streamRequest.delegate = self;
   [streamRequest setAuthenticationScheme:(NSString *)kCFHTTPAuthenticationSchemeBasic];
   [streamRequest setUsername:authToken];
   [streamRequest setPassword:@"X"];
   [streamRequest setShouldAttemptPersistentConnection:YES];
   
   [streamRequest startAsynchronous];
}


-(void)request:(ASIHTTPRequest *)request didReceiveData:(NSData *)data
{
   NSString *dataString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
   
   if( !([data length] > 1) )
      return;
   
   NSArray *messagesInStrings = [dataString componentsSeparatedByString:@"}"];
   NSMutableArray *fixedMessageStrings = [NSMutableArray array];
   int i=0;
   for( NSString *messageString in  messagesInStrings )
   {
      [fixedMessageStrings addObject:[messageString stringByAppendingString:@"}"]];
      i++;
   }
   
   for( NSString *fixedString in fixedMessageStrings )
   {
      if( !([fixedString length] > 2) )
         continue;
      
      HCMessage *message = [HCMessage messageWithJSON:fixedString];

      [delegate messageReceived:message];      
   }
   
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
   NSLog(@"Request Failed %@",[request error]);
   [delegate listeningFailed:[request error]];
}

-(void)requestFinished:(ASIHTTPRequest *)request
{
   NSLog(@"Request Finished");
   NSLog(@"%@", request);
}

-(void)sendText:(NSString*)messageText toRoom:(NSString*)roomID completionHandler:(void (^)(HCMessage* message, NSError*error))handler
{   
   NSString *urlString = [NSString stringWithFormat:@"%@/room/%@/speak.json",campfireURL,roomID];
   
   __block ASIHTTPRequest *request = [self requestWithURL:[NSURL URLWithString:urlString]];
   
   
   NSString *postBody = [self messageWithType:@"TextMessage" andMessage:messageText];
   
   [request setPostBody:(NSMutableData*)[postBody dataUsingEncoding:NSUTF8StringEncoding]];
   
   [request setCompletionBlock:^{
      SBJsonParser *parser = [[SBJsonParser new] autorelease];
      
      id messageDict = [parser objectWithString:[request responseString]];
      HCMessage *message = [HCMessage messageWithDictionary:[messageDict objectForKey:@"message"]];
      handler( message, [request error] );
   }];
   
   [request startAsynchronous];   
}

-(ASIHTTPRequest*)requestWithURL:(NSURL*)url
{
   ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
   
   [request addRequestHeader:@"Content-Type" value:@"application/xml"];
   [request setAuthenticationScheme:(NSString *)kCFHTTPAuthenticationSchemeBasic];
   [request setUsername:authToken];
   [request setPassword:@"X"];
   
   return request;
}

-(void)getMessagesFromRoom:(NSString*)roomID sinceID:(NSInteger)lastMessageID completionHandler:(void (^)(NSArray* messages))handler
{
   
   NSString *urlString = [NSString stringWithFormat:@"%@/room/%@/recent.json?since_message_id=%i",campfireURL ,roomID, lastMessageID];
   __block ASIHTTPRequest *request = [self requestWithURL:[NSURL URLWithString:urlString]];
   
   [request setCompletionBlock:^{
      NSMutableArray *messages = [NSMutableArray array];
      
      NSString *responseString = [request responseString];

      SBJsonParser *jsonParser = [[[SBJsonParser alloc] init] autorelease];
      
      id messageArray = [[jsonParser objectWithString:responseString] objectForKey:@"messages"];
      
      for( NSDictionary *messageDict in messageArray )
      {
         HCMessage *message = [HCMessage messageWithDictionary:messageDict];

         [messages addObject:message];
      }
      handler( messages );
   }];
   
   [request startAsynchronous];    
}

-(void)getVisibleRoomsWithHandler:(void (^)(NSArray* rooms))handler
{
   NSString *urlString = [NSString stringWithFormat:@"%@/rooms.xml",campfireURL];
   __block ASIHTTPRequest *request = [self requestWithURL:[NSURL URLWithString:urlString]];
   [request setCompletionBlock:^{
      NSString *responseString = [request responseString];
      
      
      GDataXMLElement *element = [[[GDataXMLElement alloc] initWithXMLString:responseString error:nil] autorelease];
      NSArray *roomElements = [element elementsForName:@"room"];
      NSMutableArray *rooms = [NSMutableArray array];
      for( GDataXMLElement *roomElement in roomElements )
      {
         HCRoom *room = [[HCRoom new] autorelease];
         
         room.roomID = [[[roomElement elementsForName:@"id"] lastObject] stringValue];
         room.name = [[[roomElement elementsForName:@"name"] lastObject] stringValue];
         room.topic = [[[roomElement elementsForName:@"topic"] lastObject] stringValue];
         
         [rooms addObject:room];
      }
      
      handler( rooms );
   }];
   
   [request startAsynchronous];
}

-(void)getRoomsAuthenticatedUserIsInWithHandler:(void (^)(NSArray* rooms))handler
{
   NSString *urlString = [NSString stringWithFormat:@"%@/presence.xml",campfireURL];
   __block ASIHTTPRequest *request = [self requestWithURL:[NSURL URLWithString:urlString]];
   [request setCompletionBlock:^{
      NSString *responseString = [request responseString];
      
      GDataXMLElement *element = [[[GDataXMLElement alloc] initWithXMLString:responseString error:nil] autorelease];
      
      NSArray *roomElements = [element elementsForName:@"room"];
      NSMutableArray *rooms = [NSMutableArray array];
      for( GDataXMLElement *roomElement in roomElements )
      {
         HCRoom *room = [[HCRoom new] autorelease];
         
         room.roomID = [[[roomElement elementsForName:@"id"] lastObject] stringValue];
         room.name = [[[roomElement elementsForName:@"name"] lastObject] stringValue];
         room.topic = [[[roomElement elementsForName:@"topic"] lastObject] stringValue];
         
         [rooms addObject:room];
      }
      
      handler( rooms );
   }];
   
   [request startAsynchronous];   
}

-(void)getRoomWithID:(NSString*)roomID completionHandler:(void (^)(HCRoom *room))handler
{
   NSString *urlString = [NSString stringWithFormat:@"%@/room/%@.xml", campfireURL, roomID];
   
   __block ASIHTTPRequest *request = [self requestWithURL:[NSURL URLWithString:urlString]];
   
   [request setCompletionBlock:^{
      NSString *responseString = [request responseString];

      
      HCRoom *room = [[HCRoom new] autorelease];
      GDataXMLElement *roomElement = [[[GDataXMLElement alloc] initWithXMLString:responseString error:nil] autorelease];
      
      room.roomID = [[[roomElement elementsForName:@"id"] lastObject] stringValue];
      room.name = [[[roomElement elementsForName:@"name"] lastObject] stringValue];
      room.topic = [[[roomElement elementsForName:@"topic"] lastObject] stringValue];
      
      NSArray *userElements = [[[roomElement elementsForName:@"users"] lastObject] elementsForName:@"user"];
      NSMutableArray *usersInRoom = [NSMutableArray array];
      
      for( GDataXMLElement *userElement in userElements )
      {
         HCUser *user = [self userWithUserElement:userElement];
         
         [usersInRoom addObject:user];
      }
      
      room.users = usersInRoom;
      
      
      handler( room );
      
   }];
   
   [request startAsynchronous];    
}

-(HCUploadFile *)uploadFileWithUploadElement:(GDataXMLElement*)element
{
   HCUploadFile *file = [[HCUploadFile new] autorelease];
   file.sizeInBytes = [[[[element elementsForName:@"byte-size"] lastObject] stringValue] intValue];
   file.fullURL = [[[element elementsForName:@"full-url"] lastObject] stringValue];
   file.contentType = [[[element elementsForName:@"content-type"] lastObject] stringValue];
   
   NSDateFormatter *dateFormatter = [[NSDateFormatter new] autorelease];
   [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
   [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
   file.createdAt = [dateFormatter dateFromString:[[[element elementsForName:@"created-at"] lastObject] stringValue]];
   file.fileID = [[[[element elementsForName:@"id"] lastObject] stringValue] intValue];
   file.name = [[[element elementsForName:@"name"] lastObject] stringValue];
   file.roomID = [[[element elementsForName:@"room-id"] lastObject] stringValue];
   file.userID = [[[element elementsForName:@"user-id"] lastObject] stringValue]; 
   return file;
}

-(void)postFile:(NSString*)file toRoom:(NSString*)roomID completionHandler:(void (^)(HCUploadFile *file, NSError *error))handler
{
   NSString *urlString = [NSString stringWithFormat:@"%@/room/%@/uploads.xml", campfireURL, roomID];
   
   __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]];
   [request addRequestHeader:@"Content-Type" value:@"multipart/form-data"];
   [request setAuthenticationScheme:(NSString *)kCFHTTPAuthenticationSchemeBasic];
   [request setUsername:authToken];
   [request setPassword:@"X"];
   
   [request setFile:file forKey:@"upload"];
   
   [request setCompletionBlock:^{
      
      
      GDataXMLElement *element = [[[GDataXMLElement alloc] initWithXMLString:[request responseString] error:nil] autorelease];

      HCUploadFile *file = [self uploadFileWithUploadElement:element];
      
      handler(file,[request error]);
   }];
    
   [request setFailedBlock:^{
      handler(nil,[request error]);
   }];
   
   [request startAsynchronous];
}

-(void)updateRoom:(NSString*)roomID topic:(NSString*)topic name:(NSString*)name completionHandler:(void (^)(NSError *error))handler
{
   NSString *urlString = [NSString stringWithFormat:@"%@/room/%@.xml", campfireURL, roomID];
   __block ASIHTTPRequest *request = [self requestWithURL:[NSURL URLWithString:urlString]];
   
   NSString *postString = [NSString stringWithFormat:@"<room><name>%@</name><topic>%@</topic></room>", name, topic];
   

   [request setPostBody:(NSMutableData*)[postString dataUsingEncoding:NSUTF8StringEncoding]];
      [request setRequestMethod:@"PUT"];
   [request startAsynchronous];
   
}

-(void)getRecentlyUploadedFilesFromRoom:(NSString*)roomID completionHandler:(void (^)(NSArray *files, NSError *error))handler
{
   NSString *urlString = [NSString stringWithFormat:@"%@/room/%@/uploads.xml", campfireURL, roomID];
   
   __block ASIHTTPRequest *request = [self requestWithURL:[NSURL URLWithString:urlString]];

   
   [request setCompletionBlock:^{
      
      
      GDataXMLElement *element = [[[GDataXMLElement alloc] initWithXMLString:[request responseString] error:nil] autorelease];
      
      NSArray *uploadFileElements = [element elementsForName:@"upload"];
      NSMutableArray *uploadFiles = [NSMutableArray array];
      for( GDataXMLElement *uploadFileElement in uploadFileElements )
      {
         
         HCUploadFile *file = [self uploadFileWithUploadElement:uploadFileElement];
         [uploadFiles addObject:file];
      }
      
      handler(uploadFiles,[request error]);
   }];
   
   [request setFailedBlock:^{
      handler(nil,[request error]);
   }];
   
   [request startAsynchronous];   
}

-(void)joinRoom:(NSString*)roomID WithCompletionHandler:(void (^)(NSError *error))handler
{
   NSString *urlString = [NSString stringWithFormat:@"%@/room/%@/join.xml", campfireURL, roomID];
   
   __block ASIHTTPRequest *request = [self requestWithURL:[NSURL URLWithString:urlString]];
   [request setRequestMethod:@"POST"];

   
   [request setCompletionBlock:^{
      handler( [request error] );
      
   }];
   
   [request startAsynchronous];   
}

-(void)leaveRoom:(NSString*)roomID WithCompletionHandler:(void (^)(NSError *error))handler
{
   NSString *urlString = [NSString stringWithFormat:@"%@/room/%@/leave.xml", campfireURL, roomID];
   
   __block ASIHTTPRequest *request = [self requestWithURL:[NSURL URLWithString:urlString]];
   [request setRequestMethod:@"POST"];
   
   
   [request setCompletionBlock:^{
      handler( [request error] );
      
   }];
   
   [request startAsynchronous];     
}

-(void)lockRoom:(NSString*)roomID WithCompletionHandler:(void (^)(NSError *error))handler
{
   NSString *urlString = [NSString stringWithFormat:@"%@/room/%@/lock.xml", campfireURL, roomID];
   
   __block ASIHTTPRequest *request = [self requestWithURL:[NSURL URLWithString:urlString]];
   [request setRequestMethod:@"POST"];
   
   
   [request setCompletionBlock:^{
      handler( [request error] );
      
   }];
   
   [request startAsynchronous];     
}

-(void)unlockRoom:(NSString*)roomID WithCompletionHandler:(void (^)(NSError *error))handler
{
   NSString *urlString = [NSString stringWithFormat:@"%@/room/%@/unlock.xml", campfireURL, roomID];
   
   __block ASIHTTPRequest *request = [self requestWithURL:[NSURL URLWithString:urlString]];
   [request setRequestMethod:@"POST"];
   
   
   [request setCompletionBlock:^{
      handler( [request error] );
      
   }];
   
   [request startAsynchronous];     
}

-(HCUser*)userWithUserElement:(GDataXMLElement*)element
{
   HCUser *user = [[HCUser new] autorelease];
   
   user.userID = [[[[element elementsForName:@"id"] lastObject] stringValue] intValue];
   user.name = [[[element elementsForName:@"name"] lastObject] stringValue];
   user.email = [[[element elementsForName:@"email-address"] lastObject] stringValue];
   user.avatarURL = [[[element elementsForName:@"avatar-url"] lastObject] stringValue];
   user.authToken = [[[element elementsForName:@"api-auth-token"] lastObject] stringValue];
   
   return user;
}

-(void)getUserWithID:(NSString*)userID withCompletionHandler:(void(^)(HCUser*user, NSError*error))handler
{
   NSString *urlString = [NSString stringWithFormat:@"%@/users/%@.xml", campfireURL, userID];
   
   __block ASIHTTPRequest *request = [self requestWithURL:[NSURL URLWithString:urlString]];
   
   [request setCompletionBlock:^{
      GDataXMLElement *userElement = [[[GDataXMLElement alloc] initWithXMLString:[request responseString] error:nil] autorelease];
      HCUser *user = [self userWithUserElement:userElement];
      handler( user, [request error] );
      
   }];
   
   [request startAsynchronous];     
}

-(void)getAuthenticatedUserInfo:(void(^)(HCUser *user, NSError*error))handler
{
   NSString *urlString = [NSString stringWithFormat:@"%@/users/me.xml", campfireURL];
   
   __block ASIHTTPRequest *request = [self requestWithURL:[NSURL URLWithString:urlString]];
   
   [request setCompletionBlock:^{
      
      GDataXMLElement *userElement = [[[GDataXMLElement alloc] initWithXMLString:[request responseString] error:nil] autorelease];
      HCUser *user = [self userWithUserElement:userElement];
      handler( user, [request error] );
      
   }];
   
   [request startAsynchronous];     
}

-(void)authenticateUserWithName:(NSString*)userName password:(NSString*)password completionHandler:(void(^)(HCUser *user, NSError*error))handler
{
   NSString *urlString = [NSString stringWithFormat:@"%@/users/me.xml", campfireURL];
   
   __block ASIHTTPRequest *request = [self requestWithURL:[NSURL URLWithString:urlString]];
   [request setUsername:userName];
   [request setPassword:password];
   
   [request setCompletionBlock:^{
      GDataXMLElement *userElement = [[[GDataXMLElement alloc] initWithXMLString:[request responseString] error:nil] autorelease];

      HCUser *user = [self userWithUserElement:userElement];
      handler( user, [request error] );
      authToken = user.authToken;
      
   }];
   
   [request startAsynchronous];     
}

-(void)sendSound:(NSString*)sound toRoom:(NSString*)roomID completionHandler:(void (^)(HCMessage* message, NSError*error))handler
{
   NSString *urlString = [NSString stringWithFormat:@"%@/room/%@/speak.json",campfireURL,roomID];
   
   
   __block ASIHTTPRequest *request = [self requestWithURL:[NSURL URLWithString:urlString]];
   
   NSString *postBody = [self messageWithType:@"SoundMessage" andMessage:sound];
   
   [request setPostBody:(NSMutableData*)[postBody dataUsingEncoding:NSUTF8StringEncoding]];
   
   [request setCompletionBlock:^{
      SBJsonParser *parser = [[SBJsonParser new] autorelease];
      
      id messageDict = [parser objectWithString:[request responseString]];
      HCMessage *message = [HCMessage messageWithDictionary:[messageDict objectForKey:@"message"]];

      handler( message, [request error] );
   }];
   
   [request startAsynchronous];      
}

@end
