//
//  STAssertsEqualStrings.h
//  LetterFarm
//
//  Created by Daniel Mueller on 4/4/13.
//
//

#define STAssertEqualStrings(a1, a2, description, ...) \
do { \
@try {\
NSString* a1string = (a1); \
NSString* a2string = (a2); \
if (a1string != a2string) { \
if ( [a1string isEqualToString:a2string] ) continue; \
[self failWithException:([NSException failureInEqualityBetweenObject:a1string \
andObject:a2string \
inFile:[NSString stringWithUTF8String:__FILE__] \
atLine:__LINE__ \
withDescription:@"%@", STComposeString(description, ##__VA_ARGS__)])]; \
} \
}\
@catch (id anException) {\
[self failWithException:([NSException failureInRaise:[NSString stringWithFormat:@"(%s) == (%s)", #a1, #a2] \
exception:anException \
inFile:[NSString stringWithUTF8String:__FILE__] \
atLine:__LINE__ \
withDescription:@"%@", STComposeString(description, ##__VA_ARGS__)])]; \
}\
} while(0)

