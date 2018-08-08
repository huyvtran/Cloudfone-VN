//
//  OTRXMPPManager.m
//  Off the Record
//
//  Created by Chris Ballinger on 9/7/11.
//  Copyright (c) 2011 Chris Ballinger. All rights reserved.
//
//  This file is part of ChatSecure.
//
//  ChatSecure is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ChatSecure is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ChatSecure.  If not, see <http://www.gnu.org/licenses/>.

#import "OTRXMPPManager.h"
#import "MainChatViewController.h"
#import "GroupMainChatViewController.h"
#import "GCDAsyncSocket.h"
#import "XMPP.h"
#import "XMPPReconnect.h"
#import "XMPPCapabilitiesCoreDataStorage.h"
#import "XMPPRosterCoreDataStorage.h"
#import "XMPPvCardAvatarModule.h"
#import "XMPPvCardCoreDataStorage.h"
#import "XMPPMessage+XEP_0184.h"
#import "XMPPMessage+XEP_0085.h"
#import "strings.h"

#import "DDLog.h"
#import "DDTTYLogger.h"

#import <CFNetwork/CFNetwork.h>

#import "OTRSettingsManager.h"
#import "OTRConstants.h"
#import "OTRProtocolManager.h"
#include <stdlib.h>
#import "contactBlackListCell.h"
#import "NSBubbleData.h"
#import "NSDatabase.h"
#import "OTRConstants.h"
#import "PhoneMainView.h"

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

@interface OTRXMPPManager(){
    NSString *strDataReceive;
}

- (void)setupStream;
- (void)teardownStream;

- (void)goOnline;
- (void)goOffline;
- (void)failedToConnect;

@end


@implementation OTRXMPPManager
@synthesize password, JID;

//@synthesize xmppStream;
@synthesize xmppReconnect;
@synthesize xmppRoster;
@synthesize xmppRosterStorage;
@synthesize xmppvCardTempModule;
@synthesize xmppvCardAvatarModule;
@synthesize xmppCapabilities;
@synthesize xmppCapabilitiesStorage;
@synthesize isXmppConnected;
@synthesize protocolBuddyList;
@synthesize account;
@synthesize appDelegate;
@synthesize _sqlitePath, _database;
@synthesize byteData, seq, checkClose;

- (id)init
{
    self = [super init];
    
    if(self)
    {
        appDelegate = (LinphoneAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        /*--active xmppStream cho outgoing file--*/
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activeOutgoingFile:)
                                                     name:activeOutgoingFileTransfer object:nil];
        // Configure logging framework
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
        
        // Setup the XMPP stream
        [self setupStream];
        
        //[self setupStream];
        protocolBuddyList = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc
{
	[self teardownStream];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark NSFetchedResultsController
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSFetchedResultsController *)fetchedResultsController
{
	if (fetchedResultsController == nil)
	{
		NSManagedObjectContext *moc = [self managedObjectContext_roster];
		
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject"
		                                          inManagedObjectContext:moc];
        
		NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"sectionNum" ascending:YES];
		NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
		
		NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, sd2, nil];
		
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		[fetchRequest setEntity:entity];
		[fetchRequest setSortDescriptors:sortDescriptors];
		[fetchRequest setFetchBatchSize:10];
		
		fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
		                                                               managedObjectContext:moc
		                                                                 sectionNameKeyPath:@"sectionNum"
		                                                                          cacheName:nil];
		[fetchedResultsController setDelegate:self];
		
		NSError *error = nil;
		if (![fetchedResultsController performFetch:&error])
		{
			NSLog(@"Error performing fetch: %@", error);
		}
	}
	return fetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kOTRBuddyListUpdate object:self];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Core Data
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSManagedObjectContext *)managedObjectContext_roster
{
	NSAssert([NSThread isMainThread],
	         @"NSManagedObjectContext is not thread safe. It must always be used on the same thread/queue");
	
	if (managedObjectContext_roster == nil)
	{
		managedObjectContext_roster = [[NSManagedObjectContext alloc] init];
		
		NSPersistentStoreCoordinator *psc = [xmppRosterStorage persistentStoreCoordinator];
		[managedObjectContext_roster setPersistentStoreCoordinator:psc];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
		                                         selector:@selector(contextDidSave:)
		                                             name:NSManagedObjectContextDidSaveNotification
		                                           object:nil];
	}
	
	return managedObjectContext_roster;
}

- (NSManagedObjectContext *)managedObjectContext_capabilities
{
	NSAssert([NSThread isMainThread],
	         @"NSManagedObjectContext is not thread safe. It must always be used on the same thread/queue");
	
	if (managedObjectContext_capabilities == nil)
	{
		managedObjectContext_capabilities = [[NSManagedObjectContext alloc] init];
		
		NSPersistentStoreCoordinator *psc = [xmppCapabilitiesStorage persistentStoreCoordinator];
		[managedObjectContext_roster setPersistentStoreCoordinator:psc];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
		                                         selector:@selector(contextDidSave:)
		                                             name:NSManagedObjectContextDidSaveNotification
		                                           object:nil];
	}
	
	return managedObjectContext_capabilities;
}

- (void)contextDidSave:(NSNotification *)notification
{
	NSManagedObjectContext *sender = (NSManagedObjectContext *)[notification object];
	
	if (sender != managedObjectContext_roster &&
	    [sender persistentStoreCoordinator] == [managedObjectContext_roster persistentStoreCoordinator])
	{
		DDLogVerbose(@"%@: %@ - Merging changes into managedObjectContext_roster", THIS_FILE, THIS_METHOD);
		
		dispatch_async(dispatch_get_main_queue(), ^{			
			[managedObjectContext_roster mergeChangesFromContextDidSaveNotification:notification];
		});
    }
	
	if (sender != managedObjectContext_capabilities &&
	    [sender persistentStoreCoordinator] == [managedObjectContext_capabilities persistentStoreCoordinator])
	{
		DDLogVerbose(@"%@: %@ - Merging changes into managedObjectContext_capabilities", THIS_FILE, THIS_METHOD);
		
		dispatch_async(dispatch_get_main_queue(), ^{
			
			[managedObjectContext_capabilities mergeChangesFromContextDidSaveNotification:notification];
		});
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Private
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setupStream
{
	//NSAssert(xmppStream == nil, @"Method setupStream invoked multiple times");
	//NSAssert(appDelegate.xmppStream == nil, @"Method setupStream invoked multiple times");
    
	// Setup xmpp stream
	//
	// The XMPPStream is the base class for all activity.
	// Everything else plugs into the xmppStream, such as modules/extensions and delegates.
    
	//xmppStream = [[XMPPStream alloc] init];
    appDelegate.xmppStream = [XMPPStream new];
    
#if !TARGET_IPHONE_SIMULATOR
	{
		// Want xmpp to run in the background?
		//
		// P.S. - The simulator doesn't support backgrounding yet.
		//        When you try to set the associated property on the simulator, it simply fails.
		//        And when you background an app on the simulator,
		//        it just queues network traffic til the app is foregrounded again.
		//        We are patiently waiting for a fix from Apple.
		//        If you do enableBackgroundingOnSocket on the simulator,
		//        you will simply see an error message from the xmpp stack when it fails to set the property.
		appDelegate.xmppStream.enableBackgroundingOnSocket = YES;
	}
#endif
	
	// Setup reconnect
	//
	// The XMPPReconnect module monitors for "accidental disconnections" and
	// automatically reconnects the stream for you.
	// There's a bunch more information in the XMPPReconnect header file.
	
	xmppReconnect = [[XMPPReconnect alloc] init];
	
	// Setup roster
	//
	// The XMPPRoster handles the xmpp protocol stuff related to the roster.
	// The storage for the roster is abstracted.
	// So you can use any storage mechanism you want.
	// You can store it all in memory, or use core data and store it on disk, or use core data with an in-memory store,
	// or setup your own using raw SQLite, or create your own storage mechanism.
	// You can do it however you like! It's your application.
	// But you do need to provide the roster with some storage facility.
    
    //NSLog(@"Unique Identifier: %@",self.account.uniqueIdentifier);
	
    //xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] initWithDatabaseFilename:self.account.uniqueIdentifier];
    //  xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] initWithInMemoryStore];
	
	xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterStorage];
	
	xmppRoster.autoFetchRoster = YES;
	xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
	
	// Setup vCard support
	//
	// The vCard Avatar module works in conjuction with the standard vCard Temp module to download user avatars.
	// The XMPPRoster will automatically integrate with XMPPvCardAvatarModule to cache roster photos in the roster.
	
	xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
	xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
	
	xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:xmppvCardTempModule];
	
	// Setup capabilities
	//
	// The XMPPCapabilities module handles all the complex hashing of the caps protocol (XEP-0115).
	// Basically, when other clients broadcast their presence on the network
	// they include information about what capabilities their client supports (audio, video, file transfer, etc).
	// But as you can imagine, this list starts to get pretty big.
	// This is where the hashing stuff comes into play.
	// Most people running the same version of the same client are going to have the same list of capabilities.
	// So the protocol defines a standardized way to hash the list of capabilities.
	// Clients then broadcast the tiny hash instead of the big list.
	// The XMPPCapabilities protocol automatically handles figuring out what these hashes mean,
	// and also persistently storing the hashes so lookups aren't needed in the future.
	//
	// Similarly to the roster, the storage of the module is abstracted.
	// You are strongly encouraged to persist caps information across sessions.
	//
	// The XMPPCapabilitiesCoreDataStorage is an ideal solution.
	// It can also be shared amongst multiple streams to further reduce hash lookups.
	
	xmppCapabilitiesStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
    xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:xmppCapabilitiesStorage];
    
    xmppCapabilities.autoFetchHashedCapabilities = YES;
    xmppCapabilities.autoFetchNonHashedCapabilities = NO;
    
	// Activate xmpp modules
    
	[xmppReconnect         activate:appDelegate.xmppStream];
	[xmppRoster            activate:appDelegate.xmppStream];
	[xmppvCardTempModule   activate:appDelegate.xmppStream];
	[xmppvCardAvatarModule activate:appDelegate.xmppStream];
	[xmppCapabilities      activate:appDelegate.xmppStream];
    
	// Add ourself as a delegate to anything we may be interested in
    
	[appDelegate.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
	[xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppCapabilities addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
	// Optional:
	//
	// Replace me with the proper domain and port.
	// The example below is setup for a typical google talk account.
	//
	// If you don't supply a hostName, then it will be automatically resolved using the JID (below).
	// For example, if you supply a JID like 'user@quack.com/rsrc'
	// then the xmpp framework will follow the xmpp specification, and do a SRV lookup for quack.com.
	//
	// If you don't specify a hostPort, then the default (5222) will be used.
	
    //	[xmppStream setHostName:@"talk.google.com"];
    //	[xmppStream setHostPort:5222];
	
    
	// You may need to alter these settings depending on the server you're connecting to
	allowSelfSignedCertificates = account.allowSelfSignedSSL;
	allowSSLHostNameMismatch = account.allowSSLHostNameMismatch;
}

- (void)teardownStream
{
	[appDelegate.xmppStream removeDelegate:self];
	[xmppRoster removeDelegate:self];
	
	[xmppReconnect         deactivate];
	[xmppRoster            deactivate];
	[xmppvCardTempModule   deactivate];
	[xmppvCardAvatarModule deactivate];
	[xmppCapabilities      deactivate];
	
	[appDelegate.xmppStream disconnect];
	
	appDelegate.xmppStream = nil;
	xmppReconnect = nil;
    xmppRoster = nil;
	xmppRosterStorage = nil;
	xmppvCardStorage = nil;
    xmppvCardTempModule = nil;
	xmppvCardAvatarModule = nil;
	xmppCapabilities = nil;
	xmppCapabilitiesStorage = nil;
}

// It's easy to create XML elments to send and to read received XML elements.
// You have the entire NSXMLElement and NSXMLNode API's.
//
// In addition to this, the NSXMLElement+XMPP category provides some very handy methods for working with XMPP.
//
// On the iPhone, Apple chose not to include the full NSXML suite.
// No problem - we use the KissXML library as a drop in replacement.
//
// For more information on working with XML elements, see the Wiki article:
// http://code.google.com/p/xmppframework/wiki/WorkingWithElements

- (void)goOnline
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kOTRProtocolLoginSuccess object:self];
	XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit
    
	//  [[self xmppStream] sendElement:presence];
    [appDelegate.xmppStream sendElement: presence];
    [[NSNotificationCenter defaultCenter] postNotificationName:kOTRBuddyListUpdate object:nil];
    
    [self getGroupDataFromServer];
}

- (void)goOffline
{
	XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [appDelegate.xmppStream sendElement: presence];
}

- (void)failedToConnect
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kOTRProtocolLoginFail object:self];
}

///////////////////////////////
#pragma mark Capabilities Collected
- (void)xmppCapabilities:(XMPPCapabilities *)sender collectingMyCapabilities:(NSXMLElement *)query
{
    if(account.sendDeliveryReceipts)
    {
        NSXMLElement * deliveryReceiptsFeature = [NSXMLElement elementWithName:@"feature"];
        [deliveryReceiptsFeature addAttributeWithName:@"var" stringValue:@"urn:xmpp:receipts"];
        [query addChild:deliveryReceiptsFeature];
    }
    
    NSXMLElement * chatStateFeature = [NSXMLElement elementWithName:@"feature"];
	[chatStateFeature addAttributeWithName:@"var" stringValue:@"http://jabber.org/protocol/chatstates"];
    [query addChild:chatStateFeature];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Connect/disconnect
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)connectWithJID:(NSString*) myJID password:(NSString*)myPassword;
{
    if (myJID == nil || [myJID isEqualToString:@""]) {
        myJID = [NSString stringWithFormat:@"%@@%@", USERNAME, xmpp_cloudfone];
    }
    
    appDelegate.xmppStream.myJID = [XMPPJID jidWithString:myJID resource: appDelegate._resource];
    
    if (appDelegate._xmppIncomingFileTransfer == nil) {
        appDelegate._xmppIncomingFileTransfer = [XMPPIncomingFileTransfer new];
        // Activate all modules
        
        [appDelegate._xmppIncomingFileTransfer activate: appDelegate.xmppStream];
        [appDelegate._xmppIncomingFileTransfer addDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    
    //  NSLog(@"myJID %@",myJID);
	if (![appDelegate.xmppStream isDisconnected]) {
		return YES;
	}
    
	//
	// If you don't want to use the Settings view to set the JID,
	// uncomment the section below to hard code a JID and password.
	//
	// Replace me with the proper JID and password:
	//	myJID = @"user@gmail.com/xmppframework";
	//	myPassword = @"";
    
	if (myJID == nil || myPassword == nil) {
		DDLogWarn(@"JID and password must be set before connecting!");
        
		return NO;
	}
    
    JID = [XMPPJID jidWithString:myJID resource: appDelegate._resource];
    
    [appDelegate.xmppStream setMyJID: JID];
    [appDelegate.xmppStream setHostName:self.account.domain];
    [appDelegate.xmppStream setHostPort:(UInt16)5222];
    password = myPassword;
    
    
	NSError *error = nil;
    if (![appDelegate.xmppStream connectWithTimeout:30.0 error:&error])
	{
		DDLogError(@"Error connecting: %@", error);
		return NO;
	}
	return YES;
}

#pragma mark - XMPPIncomingFileTransferDelegate Methods

- (void)xmppIncomingFileTransfer:(XMPPIncomingFileTransfer *)sender
                didFailWithError:(NSError *)error
{
    DDLogVerbose(@"%@: Incoming file transfer failed with error: %@", THIS_FILE, error);
}

/*----- Thông tin file nhận được -----*/
- (void)xmppIncomingFileTransfer:(XMPPIncomingFileTransfer *)sender
               didReceiveSIOffer:(XMPPIQ *)offer
{
    HMLocalization *localization = [HMLocalization sharedInstance];
    
    NSString *idMessage = @"";
    DDXMLElement *siElement = [offer elementForName:@"si"];
    if (siElement != nil) {
        idMessage = [[siElement attributeForName:@"id"] stringValue];
    }else{
        idMessage = [AppUtils randomStringWithLength: 10];
    }
    
    NSString *fullUsername = [[offer attributeForName:@"from"] stringValue];
    NSXMLElement *fileElement = [[offer elementForName:@"si"] elementForName:@"file"];
    NSString *fileName = [[fileElement attributeForName:@"name"] stringValue];
    
    NSXMLElement *descElemnt = [fileElement elementForName:@"desc"];
    NSString *desc = @"";
    if (descElemnt != nil) {
        desc = [descElemnt stringValue];
    }
    
    int expireTime = [self getExpireTimeOfImageReceive: offer];
    
    // Tạo message cho file trước khi nhận
    [self createMessageForFileBeforeReceiveWithUser:fullUsername idMessage:idMessage fileName:fileName description:desc expireTime: expireTime];
    
    // Tạo thông báo khi đang chạy background
    NSString *sendPhone = [AppUtils getSipFoneIDFromString: fullUsername];
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground) {
        NSString *name = [NSDatabase getNameOfContactWithPhoneNumber: sendPhone];
        
        NSString *alertStr = [NSString stringWithFormat:@"%@\n%@", name, [localization localizedStringForKey:text_message_image_received]];
        NSDictionary *infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:bannerNotifUserMessage,@"type",sendPhone,@"user", nil];
        [AppUtils createLocalNotificationWithAlertBody:alertStr andInfoDict:infoDict ofUser:sendPhone];
        // Cập nhật badge cho app
        int curBadge = (int)[[UIApplication sharedApplication] applicationIconBadgeNumber];
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:curBadge+1];
    }else{
        // Nếu không là message của user đang chat thì tạo thông báo
        
        NSString *friendStr = [AppUtils getSipFoneIDFromString: appDelegate.friendBuddy.accountName];
        if (![[[PhoneMainView instance] currentView] isEqual:[MainChatViewController compositeViewDescription]] || ![friendStr isEqualToString:sendPhone]) {
            [self createRingAndVibrationOfNewMessageForUser: sendPhone];
        }
    }
    [sender setIdMessage: idMessage];
    
    [sender acceptSIOffer:offer];
}

- (void)xmppIncomingFileTransfer:(XMPPIncomingFileTransfer *)sender
              didSucceedWithData:(NSData *)data
                           named:(NSString *)name idMessage:(NSString *)idMessage
{
    DDLogVerbose(@"%@: Incoming file transfer did succeed.", THIS_FILE);
    [self saveDataOfDocument:data withFileName:name idMessage: idMessage];
}

- (void)disconnect {
    
    [self goOffline];
    
    [appDelegate.xmppStream disconnect];
    
    OTRProtocolManager *protocolManager = [OTRProtocolManager sharedInstance];
    [protocolManager.protocolManagers removeObjectForKey:self.account.uniqueIdentifier];
    
    [self.xmppRosterStorage clearAllUsersAndResourcesForXMPPStream: appDelegate.xmppStream];
    
    
     self.protocolBuddyList = nil;
//     NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//     NSEntityDescription *entity = [NSEntityDescription entityForName:entityDescription inManagedObjectContext:managedObjectContext_roster];
//     [fetchRequest setEntity:entity];
//     
//     NSError *error;
//     NSArray *items = [managedObjectContext_roster executeFetchRequest:fetchRequest error:&error];
//     
//     
//     for (NSManagedObject *managedObject in items) {
//     [managedObjectContext_roster deleteObject:managedObject];
//     NSLog(@"%@ object deleted",entityDescription);
//     }
//     if (![managedObjectContext_roster save:&error]) {
//     NSLog(@"Error deleting %@ - error:%@",entityDescription,error);
//     }
//     
//     NSPersistentStoreCoordinator * storeCoordinator = self.xmppRosterStorage.persistentStoreCoordinator;
//     NSArray *stores = storeCoordinator.persistentStores;
//     
//     for(NSPersistentStore *store in stores)
//     {
//     NSError * error = nil;
//     NSURL *storeURL = store.URL;
//     [storeCoordinator removePersistentStore:store error:&error];
//     [[NSFileManager defaultManager] removeItemAtPath:storeURL.path error:&error];
//     if(error)
//     NSLog(@"%@",[error description]);
//     }
    [[NSNotificationCenter defaultCenter] postNotificationName:kOTRProtocolLogout object:self];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPStream Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma clang diagnostic ignored "-Wdeprecated-declarations"

- (void)xmppStream:(XMPPStream *)sender socketWillConnect:(GCDAsyncSocket *)socket
{
    // Tell the socket to stay around if the app goes to the background (only works on apps with the VoIP background flag set)
    [socket performBlock:^{
        [socket enableBackgroundingOnSocket];
    }];
}

- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    [socket enableBackgroundingOnSocket];
    [appDelegate.xmppStream setEnableBackgroundingOnSocket: YES];
}

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	if (allowSelfSignedCertificates)
	{
		[settings setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCFStreamSSLAllowsAnyRoot];
	}
	
	if (allowSSLHostNameMismatch)
	{
		[settings setObject:[NSNull null] forKey:(NSString *)kCFStreamSSLPeerName];
	}
	else
	{
		// Google does things incorrectly (does not conform to RFC).
		// Because so many people ask questions about this (assume xmpp framework is broken),
		// I've explicitly added code that shows how other xmpp clients "do the right thing"
		// when connecting to a google server (gmail, or google apps for domains).
		
		NSString *expectedCertName = nil;
		
		NSString *serverDomain = appDelegate.xmppStream.hostName;
		NSString *virtualDomain = [appDelegate.xmppStream.myJID domain];
		
		if ([serverDomain isEqualToString:@"talk.google.com"])
		{
			if ([virtualDomain isEqualToString:@"gmail.com"])
			{
				expectedCertName = virtualDomain;
			}
			else
			{
				expectedCertName = serverDomain;
			}
		}
		else if (serverDomain == nil)
		{
			expectedCertName = virtualDomain;
		}
		else
		{
			expectedCertName = serverDomain;
		}
		
		if (expectedCertName)
		{
			[settings setObject:expectedCertName forKey:(NSString *)kCFStreamSSLPeerName];
		}
	}
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	NSError *error = nil;
    password = PASSWORD;
    
	//if (![[self xmppStream] authenticateWithPassword:password error:&error])
    if (![appDelegate.xmppStream authenticateWithPassword:password error:&error])
	{
		DDLogError(@"Error authenticating: %@", error);
        isXmppConnected = NO;
        return;
	}
    isXmppConnected = YES;
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	[self goOnline];
}

-(void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule didReceivevCardTemp:(XMPPvCardTemp *)vCardTemp forJID:(XMPPJID *)jid{
    NSLog(@"123");
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    [self failedToConnect];
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    NSString *idIQ = [[iq attributeForName:@"id"] stringValue];
    
    //  Kiểm tra requestsent: nếu 2 user ko phải from to thì sẽ trả về type = error
    if ([idIQ hasPrefix:@"requestsent_"])
    {
        [appDelegate.myBuddy.protocol sendRequestFrom:appDelegate.myBuddy.accountName
                                               toUser: appDelegate._cloudfoneRequestSent];
        appDelegate._cloudfoneRequestSent = @"";
    }
    
    if ([[[iq attributeForName:@"id"] stringValue] hasPrefix:@"leaveroom_id"]) {
        if ([[[iq attributeForName:@"type"] stringValue] isEqualToString:@"result"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:receiveIQResultLeaveRoom object:nil];
        }else if ([[[iq attributeForName:@"type"] stringValue] isEqualToString:@"error"]){
            [[NSNotificationCenter defaultCenter] postNotificationName:receiveIQErrorLeaveRoom object:nil];
        }
    }
    
    
    NSXMLElement *query = [iq elementForName:@"query" xmlns:XMPPMUCPrivateStorage];
    if (query != nil) {
        //NSLog(@"XMPPService: xmppStream->didReceiveIQ = %@",iq.description);
        NSXMLElement *groups = [query elementForName:@"groups" xmlns:@"cloudfone/rooms"];
        if (groups != nil) {
            NSString *groupIds = [[groups elementForName:@"ids"] stringValue];
            if (groupIds == nil) {
                groupIds = @"";
            }
            NSString *key = [NSString stringWithFormat:@"GROUPS_%@", USERNAME];
            [[NSUserDefaults standardUserDefaults] setObject:groupIds forKey:key];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:getAllGroupsForAccountSuccessful
                                                                object:nil];
            [appDelegate.myBuddy.protocol storeGroupDataToServer: groupIds];
        }
    }
    
    if([iq.type isEqualToString:@"result"])
    {
        // Kiểm tra có phải kết quả get list user trong chat room hay không?
        NSString *fromStr = [[iq attributeForName:@"from"] stringValue];
        if (fromStr != nil) {
            NSRange roomRange = [fromStr rangeOfString: [NSString stringWithFormat:@"@%@", xmpp_cloudfone_group]];
            if (roomRange.location != NSNotFound) {
                DDXMLElement *query = [iq elementForName:@"query"];
                NSString *xmlns = [query xmlns];
                if ([xmlns isEqualToString:@"http://jabber.org/protocol/disco#info"]) {
                    NSArray *xArr = [query elementsForName:@"x"];
                    if (xArr.count > 0) {
                        NSXMLElement *xElement = [xArr objectAtIndex: 0];
                        NSArray *xChildArr = [xElement children];
                        for (int iCount=0; iCount<xChildArr.count; iCount++) {
                            NSXMLElement *fieldElement = [xChildArr objectAtIndex: iCount];
                            NSString *var = [[fieldElement attributeForName:@"var"] stringValue];
                            if ([var isEqualToString:@"muc#roominfo_subject"]) {
                                NSArray *subjectArr = [fieldElement elementsForName:@"value"];
                                if (subjectArr.count > 0) {
                                    NSString *roomName = [fromStr substringToIndex: roomRange.location];
                                    NSString *subject = [[subjectArr objectAtIndex: 0] stringValue];
                                    if (subject == nil || [subject isEqualToString: @""]) {
                                        subject = roomName;
                                    }
                                    [NSDatabase saveRoomSubject: subject forRoom: roomName];
                                    [[NSNotificationCenter defaultCenter] postNotificationName:reloadSubjectForRoom
                                                                                        object:nil];
                                }
                            }
                        }
                    }
                }else{
                    if (query != nil) {
                        NSArray *listItem = [query children];
                        NSMutableArray *userArr = [[NSMutableArray alloc] init];
                        for (int iCount = 0; iCount < listItem.count; iCount++) {
                            DDXMLElement *item = [listItem objectAtIndex: iCount];
                            NSString *callnexUser = [[item attributeForName:@"jid"] stringValue];
                            if (callnexUser != nil && ![callnexUser isEqualToString: @""]) {
                                [userArr addObject: callnexUser];
                            }
                        }
                        [[NSNotificationCenter defaultCenter] postNotificationName:k11GetListUserInRoomChat object:userArr];
                    }
                }
            }
            
            //  Kiểm tra có phải kết quả vCard của user hay ko?
            if (![fromStr containsString:appDelegate.myBuddy.accountName])
            {
                NSLog(@"-----------VCARD");
                DDXMLElement *vcard = [iq elementForName:@"vCard" xmlns:@"vcard-temp"];
                if (vcard != nil)
                {
                    NSString *CloudFoneID = [self getCloundFoneIDFromSingleString: fromStr];
                    
                    NSString *Name = @"";
                    DDXMLElement *NameElement = [vcard elementForName:@"FN"];
                    if (NameElement != nil && ![NameElement isKindOfClass:[NSNull class]])
                    {
                        Name = [NameElement stringValue];
                        if (Name == nil || [Name isKindOfClass:[NSNull class]]) {
                            Name = @"";
                        }else{
                            Name = [Name stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                        }
                    }
                    
                    NSString *Avatar = @"";
                    DDXMLElement *PhotoElement = [vcard elementForName:@"PHOTO"];
                    if (PhotoElement != nil && ![PhotoElement isKindOfClass:[NSNull class]])
                    {
                        Avatar = [[PhotoElement elementForName:@"BINVAL"] stringValue];
                        if (Avatar == nil || [Avatar isKindOfClass:[NSNull class]]) {
                            Avatar = @"";
                        }
                    }
                    
                    NSString *Address = @"";
                    DDXMLElement *AddressElement = [vcard elementForName:@"ADR"];
                    if (AddressElement != nil && ![AddressElement isKindOfClass:[NSNull class]])
                    {
                        DDXMLElement *HomeElement = [AddressElement elementForName:@"HOME"];
                        if (HomeElement != nil && ![HomeElement isKindOfClass:[NSNull class]])
                        {
                            Address = [[HomeElement elementForName:@"STREET"] stringValue];
                            if (Address == nil || [Address isKindOfClass:[NSNull class]]) {
                                Address = @"";
                            }else{
                                Address = [Address stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                            }
                        }
                    }
                    
                    NSString *Email = @"";
                    DDXMLElement *EmailElement = [vcard elementForName:@"EMAIL"];
                    if (EmailElement != nil && ![EmailElement isKindOfClass:[NSNull class]])
                    {
                        DDXMLElement *UserIdElement = [EmailElement elementForName:@"USERID"];
                        if (UserIdElement != nil && ![UserIdElement isKindOfClass:[NSNull class]])
                        {
                            Email = [UserIdElement stringValue];
                            if (Email == nil || [Email isKindOfClass:[NSNull class]]) {
                                Email = @"";
                            }else{
                                Email = [Email stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                            }
                        }
                    }
                    
                    //  Thêm hoặc update contact khi đồng bộ
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:Name, @"Name", Avatar, @"Avatar", Address, @"Address", Email, @"Email", CloudFoneID, @"CloudFoneID", nil];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"addNewContactFromSyncXMPP"
                                                                        object:info];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:reloadCloudFoneContactAfterSync
                                                                    object:nil];
            }else{
                DDXMLElement *vcard = [iq elementForName:@"vCard" xmlns:@"vcard-temp"];
                if (vcard != nil){
                    NSString *CloudFoneID = [self getCloundFoneIDFromSingleString: fromStr];
                    
                    NSString *Name = @"";
                    DDXMLElement *NameElement = [vcard elementForName:@"FN"];
                    if (NameElement != nil && ![NameElement isKindOfClass:[NSNull class]])
                    {
                        Name = [NameElement stringValue];
                        Name = [Name stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                    }
                    
                    NSString *Avatar = @"";
                    DDXMLElement *PhotoElement = [vcard elementForName:@"PHOTO"];
                    if (PhotoElement != nil && ![PhotoElement isKindOfClass:[NSNull class]])
                    {
                        Avatar = [[PhotoElement elementForName:@"BINVAL"] stringValue];
                    }
                    
                    NSString *Address = @"";
                    DDXMLElement *AddressElement = [vcard elementForName:@"ADR"];
                    if (AddressElement != nil && ![AddressElement isKindOfClass:[NSNull class]])
                    {
                        DDXMLElement *HomeElement = [AddressElement elementForName:@"HOME"];
                        if (HomeElement != nil && ![HomeElement isKindOfClass:[NSNull class]])
                        {
                            Address = [[HomeElement elementForName:@"STREET"] stringValue];
                            Address = [Address stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                        }
                    }
                    
                    NSString *Email = @"";
                    DDXMLElement *EmailElement = [vcard elementForName:@"EMAIL"];
                    if (EmailElement != nil && ![EmailElement isKindOfClass:[NSNull class]])
                    {
                        DDXMLElement *UserIdElement = [EmailElement elementForName:@"USERID"];
                        if (UserIdElement != nil && ![UserIdElement isKindOfClass:[NSNull class]])
                        {
                            Email = [UserIdElement stringValue];
                            Email = [Email stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                        }
                    }
                    
                    NSString *status = [NSDatabase getStatusXmppOfAccount: CloudFoneID];
                    if ([status isEqualToString: @""]) {
                        status = welcomeToCloudFone;
                    }else{
                        status = [status stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                    }
                    
                    //  Nếu account đang login thì thêm vào bảng profile
                    [NSDatabase saveProfileForAccount:CloudFoneID withName:Name
                                             andAvatar:Avatar andAddress:Address
                                              andEmail:Email withStatus:status];
                }
            }
        }
        if ([idIQ hasPrefix:@"setprofile_"]){
            [[NSNotificationCenter defaultCenter] postNotificationName:updateProfileSuccessfully
                                                                object:nil];
        }
        
        if ([idIQ hasPrefix:@"changeroomname"]){
            
            //  Cập nhật tên mới và gửi message update cho các thành viên trong group
            NSRange range = [fromStr rangeOfString: [NSString stringWithFormat:@"@%@", xmpp_cloudfone_group]];
            if (range.location != NSNotFound) {
                NSString *roomName = [fromStr substringToIndex: range.location];
                [NSDatabase updateGroupNameOfRoom:roomName andNewGroupName:appDelegate._groupNameChange];
                [self changeGroupNameOfRoom:fromStr withNewName:appDelegate._groupNameChange];
                [appDelegate set_groupNameChange: @""];
                
                //  post thông báo update tên phòng
                [[NSNotificationCenter defaultCenter] postNotificationName:k11UpdateNewGroupName
                                                                    object:roomName];
            }
        }
    }
    
    if ([iq.type isEqualToString:@"set"]) {
        DDXMLElement *query = [iq elementForName:@"query"];
        if (query != nil && [[query xmlns] isEqualToString:@"jabber:iq:roster"]) {
            NSArray *itemArr = [query elementsForName:@"item"];
            if (itemArr.count > 0) {
                DDXMLElement *tmpElement = [itemArr objectAtIndex: 0];
                if ([tmpElement attributeForName:@"subscription"] != nil) {
                    NSString *subscription = [[tmpElement attributeForName:@"subscription"] stringValue];
                    NSString *ask = [[tmpElement attributeForName:@"ask"] stringValue];
                    if ([subscription isEqualToString:@"remove"])
                    {
                        NSString *fromStr = [[tmpElement attributeForName:@"jid"] stringValue];
                        NSString *cloudfoneID = [self getCloundFoneIDFromSingleString: fromStr];
                        
                        [NSDatabase removeAnUserFromRequestedList: cloudfoneID];
                        [[NSNotificationCenter defaultCenter] postNotificationName:k11AcceptRequestedSuccessfully
                                                                            object:cloudfoneID];
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:k11RejectFriendRequestSuccessfully
                                                                            object:cloudfoneID];
                    }else if ([subscription isEqualToString:@"both"]){
                        NSString *fromStr = [[tmpElement attributeForName:@"jid"] stringValue];
                        NSString *cloudfoneID = [self getCloundFoneIDFromSingleString: fromStr];
                        
                        [NSDatabase removeAnUserFromRequestedList: cloudfoneID];
                        [[NSNotificationCenter defaultCenter] postNotificationName:k11AcceptRequestedSuccessfully
                                                                            object:cloudfoneID];
                    }else if ([subscription isEqualToString:@"none"]){
                        NSLog(@"None");
                    }else if ([subscription isEqualToString:@"from"] || [subscription isEqualToString:@"to"]){
                        if (![ask isEqualToString:@"unsubscribe"]) {
                            // Gửi thông báo đến khi có request kết bạn đến
                            NSString *jid = [[tmpElement attributeForName:@"jid"] stringValue];
                            NSString *account = [[iq attributeForName:@"to"] stringValue];
                            
                            NSString *cloudfoneID = [AppUtils getSipFoneIDFromString: jid];
                            
                            // Kiểm tra đã có trong ds kết bạn hay chưa
                            BOOL isExists = [NSDatabase checkRequestFriendExistsOnList: cloudfoneID];
                            if (!isExists) {
                                BOOL isAdded = [NSDatabase addUserToWaitAcceptList: cloudfoneID];
                                if (isAdded) {
                                    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateBackground) {
                                        [self createRingAndVibrationOfNewMessageForUser:cloudfoneID];
                                    }else{
                                        HMLocalization *localization = [HMLocalization sharedInstance];
                                        NSString *name = [NSDatabase getNameOfContactWithPhoneNumber: cloudfoneID];
                                        
                                        NSString *alertStr = [NSString stringWithFormat:@"%@\n%@", name, [localization localizedStringForKey:CN_CONTACT_VERIFICATION_TEXT]];
                                        NSDictionary *infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:bannerNotifFriendReqest,@"type",cloudfoneID,@"user", nil];
                                        
                                        [AppUtils createLocalNotificationWithAlertBody:alertStr andInfoDict:infoDict ofUser:cloudfoneID];
                                    }
                                    [[NSNotificationCenter defaultCenter] postNotificationName:k11ReloadListFriendsRequested
                                                                                        object:nil];
                                }
                            }else{
                                [appDelegate.myBuddy.protocol sendAcceptRequestFromMe:account toUser:jid];
                                NSLog(@"Da co trong danh sach ket ban");
                            }
                        }else{
                            NSLog(@"Thong bao huy ket ban");
                        }
                    }
                }
            }
        }
    }
    
    NSXMLElement *queryElement = [iq elementForName: @"query" xmlns: @"jabber:iq:roster"];
    if (queryElement)
    {
        NSArray *itemElements = [queryElement elementsForName: @"item"];
        for (int i=0; i<[itemElements count]; i++)
        {
            DDXMLElement *item = [itemElements objectAtIndex: i];
            NSString *jidString = [[item attributeForName:@"jid"] stringValue];
            NSString *subscription = [[item attributeForName:@"subscription"] stringValue];
            if ([subscription isEqualToString:@"both"]) {
                if (![appDelegate._listFriends containsObject: jidString]) {
                    [appDelegate._listFriends addObject: jidString];
                }
            }else{
                [appDelegate._listFriends removeObject: jidString];
            }
        }
    }
    return YES;
}

#pragma mark - receive file

/*----- kiểm tra phần mở rộng của file nhận -----*/
- (NSString *)checkFileExtension: (NSString *)extensionStr{
    if ([extensionStr isEqualToString:@"jpg"] || [extensionStr isEqualToString:@"JPG"] || [extensionStr isEqualToString:@"png"] || [extensionStr isEqualToString:@"PNG"] || [extensionStr isEqualToString:@"gif"] || [extensionStr isEqualToString:@"GIF"] || [extensionStr isEqualToString:@"jpeg"] || [extensionStr isEqualToString:@"JPEG"]) {
        return imageMessage;
    }else if([extensionStr isEqualToString:@"m4a"] || [extensionStr isEqualToString:@"M4A"] || [extensionStr isEqualToString:@"wav"] || [extensionStr isEqualToString:@"WAV"] || [extensionStr isEqualToString:@"wma"] || [extensionStr isEqualToString:@"WMA"] || [extensionStr isEqualToString:@"aiff"] ||[extensionStr isEqualToString:@"AIFF"] || [extensionStr isEqualToString:@"3gp"] || [extensionStr isEqualToString:@"3GP"] || [extensionStr isEqualToString:@"mp3"] || [extensionStr isEqualToString:@"MP3"] || [extensionStr isEqualToString:@"m4p"] || [extensionStr isEqualToString:@"MP4"] || [extensionStr isEqualToString:@"cda"] || [extensionStr isEqualToString:@"CDA"] || [extensionStr isEqualToString:@"dat"] || [extensionStr isEqualToString:@"DAT"]){
        return audioMessage;
    }else if ([extensionStr isEqualToString:@"avi"] || [extensionStr isEqualToString:@"AVI"] || [extensionStr isEqualToString:@"riff"] || [extensionStr isEqualToString:@"RIFF"] || [extensionStr isEqualToString:@"mpg"] || [extensionStr isEqualToString:@"MPG"] || [extensionStr isEqualToString:@"vob"] || [extensionStr isEqualToString:@"VOB"] || [extensionStr isEqualToString:@"mp4"] || [extensionStr isEqualToString:@"MP4"] || [extensionStr isEqualToString:@"mov"] || [extensionStr isEqualToString:@"MOV"] || [extensionStr isEqualToString:@"3gp"] || [extensionStr isEqualToString:@"3GP"] || [extensionStr isEqualToString:@"mkv"] || [extensionStr isEqualToString:@"MKV"] || [extensionStr isEqualToString:@"flv"] || [extensionStr isEqualToString:@"FLV"] || [extensionStr isEqualToString:@"3gpp"] || [extensionStr isEqualToString:@"3GPP"]){
        return videoMessage;
    }else{
        return @"";
    }
}

/* Hàm tạo trả về buddy theo chuỗi message nhận được:
        - Nếu buddy không nằm trong BuddyList thì trả về buddy mới
 */
-(OTRBuddy *)buddyWithMessage:(XMPPMessage *)message
{
    XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:[message from]
                                                             xmppStream:appDelegate.xmppStream
                                                   managedObjectContext:[self managedObjectContext_roster]];
    if (user != nil) {
        if ([protocolBuddyList count] == 0) {
            //NSString *accountStr = [self removeResourceStrFromString:[message fromStr]];
            OTRBuddy *newBuddy = [[OTRBuddy alloc] initWithDisplayName:@"" accountName:[message fromStr] protocol:appDelegate.myBuddy.protocol status:0 groupName:@""];
            return newBuddy;
        }else{
            if ([protocolBuddyList objectForKey: user.jidStr] != nil) {
                return [protocolBuddyList objectForKey:user.jidStr];
            }else{
                OTRBuddy *newBuddy = [[OTRBuddy alloc] initWithDisplayName:@"" accountName:[message fromStr] protocol:appDelegate.myBuddy.protocol status:0 groupName:@""];
                return newBuddy;
            }
        }
    }else{
        OTRBuddy *newBuddy = nil;
        if ([protocolBuddyList count] > 0) {
            newBuddy = [protocolBuddyList objectForKey:appDelegate.myBuddy.accountName];
            if (newBuddy == nil) {
                 NSString *userStr = [message fromStr];
                newBuddy = [[OTRBuddy alloc] initWithDisplayName:[AppUtils getSipFoneIDFromString:userStr] accountName:userStr protocol:appDelegate.myBuddy.protocol status:0 groupName:@""];
            }
            NSString *accountStr = [self removeResourceStrFromString:[message fromStr]];
            OTRBuddy *rsBuddy = [[OTRBuddy alloc] initWithDisplayName:accountStr accountName:accountStr protocol:newBuddy.protocol status:0 groupName:@""];
            return rsBuddy;
        }else{
            newBuddy = [[OTRBuddy alloc] initWithDisplayName:@"" accountName:[message fromStr] protocol:appDelegate.myBuddy.protocol status:0 groupName:@""];
        }
        return newBuddy;
    }
}

//  Bỏ resource ra khỏi chuỗi
- (NSString *)removeResourceStrFromString: (NSString *)strWithResource{
    NSString *resultStr = @"";
    NSRange range = [strWithResource rangeOfString:[NSString stringWithFormat:@"@%@", xmpp_cloudfone]];
    if (range.location != NSNotFound) {
        resultStr = [strWithResource substringToIndex:range.location+range.length];
    }
    return resultStr;
}

/*----- Send location đến user -----*/
- (void)sendLocationToUser: (NSString *)user withLat: (float)lat andLng: (float)lng andAddress: (NSString *)address andDescription: (NSString *)description withIdMessage: (NSString *)idMessage{
    
    XMPPMessage *message = [[XMPPMessage alloc] init];
    [message addAttributeWithName:@"xmlns" stringValue:@"jabber:client"];
    [message addAttributeWithName:@"id" stringValue:idMessage];
    [message addAttributeWithName:@"to" stringValue: user];
    [message addAttributeWithName:@"type" stringValue:@"chat"];
    
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    
    
    NSString *bodyLocation = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/staticmap?center=%f,%f&zoom=16&scale<scale>&size=300x400&maptype=roadmap&sensor=true", lat, lng];
    [body setStringValue: bodyLocation];
    [message addChild: body];
    
    NSXMLElement *request = [NSXMLElement elementWithName:@"request"];
    [request addAttributeWithName:@"xmlns" stringValue:@"urn:xmpp:receipts"];
    [message addChild: request];
    
    NSXMLElement *action = [[NSXMLElement alloc] initWithName:@"action"];
    [action addAttributeWithName:@"xmlns" stringValue:@"callnex:message:action"];
    [action addAttributeWithName:@"name" stringValue:@"location_message"];
    [action addAttributeWithName:@"value" stringValue:[NSString stringWithFormat:@"%f|%f|%@", lat, lng, address]];
    [action addAttributeWithName:@"description" stringValue: description];
    [message addChild: action];
    
    [appDelegate.xmppStream sendElement: message];
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    NSString *fromString = [[message attributeForName:@"from"] stringValue];
    NSString *typeValue = [[message attributeForName:@"type"] stringValue];

    NSRange rangeRoom = [fromString rangeOfString:[NSString stringWithFormat:@"@%@", xmpp_cloudfone_group]];
    
    // Kiểm tra có phải message mời vào group hay không?
    if (typeValue == nil && fromString && rangeRoom.location != NSNotFound)
    {   // Send xmpp đồng ý vào group chat
        NSString *roomName = [fromString substringToIndex: rangeRoom.location];
        [self acceptJoinToRoomChat: roomName];
        
        [NSDatabase saveRoomChatIntoDatabase:roomName andGroupName: roomName];
        
        // Lưu conversation cho room chat
        [NSDatabase saveConversationForRoomChat:roomName isUnread: NO];
    }else{
        NSString *typeMessage = [[message attributeForName:@"type"] stringValue];
        // CHAT VỚI USER
        if (![typeMessage isEqualToString: group_chat])
        {   // Nếu tin nhắn bị lỗi
            if ([typeMessage isEqualToString:@"error"]) {
                //  Kiểm tra change subject
                NSArray *subjectArr = [message elementsForName:@"subject"];
                if (subjectArr != nil && subjectArr.count > 0) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:failedChangeRoomSubject
                                                                        object:nil];
                }else{
                    NSString *idMessage = [[message attributeForName:@"id"] stringValue];
                    [[NSNotificationCenter defaultCenter] postNotificationName:k11UpdateDeliveredError
                                                                        object:idMessage];
                }
            }else{
                DDXMLElement *actionElement = [message elementForName:@"action"];
                NSString *msgAction = [[actionElement attributeForName:@"name"] stringValue];
                
                //  Kiểm tra có phải thông tin request kết bạn hay ko
                if (msgAction != nil && [msgAction isEqualToString:@"request-note"]) {
                    NSString *content = [[actionElement attributeForName:@"value"] stringValue];
                    if (content != nil) {
                        NSDictionary *dict = [[[NSUserDefaults standardUserDefaults] objectForKey:callnexFriendsRequest] copy];
                        if (dict == nil) {
                            [[NSUserDefaults standardUserDefaults] setObject:[[NSMutableDictionary alloc] init]
                                                                      forKey:callnexFriendsRequest];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                        }
                        NSString *displayName = [[actionElement attributeForName:@"displayname"] stringValue];
                        NSString *userAccount = [AppUtils getSipFoneIDFromString: fromString];
                        if (displayName == nil) {
                            displayName = @"";
                        }
                        NSArray *infoArr = [NSArray arrayWithObjects:content, displayName, nil];
                            
                        NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
                        [tmpDict setObject:infoArr forKey:userAccount];
                        [[NSUserDefaults standardUserDefaults] setObject:tmpDict
                                                                  forKey:callnexFriendsRequest];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                }
                
                // Trạng thái nhập vào của user
                if([message hasChatState]) {
                    OTRBuddy * messageBuddy = [self buddyWithMessage:message];
                    if([message hasComposingChatState])
                        [messageBuddy receiveChatStateMessage:kOTRChatStateComposing];
                    else if([message hasPausedChatState])
                        [messageBuddy receiveChatStateMessage:kOTRChatStatePaused];
                    else if([message hasActiveChatState])
                        [messageBuddy receiveChatStateMessage:kOTRChatStateActive];
                    else if([message hasInactiveChatState])
                        [messageBuddy receiveChatStateMessage:kOTRChatStateInactive];
                    else if([message hasGoneChatState])
                        [messageBuddy receiveChatStateMessage:kOTRChatStateGone];
                }
                
                // send delivered cho user
                if([message hasReceiptRequest] && self.account.sendDeliveryReceipts) {
                    XMPPMessage * responseMessage = [message generateReceiptResponse];
                    [appDelegate.xmppStream sendElement:responseMessage];
                }
                
                NSString *userStr = [self getCloundFoneIDFromSingleString:[message fromStr]];
                // Nhận delivered sau khi send message
                if ([message hasReceiptResponse]) {
                    NSString *idMessage = [self getIdOfMessage: message];
                    [NSDatabase updateDeliveredMessageOfUser:userStr idMessage: idMessage];
                    [[NSNotificationCenter defaultCenter] postNotificationName:updateDeliveredChat
                                                                        object: idMessage];
                }
                
                //  Nhan display message
                DDXMLElement *xElement = [message elementForName:@"x"];
                if (xElement != nil && [[xElement xmlns] isEqualToString:@"jabber:x:displayed"]) {
                    NSString *listId = [[xElement attributeForName:@"listid"] stringValue];
                    if (listId != nil && ![listId isEqualToString:@""]) {
                        [self updateMessageSeenWithList: listId];
                    }
                }
                
                // Nhận tin nhắn đến
                NSString *body = [[message elementForName:@"body"] stringValue];
                
                OTRBuddy * messageBuddy = [self buddyWithMessage:message];
                OTRMessage *otrMessage = [OTRMessage messageWithBuddy:messageBuddy message:body];
                OTRMessage *decodedMessage = nil;
                // Tam thoi kiem tra OTR
                if (body != nil) {
                    decodedMessage = [OTRCodec decodeMessage:otrMessage];
                }
                
                if (decodedMessage.message == nil && [body hasPrefix:@"?OTR:"]) {
                    [[OTRKit sharedInstance] disableEncryptionForUsername:messageBuddy.accountName
                                                              accountName:messageBuddy.protocol.account.username
                                                                 protocol:messageBuddy.protocol.account.protocol];
                    
                    NSString *idMessage = [NSString stringWithFormat:@"resendotr-%@", [AppUtils randomStringWithLength:10]];
                    [appDelegate.myBuddy.protocol destroySessionOTRWithUser:messageBuddy.accountName andIdMessage:idMessage];
                }
                
                //  Kiểm tra metadata của tin nhắn
                NSArray *metadataArr = [message elementsForName:@"metadata"];
                if (metadataArr != nil && metadataArr.count > 0)
                {
                    NSXMLElement *metadata = [metadataArr objectAtIndex: 0];
                    NSArray *imageUrlArr = [metadata elementsForName:@"imageurl"];
                    NSArray *descriptionArr = [metadata elementsForName:@"description"];
                    NSArray *typeArr = [metadata elementsForName:@"type"];
                    
                    NSString *linkImage = @"";
                    if (imageUrlArr.count > 0) {
                        NSXMLElement *imageUrlElement = [imageUrlArr objectAtIndex: 0];
                        if (imageUrlElement != nil) {
                            linkImage = [imageUrlElement stringValue];
                        }
                    }
                    
                    NSString *descriptionImage = @"";
                    if (descriptionArr.count > 0) {
                        NSXMLElement *descElement = [descriptionArr objectAtIndex: 0];
                        if (descElement != nil) {
                            descriptionImage = [descElement stringValue];
                        }
                    }
                    
                    NSString *typeMessage = @"";
                    if (typeArr.count > 0) {
                        NSXMLElement *typeElement = [typeArr objectAtIndex: 0];
                        if (typeElement != nil) {
                            typeMessage = [typeElement stringValue];
                        }
                    }
                    
                    //  Kiểm tra tin nhắn đã đc nhận hay chưa
                    NSString *idMessage = [[message attributeForName:@"id"] stringValue];
                    BOOL isExists = [NSDatabase checkMessageExistsInDatabase: idMessage];
                    
                    // Nếu nhận message của người đang chat thì hiển thị lên màn hình
                    NSString *messageUser = [self getAccountNameFromString: messageBuddy.accountName];
                    NSString *currentUser = [self getAccountNameFromString: appDelegate.friendBuddy.accountName];
                    
                    NSString *sendPhone = [self getCloundFoneIDFromSingleString: messageBuddy.accountName];
                    
                    //  Kiểm tra burn message
                    int burn = [self getBurnOfMessage: message];
                    
                    if (!isExists)
                    {
                        if (([[[PhoneMainView instance] currentView] isEqual:[MainChatViewController compositeViewDescription]] || [[[PhoneMainView instance] currentView] isEqual:[GroupMainChatViewController compositeViewDescription]]) && [messageUser isEqualToString: currentUser])
                        {
                            // Nhận text message
                            if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground)
                            {
                                // Tang badge app len 1
                                int curBadge = (int)[[UIApplication sharedApplication] applicationIconBadgeNumber];
                                [[UIApplication sharedApplication] setApplicationIconBadgeNumber:curBadge+1];
                                
                                // Save message
                                NSString *type = @"";
                                if ([typeMessage isEqualToString:userimage]) {
                                    type = imageMessage;
                                }else if ([typeMessage isEqualToString:@"uservideo"]){
                                    type = videoMessage;
                                }
                                [NSDatabase saveMessage:sendPhone toPhone:USERNAME withContent:linkImage andStatus:NO withDelivered:2 andIdMsg:idMessage detailsUrl:linkImage andThumbUrl:linkImage withTypeMessage:type andExpireTime:burn andRoomID:@"" andExtra:nil andDesc:descriptionImage];
                            }else{
                                NSString *type = @"";
                                if ([typeMessage isEqualToString:userimage]) {
                                    type = imageMessage;
                                }else if ([typeMessage isEqualToString:@"uservideo"]){
                                    type = videoMessage;
                                }
                                [NSDatabase saveMessage:sendPhone toPhone:USERNAME withContent:linkImage andStatus:NO withDelivered:2 andIdMsg:idMessage detailsUrl:linkImage andThumbUrl:linkImage withTypeMessage:type andExpireTime:burn andRoomID:@"" andExtra:nil andDesc:descriptionImage];
                                
                                // Post notification cập nhật list message history
                                NSMutableDictionary *messageInfo = [NSMutableDictionary dictionaryWithObject:decodedMessage forKey:@"message"];
                                [messageInfo setObject:type forKey:@"typeMessage"];
                                [messageInfo setObject:idMessage forKey:@"idMessage"];
                                
                                [[NSNotificationCenter defaultCenter] postNotificationName:kOTRMessageReceived
                                                                                    object:self userInfo:messageInfo];
                            }
                            
                            //  If it is image message, the app will download this image from server
                            if ([typeMessage isEqualToString: userimage]) {
                                [self downloadImageFromServerWithName: linkImage andIdMessage: idMessage];
                            }
                        }else{
                            // LƯU MESSAGE VỚI TRẠNG THÁI CHƯA NHẬN
                            if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground)
                            {
                                // Tang badge app len 1
                                int curBadge = (int)[[UIApplication sharedApplication] applicationIconBadgeNumber];
                                [[UIApplication sharedApplication] setApplicationIconBadgeNumber:curBadge+1];
                                
                                NSString *type = @"";
                                if ([typeMessage isEqualToString:userimage]) {
                                    type = imageMessage;
                                }else if ([typeMessage isEqualToString:@"uservideo"]){
                                    type = videoMessage;
                                }
                                
                                [NSDatabase saveMessage:sendPhone toPhone:USERNAME withContent:linkImage andStatus:NO withDelivered:2 andIdMsg:idMessage detailsUrl:linkImage andThumbUrl:linkImage withTypeMessage:type andExpireTime:burn andRoomID:@"" andExtra:nil andDesc:descriptionImage];
                            }else{
                                // Save message truoc khi tao thong bao
                                [AppUtils updateBadgeForMessageOfUser:sendPhone isIncrease:YES];
                                
                                NSString *type = @"";
                                if ([typeMessage isEqualToString:userimage]) {
                                    type = imageMessage;
                                }else if ([typeMessage isEqualToString:@"uservideo"]){
                                    type = videoMessage;
                                }
                                
                                [NSDatabase saveMessage:sendPhone toPhone:USERNAME withContent:linkImage andStatus:NO withDelivered:2 andIdMsg:idMessage detailsUrl:linkImage andThumbUrl:linkImage withTypeMessage:type andExpireTime:burn andRoomID:@"" andExtra:nil andDesc:descriptionImage];
                                
                                [self createRingAndVibrationOfNewMessageForUser: sendPhone];
                                
                                //  Cập nhật list message history
                                NSMutableDictionary *messageInfo = [NSMutableDictionary dictionaryWithObject:decodedMessage forKey:@"message"];
                                [messageInfo setObject:type forKey:@"typeMessage"];
                                [messageInfo setObject:idMessage forKey:@"idMessage"];
                                [[NSNotificationCenter defaultCenter] postNotificationName:kOTRMessageReceived
                                                                                    object:self userInfo:messageInfo];
                            }
                            //  Download picture from server
                            //  If it is image message, the app will download this image from server
                            if ([typeMessage isEqualToString: userimage]) {
                                [self downloadImageFromServerWithName: linkImage andIdMessage: idMessage];
                            }else if ([typeMessage isEqualToString:@"uservideo"]){
                                MessageEvent *msgEvent = [NSDatabase getMessageEventWithId:idMessage];
                                [AppUtils savePictureOfVideoToDocument: msgEvent];
                                [[NSNotificationCenter defaultCenter] postNotificationName:updatePreviewImageForVideo
                                                                                    object:idMessage];
                            }
                        }
                    }
                }else{
                    if(decodedMessage)
                    {
                         NSString *sendPhone = [self getCloundFoneIDFromSingleString: messageBuddy.accountName];
                        //  Kiểm tra burn message
                        int burn = [self getBurnOfMessage: message];
                        
                        NSString *idMsgReceive = [[message attributeForName:@"id"] stringValue];
                         
                        NSString *messageUser = [self getAccountNameFromString: messageBuddy.accountName];
                        NSString *currentUser = [self getAccountNameFromString: appDelegate.friendBuddy.accountName];
                        if (([[[PhoneMainView instance] currentView] isEqual:[MainChatViewController compositeViewDescription]] || [[[PhoneMainView instance] currentView] isEqual:[GroupMainChatViewController compositeViewDescription]]) && [messageUser isEqualToString: currentUser])
                        {
                            // Nhận text message
                            if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground)
                            {
                                //  Leo Kelvin: khi nhanj push message, app tu dong register xmpp roi lai duplicate notification
                                //  NSString *name = [NSDatabase getNameOfContactWithPhoneNumber: sendPhone];
                                //  NSMutableAttributedString *msgAttrStr = [AppUtils convertMessageStringToEmojiString: decodedMessage.message];
                                //  NSString *alertStr = [NSString stringWithFormat:@"%@\n%@", name, msgAttrStr.string];
                                //  NSDictionary *infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:bannerNotifUserMessage,@"type",sendPhone,@"user", nil];
                                //  [AppUtils createLocalNotificationWithAlertBody:alertStr andInfoDict:infoDict ofUser:sendPhone];
                                
                                // Tang badge app len 1
                                int curBadge = (int)[[UIApplication sharedApplication] applicationIconBadgeNumber];
                                [[UIApplication sharedApplication] setApplicationIconBadgeNumber:curBadge+1];
                                
                                // Save message
                                [NSDatabase saveMessage:sendPhone toPhone:USERNAME withContent:decodedMessage.message andStatus:YES withDelivered:2 andIdMsg:idMsgReceive detailsUrl:@"" andThumbUrl:@"" withTypeMessage:typeTextMessage andExpireTime:burn andRoomID:@"" andExtra:nil andDesc:nil];
                            }else{
                                [NSDatabase saveMessage:sendPhone toPhone:USERNAME withContent:decodedMessage.message andStatus:YES withDelivered:2 andIdMsg:idMsgReceive detailsUrl:@"" andThumbUrl:@"" withTypeMessage:typeTextMessage andExpireTime:burn andRoomID:@"" andExtra:nil andDesc:nil];
                                
                                // Post notification cập nhật list message history
                                NSMutableDictionary *messageInfo = [NSMutableDictionary dictionaryWithObject:decodedMessage forKey:@"message"];
                                [messageInfo setObject:typeTextMessage forKey:@"typeMessage"];
                                [messageInfo setObject:idMsgReceive forKey:@"idMessage"];
                                
                                [[NSNotificationCenter defaultCenter] postNotificationName:kOTRMessageReceived object:self userInfo:messageInfo];
                            }
                        }else{
                            // LƯU MESSAGE VỚI TRẠNG THÁI CHƯA NHẬN
                            //  Đang chạy background thì tạo localnotifications, không thì tạo thông báo
                            if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground)
                            {
                                //  Leo Kelvin: khi nhanj push message, app tu dong register xmpp roi lai duplicate notification
                                //  NSString *name = [NSDatabase getNameOfContactWithPhoneNumber: sendPhone];
                                //  NSMutableAttributedString *msgAttrStr = [AppUtils convertMessageStringToEmojiString: decodedMessage.message];
                                //  NSString *alertStr = [NSString stringWithFormat:@"%@: %@", name, msgAttrStr.string];
                                //  NSDictionary *infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:bannerNotifUserMessage,@"type",sendPhone,@"user", nil];
                                //  [AppUtils createLocalNotificationWithAlertBody:alertStr andInfoDict:infoDict ofUser:sendPhone];
                                
                                // Tang badge app len 1
                                int curBadge = (int)[[UIApplication sharedApplication] applicationIconBadgeNumber];
                                [[UIApplication sharedApplication] setApplicationIconBadgeNumber:curBadge+1];
                                
                                [NSDatabase saveMessage:sendPhone toPhone:USERNAME withContent:decodedMessage.message andStatus:NO withDelivered:2 andIdMsg:idMsgReceive detailsUrl:@"" andThumbUrl:@"" withTypeMessage:typeTextMessage andExpireTime:burn andRoomID:@"" andExtra:nil andDesc:nil];
                            }else{
                                // Save message truoc khi tao thong bao
                                [AppUtils updateBadgeForMessageOfUser:sendPhone isIncrease:YES];
                                
                                [NSDatabase saveMessage:sendPhone toPhone:USERNAME withContent:decodedMessage.message andStatus:NO withDelivered:2 andIdMsg:idMsgReceive detailsUrl:@"" andThumbUrl:@"" withTypeMessage:typeTextMessage andExpireTime:burn andRoomID:@"" andExtra:nil andDesc:nil];
                                
                                [self createRingAndVibrationOfNewMessageForUser: sendPhone];
                            }
                            //  Cập nhật list message history
                            NSMutableDictionary *messageInfo = [NSMutableDictionary dictionaryWithObject:decodedMessage forKey:@"message"];
                            [messageInfo setObject:typeTextMessage forKey:@"typeMessage"];
                            [[NSNotificationCenter defaultCenter] postNotificationName:kOTRMessageReceived
                                                                                object:self userInfo:messageInfo];
                        }
                    }
                }
                
                // Nhận thông báo recall message jsi_6429552957187960473
                NSString *idMsgRecall = [self checkRequestRecall: message];
                if (![idMsgRecall isEqualToString:@""]) {
                    if ([NSDatabase updateMessageRecallMeReceive: idMsgRecall])
                    {   // Gửi thông báo phản hồi sau khi delete thành công
                        [self sendDeleteSuccessRecallToUser:message.fromStr andIdMsg: idMsgRecall];
                        
                        NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:idMsgRecall, @"idMessage", [NSNumber numberWithInt: 0], @"showPopup", nil];
                        [[NSNotificationCenter defaultCenter] postNotificationName:k11DeleteMsgWithRecallID object: infoDict];
                    }
                }
                
                // Nhận thông báo sau khi gửi recall message
                NSString *idMessage = [self checkRecallSucessfully: message];
                if (![idMessage isEqualToString: @""]) {
                    BOOL isRecalled = [NSDatabase updateMessageForRecall: idMessage];
                    if (isRecalled) {
                        NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:idMessage, @"idMessage", [NSNumber numberWithInt: 1], @"showPopup", nil];
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:k11DeleteMsgWithRecallID object: infoDict];
                    }
                }
            }
        }else
        {
            //  GROUP CHAT
            NSArray *roomInfos = [self getRoomNameAndUserJID: message];
            if (roomInfos.count >= 2) {
                if ([[roomInfos objectAtIndex: 0] isEqualToString:@""]) {
                    NSLog(@"Can not get room name");
                }else{
                    //  Check message change subject room
                    NSXMLElement *subject = [message elementForName:@"subject"];
                    if (subject != nil && ![[subject stringValue] isEqualToString: @""])
                    {
                        BOOL success = [NSDatabase updateSubjectOfRoom:[roomInfos objectAtIndex:0]
                                                           withSubject:[subject stringValue]];
                        if (success) {
                            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[roomInfos objectAtIndex:0], @"RoomName", [roomInfos objectAtIndex:1], @"CloudFoneID", [subject stringValue], @"subject", nil];
                            [[NSNotificationCenter defaultCenter] postNotificationName:k11SubjectOfRoomChanged
                                                                                object:dict];
                        }
                    }else{
                        //  Kiểm tra metadata của tin nhắn
                        NSArray *metadataArr = [message elementsForName:@"metadata"];
                        if (metadataArr != nil && metadataArr.count > 0)
                        {
                            NSXMLElement *metadata = [metadataArr objectAtIndex: 0];
                            NSArray *imageUrlArr = [metadata elementsForName:@"imageurl"];
                            NSArray *descriptionArr =[metadata elementsForName:@"description"];
                            NSArray *typeArr = [metadata elementsForName:@"type"];
                            
                            NSString *linkImage = @"";
                            if (imageUrlArr.count > 0) {
                                NSXMLElement *imageUrlElement = [imageUrlArr objectAtIndex: 0];
                                if (imageUrlElement != nil) {
                                    linkImage = [imageUrlElement stringValue];
                                }
                            }
                            
                            NSString *descriptionImage = @"";
                            if (descriptionArr.count > 0) {
                                NSXMLElement *descElement = [descriptionArr objectAtIndex: 0];
                                if (descElement != nil) {
                                    descriptionImage = [descElement stringValue];
                                }
                            }
                            
                            NSString *typeMessage = @"";
                            if (typeArr.count > 0) {
                                NSXMLElement *typeElement = [typeArr objectAtIndex: 0];
                                if (typeElement != nil) {
                                    typeMessage = [typeElement stringValue];
                                }
                            }
                            
                            //  Kiểm tra tin nhắn đã đc nhận hay chưa
                            NSString *idMessage = [[message attributeForName:@"id"] stringValue];
                            BOOL isExists = [NSDatabase checkMessageExistsInDatabase: idMessage];
                            
                            NSString *sendPhone = [roomInfos objectAtIndex: 1];
                            if (!isExists) {
                                //  Kiểm tra có phải message của mình send đến cho mình hay không?
                                if (![sendPhone isEqualToString:USERNAME]) {
                                    NSString *curRoomName = [roomInfos objectAtIndex:0];
                                    
                                    NSString *body = [[message elementForName:@"body"] stringValue];
                                    //  Có giá trị body thì mới hiển thị tin nhắn
                                    if (body != nil) {
                                        OTRBuddy * messageBuddy = [self buddyWithMessage:message];
                                        OTRMessage *otrMessage = [OTRMessage messageWithBuddy:messageBuddy message:body];
                                        OTRMessage *decodedMessage = [OTRCodec decodeMessage:otrMessage];
                                        
                                        if(decodedMessage)
                                        {
                                            //Posible needs a setting to turn on and off
                                            if([message hasReceiptRequest] && self.account.sendDeliveryReceipts)
                                            {
                                                XMPPMessage * responseMessage = [message generateReceiptResponse];
                                                [appDelegate.xmppStream sendElement:responseMessage];
                                            }
                                            //  Kiểm tra có phải message của room chat hiện tại hay không
                                            if ([[[PhoneMainView instance] currentView] isEqual:[GroupMainChatViewController compositeViewDescription]] && [curRoomName isEqualToString:appDelegate.roomChatName])
                                            {
                                             
                                                NSString *type = @"";
                                                if ([typeMessage isEqualToString:userimage]) {
                                                    type = imageMessage;
                                                }else if ([typeMessage isEqualToString:@"uservideo"]){
                                                    type = videoMessage;
                                                }
                                                
                                                [NSDatabase saveMessage:[roomInfos objectAtIndex:1] toPhone:USERNAME withContent:linkImage andStatus:true withDelivered:2 andIdMsg:idMessage detailsUrl:linkImage andThumbUrl:linkImage withTypeMessage:type andExpireTime:0 andRoomID:appDelegate.roomChatName andExtra:nil andDesc:descriptionImage];
                                                
                                                //  Post notification cập nhật list message history
                                                NSMutableDictionary *messageInfo = [NSMutableDictionary dictionaryWithObject:decodedMessage forKey:@"message"];
                                                [messageInfo setObject:typeTextMessage forKey:@"typeMessage"];
                                                [messageInfo setObject:idMessage forKey:@"idMessage"];
                                                
                                                [[NSNotificationCenter defaultCenter] postNotificationName:k11ReceivedRoomChatMessage
                                                                                                    object: messageInfo];
                                            }else{
                                                //  SAVE CONVERSATION CHO ROOM CHAT NEU CHUA TON TAI
                                                [NSDatabase saveConversationForRoomChat:curRoomName isUnread:YES];
                                                
                                                NSString *type = @"";
                                                if ([typeMessage isEqualToString:userimage]) {
                                                    type = imageMessage;
                                                }else if ([typeMessage isEqualToString:@"uservideo"]){
                                                    type = videoMessage;
                                                }
                                                
                                                [NSDatabase saveMessage:[roomInfos objectAtIndex:1] toPhone:USERNAME withContent:linkImage andStatus:false withDelivered:2 andIdMsg:idMessage detailsUrl:linkImage andThumbUrl:linkImage withTypeMessage:type andExpireTime:-1 andRoomID:curRoomName andExtra:nil andDesc:descriptionImage];
                                                
                                                [self createRingAndVibrationOfNewMessageForUser: sendPhone];
                                                
                                                [[NSNotificationCenter defaultCenter] postNotificationName:k11ReceiveMsgOtherRoomChat
                                                                                                    object: idMessage];
                                            }
                                        }
                                        
                                        //  If it is image message, the app will download this image from server
                                        if ([typeMessage isEqualToString: userimage]) {
                                            [self downloadImageFromServerWithName: linkImage andIdMessage: idMessage];
                                        }else if ([typeMessage isEqualToString:@"uservideo"]){
                                            MessageEvent *msgEvent = [NSDatabase getMessageEventWithId:idMessage];
                                            [AppUtils savePictureOfVideoToDocument: msgEvent];
                                            [[NSNotificationCenter defaultCenter] postNotificationName:updatePreviewImageForVideo
                                                                                                object:idMessage];
                                        }
                                    }
                                }
                            }else{
                                if ([sendPhone isEqualToString:USERNAME]) {
                                    [NSDatabase updateMessageDeliveredWithId:idMessage ofRoom:[roomInfos objectAtIndex:0]];
                                    [[NSNotificationCenter defaultCenter] postNotificationName:updateDeliveredChat
                                                                                        object: idMessage];
                                }
                            }
                        }else{
                            //  Kiểm tra tin nhắn đã đc nhận hay chưa
                            NSString *idMessage = [[message attributeForName:@"id"] stringValue];
                            BOOL isExists = [NSDatabase checkMessageExistsInDatabase: idMessage];
                            
                            NSString *sendPhone = [roomInfos objectAtIndex: 1];
                            if (!isExists) {
                                NSString *curRoomName = [roomInfos objectAtIndex:0];
                                
                                NSString *body = [[message elementForName:@"body"] stringValue];
                                //  Có giá trị body thì mới hiển thị tin nhắn
                                if (body != nil) {
                                    OTRBuddy * messageBuddy = [self buddyWithMessage:message];
                                    OTRMessage *otrMessage = [OTRMessage messageWithBuddy:messageBuddy message:body];
                                    OTRMessage *decodedMessage = [OTRCodec decodeMessage:otrMessage];
                                    NSString *idMsgReceive = [[message attributeForName:@"id"] stringValue];
                                    
                                    if(decodedMessage)
                                    {
                                        //Posible needs a setting to turn on and off
                                        if([message hasReceiptRequest] && self.account.sendDeliveryReceipts)
                                        {
                                            XMPPMessage * responseMessage = [message generateReceiptResponse];
                                            [appDelegate.xmppStream sendElement:responseMessage];
                                        }
                                        
                                        //  Kiểm tra có phải message của room chat hiện tại hay không
                                        if ([[[PhoneMainView instance] currentView] isEqual:[GroupMainChatViewController compositeViewDescription]] && [curRoomName isEqualToString:appDelegate.roomChatName]) {
                                            
                                            [NSDatabase saveMessage:[roomInfos objectAtIndex:1] toPhone:USERNAME withContent:decodedMessage.message andStatus:true withDelivered:2 andIdMsg:idMsgReceive detailsUrl:@"" andThumbUrl:@"" withTypeMessage:typeTextMessage andExpireTime:0 andRoomID:appDelegate.roomChatName andExtra:nil andDesc:nil];
                                            
                                            //  Post notification cập nhật list message history
                                            NSMutableDictionary *messageInfo = [NSMutableDictionary dictionaryWithObject:decodedMessage forKey:@"message"];
                                            [messageInfo setObject:typeTextMessage forKey:@"typeMessage"];
                                            [messageInfo setObject:idMsgReceive forKey:@"idMessage"];
                                            
                                            [[NSNotificationCenter defaultCenter] postNotificationName:k11ReceivedRoomChatMessage
                                                                                                object: messageInfo];
                                        }else{
                                            
                                            [NSDatabase saveMessage:[roomInfos objectAtIndex:1] toPhone:USERNAME withContent:decodedMessage.message andStatus:false withDelivered:2 andIdMsg:idMsgReceive detailsUrl:@"" andThumbUrl:@"" withTypeMessage:typeTextMessage andExpireTime:0 andRoomID:curRoomName andExtra:nil andDesc:nil];
                                            
                                            [self createRingAndVibrationOfNewMessageForUser: sendPhone];
                                            
                                            [[NSNotificationCenter defaultCenter] postNotificationName:k11ReceiveMsgOtherRoomChat
                                                                                                object: idMsgReceive];
                                        }
                                    }
                                }
                            }else{
                                if ([sendPhone isEqualToString:USERNAME]) {
                                    //  Nếu mình nhận đc tin nhắn của mình thì update trạng thái -> delivered
                                    [NSDatabase updateMessageDeliveredWithId:idMessage ofRoom:[roomInfos objectAtIndex:0]];
                                    [[NSNotificationCenter defaultCenter] postNotificationName:updateDeliveredChat
                                                                                        object: idMessage];
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

#pragma mark - Groups chat
- (NSArray *)getRoomNameAndUserJID: (XMPPMessage *)message{
    NSString *groupName = @"";
    NSString *jidStr = @"";
    
    NSString *fullName = [[message attributeForName:@"from"] stringValue];
    NSRange range = [fullName rangeOfString: [NSString stringWithFormat:@"@%@/", xmpp_cloudfone_group]];
    if (range.location != NSNotFound) {
        groupName = [fullName substringToIndex: range.location];
        jidStr = [fullName substringFromIndex: range.location + range.length];
    }
    return [[NSArray alloc] initWithObjects:groupName, jidStr, nil];
}

/*--Lấy tên của người mời vào group chat--*/
- (NSString *)getNameOfUserInviteMeJoinToGroupChat: (XMPPMessage *)inviteMessage{
    NSArray *listElement = [inviteMessage elementsForName:@"x"];
    if (listElement.count > 0) {
        for (int iCount=0; iCount<listElement.count; iCount++) {
            DDXMLElement *inviteElement = [listElement objectAtIndex: iCount];
            if ([inviteElement.children count] > 0) {
                XMPPElement *element = [inviteElement.children objectAtIndex: 0];
                if ([element.name isEqualToString:@"invite"]) {
                    //  Leo Kelvin
                    //  NSString *fromStr = [[element attributeForName:@"from"] stringValue];
                    //  NSString *inviteCallnex = [AppUtils getSipFoneIDFromString: fromStr];
                    //  NSString *name = [NSDatabase getNameOfContactWithPhoneNumber: inviteCallnex];
                    NSString *name = @"";
                    return name;
                }
            }
        }
    }
    return @"";
}

/*-Get số người online trong group */
- (void)getListOnlineOccupantsInGroup: (NSString *)groupName{
    /*
     <iq from='hag66@shakespeare.lit/pda' id='kl2fax27' to='coven@chat.shakespeare.lit'
     type='get'>
     <query xmlns='http://jabber.org/protocol/disco#items'/>
     </iq>
    */
    NSString *fullGroupName = [NSString stringWithFormat:@"%@@%@", groupName, xmpp_cloudfone_group];
    NSString *idMessage = [AppUtils randomStringWithLength: 10];
    NSString *fromStr = [NSString stringWithFormat:@"%@@%@", USERNAME, xmpp_cloudfone];
    
    XMPPIQ  *iq = [[XMPPIQ alloc] initWithType:@"get"];
    [iq addAttributeWithName:@"from" stringValue: fromStr];
    [iq addAttributeWithName:@"id" stringValue: idMessage];
    [iq addAttributeWithName:@"to" stringValue: fullGroupName];
    
    
    NSXMLElement *query = [NSXMLElement elementWithName:@"query"];
    [query addAttributeWithName:@"xmlns" stringValue:@"http://jabber.org/protocol/disco#items"];
    [iq addChild: query];
    [appDelegate.xmppStream sendElement: iq];
}

//  Send nội dung yêu cầu huỷ OTR
- (void)destroySessionOTRWithUser: (NSString *)user andIdMessage: (NSString *)idMessage {
    NSString *myStr = [NSString stringWithFormat:@"%@@%@", USERNAME, xmpp_cloudfone];
    XMPPMessage *message = [[XMPPMessage alloc] init];
    [message addAttributeWithName:@"xmlns" stringValue:@"jabber:client"];
    [message addAttributeWithName:@"id" stringValue: idMessage];
    [message addAttributeWithName:@"to" stringValue:user];
    [message addAttributeWithName:@"from" stringValue:myStr];
    
    NSXMLElement *action = [[NSXMLElement alloc] initWithName:@"action"];
    [action addAttributeWithName:@"xmlns" stringValue:@"callnex:message:action"];
    [action addAttributeWithName:@"name" stringValue:@"close-encryption"];
    [action addAttributeWithName:@"type" stringValue:@"require"];
    [action addAttributeWithName:@"value" stringValue:@""];
    [action addAttributeWithName:@"description" stringValue:@""];
    [message addChild: action];
    
    [appDelegate.xmppStream sendElement: message];
}

/*--Chap nhan huy OTR voi mot user--*/
- (void)acceptDestroySessionOTRWithUser: (NSString *)user{
    NSString *myStr = [NSString stringWithFormat:@"%@@%@", USERNAME, xmpp_cloudfone];
    NSString *idMessage = [AppUtils randomStringWithLength: 10];
    XMPPMessage *message = [[XMPPMessage alloc] init];
    [message addAttributeWithName:@"xmlns" stringValue:@"jabber:client"];
    [message addAttributeWithName:@"id" stringValue: idMessage];
    [message addAttributeWithName:@"to" stringValue:user];
    [message addAttributeWithName:@"from" stringValue:myStr];
    
    NSXMLElement *action = [[NSXMLElement alloc] initWithName:@"action"];
    [action addAttributeWithName:@"xmlns" stringValue:@"callnex:message:action"];
    [action addAttributeWithName:@"name" stringValue:@"close-encryption"];
    [action addAttributeWithName:@"type" stringValue:@"accept"];
    [message addChild: action];
    
    [appDelegate.xmppStream sendElement: message];
}

- (void)sendRequestOTRToUser: (NSString *)userStr {
    NSString *myStr = [NSString stringWithFormat:@"%@@%@", USERNAME, xmpp_cloudfone];
    NSString *idMessage = [AppUtils randomStringWithLength: 10];
    
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat"];
    [message addAttributeWithName:@"id" stringValue: idMessage];
    [message addAttributeWithName:@"to" stringValue: userStr];
    [message addAttributeWithName:@"from" stringValue:myStr];
    
    XMPPElement *body = [XMPPElement elementWithName:@"body" stringValue: @"?OTRv2?"];
    [message addChild: body];
    
    XMPPElement *thread = [XMPPElement elementWithName:@"thread" stringValue: @"pRk5WJ"];
    [message addChild: thread];
    
    [appDelegate.xmppStream sendElement: message];
    
    //  <message to="7788990004@xmpp.cloudfone.vn/ios_Csvo2iHy5q" id="UTN43-246" type="chat" from="7788990005@xmpp.cloudfone.vn/Spark"><body>?OTRv2?</body><thread>ERz36v</thread></message>
    //  <message type="chat" id="EJBQhToe8w" to="7788990005@xmpp.cloudfone.vn" from="7788990004@xmpp.cloudfone.vn"><body>?OTRv2?</body></message>
}

/* Send message cho group */
- (void)sendMessageWithContent: (NSString *)contentMsg ofMe: (NSString *)meStr toGroup: (NSString *)groupName withIdMessage: (NSString *)idMessage{
    XMPPMessage *message = [[XMPPMessage alloc] init];
    [message addAttributeWithName:@"xmlns" stringValue:@"jabber:client"];
    [message addAttributeWithName:@"id" stringValue: idMessage];
    NSString *toStr = [NSString stringWithFormat:@"%@@%@", groupName, xmpp_cloudfone_group];
    [message addAttributeWithName:@"to" stringValue: toStr];
    
    NSString *fromStr = [NSString stringWithFormat:@"%@@%@", USERNAME, xmpp_cloudfone];
    [message addAttributeWithName:@"from" stringValue: fromStr];
    
    [message addAttributeWithName:@"type" stringValue: group_chat];
    XMPPElement *body = [XMPPElement elementWithName:@"body" stringValue: contentMsg];
    [message addChild: body];
    [appDelegate.xmppStream sendElement: message];
}

/*----- Hàm kiểm tra request recall -----*/
- (NSString *)checkRequestRecall: (XMPPMessage *)message
{
    NSString *idMsgRecall = @"";
    DDXMLElement *recallElement = [message elementForName:@"requestrecall"];
    if (recallElement != nil) {
        idMsgRecall = [[recallElement attributeForName:@"id"] stringValue];
    }
    return idMsgRecall;
}
/*
 <message xmlns="jabber:client" id="lrKWT-32" to="8889998008@xmpp.callnex.com/AE60C42E-F10F-4DD2-AF70-94680D3E7D96" from="8889998016@xmpp.callnex.com/Callnex359051220333322">
    < xmlns="" id="jsi_USkvWa7a7ZeSFdAiTW"/>
 </message>
*/

/*----- Hàm kiểm tra request recall -----*/
- (NSString *)checkRecallSucessfully: (XMPPMessage *)message{
    NSString *idRecall = @"";
    DDXMLElement *recallElement = [message elementForName:@"recall" xmlns:@"urn:xmpp:recall"];
    if (recallElement != nil) {
        idRecall = [[recallElement attributeForName:@"id"] stringValue];
    }
    return idRecall;
}

/*
    <message xmlns="jabber:client" id="dW5pa-25" to="8889998008@xmpp.callnex.com" type="chat" from="8889998016@xmpp.callnex.com/Callnex359051220333322">
        <body>Lkk</body>
        <thread>fxkm817BblX3</thread>
        <active xmlns="http://jabber.org/protocol/chatstates"/>
        <request xmlns="urn:xmpp:receipts"/>
    </message>
 
    <message xmlns="jabber:client" id="dW5pa-27" to="8889998008@xmpp.callnex.com" type="chat" from="8889998016@xmpp.callnex.com/Callnex359051220333322">
        <body>Vvvv</body>
        <thread>fxkm817BblX3</thread>
        <active xmlns="http://jabber.org/protocol/chatstates"/>
        <request xmlns="urn:xmpp:receipts"/>
        <x xmlns="" seconds="10"/>
    </message>
*/

/*----- Hàm get thời gian expire của message -----*/
- (int)getExpireTimeOfMessage: (XMPPMessage *)message{
    DDXMLElement *xElement = [message elementForName:@"x" xmlns:@"jabber:x:expire"];
    if (xElement == nil) {
        return 0;
    }else{
        return [[[xElement attributeForName:@"seconds"] stringValue] intValue];
    }
}

- (int)getBurnOfMessage: (XMPPMessage *)message{
    DDXMLElement *xElement = [message elementForName:@"x" xmlns:@"jabber:x:burn"];
    if (xElement == nil) {
        return 0;
    }else{
        return [[[xElement attributeForName:@"burn"] stringValue] intValue];
    }
}

/*----- Get thời gian expire của ảnh nếu có -----*/
- (int)getExpireTimeOfImageReceive: (XMPPIQ *)messageInfo
{
    int expireTime = -1;
    DDXMLElement *childElement = [messageInfo elementForName:@"si"];
    if (childElement != nil) {
        childElement = [childElement elementForName:@"file"];
        if (childElement != nil) {
            childElement = [childElement elementForName:@"expire"];
            if (childElement != nil) {
                expireTime = [[childElement stringValue] intValue];
            }
        }
    }
    return expireTime;
}

/*
 <message xmlns="jabber:client" id="Nd5Q2-84" to="8889998008@xmpp.callnex.com/F8D094A0-6222-49BE-950E-8B7C3F44EF7B" from="8889998016@xmpp.callnex.com/Callnex359051220333322">
        <received xmlns="urn:xmpp:receipts" id="VzAR2o81nc"/></message>
*/
- (NSString *)getIdOfMessage: (XMPPMessage *)message
{
    NSString *idMessageReceived = @"";
    DDXMLElement *receivedElement = [message elementForName:@"received" xmlns:@"urn:xmpp:receipts"];
    if (receivedElement != nil) {
        idMessageReceived = [[receivedElement attributeForName:@"id"] stringValue];
    }
    return idMessageReceived;
}

/*----- Refresh Roster List XMPP -----*/
- (void)refreshRosterList{
    XMPPPresence *presence = [XMPPPresence presence];
    [appDelegate.xmppStream sendElement: presence];
}

//  Tạo chuông và rung nếu có tin nhắn khác đến
- (void)createRingAndVibrationOfNewMessageForUser: (NSString *)user{
    //  Kiểm tra user hiện tại có settings tắt tin nhắn hay ko?
    int receive = [AppUtils getNewMessageValueOfRemoteParty: user];
    if (receive) {
        SystemSoundID soundID;
        CFBundleRef mainBundle = CFBundleGetMainBundle();
        CFURLRef ref = CFBundleCopyResourceURL(mainBundle, (CFStringRef)@"msg.caf", NULL, NULL);
        AudioServicesCreateSystemSoundID(ref, &soundID);
        AudioServicesPlaySystemSound(soundID);
        
        BOOL vibrate = [AppUtils getVibrateForMessageForSettingsOfAccount: USERNAME];
        if (vibrate) {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
    }
    /*--Post notificationCenter để cập nhật số tin nhắn chưa đọc ở UIMainBar--*/
    [[NSNotificationCenter defaultCenter] postNotificationName:k11UpdateBarNotifications object:nil];
}

- (NSString*)getCloundFoneIDFromSingleString: (NSString*)string {
    NSString *result = @"";
    
    NSRange range = [string rangeOfString:[NSString stringWithFormat:@"@%@", xmpp_cloudfone]];
    
    if (range.location != NSNotFound) {
        return [string substringToIndex: range.location];
    }else{
        string = [string stringByReplacingOccurrencesOfString:single_cloudfone withString:xmpp_cloudfone];
        range = [string rangeOfString:[NSString stringWithFormat:@"@%@", xmpp_cloudfone]];
        if (range.location != NSNotFound) {
            result = [string substringToIndex: range.location+range.length];
        }
    }
    return result;
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    if ([presence.type isEqualToString:@"subscribe"])
    {
        // Gửi thông báo đến khi có request kết bạn đến
        NSString *cloudfoneID = [AppUtils getSipFoneIDFromString: presence.fromStr];
        
        // Kiểm tra đã có trong ds kết bạn hay chưa
        BOOL isExists = [NSDatabase checkRequestFriendExistsOnList: cloudfoneID];
        if (!isExists) {
            BOOL isAdded = [NSDatabase addUserToWaitAcceptList: cloudfoneID];
            if (isAdded) {
                [self createRingAndVibrationOfNewMessageForUser:cloudfoneID];
                [[NSNotificationCenter defaultCenter] postNotificationName:k11ReloadListFriendsRequested
                                                                    object:nil];
            }
        }else{
            NSLog(@"Da co trong danh sach ket ban");
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:k11UpdateBarNotifications
                                                            object:nil];
    }else if ([presence.type isEqualToString:@"subscribed"]) {
        NSString *cloudfoneID = [AppUtils getSipFoneIDFromString: presence.fromStr];
        if (![cloudfoneID isEqualToString: @""]) {
            [NSDatabase removeAnUserFromRequestedList: cloudfoneID];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:k11AcceptRequestedSuccessfully
                                                                object:cloudfoneID];
        }
        //  [self acceptRequestFromUser:presence.fromStr toMe:appDelegate.myBuddy.accountName];
    }else if ([presence.type isEqualToString:@"unsubscribed"])
    {
        // User từ chối yêu cầu kết bạn
        [self deleteUserFromRosterList: presence.fromStr];
        [NSDatabase removeUserFromRequestSent: [AppUtils getSipFoneIDFromString: presence.fromStr]];
        //  <presence type="unavailable" from="7788990089@xmpp.cloudfone.vn/ios_qlNbZyyles" to="7788990004@xmpp.cloudfone.vn"/>
    }else if ([[presence type] isEqualToString:@"unavailable"]){
        if ([presence.fromStr containsString:xmpp_cloudfone_group]) {
            NSArray *xArr = [presence elementsForXmlns:@"http://jabber.org/protocol/muc#user"];
            if (xArr != nil && xArr.count > 0) {
                NSXMLElement *xElement = [xArr objectAtIndex: 0];
                NSArray *xChild = [xElement children];
                if (xChild != nil && xChild.count > 0) {
                    NSXMLElement *itemElement = [xChild objectAtIndex: 0];
                    NSString *jid = [[itemElement attributeForName:@"jid"] stringValue];
                    NSString *role = [[itemElement attributeForName:@"role"] stringValue];
                    NSString *affiliation = [[itemElement attributeForName:@"affiliation"] stringValue];
                    
                    //  Kiểm tra phòng bị huỷ
                    if (jid == nil && [role isEqualToString:@"none"] && [affiliation isEqualToString:@"none"]) {
                        NSString *roomName = [self getRoomNameFromString: presence.fromStr];
                        [NSDatabase deleteARoomChatWithRoomName: roomName];
                        
                        //  Xoá các user trong nhóm
                        [NSDatabase removeAllUserInGroupChat:roomName];
                        
                        //  Xoá tất cả tin nhắn của nhóm đó
                        [NSDatabase deleteConversationOfMeWithRoomChat: roomName];
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:whenRoomDestroyed
                                                                            object:roomName];
                    }else{
                        //  User rời khỏi room chat
                        if ([role isEqualToString:@"none"] && jid != nil && ![jid isEqualToString: @""]) {
                            NSString *cloudfoneID = [self getCloundFoneIDFromSingleString: jid];
                            NSString *roomName = [self getRoomNameFromString: presence.fromStr];
                            
                            if ([cloudfoneID isEqualToString: USERNAME]) {
                                /*  Nếu là mình rời khỏi nhóm */
                                //  Xoá nhóm ra khỏi DB
                                [NSDatabase deleteARoomChatWithRoomName: roomName];
                                
                                //  Xoá các user trong nhóm
                                [NSDatabase removeAllUserInGroupChat:roomName];
                                
                                //  Xoá tất cả tin nhắn của nhóm đó
                                [NSDatabase deleteConversationOfMeWithRoomChat: roomName];
                                
                                [[NSNotificationCenter defaultCenter] postNotificationName:afterLeaveFromRoomChat
                                                                                    object:nil];
                            }else{
                                [NSDatabase removeUser:cloudfoneID fromRoomChat:roomName forAccount:USERNAME];
                                [[NSNotificationCenter defaultCenter] postNotificationName:aUserLeaveRoomChat
                                                                                    object:nil];
                            }
                            
                            NSString *key = [NSString stringWithFormat:@"GROUPS_%@", USERNAME];
                            NSString *groupIds = [[NSUserDefaults standardUserDefaults] objectForKey: key];
                            if (groupIds != nil && ![groupIds isEqualToString:@""]) {
                                if ([groupIds containsString:[NSString stringWithFormat:@"%@,", roomName]]) {
                                    groupIds = [groupIds stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@,", roomName] withString:@""];
                                }else if ([groupIds containsString:[NSString stringWithFormat:@",%@", roomName]]){
                                    groupIds = [groupIds stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@",%@", roomName] withString:@""];
                                }else if ([groupIds containsString:roomName]){
                                    groupIds = [groupIds stringByReplacingOccurrencesOfString:roomName withString:@""];
                                }
                            }
                            [[NSUserDefaults standardUserDefaults] setObject:groupIds forKey:key];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                            
                            [appDelegate.myBuddy.protocol storeGroupDataToServer: groupIds];
                        }
                    }
                }
            }
        }else{
            //  Logout thi huy OTR
            NSString *curUser = [AppUtils getSipFoneIDFromString: [presence fromStr]];
            OTRBuddy *curBuddy = [AppUtils getBuddyOfUserOnList: curUser];
            if (curBuddy.encryptionStatus == 1) {
                [[OTRKit sharedInstance] disableEncryptionForUsername:curBuddy.accountName
                                                          accountName:curBuddy.protocol.account.username
                                                             protocol:curBuddy.protocol.account.protocol];
                [[NSNotificationCenter defaultCenter] postNotificationName:k11DisableEncryption object:[NSString stringWithFormat:@"%@@%@", curUser, xmpp_cloudfone]];
            }
        }
    }

    NSString *status = [presence status];
    if ([[presence from] user] != nil && ![[[presence from] user] isEqualToString:@""]) {
        if (status != nil) {
            [appDelegate._statusXMPPDict setObject: status forKey: [[presence from] user]];
        }
    }
    if ([[presence fromStr] containsString:xmpp_cloudfone_group]) {
        if (![[presence type] isEqualToString:@"error"]) {
            NSXMLElement *xElement = [presence elementForName:@"x" xmlns:@"http://jabber.org/protocol/muc#user"];
            if (xElement != nil) {
                NSArray *statusArr = [xElement elementsForName:@"status"];
                if (statusArr.count > 0) {
                    /*  Close by Khai Le on 25/01/2018
                    BOOL success = [self checkCreateGroupChatSuccessfully: statusArr];
                    if (success) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:k11CreateGroupChatSuccessfully
                                                                            object:nil];
                    }   */
                }
                
                if (![[presence type] isEqualToString:@"unavailable"]) {
                    NSArray *itemArr = [xElement elementsForName:@"item"];
                    if (itemArr.count > 0) {
                        NSString *fromStr = [[presence attributeForName:@"from"] stringValue];
                        NSString *roomName = [self getRoomNameFromString: fromStr];
                        
                        //  Update by Khải Lê on 14/10/2017
                        
                        //  NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:roomName, @"roomName", itemArr, @"item", nil];
                        //  int roomID = [NSDatabase getIdRoomChatWithRoomName: roomName];
                        
                        for (int kCount=0; kCount<itemArr.count; kCount++) {
                            NSXMLElement *item = [itemArr objectAtIndex: kCount];
                            NSString *jidString = [[item attributeForName:@"jid"] stringValue];
                            NSString *cloudfoneID = [AppUtils getAccountNameFromString: jidString];
                            
                            //  Lưu user cho room chat
                            [NSDatabase saveUser:cloudfoneID toRoomChat:roomName forAccount:USERNAME];
                            
                            /*  Leo Kelvin
                            //  Lưu message tham gia vào phòng
                            NSString *idMessage = [AppUtils randomStringWithLength: 10];
                            NSString *username = [NSDatabase getNameOfContactWithCallnexID: cloudfoneID];
                            NSString *time = [AppUtils getCurrentTimeStamp];
                            
                            int delivered = 2;
                            
                            NSString *msgContent = @"";
                            if (![cloudfoneID isEqualToString:USERNAME])
                            {
                                msgContent = [NSString stringWithFormat:@"%@ %@ %@", username, [localization localizedStringForKey:joined_the_room], time];
                                [NSDatabase saveMessage:@"" toPhone:USERNAME withContent:msgContent andStatus:YES withDelivered:delivered andIdMsg:idMessage detailsUrl:@"" andThumbUrl:@"" withTypeMessage:descriptionMessage andExpireTime:-1 andRoomID:[NSString stringWithFormat:@"%d", roomID] andExtra:@"" andDesc: nil];
                            }else{
                                msgContent = [NSString stringWithFormat:@"%@ %@", [localization localizedStringForKey:text_joined_room_at], time];
                                
                                [NSDatabase saveMessage:@"" toPhone:USERNAME withContent:msgContent andStatus:YES withDelivered:delivered andIdMsg:idMessage detailsUrl:@"" andThumbUrl:@"" withTypeMessage:descriptionMessage andExpireTime:-1 andRoomID:[NSString stringWithFormat:@"%d", roomID] andExtra:@"" andDesc: nil];
                            }
                            */
                        }
                        
                        //  Update by Khải Lê on 14/10/2017
                        //  [[NSNotificationCenter defaultCenter] postNotificationName:userJoinToRoom object:dict];
                    }
                }
                
                if ([[presence type] isEqualToString:@"unavailable"]) {
                    NSArray *itemArr = [xElement elementsForName:@"item"];
                    
                    NSString *fromStr = [[presence attributeForName:@"from"] stringValue];
                    NSString *roomName = [self getRoomNameFromString: fromStr];
                    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:roomName, @"roomName", itemArr, @"item", nil];
                    
                    //  Xoa user ra khoi room chat
                    NSString *from = [self getCloundFoneIDFromSingleString: fromStr];
                    [NSDatabase removeUser:from fromRoomChat:roomName forAccount:USERNAME];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:updateListMemberInRoom object:dict];
                }
            }
        }
    }
}

- (NSString *)getRoomNameFromString: (NSString *)fromStr
{
    NSRange range = [fromStr rangeOfString: [NSString stringWithFormat:@"@%@", xmpp_cloudfone_group]];
    if (range.location != NSNotFound) {
        NSString *roomName = [fromStr substringToIndex: range.location];
        return roomName;
    }
    return @"";
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    // [[NSNotificationCenter defaultCenter] postNotificationName:kOTRProtocolDiconnect object:self];
	if (!isXmppConnected)
	{
		DDLogError(@"Unable to connect to server. Check xmppStream.hostName");
        [self failedToConnect];
	}
    else {
        NSLog(@"Lost connection......");
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPRosterDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppRoster:(XMPPRoster *)sender didReceiveBuddyRequest:(XMPPPresence *)presence
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:[presence from]
	                                                         xmppStream:appDelegate.xmppStream
	                                               managedObjectContext:[self managedObjectContext_roster]];
	NSString *displayName = [user displayName];
	NSString *jidStrBare = [presence fromStr];
	NSString *body = nil;
	if (![displayName isEqualToString:jidStrBare])
	{
		body = [NSString stringWithFormat:@"Buddy request from %@ <%@>", displayName, jidStrBare];
	}
	else
	{
		body = [NSString stringWithFormat:@"Buddy request from %@", displayName];
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark OTRProtocol
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) sendMessage:(OTRMessage*)theMessage
{
    NSString *messageStr = theMessage.message;
    
    if ([messageStr length] >0)
    {
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
		[body setStringValue:messageStr];
		
		NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
		[message addAttributeWithName:@"type" stringValue:@"chat"];
        
        //  nếu domain là cloudfone.vn thì đổi lại
        NSString *accountName = theMessage.buddy.accountName;
        NSRange range = [accountName rangeOfString: xmpp_cloudfone];
        if (range.location == NSNotFound) {
            accountName = [accountName stringByReplacingOccurrencesOfString:single_cloudfone
                                                                 withString:xmpp_cloudfone];
        }
        [message addAttributeWithName:@"id" stringValue: theMessage.idMessage];
        
        [message addAttributeWithName:@"to" stringValue: accountName];
        
        NSXMLElement * receiptRequest = [NSXMLElement elementWithName:@"request"];
        [receiptRequest addAttributeWithName:@"xmlns" stringValue:@"urn:xmpp:receipts"];
        [message addChild:receiptRequest];
        
		[message addChild:body];
        
        XMPPMessage * xMessage = [XMPPMessage messageFromElement:message];
        [xMessage addActiveChatState];
        
		//Kiem tra buddy neu co expire time thi them
        NSString *cloudfoneID = [self getCloundFoneIDFromSingleString: accountName];
        int burnMessage = [AppUtils getBurnMessageValueOfRemoteParty: cloudfoneID];
        
        NSString *strBurn = [NSString stringWithFormat:@"%d", burnMessage];
        NSXMLElement *query = [NSXMLElement elementWithName:@"x" xmlns:@"jabber:x:burn"];
        [query addAttributeWithName:@"burn" stringValue: strBurn];
        
        [message addChild: query];
		[appDelegate.xmppStream sendElement:message];
    }
}

//  Ping để giữ kết nối đến server
- (void)pingForConnectToServer
{
    XMPPIQ *pingIQ = [XMPPIQ iqWithType:@"get"];
    [pingIQ addAttributeWithName:@"id" stringValue:@"pingForConnect"];
    
    NSXMLElement *pingElement = [NSXMLElement elementWithName:@"ping" xmlns:@"urn:xmpp:ping"];
    [pingIQ addChild: pingElement];
    [appDelegate.xmppStream sendElement: pingIQ];
}

// Function cho send message thất bại
- (void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error
{
    NSString *idFailMsg = [[message attributeForName:@"id"] stringValue];
    if (idFailMsg != nil && ![idFailMsg isEqualToString:@""])
    {   // Kiểm tra message này tồn tại hay chưa
        BOOL exists = [NSDatabase checkMessageExistsOnFailedList: idFailMsg];
        if (!exists) {
            BOOL result = [NSDatabase addNewFailedMessageForAccountWithIdMessage: idFailMsg];
            [[NSNotificationCenter defaultCenter] postNotificationName:k11UpdateDeliveredError
                                                                object:idFailMsg];
            if (!result) {
                NSLog(@"Can not add failed to list.....");
            }
        }
    }
}

// Xoá user ra khỏi roster list
- (void)deleteUserFromRosterList: (NSString *)user
{
    NSMutableDictionary *listUserDict = [[[OTRProtocolManager sharedInstance] buddyList] allBuddies];
    NSMutableDictionary *rosterDict = [listUserDict objectForKey:[AppUtils uniqueIDForDevice]];
    [rosterDict removeObjectForKey: user];
    
    listUserDict = [[[OTRProtocolManager sharedInstance] buddyList] allBuddies];
    NSArray *listUser = [OTRBuddyList sortBuddies: listUserDict];
    NSLog(@"%d", (int)listUser.count);
}

#pragma mark - Tracking user

/*--Gửi request yêu cầu tracking đến user--*/
- (void)sendTrackingRequestToUser: (NSString *)userStr withLocationInfo: (NSString *)locationInfo
{
    NSString *idMessage = [AppUtils randomStringWithLength: 10];
    NSString *meStr = [NSString stringWithFormat:@"%@@%@", USERNAME, xmpp_cloudfone];
    XMPPMessage *aMessage = [XMPPMessage messageWithType:@"message"];
    [aMessage addAttributeWithName:@"to" stringValue:userStr];
    [aMessage addAttributeWithName:@"from" stringValue:meStr];
    [aMessage addAttributeWithName:@"id" stringValue:idMessage];
    [aMessage addAttributeWithName:@"type" stringValue:@"chat"];
    
    NSXMLElement *trackingElement = [NSXMLElement elementWithName:@"tracking"];
    [trackingElement addAttributeWithName:@"xmlns" stringValue:@"callnex:tracking"];
    [trackingElement addAttributeWithName:@"type" stringValue:@"request"];
    [trackingElement addAttributeWithName:@"value" stringValue: locationInfo];
    [aMessage addChild: trackingElement];
    
    [appDelegate.xmppStream sendElement: aMessage];
}

/*--Gửi thông tin location nếu chấp nhận--*/
- (void)sendYourLocationToUserRequestTracking: (NSString *)userStr withLocation: (NSString *)locationInfo
{
    NSString *idMessage = [AppUtils randomStringWithLength: 10];
    NSString *meStr = [NSString stringWithFormat:@"%@@%@", USERNAME, xmpp_cloudfone];
    
    XMPPMessage *aMessage = [XMPPMessage messageWithType:@"message"];
    [aMessage addAttributeWithName:@"to" stringValue:userStr];
    [aMessage addAttributeWithName:@"from" stringValue:meStr];
    [aMessage addAttributeWithName:@"id" stringValue:idMessage];
    [aMessage addAttributeWithName:@"type" stringValue:@"chat"];
    
    NSXMLElement *trackingElement = [NSXMLElement elementWithName:@"tracking"];
    [trackingElement addAttributeWithName:@"xmlns" stringValue:@"callnex:tracking"];
    [trackingElement addAttributeWithName:@"type" stringValue:@"accept"];
    [trackingElement addAttributeWithName:@"value" stringValue: locationInfo];
    [aMessage addChild: trackingElement];
    
    [appDelegate.xmppStream sendElement: aMessage];
}

/*--Từ chối yêu cầu tracking từ user--*/
- (void)ejectTrackingFromUser: (NSString *)user{
    NSString *idMessage = [AppUtils randomStringWithLength: 10];
    NSString *meStr = [NSString stringWithFormat:@"%@@%@", USERNAME, xmpp_cloudfone];
    
    XMPPMessage *aMessage = [XMPPMessage messageWithType:@"message"];
    [aMessage addAttributeWithName:@"to" stringValue:user];
    [aMessage addAttributeWithName:@"from" stringValue:meStr];
    [aMessage addAttributeWithName:@"id" stringValue:idMessage];
    [aMessage addAttributeWithName:@"type" stringValue:@"chat"];
    
    NSXMLElement *trackingElement = [NSXMLElement elementWithName:@"tracking"];
    [trackingElement addAttributeWithName:@"xmlns" stringValue:@"callnex:tracking"];
    [trackingElement addAttributeWithName:@"type" stringValue:@"cancel"];
    [trackingElement addAttributeWithName:@"value" stringValue: @""];
    [aMessage addChild: trackingElement];

    [appDelegate.xmppStream sendElement: aMessage];
}

/*--Gửi update location đến user trong tracking list--*/
- (void)sendUpdateLocationToUser: (NSString *)user andMyLocationInfo: (NSString *)locationInfo {
    NSString *idMessage = [AppUtils randomStringWithLength: 10];
    NSString *meStr = [NSString stringWithFormat:@"%@@%@", USERNAME, xmpp_cloudfone];
    
    XMPPMessage *aMessage = [XMPPMessage messageWithType:@"message"];
    [aMessage addAttributeWithName:@"to" stringValue:user];
    [aMessage addAttributeWithName:@"from" stringValue:meStr];
    [aMessage addAttributeWithName:@"id" stringValue:idMessage];
    [aMessage addAttributeWithName:@"type" stringValue:@"chat"];
    
    NSXMLElement *trackingElement = [NSXMLElement elementWithName:@"tracking"];
    [trackingElement addAttributeWithName:@"xmlns" stringValue:@"callnex:tracking"];
    [trackingElement addAttributeWithName:@"type" stringValue:@"update"];
    [trackingElement addAttributeWithName:@"value" stringValue: locationInfo];
    [aMessage addChild: trackingElement];
    
    [appDelegate.xmppStream sendElement: aMessage];
}

/*--send message tracking đến user--*/
- (void)sendMessageTrackingToUser: (NSString *)user withContent: (NSString *)content andIdMessage: (NSString *)idMessage
{
    NSString *me = [NSString stringWithFormat:@"%@@%@", USERNAME, xmpp_cloudfone];
    XMPPMessage *aMessage = [XMPPMessage messageWithType:@"message"];
    [aMessage addAttributeWithName:@"to" stringValue:user];
    [aMessage addAttributeWithName:@"from" stringValue:me];
    [aMessage addAttributeWithName:@"id" stringValue:idMessage];
    [aMessage addAttributeWithName:@"type" stringValue:@"chat"];
    
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue: content];
    [aMessage addChild: body];
    
    NSXMLElement *request = [NSXMLElement elementWithName:@"request"];
    [request addAttributeWithName:@"xmlns" stringValue:@"urn:xmpp:receipts"];
    [aMessage addChild: request];
    
    NSXMLElement *trackingElement = [NSXMLElement elementWithName:@"tracking"];
    [trackingElement addAttributeWithName:@"xmlns" stringValue:@"callnex:tracking"];
    [trackingElement addAttributeWithName:@"type-tracking" stringValue:@"tracking-message"];
    [aMessage addChild: trackingElement];
    
    [appDelegate.xmppStream sendElement: aMessage];
}

#pragma mark - Blacklist and Whitelist

/*-----Tạo một Blacklist-----*/
- (void)createBlackListOfMe: (NSArray *)blackList
{
    NSString *meStr = [NSString stringWithFormat:@"%@@%@", USERNAME, xmpp_cloudfone];
    NSString *xmppString = @"";
    NSXMLElement *listElement = [NSXMLElement elementWithName:@"list"];
    [listElement addAttributeWithName: @"name" stringValue: Blacklist];
    
    for (int iCount=0; iCount<blackList.count; iCount++)
    {
        contactBlackListCell *contactCell = [blackList objectAtIndex: iCount];
        NSXMLElement *item = [NSXMLElement elementWithName:@"item"];
        NSXMLElement *itemMes = [NSXMLElement elementWithName:@"message"];
        xmppString = [NSString stringWithFormat:@"%@@%@", contactCell._callnexContact, xmpp_cloudfone];
        [item addAttributeWithName:@"type" stringValue:@"jid"];
        [item addAttributeWithName:@"value" stringValue: xmppString];
        [item addAttributeWithName:@"action" stringValue: @"deny"];
        [item addAttributeWithName:@"order" stringValue: [NSString stringWithFormat:@"%d", iCount+1]];
        [item addChild: itemMes];
        [listElement addChild: item];
    }
    
	NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:privacy"];
    [queryElement addChild: listElement];
    
    NSString *idIQ = [AppUtils randomStringWithLength: 10];
    
	XMPPIQ *iq = [XMPPIQ iqWithType:@"set"];
    [iq addAttributeWithName:@"from" stringValue: meStr];
    [iq addAttributeWithName:@"id" stringValue: idIQ];
	[iq addChild: queryElement];
	[appDelegate.xmppStream sendElement:iq];
}

/*-----Active Blacklist-----*/
- (void)activeBlackListOfMe
{
    NSString *meStr = [NSString stringWithFormat:@"%@@%@", USERNAME, xmpp_cloudfone];
    
    NSString *idMessage = [AppUtils randomStringWithLength: 10];
    
    NSXMLElement *activeElement = [NSXMLElement elementWithName:@"active"];
    [activeElement addAttributeWithName:@"name" stringValue: Blacklist];
    
    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:privacy"];
    [queryElement addChild: activeElement];
    
	XMPPIQ *iq = [XMPPIQ iqWithType:@"set"];
    [iq addAttributeWithName:@"from" stringValue: meStr];
    [iq addAttributeWithName:@"id" stringValue: idMessage];
	[iq addChild: queryElement];
	[appDelegate.xmppStream sendElement: iq];
}

/*-----Block user trong Callnex Blacklist-----*/
- (void)blockUserInCallnexBlacklist: (NSArray *)blackListArr
{
    NSString *meStr = [NSString stringWithFormat:@"%@@%@", USERNAME, xmpp_cloudfone];
    NSString *xmppString;
    NSXMLElement *listElement = [NSXMLElement elementWithName:@"list"];
    [listElement addAttributeWithName:@"name" stringValue:@"Blacklist"];
    
    for (int iCount=0; iCount<blackListArr.count; iCount++) {
        contactBlackListCell *contactCell = [blackListArr objectAtIndex: iCount];
        NSXMLElement *item = [NSXMLElement elementWithName:@"item"];
        NSXMLElement *itemMes = [NSXMLElement elementWithName:@"message"];
        xmppString = [NSString stringWithFormat:@"%@@%@", contactCell._callnexContact, xmpp_cloudfone];
        [item addAttributeWithName:@"type" stringValue:@"jid"];
        [item addAttributeWithName:@"value" stringValue: xmppString];
        [item addAttributeWithName:@"action" stringValue: @"deny"];
        [item addAttributeWithName:@"order" stringValue: [NSString stringWithFormat:@"%d", iCount+1]];
        [item addChild: itemMes];
        [listElement addChild: item];
    }
    
	NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:privacy"];
    [queryElement addChild: listElement];
    
    NSString *idIQ = [AppUtils randomStringWithLength: 10];
    
	XMPPIQ *iq = [XMPPIQ iqWithType:@"set"];
    [iq addAttributeWithName:@"from" stringValue: meStr];
    [iq addAttributeWithName:@"id" stringValue: idIQ];
	[iq addChild: queryElement];
	[appDelegate.xmppStream sendElement:iq];
}

/* Block neu change whitelist */
- (void)blockAllContactNotInWhiteList: (NSString *)meXmppString whiteList: (NSArray *)whiteList{
    NSString *xmppString;
    NSXMLElement *item1 = [NSXMLElement elementWithName:@"list"];
    [item1 addAttributeWithName:@"name" stringValue:@"Blacklist"];
    
    //Allow cac contact co trong whiteList
    for (int iCount=0; iCount<whiteList.count; iCount++) {
        NSString *callnexID = [whiteList objectAtIndex: iCount];
        NSXMLElement *item = [NSXMLElement elementWithName:@"item"];
        NSXMLElement *itemMes = [NSXMLElement elementWithName:@"message"];
        xmppString = [NSString stringWithFormat:@"%@@%@", callnexID, xmpp_cloudfone];
        [item addAttributeWithName:@"type" stringValue:@"jid"];
        [item addAttributeWithName:@"value" stringValue: xmppString];
        [item addAttributeWithName:@"action" stringValue: @"allow"];
        [item addAttributeWithName:@"order" stringValue: @"2"];
        [item addChild: itemMes];
        [item1 addChild: item];
    }
    
    //Deny tat ca cac contact con lai, ke ca so la
    NSXMLElement *itemBlock = [NSXMLElement elementWithName:@"item"];
    [itemBlock addAttributeWithName:@"action" stringValue: @"deny"];
    [itemBlock addAttributeWithName:@"order" stringValue: @"3"];
    [item1 addChild: itemBlock];
    
	NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:privacy"];
    [query addChild: item1];
    
	XMPPIQ *iq = [XMPPIQ iqWithType:@"set"];
    [iq addAttributeWithName:@"from" stringValue: meXmppString];
	[iq addChild:query];
	[appDelegate.xmppStream sendElement:iq];
}

- (void)pingAnUser: (NSString *)user{
    XMPPIQ *iq = [XMPPIQ iqWithType:@"get"];
    NSString *idIQ = [NSString stringWithFormat:@"pinguser_%@", [AppUtils randomStringWithLength: 10]];
    [iq addAttributeWithName:@"to" stringValue: user];
    [iq addAttributeWithName:@"id" stringValue: idIQ];
    
    NSXMLElement *ping = [NSXMLElement elementWithName:@"ping" xmlns:@"urn:xmpp:ping"];
    [iq addChild: ping];
    [appDelegate.xmppStream sendElement: iq];
}

//  Gửi yêu cầu kết bạn đến 1 user
- (void)sendRequestFrom:(NSString *)fromUser toUser: (NSString *)toUser {
    XMPPJID *userJID = [XMPPJID jidWithString: toUser];
    [xmppRoster addUser:userJID withNickname:toUser];
    
    /*  Leo Kelvin
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"subscribe"];
    [presence addAttributeWithName:@"xmlns" stringValue:@"jabber:client"];
    [presence addAttributeWithName:@"id" stringValue:[AppUtils randomStringWithLength:10]];
    [presence addAttributeWithName:@"to" stringValue: toUser];
    [presence addAttributeWithName:@"type" stringValue:@"subscribe"];
    [presence addAttributeWithName:@"from" stringValue: fromUser];
    
    [appDelegate.xmppStream sendElement: presence];
    */
}


//  Send thông tin kết bạn đến user
- (void)sendRequestUserInfoOf: (NSString *)fromUser toUser: (NSString *)toUser
                  withContent: (NSString *)content andDisplayName: (NSString *)displayName {
    
    content = [content stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    displayName = [displayName stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    
    XMPPMessage *message = [[XMPPMessage alloc] init];
    [message addAttributeWithName:@"xmlns" stringValue:@"jabber:client"];
    [message addAttributeWithName:@"id" stringValue:[AppUtils randomStringWithLength:10]];
    [message addAttributeWithName:@"to" stringValue: toUser];
    [message addAttributeWithName:@"type" stringValue:@"chat"];
    
    NSXMLElement *action = [[NSXMLElement alloc] initWithName:@"action"];
    [action addAttributeWithName:@"xmlns" stringValue:@"callnex:message:action"];
    [action addAttributeWithName:@"name" stringValue:@"request-note"];
    [action addAttributeWithName:@"value" stringValue: content];
    [action addAttributeWithName:@"displayname" stringValue: displayName];
    [message addChild: action];
    
    [appDelegate.xmppStream sendElement: message];
}

/*----- Send contact cho user -----*/
- (void)sendContactMessageToUser: (XMPPMessage *)message{
    [appDelegate.xmppStream sendElement: message];
}


// Gửi thông tin xác nhận đã xoá request recall
- (void)sendDeleteSuccessRecallToUser: (NSString *)userXmppStr andIdMsg: (NSString *)idMessage{
    NSString *myStr = [NSString stringWithFormat:@"%@@%@", USERNAME, xmpp_cloudfone];
    NSXMLElement *message = [NSXMLElement elementWithName:@"message" xmlns:@"jabber:client"];
    [message addAttributeWithName:@"to" stringValue: userXmppStr];
    [message addAttributeWithName:@"from" stringValue:myStr];
    [message addAttributeWithName:@"id" stringValue:[AppUtils randomStringWithLength: 10]];
    
	NSXMLElement *recall = [NSXMLElement elementWithName:@"recall" xmlns:@"urn:xmpp:recall"];
    [recall addAttributeWithName:@"id" stringValue:idMessage];
    [message addChild: recall];
    [appDelegate.xmppStream sendElement: message];
}

/*----- Gửi thông tin xác nhận đã xoá request recall -----*/
- (void)sendRequestRecallToUser: (NSString *)userXmppStr fromUser: (NSString *)fromUser andIdMsg: (NSString *)idMessage{
    NSXMLElement *message = [NSXMLElement elementWithName:@"message" xmlns:@"jabber:client"];
    [message addAttributeWithName:@"id" stringValue:[AppUtils randomStringWithLength: 10]];
    [message addAttributeWithName:@"to" stringValue: userXmppStr];
    [message addAttributeWithName:@"from" stringValue: fromUser];
    
    NSXMLElement *recall = [NSXMLElement elementWithName:@"requestrecall" xmlns:@"urn:xmpp:recall"];
    [recall addAttributeWithName:@"id" stringValue:idMessage];
    [message addChild: recall];
    [appDelegate.xmppStream sendElement: message];
}

// Gửi nội dung message cho tracking list
- (void)sendMessageToUserInTrackingList: (NSString *)user withContent: (NSString *)contentMessage withId: (NSString *)idMessage{
    NSXMLElement *message = [NSXMLElement elementWithName:@"message" xmlns:@"jabber:client"];
    [message addAttributeWithName:@"type" stringValue:@"chat"];
    [message addAttributeWithName:@"id" stringValue:idMessage];
    [message addAttributeWithName:@"to" stringValue: user];
    [message addAttributeWithName:@"from" stringValue:appDelegate.myBuddy.accountName];
    
	NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue: contentMessage];
    [message addChild: body];
    
    NSXMLElement *request = [NSXMLElement elementWithName:@"request"];
    [request addAttributeWithName:@"xmlns" stringValue:@"urn:xmpp:receipts"];
    [message addChild: request];
    
    [appDelegate.xmppStream sendElement: message];
}

// Xoá 1 user ra khỏi roster list
- (void)removeUserFromRosterList: (NSString *)user withIdMessage: (NSString *)idIQ
{
    XMPPJID *jid = [XMPPJID jidWithString: user];
    
    XMPPJID *myJID = appDelegate.xmppStream.myJID;
    
    if ([myJID isEqualToJID:jid options:XMPPJIDCompareBare])
    {
        NSLog(@"%@: %@ - Ignoring request to remove myself from my own roster", [self class], THIS_METHOD);
        return;
    }
    
    NSXMLElement *item = [NSXMLElement elementWithName:@"item"];
    [item addAttributeWithName:@"jid" stringValue:[jid bare]];
    [item addAttributeWithName:@"subscription" stringValue:@"remove"];
    
    
    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:roster"];
    [query addChild:item];
    
    XMPPIQ *iq = [XMPPIQ iqWithType:@"set"];
    [iq addChild:query];
    [iq addAttributeWithName:@"id" stringValue:idIQ];
    
    [appDelegate.xmppStream sendElement:iq];
}

- (void)acceptRequestFriendFromUser: (NSString *)user {
    NSString *account = [NSString stringWithFormat:@"%@@%@", USERNAME, xmpp_cloudfone];
    
    XMPPIQ *iq = [XMPPIQ iqWithType:@"set"];
    [iq addAttributeWithName:@"xmlns" stringValue:@"jabber:client"];
    [iq addAttributeWithName:@"from" stringValue:account];
    [iq addAttributeWithName:@"to" stringValue:user];
    
    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:roster"];
    NSXMLElement *item = [NSXMLElement elementWithName:@"item"];
    [item addAttributeWithName:@"jid" stringValue:user];
    [item addAttributeWithName:@"name" stringValue:user];
    [item addAttributeWithName:@"subscription" stringValue:@"to"];
    
    [query addChild: item];
    [iq addChild: query];
    [appDelegate.xmppStream sendElement:iq];
    
    [NSTimer scheduledTimerWithTimeInterval:1.5 target:self
                                   selector:@selector(nextStepForAcceptFriendRequest:)
                                   userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"from", account, @"to", user, nil]
                                    repeats:NO];
}

- (void)nextStepForAcceptFriendRequest: (NSTimer *)timer {
    NSDictionary *object = [timer userInfo];
    if (object != nil) {
        NSString *from = [object objectForKey:@"from"];
        NSString *to = [object objectForKey:@"to"];
        if (from != nil && to != nil) {
            [self acceptRequestFromUser:to toMe:from];
        }
    }
}

/*----- Chấp nhận yêu cầu kết bạn từ 1 user -----*/
- (void)acceptRequestFromUser:(NSString *)fromUser toMe: (NSString *)toMe
{
    NSXMLElement *presenceStr = [NSXMLElement elementWithName:@"presence"];
    [presenceStr addAttributeWithName:@"to" stringValue: fromUser];
    [presenceStr addAttributeWithName:@"from" stringValue: toMe];
    [presenceStr addAttributeWithName:@"type" stringValue:@"subscribed"];
    [appDelegate.xmppStream sendElement:presenceStr];
}

//  Chấp nhận yêu cầu kết bạn của 1 user
- (void)sendAcceptRequestFromMe: (NSString *)me toUser: (NSString *)user
{
//    NSXMLElement *preSubscribed = [NSXMLElement elementWithName:@"presence"];
//    [preSubscribed addAttributeWithName:@"to" stringValue: user];
//    [preSubscribed addAttributeWithName:@"from" stringValue: me];
//    [preSubscribed addAttributeWithName:@"type" stringValue:@"subscribed"];
//    [appDelegate.xmppStream sendElement:preSubscribed];
    
    NSXMLElement *preSubscribe = [NSXMLElement elementWithName:@"presence"];
    [preSubscribe addAttributeWithName:@"to" stringValue: user];
    [preSubscribe addAttributeWithName:@"from" stringValue: me];
    [preSubscribe addAttributeWithName:@"type" stringValue:@"subscribe"];
    [appDelegate.xmppStream sendElement:preSubscribe];
}

- (void)clearStateOfUserBeforeSendRequest: (NSString *)user {
    NSString *idIQ = [NSString stringWithFormat:@"clearfriend_%@_%@", user, [AppUtils randomStringWithLength: 8]];
    NSXMLElement *item = [NSXMLElement elementWithName:@"item"];
    [item addAttributeWithName:@"jid" stringValue: user];
    [item addAttributeWithName:@"subscription" stringValue:@"remove"];
    
    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:roster"];
    [query addChild:item];
    
    XMPPIQ *iq = [XMPPIQ iqWithType:@"set"];
    [iq addAttributeWithName:@"id" stringValue: idIQ];
    [iq addChild:query];
    
    [appDelegate.xmppStream sendElement:iq];
}

- (void)setProfileForAccountWithName: (NSString *)fullname email: (NSString *)email address: (NSString *)address avatar: (NSString *)strAvatar
{
    XMPPIQ *iq = [XMPPIQ iqWithType:@"set"];
    NSString *idIQ = [NSString stringWithFormat:@"setprofile_%@", [AppUtils randomStringWithLength: 10]];
    [iq addAttributeWithName:@"id" stringValue: idIQ];
    
    NSXMLElement *vCard = [NSXMLElement elementWithName:@"vCard" xmlns:@"vcard-temp"];
    
    NSXMLElement *nameElement = [NSXMLElement elementWithName:@"FN" stringValue:fullname];
    [vCard addChild: nameElement];
    
    NSXMLElement *emailElement = [NSXMLElement elementWithName:@"EMAIL"];
    NSXMLElement *USERID = [NSXMLElement elementWithName:@"USERID" stringValue:email];
    [emailElement addChild: USERID];
    [vCard addChild: emailElement];
    
    NSXMLElement *streetElement = [NSXMLElement elementWithName:@"STREET" stringValue:address];
    [vCard addChild: streetElement];
    
    NSXMLElement *photoElement = [NSXMLElement elementWithName:@"PHOTO"];
    NSXMLElement *TYPE = [NSXMLElement elementWithName:@"TYPE" stringValue:@"image/jpeg"];
    [photoElement addChild: TYPE];
    
    NSXMLElement *BINVAL = [NSXMLElement elementWithName:@"BINVAL" stringValue:strAvatar];
    [photoElement addChild: BINVAL];
    
    [vCard addChild: photoElement];
    [iq addChild:vCard];
    
    [appDelegate.xmppStream sendElement:iq];
}

- (void)getVcard{
    /*
    XMPPIQ *iq = [XMPPIQ iqWithType:@"get"];
    [iq addAttributeWithName:@"from" stringValue:@"7788990004@xmpp.cloudfone.vn"];
    [iq addAttributeWithName:@"id" stringValue:[AppUtils randomStringWithLength:10]];
    [iq addAttributeWithName:@"to" stringValue:@"7788990005@xmpp.cloudfone.vn"];
    
    NSXMLElement *vCard = [NSXMLElement elementWithName:@"vCard" xmlns:@"vcard-temp"];
    [iq addChild:vCard];
    
    [appDelegate.xmppStream sendElement:iq];
    */
}

/*----- Từ chối yêu cầu kết bạn của một user -----*/
- (void) rejectRequestFromUser:(NSString *)toUser toMe: (NSString *)fromMe
{
    NSXMLElement *presenceStr = [NSXMLElement elementWithName:@"presence"];
    [presenceStr addAttributeWithName:@"type" stringValue:@"unsubscribed"];
    //[presenceStr addAttributeWithName:@"from" stringValue: fromMe];
    [presenceStr addAttributeWithName:@"to" stringValue: toUser];
    [appDelegate.xmppStream sendElement:presenceStr];
    
    NSXMLElement *item = [NSXMLElement elementWithName:@"item"];
	[item addAttributeWithName:@"jid" stringValue: toUser];
	[item addAttributeWithName:@"subscription" stringValue:@"remove"];
	
	NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:roster"];
	[query addChild:item];
	XMPPIQ *iq = [XMPPIQ iqWithType:@"set"];
	[iq addChild:query];
	[appDelegate.xmppStream sendElement:iq];
}

// Hàm set status text
- (void)setStatus: (NSString *)statusText withUser: (NSString *)user{
    XMPPPresence *presence = [XMPPPresence presence];
    [presence addAttributeWithName:@"type" stringValue: @"get"];
    [presence addAttributeWithName:@"from" stringValue: user];
    NSXMLElement *status = [NSXMLElement elementWithName:@"status"];
    [status setStringValue: statusText];
    [presence addChild:status];
    [appDelegate.xmppStream sendElement:presence];
}

- (NSString*) accountName {
    return [JID full];
}

//  Hàm trả về danh sách trong Roster
- (NSArray*) buddyList
{
    NSFetchedResultsController *frc = [self fetchedResultsController];
    NSArray *sections = [[self fetchedResultsController] sections];
    int sectionsCount = (int)[[[self fetchedResultsController] sections] count];
    
    for(int sectionIndex = 0; sectionIndex < sectionsCount; sectionIndex++)
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:sectionIndex];
        NSString *sectionName;
        OTRBuddyStatus otrBuddyStatus;
        
        int section = [sectionInfo.name intValue];
        switch (section)
        {
            case 0  :
                sectionName = @"XMPP - Available";
                otrBuddyStatus = kOTRBuddyStatusAvailable;
                break;
            case 1  :
                sectionName = @"XMPP - Away";
                otrBuddyStatus = kOTRBuddyStatusAway;
                break;
            default :
                sectionName = @"XMPP - Offline";
                otrBuddyStatus = kOTRBuddyStatusOffline;
                break;
        }
        for(int j = 0; j < sectionInfo.numberOfObjects; j++)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:sectionIndex];
            XMPPUserCoreDataStorageObject *user = [frc objectAtIndexPath:indexPath];
            OTRBuddy *otrBuddy = [protocolBuddyList objectForKey:user.jidStr];
            NSString *resouceStr = user.primaryResource.jid.resource;
            if (resouceStr == nil) {
                resouceStr = @"";
            }
            
            if(otrBuddy){
                otrBuddy.status = otrBuddyStatus;
                otrBuddy.resourceStr = resouceStr;
            }else {
                OTRBuddy *newBuddy = [OTRBuddy buddyWithDisplayName:user.displayName accountName: [[user jid] full] protocol:self status:otrBuddyStatus groupName:sectionName];
                newBuddy.resourceStr = resouceStr;
                
                if ([user.subscription isEqualToString:@"both"]) {
                    [protocolBuddyList setObject:newBuddy forKey:user.jidStr];
                }
            }
        }
    }
    return [protocolBuddyList allValues];
}

- (NSString*) type {
    return kOTRProtocolTypeXMPP;
}

- (OTRBuddy *) getBuddyByAccountName:(NSString *)buddyAccountName
{
    if (protocolBuddyList)
        return [protocolBuddyList objectForKey:buddyAccountName];
    else
        return nil;
}

-(void)connectWithPassword:(NSString *)myPassword
{
    if (myPassword == nil || [myPassword isEqualToString:@""]) {
        myPassword = PASSWORD;
    }
    NSString *userName = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@@%@", USERNAME, xmpp_cloudfone]];
    
    [self connectWithJID:userName password:myPassword];
}

-(void)sendChatState:(int)chatState withBuddy:(OTRBuddy *)buddy
{
    if (!self.account.sendTypingNotifications) {
        return;
    }
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    [message addAttributeWithName:@"type" stringValue:@"chat"];
    [message addAttributeWithName:@"to" stringValue:buddy.accountName];
    
    XMPPMessage * xMessage = [XMPPMessage messageFromElement:message];
    
    BOOL shouldSend = YES;
    
    switch (chatState)
    {
        case kOTRChatStateActive  :
            [xMessage addActiveChatState];
            break;
        case kOTRChatStateComposing  :
            [xMessage addComposingChatState];
            break;
        case kOTRChatStateInactive:
            [xMessage addInactiveChatState];
            break;
        case kOTRChatStatePaused:
            [xMessage addPausedChatState];
            break;
        case kOTRChatStateGone:
            [xMessage addGoneChatState];
            break;
        default :
            shouldSend = NO;
            break;
    }
    if(shouldSend)
        [appDelegate.xmppStream sendElement:message];
}

#pragma mark - my functions
- (NSString *)removeAllSpecialInString: (NSString *)phoneString{
    NSString *resultStr = @"";
    for (int strCount=0; strCount<phoneString.length; strCount++) {
        char characterChar = [phoneString characterAtIndex: strCount];
        NSString *characterStr = [NSString stringWithFormat:@"%c", characterChar];
        if ([characterStr isEqualToString:@" "] || [characterStr isEqualToString:@"-"] || [characterStr isEqualToString:@"("] || [characterStr isEqualToString:@")"] || [characterStr isEqualToString:@" "]) {
            //do not thing
        }else{
            resultStr = [NSString stringWithFormat:@"%@%@", resultStr, characterStr];
        }
    }
    return resultStr;
}

/*---Hàm save image google map---*/
- (NSString *)saveImageFromGoogleMap: (NSString *)staticMapUrl{
    NSString *mapName = [NSString stringWithFormat:@"map_%@.PNG", [AppUtils randomStringWithLength: 10]];
    
    NSURL *mapUrl = [NSURL URLWithString:[staticMapUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSData *googleMapData = [NSData dataWithContentsOfURL:mapUrl];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    //Kiểm tra folder có tồn tại hay không?
    NSString *folderPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/files/%@", mapName]];
    [googleMapData writeToFile:folderPath atomically:YES];
    return mapName;
}

/*----- Hàm tạo message ảo trước khi nhận file -----*/
- (void)createMessageForFileBeforeReceiveWithUser: (NSString *)user idMessage: (NSString *)idMessage fileName: (NSString *)fileName description: (NSString *)descriptionStr expireTime: (int)expireTime
{
    NSString *sendPhone = [AppUtils getSipFoneIDFromString: user];
    
    BOOL msgStatus = false;
     NSString *friendStr = [AppUtils getSipFoneIDFromString: appDelegate.friendBuddy.accountName];
     
    if (([[[PhoneMainView instance] currentView] isEqual:[MainChatViewController compositeViewDescription]] || [[[PhoneMainView instance] currentView] isEqual:[GroupMainChatViewController compositeViewDescription]]) && [friendStr isEqualToString: sendPhone]) {
        msgStatus = true;
    }else{
        msgStatus = false;
    }
    
    NSString *typeFile = [AppUtils checkFileExtension: fileName];
    if ([typeFile isEqualToString: imageMessage]) {
        // Image message
        [NSDatabase saveMessage:sendPhone toPhone:USERNAME withContent:descriptionStr andStatus:msgStatus withDelivered:1 andIdMsg:idMessage detailsUrl:@"" andThumbUrl:@"" withTypeMessage:imageMessage andExpireTime:expireTime andRoomID:@"" andExtra:@"" andDesc:descriptionStr];
        
        NSMutableDictionary *messageInfo = [NSMutableDictionary dictionaryWithObject:idMessage forKey:@"idMessage"];
        [messageInfo setObject:imageMessage forKey:@"typeMessage"];
        [messageInfo setObject:sendPhone forKey:@"user"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kOTRMessageReceived object:nil userInfo:messageInfo];
    }else if ([typeFile isEqualToString: audioMessage]){
        NSMutableString *fullFileName = [[NSMutableString alloc] initWithString: fileName];
        fileName = [fullFileName stringByReplacingCharactersInRange:NSMakeRange(fullFileName.length-4, 4) withString:@".m4a"];
        
        [NSDatabase saveMessage:sendPhone toPhone:USERNAME withContent:audioMessage andStatus:msgStatus withDelivered:1 andIdMsg:idMessage detailsUrl:fileName andThumbUrl:fileName withTypeMessage:audioMessage andExpireTime:expireTime andRoomID:@"" andExtra:@"" andDesc:@""];
        
        NSMutableDictionary *messageInfo = [NSMutableDictionary dictionaryWithObject:idMessage forKey:@"idMessage"];
        [messageInfo setObject:audioMessage forKey:@"typeMessage"];
        [messageInfo setObject:sendPhone forKey:@"user"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kOTRMessageReceived object:nil userInfo:messageInfo];
    }else if ([typeFile isEqualToString: videoMessage]){
        [NSDatabase saveMessage:sendPhone toPhone:USERNAME withContent:videoMessage andStatus:msgStatus withDelivered:1 andIdMsg:idMessage detailsUrl:fileName andThumbUrl:fileName withTypeMessage:videoMessage andExpireTime:expireTime andRoomID:@"" andExtra:@"" andDesc:@""];
        
        NSMutableDictionary *messageInfo = [NSMutableDictionary dictionaryWithObject:idMessage forKey:@"idMessage"];
        [messageInfo setObject:videoMessage forKey:@"typeMessage"];
        [messageInfo setObject:sendPhone forKey:@"user"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kOTRMessageReceived object:nil userInfo:messageInfo];
    }
}

/*----- Nhận file thành công -----*/
- (void)saveDataOfDocument: (NSData *)fileData withFileName: (NSString *)fileName idMessage: (NSString *)idMessage{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *typeFile = [AppUtils checkFileExtension: fileName];
    
    if ([typeFile isEqualToString: imageMessage]) {
        NSString *tmpStr = [AppUtils randomStringWithLength:10];
        fileName = [NSString stringWithFormat:@"%@_%@", tmpStr, fileName];
        
        NSString *detailImgLoc = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/files/%@", fileName]];
        [fileData writeToFile:detailImgLoc atomically:YES];
        
        NSString *thumbImgName = [NSString stringWithFormat:@"thumb_%@", fileName];
        NSString *thumbImgLoc = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/files/%@", thumbImgName]];
        UIImage *image = [UIImage imageWithData: fileData];
        
        // Lưu image thumb cho mesage
        UIImage *picture1 = [AppUtils squareImageWithImage:image withSizeWidth: 200];
        NSData *imgData = UIImagePNGRepresentation(picture1);
        [imgData writeToFile:thumbImgLoc atomically:YES];
        
        [NSDatabase updateImageMessageWithDetailsUrl:fileName
                                          andThumbUrl:thumbImgName
                                       ofImageMessage:idMessage];
        [[NSNotificationCenter defaultCenter] postNotificationName:k11UpdateMsgAfterReceivedFile
                                                            object:idMessage];
        
    }else if ([typeFile isEqualToString: audioMessage]){
        NSMutableString *fullFileName = [[NSMutableString alloc] initWithString: fileName];
        fileName = [fullFileName stringByReplacingCharactersInRange:NSMakeRange(fullFileName.length-4, 4) withString:@".m4a"];
        
         NSString *databaseFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/records/%@", fileName]];
        [fileData writeToFile:databaseFile atomically:YES];
        [NSDatabase updateAudioMessageAfterReceivedSuccessfullly:idMessage];
        [[NSNotificationCenter defaultCenter] postNotificationName:k11UpdateMsgAfterReceivedFile
                                                            object:idMessage];
    }
    //    else if([typeData isEqualToString: audioMessage]){
    //        [NSDatabase saveMessage:dataObject.sendPhone
    //                         toPhone:USERNAME
    //                     withContent: textAudioMessage
    //                       andStatus:YES
    //                   withDelivered:2
    //                        andIdMsg:sid
    //                      detailsUrl:dataObject.nameFile
    //                     andThumbUrl:dataObject.nameFile
    //                 withTypeMessage:audioMessage
    //                   andExpireTime:expireTime
    //                       andRoomID:@""
    //                        andExtra:nil
    //                         andDesc:nil];
    //
    //        [[NSNotificationCenter defaultCenter] postNotificationName:k11UpdateViewChatsAfterReceivedFile
    //                                                            object: sid];
    //
    //    }else if ([typeData isEqualToString: videoMessage]){
    //        NSString *databaseFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/videos/%@", dataObject.nameFile]];
    //        [dataObject.dataFile writeToFile:databaseFile atomically:YES];
    //
    //        [NSDatabase saveMessage:dataObject.sendPhone
    //                         toPhone:USERNAME
    //                     withContent:@""
    //                       andStatus:YES
    //                   withDelivered:2
    //                        andIdMsg:idMsg
    //                      detailsUrl:dataObject.nameFile
    //                     andThumbUrl:@""
    //                 withTypeMessage:videoMessage
    //                   andExpireTime:-1
    //                       andRoomID:@""
    //                        andExtra:nil
    //                         andDesc:nil];
    //
    //        [[NSNotificationCenter defaultCenter] postNotificationName:k11UpdateViewChatsAfterReceivedFile
    //                                                            object: nil];
    //    }
    //    [appDelegate.dataReceiveDict removeObjectForKey: sid];
}

- (void)activeOutgoingFile: (NSNotification *)notif{
    id object = [notif object];
    if ([object isKindOfClass:[XMPPOutgoingFileTransfer class]]) {
        [(XMPPOutgoingFileTransfer *)object activate: appDelegate.xmppStream];
    }
}

- (NSString *)getCallnexIDOfContactFromReceiveString: (NSString *)receiveStr {
    NSString *resultStr = @"";
    receiveStr = [receiveStr stringByReplacingOccurrencesOfString:@"{" withString:@""];
    receiveStr = [receiveStr stringByReplacingOccurrencesOfString:@"}" withString:@""];
    receiveStr = [receiveStr stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    NSArray *list = [receiveStr componentsSeparatedByString:@","];
    for (int iCount=0; iCount<list.count-1; iCount++) {
        NSString *valueStr = [list objectAtIndex: iCount];
        NSArray *arr = [valueStr componentsSeparatedByString:@":"];
        if (arr.count > 1) {
            if ([[arr objectAtIndex:0] isEqualToString:@"callnexId"]) {
                resultStr = [arr objectAtIndex: 1];
                break;
            }
        }
    }
    return resultStr;
}

- (NSString *)getAccountNameFromString: (NSString *)string {
    NSString *result = @"";
    NSRange range = [string rangeOfString:[NSString stringWithFormat:@"@%@", xmpp_cloudfone]];
    
    if (range.location != NSNotFound) {
        result = [string substringToIndex: range.location+range.length];
    }else{
        string = [string stringByReplacingOccurrencesOfString:single_cloudfone withString:xmpp_cloudfone];
        range = [string rangeOfString:[NSString stringWithFormat:@"@%@", xmpp_cloudfone]];
        if (range.location != NSNotFound) {
            result = [string substringToIndex: range.location+range.length];
        }
    }
    return result;
}

//  Kiểm tra tạo group thành công
- (BOOL)checkCreateGroupChatSuccessfully: (NSArray *)statusArr {
    BOOL is110 = false;
    BOOL is201 = false;
    
    for (int iCount=0; iCount<statusArr.count; iCount++) {
        NSXMLElement *statusElement = [statusArr objectAtIndex: iCount];
        NSString *status = [[statusElement attributeForName:@"code"] stringValue];
        if ([status isEqualToString:@"110"]) {
             is110 = true;
        }else if ([status isEqualToString:@"201"]){
            is201 = true;
        }
    }
    if (is110 && is201) {
        return true;
    }else{
        return false;
    }
}

//  Tạo group chat trên server
- (void)createGroupOfMe: (NSString *)meStr andGroupName: (NSString *)groupName{
    NSString *jidStr = [NSString stringWithFormat:@"%@@%@/%@", groupName, xmpp_cloudfone_group, meStr];
    
    XMPPRoomMemoryStorage *_roomMemory = [[XMPPRoomMemoryStorage alloc] init];
    XMPPJID * roomJID = [XMPPJID jidWithString: jidStr];
    XMPPRoom* xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:_roomMemory
                                                           jid:roomJID
                                                 dispatchQueue:dispatch_get_main_queue()];
    
    NSXMLElement *history = [NSXMLElement elementWithName:@"history"];
    //  [history addAttributeWithName:@"since" stringValue:offlinePoint];
    [history addAttributeWithName:@"maxstanzas" stringValue:@"0"];
    
    [xmppRoom activate: appDelegate.xmppStream];
    [xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [xmppRoom joinRoomUsingNickname:meStr
                            history:history
                           password:nil];
}

//  Đồng ý vào group chat
- (void)acceptJoinToRoomChat: (NSString *)roomName {
    /*  Leo Kelvin
    NSString *idPresence = [AppUtils randomStringWithLength: 10];
    NSString *login = USERNAME;
    NSString *toStr = [NSString stringWithFormat:@"%@@%@/%@", roomName, xmpp_cloudfone_group, login];
    
    XMPPPresence *pressence = [[XMPPPresence alloc] init];
    [pressence addAttributeWithName:@"xmlns" stringValue:@"jabber:client"];
    [pressence addAttributeWithName:@"id" stringValue: idPresence];
    [pressence addAttributeWithName:@"to" stringValue:toStr];
    
    NSXMLElement *xElement = [[NSXMLElement alloc] initWithName:@"x" xmlns:@"http://jabber.org/protocol/muc#admin"];
    NSXMLElement *itemElement = [[NSXMLElement alloc] initWithName:@"item"];
    [itemElement addAttributeWithName:@"affiliation" stringValue:@"member"];
    [itemElement addAttributeWithName:@"role" stringValue:@"participant"];
    [xElement addChild: itemElement];
    [pressence addChild:  xElement];
    [appDelegate.xmppStream sendElement:pressence]; */
    
    NSString *jidStr = @"";
    if (![roomName containsString:xmpp_cloudfone_group]) {
        jidStr = [NSString stringWithFormat:@"%@@%@/%@", roomName, xmpp_cloudfone_group, account];
    }else{
        jidStr = [NSString stringWithFormat:@"%@/%@", roomName, USERNAME];
    }
    
    XMPPRoomMemoryStorage *_roomMemory = [[XMPPRoomMemoryStorage alloc]init];
    XMPPJID * roomJID = [XMPPJID jidWithString: jidStr];
    XMPPRoom* xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:_roomMemory
                                                           jid:roomJID
                                                 dispatchQueue:dispatch_get_main_queue()];
    
    NSXMLElement *history = [NSXMLElement elementWithName:@"history"];
    //  [history addAttributeWithName:@"since" stringValue:offlinePoint];
    [history addAttributeWithName:@"maxstanzas" stringValue:@"100"];
    
    [xmppRoom activate: appDelegate.xmppStream];
    [xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [xmppRoom joinRoomUsingNickname:USERNAME history:history password:nil];
}

- (void)xmppRoomDidJoin:(XMPPRoom *)sender {
    [appDelegate.xmppChatRooms addObject: sender];
    [[NSNotificationCenter defaultCenter] postNotificationName:k11JoinGroupChatSuccessfully object:sender];
    NSLog(@"---Da join vao room");
}

- (void)xmppRoomDidCreate:(XMPPRoom *)sender {
    NSLog(@"Room created");
    [[NSNotificationCenter defaultCenter] postNotificationName:k11CreateGroupChatSuccessfully
                                                        object:sender];
}

//  Đổi tên group của room chat
- (void)changeNameOfTheRoom: (NSString *)roomName withNewName: (NSString *)newName
{
    NSString *meStr     = [NSString stringWithFormat:@"%@@%@", USERNAME, xmpp_cloudfone];
    NSString *roomStr   = [NSString stringWithFormat:@"%@%@", roomName, xmpp_cloudfone_group];
    
    NSString *idIQ = [NSString stringWithFormat:@"changeroomname_%@",[AppUtils randomStringWithLength: 10]];
    
    NSXMLElement *value1Element = [NSXMLElement elementWithName:@"value" stringValue:@"http://jabber.org/protocol/muc#roomconfig"];
    
    NSXMLElement *field1Element = [NSXMLElement elementWithName:@"field"];
    [field1Element addAttributeWithName:@"var" stringValue:@"FORM_TYPE"];
    [field1Element addChild: value1Element];
    
    NSXMLElement *value2Element = [NSXMLElement elementWithName:@"value" stringValue:newName];
    
    NSXMLElement *field2Element = [NSXMLElement elementWithName:@"field"];
    [field2Element addAttributeWithName:@"var" stringValue:@"muc#roomconfig_roomname"];
    [field2Element addChild: value2Element];
    
    NSXMLElement *xElement = [NSXMLElement elementWithName:@"x"];
    [xElement addAttributeWithName:@"xmlns" stringValue:@"jabber:x:data"];
    [xElement addAttributeWithName:@"type" stringValue:@"submit"];
    [xElement addChild: field1Element];
    [xElement addChild: field2Element];
    
    
    NSXMLElement *query = [NSXMLElement elementWithName:@"query"];
    [query addAttributeWithName:@"xmlns" stringValue:@"http://jabber.org/protocol/muc#owner"];
    [query addChild: xElement];
    
    XMPPIQ *iq = [XMPPIQ iqWithType:@"set"];
    [iq addAttributeWithName:@"from" stringValue:meStr];
    [iq addAttributeWithName:@"id" stringValue:idIQ];
    [iq addAttributeWithName:@"to" stringValue:roomStr];
    
    [iq addChild: query];
    
    [appDelegate.xmppStream sendElement: iq];
}

//  Đổi subject (status) của room chat
- (void)changeSubjectOfTheRoom: (NSString *)roomName withSubject: (NSString *)subject
{
    NSString *idMessage = [AppUtils randomStringWithLength: 10];
    NSString *toStr = [NSString stringWithFormat:@"%@@%@", roomName, xmpp_cloudfone_group];
    NSString *fromStr = [NSString stringWithFormat:@"%@@%@", USERNAME, xmpp_cloudfone];
    
    NSXMLElement *subElement = [NSXMLElement elementWithName:@"subject" stringValue: subject];
    
    XMPPMessage *message = [XMPPMessage messageWithType: group_chat];
    [message addAttributeWithName:@"id" stringValue:idMessage];
    [message addAttributeWithName:@"to" stringValue:toStr];
    [message addAttributeWithName:@"from" stringValue:fromStr];
    [message addChild: subElement];
    
    [appDelegate.xmppStream sendElement: message];
}

//  Đổi description của room chat
- (void)changeDescriptionOfTheRoom: (NSString *)roomName withSubject: (NSString *)subject
{
    NSString *idMessage = [AppUtils randomStringWithLength: 10];
    NSString *toStr = [NSString stringWithFormat:@"%@@%@", roomName, xmpp_cloudfone_group];
    NSString *fromStr = [NSString stringWithFormat:@"%@@%@", USERNAME, xmpp_cloudfone];
    
    NSXMLElement *subElement = [NSXMLElement elementWithName:@"description" stringValue: subject];
    
    XMPPMessage *message = [XMPPMessage messageWithType: group_chat];
    [message addAttributeWithName:@"id" stringValue:idMessage];
    [message addAttributeWithName:@"to" stringValue:toStr];
    [message addAttributeWithName:@"from" stringValue:fromStr];
    [message addChild: subElement];
    
    [appDelegate.xmppStream sendElement: message];
}

//  Mời danh sách user vào list chat
- (void)inviteUserToGroupChat: (NSString *)roomName andListUser: (NSArray *)listUser{
    NSString *groupNameFull = [NSString stringWithFormat:@"%@@%@", roomName, xmpp_cloudfone_group];
    NSString *idMessage = [AppUtils randomStringWithLength: 10];
    
    XMPPMessage *inviteMessage = [[XMPPMessage alloc] init];
    [inviteMessage addAttributeWithName:@"id" stringValue:idMessage];
    [inviteMessage addAttributeWithName:@"to" stringValue: groupNameFull];
    
    NSXMLElement *xElement = [NSXMLElement elementWithName:@"x"];
    [xElement addAttributeWithName:@"xmlns" stringValue:@"http://jabber.org/protocol/muc#user"];
    
    for (int iCount = 0; iCount < listUser.count; iCount++) {
        NSString *cloudfoneID = [listUser objectAtIndex: iCount];
        if (![cloudfoneID isEqualToString:@""]) {
            NSString *toStr = [NSString stringWithFormat:@"%@@%@", cloudfoneID, xmpp_cloudfone];
            NSXMLElement *invite = [NSXMLElement elementWithName:@"invite"];
            [invite addAttributeWithName:@"to" stringValue: toStr];
            NSXMLElement *reason = [NSXMLElement elementWithName:@"reason" stringValue:@"hey!!!"];
            [invite addChild: reason];
            [xElement addChild: invite];
        }
    }
    
    //  Add thêm user đang chat vào list
    NSString *toStr = appDelegate.friendBuddy.accountName;
    NSXMLElement *invite = [NSXMLElement elementWithName:@"invite"];
    [invite addAttributeWithName:@"to" stringValue: toStr];
    NSXMLElement *reason = [NSXMLElement elementWithName:@"reason" stringValue:@"hey!!!"];
    [invite addChild: reason];
    [xElement addChild: invite];
    
    [inviteMessage addChild: xElement];
    [appDelegate.xmppStream sendElement: inviteMessage];
}

- (void)setRoleForUserInGroupChat: (NSString *)roomName andListUser: (NSArray *)listUser
{
    NSString *idIQ = [AppUtils randomStringWithLength: 10];
    XMPPIQ  *iq = [[XMPPIQ alloc] initWithType:@"set"];
    [iq addAttributeWithName:@"xmlns" stringValue:@"jabber:client"];
    [iq addAttributeWithName:@"id" stringValue:idIQ];
    [iq addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@@%@", roomName, xmpp_cloudfone_group]];
    
    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://jabber.org/protocol/muc#owner"];
    [iq addChild: queryElement];
    
    for (int iCount = 0; iCount < listUser.count; iCount++) {
        NSString *cloudfoneID = [listUser objectAtIndex: iCount];
        if (![cloudfoneID isEqualToString:@""]) {
            NSString *toStr = [NSString stringWithFormat:@"%@@%@", cloudfoneID, xmpp_cloudfone];
            NSXMLElement *item = [NSXMLElement elementWithName:@"item"];
            [item addAttributeWithName:@"affiliation" stringValue: @"owner"];
            [item addAttributeWithName:@"jid" stringValue: toStr];
            [queryElement addChild: item];
        }
    }
    [appDelegate.xmppStream sendElement: iq];
}

//  Get danh sách user trong room chat
- (void)getListUserInRoomChat: (NSString *)roomName {
    NSString *strAccount = [NSString stringWithFormat:@"%@@%@", USERNAME, xmpp_cloudfone];
    NSString *idIQ = [AppUtils randomStringWithLength: 10];
    XMPPIQ  *iq = [[XMPPIQ alloc] initWithType:@"get"];
    [iq addAttributeWithName:@"xmlns" stringValue:@"jabber:client"];
    [iq addAttributeWithName:@"id" stringValue:idIQ];
    [iq addAttributeWithName:@"from" stringValue: strAccount];
    [iq addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@@%@", roomName, xmpp_cloudfone_group]];
    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://jabber.org/protocol/disco#items"];
    [iq addChild: queryElement];
    
    [appDelegate.xmppStream sendElement: iq];
}

//  Add new by Khai Le in 08/11/2017
- (void) setLeaveRoomToServer:(NSString *)roomId withId: (NSString *)idIQ
{
    NSString *roomJID = [NSString stringWithFormat:@"%@@%@", roomId, xmpp_cloudfone_group];
    
    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"http://jabber.org/protocol/muc#admin"];
    
    XMPPIQ *iq = [XMPPIQ iqWithType:@"set" child:query];
    [iq addAttributeWithName:@"to" stringValue:roomJID];
    [iq addAttributeWithName:@"id" stringValue:idIQ];
    
    NSXMLElement *item = [NSXMLElement elementWithName:@"item"];
    [item addAttributeWithName:@"affiliation" stringValue:@"none"];
    [item addAttributeWithName:@"jid" stringValue:[NSString stringWithFormat:@"%@@%@", USERNAME, xmpp_cloudfone]];
    [query addChild:item];
    
    [appDelegate.xmppStream sendElement:iq];
}

//  Rời khỏi một room chat
- (void)leaveConference: (NSString *)roomName
{
    NSString *roomJID = [NSString stringWithFormat:@"%@@%@", roomName, xmpp_cloudfone_group];
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [presence addAttributeWithName:@"from" stringValue: appDelegate.myBuddy.accountName];
    [presence addAttributeWithName:@"to" stringValue:roomJID];
    
    NSXMLElement *status = [NSXMLElement elementWithName:@"status" stringValue:@"leaving room"];
    [presence addChild:status];
    
    NSXMLElement *priority = [NSXMLElement elementWithName:@"priority" stringValue:@"0"];
    [presence addChild:priority];
    
    [appDelegate.xmppStream sendElement:presence];
}

//  Đổi tên đại diện room chat
- (void)changeGroupNameOfRoom: (NSString *)toGroup withNewName: (NSString *)newName {
    NSString *idMessage = [AppUtils randomStringWithLength: 10];
    XMPPMessage *message = [[XMPPMessage alloc] initWithType: group_chat];
    [message addAttributeWithName:@"id" stringValue: idMessage];
    [message addAttributeWithName:@"from" stringValue: appDelegate.myBuddy.accountName];
    [message addAttributeWithName:@"to" stringValue: toGroup];
    
    NSXMLElement *action = [NSXMLElement elementWithName:@"action" xmlns:@"callnex:message:action"];
    [action addAttributeWithName:@"name" stringValue: @"renameroom"];
    [action addAttributeWithName:@"value" stringValue: newName];
    [action addAttributeWithName:@"description" stringValue:@""];
    
    [message addChild: action];
    [appDelegate.xmppStream sendElement: message];
}

//  Kick một user khỏi room chat
- (void)kickOccupantInRoomChat: (NSString *)roomName withNickName: (NSString *)nickName {
    NSString *toStr = [NSString stringWithFormat:@"%@@%@", roomName, xmpp_cloudfone_group];
    XMPPIQ *iq = [[XMPPIQ alloc] initWithType:@"set"];
    [iq addAttributeWithName:@"id" stringValue:[AppUtils randomStringWithLength:10]];
    [iq addAttributeWithName:@"from" stringValue:appDelegate.myBuddy.accountName];
    [iq addAttributeWithName:@"to" stringValue: toStr];
    
    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"http://jabber.org/protocol/muc#admin"];
    
    NSXMLElement *item = [NSXMLElement elementWithName:@"item"];
    [item addAttributeWithName:@"nick" stringValue:nickName];
    [item addAttributeWithName:@"role" stringValue:@"none"];
    
    [query addChild: item];
    [iq addChild: query];
    [appDelegate.xmppStream sendElement: iq];
}

//  Ban một user khỏi room chat
- (void)banOccupantInRoomChat: (NSString *)roomName withUser: (NSString *)user
{
    NSString *idIQ = [NSString stringWithFormat:@"banuser_%@", [AppUtils randomStringWithLength:10]];
    NSString *strTo = [NSString stringWithFormat:@"%@@%@", roomName, xmpp_cloudfone_group];
    
    XMPPIQ *iq = [[XMPPIQ alloc] initWithType:@"set"];
    [iq addAttributeWithName:@"id" stringValue:idIQ];
    [iq addAttributeWithName:@"from" stringValue:appDelegate.myBuddy.accountName];
    [iq addAttributeWithName:@"to" stringValue:strTo];
    
    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"http://jabber.org/protocol/muc#admin"];
    
    NSXMLElement *item = [NSXMLElement elementWithName:@"item"];
    [item addAttributeWithName:@"affiliation" stringValue:@"outcast"];
    [item addAttributeWithName:@"jid" stringValue:user];
    
    [query addChild: item];
    [iq addChild: query];
    [appDelegate.xmppStream sendElement: iq];
}

#pragma mark -vCard
- (void)requestVCardFromAccount: (NSString *)strAccount {
    NSString *idIQ = [NSString stringWithFormat:@"%@", [AppUtils randomStringWithLength:10]];
    
    XMPPIQ *iq = [[XMPPIQ alloc] initWithType:@"get"];
    [iq addAttributeWithName:@"id" stringValue:idIQ];
    [iq addAttributeWithName:@"from" stringValue:appDelegate.myBuddy.accountName];
    [iq addAttributeWithName:@"to" stringValue:strAccount];
    
    NSXMLElement *query = [NSXMLElement elementWithName:@"vCard" xmlns:@"vcard-temp"];
    [iq addChild: query];
    [appDelegate.xmppStream sendElement: iq];
}

- (void)sendMessageImageForGroup: (NSString *)roomName withLinkImage: (NSString *)link andDescription: (NSString *)caption andIdMessage: (NSString *)idMessage
{
    XMPPMessage *message = [[XMPPMessage alloc] init];
    [message addAttributeWithName:@"xmlns" stringValue:@"jabber:client"];
    [message addAttributeWithName:@"id" stringValue: idMessage];
    NSString *toStr = [NSString stringWithFormat:@"%@@%@", roomName, xmpp_cloudfone_group];
    [message addAttributeWithName:@"to" stringValue: toStr];
    
    NSString *fromStr = [NSString stringWithFormat:@"%@@%@", USERNAME, xmpp_cloudfone];
    [message addAttributeWithName:@"from" stringValue: fromStr];
    
    [message addAttributeWithName:@"type" stringValue: group_chat];
    
    //  XMPPElement *body = [XMPPElement elementWithName:@"body" stringValue: @"groupimage"];
    XMPPElement *body = [XMPPElement elementWithName:@"body" stringValue: link];
    [message addChild: body];
    
    XMPPElement *metadata = [XMPPElement elementWithName:@"metadata"];
    XMPPElement *typeMetadata = [XMPPElement elementWithName:@"type" stringValue:@"groupimage"];
    XMPPElement *filesizeMetadata = [XMPPElement elementWithName:@"filesize" stringValue:@"0"];
    XMPPElement *imageurlMetadata = [XMPPElement elementWithName:@"imageurl" stringValue:link];
    XMPPElement *descMetadata = [XMPPElement elementWithName:@"description" stringValue:caption];
    
    [metadata addChild: typeMetadata];
    [metadata addChild: filesizeMetadata];
    [metadata addChild: imageurlMetadata];
    [metadata addChild: descMetadata];
    
    [message addChild: metadata];
    
    [appDelegate.xmppStream sendElement: message];
}

- (void)sendMessageMediaForUser: (NSString *)username withLinkImage: (NSString *)link andDescription: (NSString *)caption andIdMessage: (NSString *)idMessage andType: (NSString *)type withBurn: (int)burn forGroup: (BOOL)isGroup
{
    XMPPMessage *message = [[XMPPMessage alloc] init];
    [message addAttributeWithName:@"xmlns" stringValue:@"jabber:client"];
    [message addAttributeWithName:@"id" stringValue: idMessage];
    if (!isGroup) {
        NSString *toStr = [NSString stringWithFormat:@"%@@%@", username, xmpp_cloudfone];
        [message addAttributeWithName:@"to" stringValue: toStr];
        [message addAttributeWithName:@"type" stringValue: @"chat"];
    }else{
        NSString *toStr = [NSString stringWithFormat:@"%@@%@", username, xmpp_cloudfone_group];
        [message addAttributeWithName:@"to" stringValue: toStr];
        [message addAttributeWithName:@"type" stringValue: @"groupchat"];
    }
    
    NSXMLElement *request = [NSXMLElement elementWithName:@"request"];
    [request addAttributeWithName:@"xmlns" stringValue:@"urn:xmpp:receipts"];
    [message addChild: request];
    
    NSString *fromStr = [NSString stringWithFormat:@"%@@%@", USERNAME, xmpp_cloudfone];
    [message addAttributeWithName:@"from" stringValue: fromStr];
    
    //  XMPPElement *body = [XMPPElement elementWithName:@"body" stringValue: @"groupimage"];
    XMPPElement *body = [XMPPElement elementWithName:@"body" stringValue: link];
    [message addChild: body];
    
    XMPPElement *metadata = [XMPPElement elementWithName:@"metadata"];
    XMPPElement *typeMetadata = [XMPPElement elementWithName:@"type" stringValue:type];
    XMPPElement *filesizeMetadata = [XMPPElement elementWithName:@"filesize" stringValue:@"0"];
    XMPPElement *imageurlMetadata = [XMPPElement elementWithName:@"imageurl" stringValue:link];
    XMPPElement *descMetadata = [XMPPElement elementWithName:@"description" stringValue:caption];
    
    //  burn message
    int burnMessage = [AppUtils getBurnMessageValueOfRemoteParty: username];
    
    NSString *strBurn = [NSString stringWithFormat:@"%d", burnMessage];
    NSXMLElement *query = [NSXMLElement elementWithName:@"x" xmlns:@"jabber:x:burn"];
    [query addAttributeWithName:@"burn" stringValue: strBurn];
    [message addChild: query];
    
    [metadata addChild: typeMetadata];
    [metadata addChild: filesizeMetadata];
    [metadata addChild: imageurlMetadata];
    [metadata addChild: descMetadata];
    
    [message addChild: metadata];
    
    [appDelegate.xmppStream sendElement: message];
}

//  Download picture from server
- (void)downloadImageFromServerWithName: (NSString *)imageName andIdMessage: (NSString *)idMessage {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSString *strURL = [NSString stringWithFormat:@"%@/%@", link_picutre_chat_group, imageName];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString: strURL]];
        if (data != nil) {
            UIImage *image = [UIImage imageWithData: data];
            NSArray *fileNameArr = [AppUtils saveImageToFiles:image withImage:imageName];
            if (fileNameArr.count >= 2) {
                NSString *detailURL = [fileNameArr objectAtIndex: 0];
                NSString *thumbURL = [fileNameArr objectAtIndex: 1];
                
                [NSDatabase updateMessage:idMessage withImageName:detailURL andThumbnail:thumbURL];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadPictureFinish" object:idMessage];
        });

    });
}

- (void)sendDisplayedToUser: (NSString *)toUser fromUser: (NSString *)fromUser andListIdMsg: (NSString *)listIdMsg
{
    NSXMLElement *displayMessage = [NSXMLElement elementWithName:@"message" xmlns:@"jabber:client"];
    [displayMessage addAttributeWithName:@"type" stringValue:@"chat"];
    [displayMessage addAttributeWithName:@"id" stringValue:[AppUtils randomStringWithLength: 10]];
    NSString *toStr = [NSString stringWithFormat:@"%@@%@", toUser, xmpp_cloudfone];
    [displayMessage addAttributeWithName:@"to" stringValue: toStr];
    
    NSString *fromStr = [NSString stringWithFormat:@"%@@%@", fromUser, xmpp_cloudfone];
    [displayMessage addAttributeWithName:@"from" stringValue: fromStr];
    
    NSXMLElement *x = [NSXMLElement elementWithName:@"x" xmlns:@"jabber:x:displayed"];
    [x addAttributeWithName:@"listid" stringValue:listIdMsg];
    
    [displayMessage addChild: x];
    
    [appDelegate.xmppStream sendElement: displayMessage];
}

#pragma mark - Khai Le functions

- (void)updateMessageSeenWithList: (NSString *)listId {
    NSArray *tmpArr = [listId componentsSeparatedByString:@"|"];
    for (int iCount=0; iCount<tmpArr.count; iCount++) {
        NSString *idMessage = [tmpArr objectAtIndex: iCount];
        [NSDatabase updateSeenStatusForMessage: idMessage];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateSeenStatusForMessage"
                                                        object:tmpArr];
}

- (void)getGroupDataFromServer
{
    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:private"];
    NSXMLElement *groups = [NSXMLElement elementWithName:@"groups" xmlns:@"cloudfone/rooms"];
    [query addChild:groups];
    XMPPIQ *iq = [XMPPIQ iqWithType:@"get" elementID:@"1002" child:query];
    [appDelegate.xmppStream sendElement:iq];
}

- (void)storeGroupDataToServer:(NSString *)groups
{
    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:private"];
    NSXMLElement *groupsE = [NSXMLElement elementWithName:@"groups" xmlns:@"cloudfone/rooms"];
    NSXMLElement *body = [NSXMLElement elementWithName:@"ids"];
    [body setStringValue:groups];
    [groupsE addChild:body];
    [query addChild:groupsE];
    XMPPIQ *iq = [XMPPIQ iqWithType:@"set" elementID:@"1001" child:query];
    XMPPStream* _xmppStream = appDelegate.xmppStream;
    dispatch_queue_t bgQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(bgQueue, ^{
        [_xmppStream sendElement:iq];
    });
}

@end
