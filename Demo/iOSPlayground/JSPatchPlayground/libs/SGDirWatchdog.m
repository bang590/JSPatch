//
//  SGDirObserver.m
//  DirectoryObserver
//
//  Copyright (c) 2011 Simon Grätzer.
//

#import "SGDirWatchdog.h"
#import <fcntl.h>
#import <unistd.h>
#import <sys/event.h>

@interface SGDirWatchdog ()
@property (nonatomic, readonly) CFFileDescriptorRef kqRef;
- (void)kqueueFired;
@end


static void KQCallback(CFFileDescriptorRef kqRef, CFOptionFlags callBackTypes, void *info) {
	// Pick up the object passed in the "info" member of the CFFileDescriptorContext passed to CFFileDescriptorCreate
    SGDirWatchdog* obj = (__bridge SGDirWatchdog*) info;
	
	if ([obj isKindOfClass:[SGDirWatchdog class]]		&&	// If we can call back to the proper sort of object ...
		(kqRef == obj.kqRef)								&&	// and the FD that issued the CB is the expected one ...
		(callBackTypes == kCFFileDescriptorReadCallBack)	)	// and we're processing the proper sort of CB ...
	{
		[obj kqueueFired];										// Invoke the instance's CB handler
	}
}

@implementation SGDirWatchdog {
    int					_dirFD;
    CFFileDescriptorRef _kqRef;
}

+ (NSString *)documentsPath {
	NSArray *documentsPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
	return documentsPaths[0]; // Path to the application's "Documents" directory
}

+ (id)watchtdogOnDocumentsDir:(void (^)(void))update; {
    return [[SGDirWatchdog alloc]initWithPath:[self documentsPath] update:update];
}


- (id)initWithPath:(NSString *)path update:(void (^)(void))update; {
    if ((self = [super init])) {
        _path = path;
        _update = [update copy];
    }
    return self;
}

- (void)dealloc {
    [self stop];
    
    
}

#pragma mark -
#pragma mark Extension methods

- (void)kqueueFired {
	// Pull the native FD around which the CFFileDescriptor was wrapped
    int kq = CFFileDescriptorGetNativeDescriptor(_kqRef);
	if (kq < 0) return;
	
	// If we pull a single available event out of the queue, assume the directory was updated
    struct kevent event;
    struct timespec timeout = {0, 0};
    if (kevent(kq, NULL, 0, &event, 1, &timeout) == 1 && _update) {
		_update();
    }    
	
	// (Re-)Enable a one-shot (the only kind) callback
    CFFileDescriptorEnableCallBacks(_kqRef, kCFFileDescriptorReadCallBack);
}


- (void)start {
	// One ping only
    if (_kqRef != NULL) return;
	
	// Fetch pathname of the directory to monitor
	NSString* docPath = self.path;
	if (!docPath) return;
    
	// Open an event-only file descriptor associated with the directory
    int dirFD = open([docPath fileSystemRepresentation], O_EVTONLY);
	if (dirFD < 0) return;
	
	// Create a new kernel event queue
    int kq = kqueue();
	if (kq < 0)
	{
		close(dirFD);
		return;
	}
    
	// Set up a kevent to monitor
    struct kevent eventToAdd;					// Register an (ident, filter) pair with the kqueue
    eventToAdd.ident  = dirFD;					// The object to watch (the directory FD)
    eventToAdd.filter = EVFILT_VNODE;			// Watch for certain events on the VNODE spec'd by ident
    eventToAdd.flags  = EV_ADD | EV_CLEAR;		// Add a resetting kevent
    eventToAdd.fflags = NOTE_WRITE;				// The events to watch for on the VNODE spec'd by ident (writes)
    eventToAdd.data   = 0;						// No filter-specific data
    eventToAdd.udata  = NULL;					// No user data
    
	// Add a kevent to monitor 
	if (kevent(kq, &eventToAdd, 1, NULL, 0, NULL)) {
		close(kq);
		close(dirFD);
		return;
	}
	
	// Wrap a CFFileDescriptor around a native FD
	CFFileDescriptorContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    _kqRef = CFFileDescriptorCreate(NULL,		// Use the default allocator
									kq,			// Wrap the kqueue
									true,		// Close the CFFileDescriptor if kq is invalidated
									KQCallback,	// Fxn to call on activity
									&context);	// Supply a context to set the callback's "info" argument
    if (_kqRef == NULL) {
		close(kq);
		close(dirFD);
		return;
	}
	
	// Spin out a pluggable run loop source from the CFFileDescriptorRef
	// Add it to the current run loop, then release it
    CFRunLoopSourceRef rls = CFFileDescriptorCreateRunLoopSource(NULL, _kqRef, 0);
    if (rls == NULL) {
		CFRelease(_kqRef); _kqRef = NULL;
		close(kq);
		close(dirFD);
		return;
	}
    CFRunLoopAddSource(CFRunLoopGetCurrent(), rls, kCFRunLoopDefaultMode);
    CFRelease(rls);
    
	// Store the directory FD for later closing
	_dirFD = dirFD;
	
	// Enable a one-shot (the only kind) callback
    CFFileDescriptorEnableCallBacks(_kqRef, kCFFileDescriptorReadCallBack);
}

- (void)stop {
	if (_kqRef) {
		close(_dirFD);
		CFFileDescriptorInvalidate(_kqRef);
		CFRelease(_kqRef);
		_kqRef = NULL;
	}
}

@end
