//
//  BaseFarm-Prefix.h
//  LetterFarm
//
//  Created by Daniel Mueller on 4/3/13.
//
//

//
// Prefix header for all source files of the 'Letter Farm' target in the 'Letter Farm' project
//

#import <Availability.h>

#ifndef __IPHONE_4_0
#warning "This project uses features only available in iOS SDK 4.0 and later."
#endif

#ifdef __OBJC__
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#endif

#define PROPERTY_IF_RESPONDS(object, getter) ([object respondsToSelector:@selector(getter)] ? [object performSelector:@selector(getter)] : nil)

#define OBJECT_AT_INDEX_IF_OF_CLASS(array, index, objectClass) (OBJECT_IF_OF_CLASS( (0 < [array count] ? [array objectAtIndex:index] : nil), objectClass))

#define OBJECT_IF_OF_CLASS(object, objectClass) ([object isKindOfClass:[objectClass class]] ? (id)object : nil)
#define OBJECT_IF_OF_PROTOCOL(object, objectProtocol) ([object conformsToProtocol:@protocol(objectProtocol)] ? (id)object : nil)

#undef USE_FAKE_APPLE_ID

#define ENABLE_TESTFLIGHT 1
#define DISABLE_FB
#define DISABLE_EMAIL

#ifdef DEBUG
#define TESTING_APPSTORE 1
#define USE_FAKE_APPLE_ID 1
#define ENABLE_RESET_PURCHASES 1
#endif


#ifdef ADHOC
#define DISABLE_GK
#define ENABLE_RESET_PURCHASES 1
#endif

#ifdef RELEASE
#undef ENABLE_RESET_PURCHASES
#undef ENABLE_TESTFLIGHT
#endif

#if TARGET_IPHONE_SIMULATOR
#undef ENABLE_TESTFLIGHT
#endif
