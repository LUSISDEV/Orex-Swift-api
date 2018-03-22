// Generated by Apple Swift version 4.0.3 (swiftlang-900.0.74.1 clang-900.0.39.2)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgcc-compat"

#if !defined(__has_include)
# define __has_include(x) 0
#endif
#if !defined(__has_attribute)
# define __has_attribute(x) 0
#endif
#if !defined(__has_feature)
# define __has_feature(x) 0
#endif
#if !defined(__has_warning)
# define __has_warning(x) 0
#endif

#if __has_attribute(external_source_symbol)
# define SWIFT_STRINGIFY(str) #str
# define SWIFT_MODULE_NAMESPACE_PUSH(module_name) _Pragma(SWIFT_STRINGIFY(clang attribute push(__attribute__((external_source_symbol(language="Swift", defined_in=module_name, generated_declaration))), apply_to=any(function, enum, objc_interface, objc_category, objc_protocol))))
# define SWIFT_MODULE_NAMESPACE_POP _Pragma("clang attribute pop")
#else
# define SWIFT_MODULE_NAMESPACE_PUSH(module_name)
# define SWIFT_MODULE_NAMESPACE_POP
#endif

#if __has_include(<swift/objc-prologue.h>)
# include <swift/objc-prologue.h>
#endif

#pragma clang diagnostic ignored "-Wauto-import"
#include <objc/NSObject.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

#if !defined(SWIFT_TYPEDEFS)
# define SWIFT_TYPEDEFS 1
# if __has_include(<uchar.h>)
#  include <uchar.h>
# elif !defined(__cplusplus) || __cplusplus < 201103L
typedef uint_least16_t char16_t;
typedef uint_least32_t char32_t;
# endif
typedef float swift_float2  __attribute__((__ext_vector_type__(2)));
typedef float swift_float3  __attribute__((__ext_vector_type__(3)));
typedef float swift_float4  __attribute__((__ext_vector_type__(4)));
typedef double swift_double2  __attribute__((__ext_vector_type__(2)));
typedef double swift_double3  __attribute__((__ext_vector_type__(3)));
typedef double swift_double4  __attribute__((__ext_vector_type__(4)));
typedef int swift_int2  __attribute__((__ext_vector_type__(2)));
typedef int swift_int3  __attribute__((__ext_vector_type__(3)));
typedef int swift_int4  __attribute__((__ext_vector_type__(4)));
typedef unsigned int swift_uint2  __attribute__((__ext_vector_type__(2)));
typedef unsigned int swift_uint3  __attribute__((__ext_vector_type__(3)));
typedef unsigned int swift_uint4  __attribute__((__ext_vector_type__(4)));
#endif

#if !defined(SWIFT_PASTE)
# define SWIFT_PASTE_HELPER(x, y) x##y
# define SWIFT_PASTE(x, y) SWIFT_PASTE_HELPER(x, y)
#endif
#if !defined(SWIFT_METATYPE)
# define SWIFT_METATYPE(X) Class
#endif
#if !defined(SWIFT_CLASS_PROPERTY)
# if __has_feature(objc_class_property)
#  define SWIFT_CLASS_PROPERTY(...) __VA_ARGS__
# else
#  define SWIFT_CLASS_PROPERTY(...)
# endif
#endif

#if __has_attribute(objc_runtime_name)
# define SWIFT_RUNTIME_NAME(X) __attribute__((objc_runtime_name(X)))
#else
# define SWIFT_RUNTIME_NAME(X)
#endif
#if __has_attribute(swift_name)
# define SWIFT_COMPILE_NAME(X) __attribute__((swift_name(X)))
#else
# define SWIFT_COMPILE_NAME(X)
#endif
#if __has_attribute(objc_method_family)
# define SWIFT_METHOD_FAMILY(X) __attribute__((objc_method_family(X)))
#else
# define SWIFT_METHOD_FAMILY(X)
#endif
#if __has_attribute(noescape)
# define SWIFT_NOESCAPE __attribute__((noescape))
#else
# define SWIFT_NOESCAPE
#endif
#if __has_attribute(warn_unused_result)
# define SWIFT_WARN_UNUSED_RESULT __attribute__((warn_unused_result))
#else
# define SWIFT_WARN_UNUSED_RESULT
#endif
#if __has_attribute(noreturn)
# define SWIFT_NORETURN __attribute__((noreturn))
#else
# define SWIFT_NORETURN
#endif
#if !defined(SWIFT_CLASS_EXTRA)
# define SWIFT_CLASS_EXTRA
#endif
#if !defined(SWIFT_PROTOCOL_EXTRA)
# define SWIFT_PROTOCOL_EXTRA
#endif
#if !defined(SWIFT_ENUM_EXTRA)
# define SWIFT_ENUM_EXTRA
#endif
#if !defined(SWIFT_CLASS)
# if __has_attribute(objc_subclassing_restricted)
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# else
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# endif
#endif

#if !defined(SWIFT_PROTOCOL)
# define SWIFT_PROTOCOL(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
# define SWIFT_PROTOCOL_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
#endif

#if !defined(SWIFT_EXTENSION)
# define SWIFT_EXTENSION(M) SWIFT_PASTE(M##_Swift_, __LINE__)
#endif

#if !defined(OBJC_DESIGNATED_INITIALIZER)
# if __has_attribute(objc_designated_initializer)
#  define OBJC_DESIGNATED_INITIALIZER __attribute__((objc_designated_initializer))
# else
#  define OBJC_DESIGNATED_INITIALIZER
# endif
#endif
#if !defined(SWIFT_ENUM_ATTR)
# if defined(__has_attribute) && __has_attribute(enum_extensibility)
#  define SWIFT_ENUM_ATTR __attribute__((enum_extensibility(open)))
# else
#  define SWIFT_ENUM_ATTR
# endif
#endif
#if !defined(SWIFT_ENUM)
# define SWIFT_ENUM(_type, _name) enum _name : _type _name; enum SWIFT_ENUM_ATTR SWIFT_ENUM_EXTRA _name : _type
# if __has_feature(generalized_swift_name)
#  define SWIFT_ENUM_NAMED(_type, _name, SWIFT_NAME) enum _name : _type _name SWIFT_COMPILE_NAME(SWIFT_NAME); enum SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_ENUM_ATTR SWIFT_ENUM_EXTRA _name : _type
# else
#  define SWIFT_ENUM_NAMED(_type, _name, SWIFT_NAME) SWIFT_ENUM(_type, _name)
# endif
#endif
#if !defined(SWIFT_UNAVAILABLE)
# define SWIFT_UNAVAILABLE __attribute__((unavailable))
#endif
#if !defined(SWIFT_UNAVAILABLE_MSG)
# define SWIFT_UNAVAILABLE_MSG(msg) __attribute__((unavailable(msg)))
#endif
#if !defined(SWIFT_AVAILABILITY)
# define SWIFT_AVAILABILITY(plat, ...) __attribute__((availability(plat, __VA_ARGS__)))
#endif
#if !defined(SWIFT_DEPRECATED)
# define SWIFT_DEPRECATED __attribute__((deprecated))
#endif
#if !defined(SWIFT_DEPRECATED_MSG)
# define SWIFT_DEPRECATED_MSG(...) __attribute__((deprecated(__VA_ARGS__)))
#endif
#if __has_feature(attribute_diagnose_if_objc)
# define SWIFT_DEPRECATED_OBJC(Msg) __attribute__((diagnose_if(1, Msg, "warning")))
#else
# define SWIFT_DEPRECATED_OBJC(Msg) SWIFT_DEPRECATED_MSG(Msg)
#endif
#if __has_feature(modules)
@import ObjectiveC;
@import Foundation;
@import Dispatch;
#endif

#pragma clang diagnostic ignored "-Wproperty-attribute-mismatch"
#pragma clang diagnostic ignored "-Wduplicate-method-arg"
#if __has_warning("-Wpragma-clang-attribute")
# pragma clang diagnostic ignored "-Wpragma-clang-attribute"
#endif
#pragma clang diagnostic ignored "-Wunknown-pragmas"
#pragma clang diagnostic ignored "-Wnullability"

SWIFT_MODULE_NAMESPACE_PUSH("SwiftWebSocket")
enum WebSocketReadyState : NSInteger;

/// WebSocket objects are bidirectional network streams that communicate over HTTP. RFC 6455.
SWIFT_CLASS("_TtC14SwiftWebSocket9WebSocket")
@interface WebSocket : NSObject
@property (nonatomic, readonly) NSInteger hashValue;
/// Create a WebSocket connection to a URL; this should be the URL to which the WebSocket server will respond.
- (nonnull instancetype)init:(NSString * _Nonnull)url SWIFT_DEPRECATED_OBJC("Swift initializer 'WebSocket.init(_:)' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Create a WebSocket connection to a URL; this should be the URL to which the WebSocket server will respond.
- (nonnull instancetype)initWithUrl:(NSURL * _Nonnull)url SWIFT_DEPRECATED_OBJC("Swift initializer 'WebSocket.init(url:)' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Create a WebSocket connection to a URL; this should be the URL to which the WebSocket server will respond. Also include a list of protocols.
- (nonnull instancetype)init:(NSString * _Nonnull)url subProtocols:(NSArray<NSString *> * _Nonnull)subProtocols SWIFT_DEPRECATED_OBJC("Swift initializer 'WebSocket.init(_:subProtocols:)' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Create a WebSocket connection to a URL; this should be the URL to which the WebSocket server will respond. Also include a protocol.
- (nonnull instancetype)init:(NSString * _Nonnull)url subProtocol:(NSString * _Nonnull)subProtocol SWIFT_DEPRECATED_OBJC("Swift initializer 'WebSocket.init(_:subProtocol:)' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Create a WebSocket connection from an NSURLRequest; Also include a list of protocols.
- (nonnull instancetype)initWithRequest:(NSURLRequest * _Nonnull)request subProtocols:(NSArray<NSString *> * _Nonnull)subProtocols OBJC_DESIGNATED_INITIALIZER SWIFT_DEPRECATED_OBJC("Swift initializer 'WebSocket.init(request:subProtocols:)' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Create a WebSocket object with a deferred connection; the connection is not opened until the .open() method is called.
- (nonnull instancetype)init;
/// The URL as resolved by the constructor. This is always an absolute URL. Read only.
@property (nonatomic, readonly, copy) NSString * _Nonnull url SWIFT_DEPRECATED_OBJC("Swift property 'WebSocket.url' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// A string indicating the name of the sub-protocol the server selected; this will be one of the strings specified in the protocols parameter when creating the WebSocket object.
@property (nonatomic, readonly, copy) NSString * _Nonnull subProtocol SWIFT_DEPRECATED_OBJC("Swift property 'WebSocket.subProtocol' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Allow for Self-Signed SSL Certificates. Default is false.
@property (nonatomic) BOOL allowSelfSignedSSL SWIFT_DEPRECATED_OBJC("Swift property 'WebSocket.allowSelfSignedSSL' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// The queue for firing off events. default is main_queue
@property (nonatomic, strong) dispatch_queue_t _Nullable eventQueue SWIFT_DEPRECATED_OBJC("Swift property 'WebSocket.eventQueue' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// The current state of the connection; this is one of the WebSocketReadyState constants. Read only.
@property (nonatomic, readonly) enum WebSocketReadyState readyState SWIFT_DEPRECATED_OBJC("Swift property 'WebSocket.readyState' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Opens a deferred or closed WebSocket connection to a URL; this should be the URL to which the WebSocket server will respond.
- (void)open:(NSString * _Nonnull)url SWIFT_DEPRECATED_OBJC("Swift method 'WebSocket.open(_:)' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Opens a deferred or closed WebSocket connection to a URL; this should be the URL to which the WebSocket server will respond.
- (void)openWithNsurl:(NSURL * _Nonnull)url SWIFT_DEPRECATED_OBJC("Swift method 'WebSocket.open(nsurl:)' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Opens a deferred or closed WebSocket connection to a URL; this should be the URL to which the WebSocket server will respond. Also include a list of protocols.
- (void)open:(NSString * _Nonnull)url subProtocols:(NSArray<NSString *> * _Nonnull)subProtocols SWIFT_DEPRECATED_OBJC("Swift method 'WebSocket.open(_:subProtocols:)' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Opens a deferred or closed WebSocket connection to a URL; this should be the URL to which the WebSocket server will respond. Also include a protocol.
- (void)open:(NSString * _Nonnull)url subProtocol:(NSString * _Nonnull)subProtocol SWIFT_DEPRECATED_OBJC("Swift method 'WebSocket.open(_:subProtocol:)' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Opens a deferred or closed WebSocket connection from an NSURLRequest; Also include a list of protocols.
- (void)openWithRequest:(NSURLRequest * _Nonnull)request subProtocols:(NSArray<NSString *> * _Nonnull)subProtocols SWIFT_DEPRECATED_OBJC("Swift method 'WebSocket.open(request:subProtocols:)' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Opens a closed WebSocket connection from an NSURLRequest; Uses the same request and protocols as previously closed WebSocket
- (void)open SWIFT_DEPRECATED_OBJC("Swift method 'WebSocket.open()' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Closes the WebSocket connection or connection attempt, if any. If the connection is already closed or in the state of closing, this method does nothing.
/// :param: code An integer indicating the status code explaining why the connection is being closed. If this parameter is not specified, a default value of 1000 (indicating a normal closure) is assumed.
/// :param: reason A human-readable string explaining why the connection is closing. This string must be no longer than 123 bytes of UTF-8 text (not characters).
- (void)close:(NSInteger)code reason:(NSString * _Nonnull)reason SWIFT_DEPRECATED_OBJC("Swift method 'WebSocket.close(_:reason:)' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Transmits message to the server over the WebSocket connection.
/// :param: message The message to be sent to the server.
- (void)send:(id _Nonnull)message SWIFT_DEPRECATED_OBJC("Swift method 'WebSocket.send(_:)' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Transmits a ping to the server over the WebSocket connection.
/// :param: optional message The data to be sent to the server.
- (void)ping:(id _Nonnull)message SWIFT_DEPRECATED_OBJC("Swift method 'WebSocket.ping(_:)' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Transmits a ping to the server over the WebSocket connection.
- (void)ping SWIFT_DEPRECATED_OBJC("Swift method 'WebSocket.ping()' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
@end

@protocol WebSocketDelegate;

@interface WebSocket (SWIFT_EXTENSION(SwiftWebSocket))
/// The events of the WebSocket using a delegate.
@property (nonatomic, strong) id <WebSocketDelegate> _Nullable delegate SWIFT_DEPRECATED_OBJC("Swift property 'WebSocket.delegate' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Transmits message to the server over the WebSocket connection.
/// :param: text The message (string) to be sent to the server.
- (void)sendWithText:(NSString * _Nonnull)text;
/// Transmits message to the server over the WebSocket connection.
/// :param: data The message (binary) to be sent to the server.
- (void)sendWithData:(NSData * _Nonnull)data;
@end

@class NSError;

/// WebSocketDelegate is an Objective-C alternative to WebSocketEvents and is used to delegate the events for the WebSocket connection.
SWIFT_PROTOCOL("_TtP14SwiftWebSocket17WebSocketDelegate_")
@protocol WebSocketDelegate
/// A function to be called when the WebSocket connection’s readyState changes to .Open; this indicates that the connection is ready to send and receive data.
- (void)webSocketOpen;
/// A function to be called when the WebSocket connection’s readyState changes to .Closed.
- (void)webSocketClose:(NSInteger)code reason:(NSString * _Nonnull)reason wasClean:(BOOL)wasClean;
/// A function to be called when an error occurs.
- (void)webSocketError:(NSError * _Nonnull)error;
@optional
/// A function to be called when a message (string) is received from the server.
- (void)webSocketMessageText:(NSString * _Nonnull)text;
/// A function to be called when a message (binary) is received from the server.
- (void)webSocketMessageData:(NSData * _Nonnull)data;
/// A function to be called when a pong is received from the server.
- (void)webSocketPong;
/// A function to be called when the WebSocket process has ended; this event is guarenteed to be called once and can be used as an alternative to the “close” or “error” events.
- (void)webSocketEnd:(NSInteger)code reason:(NSString * _Nonnull)reason wasClean:(BOOL)wasClean error:(NSError * _Nullable)error;
@end

/// The WebSocketReadyState enum is used by the readyState property to describe the status of the WebSocket connection.
typedef SWIFT_ENUM(NSInteger, WebSocketReadyState) {
/// The connection is not yet open.
  WebSocketReadyStateConnecting = 0,
/// The connection is open and ready to communicate.
  WebSocketReadyStateOpen = 1,
/// The connection is in the process of closing.
  WebSocketReadyStateClosing = 2,
/// The connection is closed or couldn’t be opened.
  WebSocketReadyStateClosed = 3,
};

SWIFT_MODULE_NAMESPACE_POP
#pragma clang diagnostic pop
