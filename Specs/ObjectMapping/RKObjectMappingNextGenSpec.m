//
//  RKObjectMappingNextGenSpec.m
//  RestKit
//
//  Created by Blake Watters on 4/30/11.
//  Copyright 2011 Two Toasters
//  
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//  
//  http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <OCMock/OCMock.h>
#import <OCMock/NSNotificationCenter+OCMAdditions.h>
#import "RKSpecEnvironment.h"
#import "RKObjectMapping.h"
#import "RKObjectMappingOperation.h"
#import "RKObjectAttributeMapping.h"
#import "RKObjectRelationshipMapping.h"
#import "RKLog.h"
#import "RKObjectMapper.h"
#import "RKObjectMapper_Private.h"
#import "RKObjectMapperError.h"
#import "RKDynamicMappingModels.h"
#import "RKSpecAddress.h"
#import "RKSpecUser.h"
#import "RKHuman.h"
#import "RKCat.h"

@interface RKExampleGroupWithUserArray : NSObject {
    NSString * _name;
    NSArray* _users;
}

@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSArray* users;

@end

@implementation RKExampleGroupWithUserArray

@synthesize name = _name;
@synthesize users = _users;

+ (RKExampleGroupWithUserArray*)group {
    return [[self new] autorelease];
}

// isEqual: is consulted by the mapping operation
// to determine if assocation values should be set
- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[RKExampleGroupWithUserArray class]]) {
        return [[(RKExampleGroupWithUserArray*)object name] isEqualToString:self.name];
    } else {
        return NO;
    }
}

@end

@interface RKExampleGroupWithUserSet : NSObject {
    NSString * _name;
    NSSet* _users;
}

@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSSet* users;

@end

@implementation RKExampleGroupWithUserSet

@synthesize name = _name;
@synthesize users = _users;

+ (RKExampleGroupWithUserSet*)group {
    return [[self new] autorelease];
}

// isEqual: is consulted by the mapping operation
// to determine if assocation values should be set
- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[RKExampleGroupWithUserSet class]]) {
        return [[(RKExampleGroupWithUserSet*)object name] isEqualToString:self.name];
    } else {
        return NO;
    }
}

@end

////////////////////////////////////////////////////////////////////////////////

#pragma mark -

@interface RKObjectMappingNextGenSpec : RKSpec {
    
}

@end

@implementation RKObjectMappingNextGenSpec

#pragma mark - RKObjectKeyPathMapping Specs

- (void)itShouldDefineElementToPropertyMapping {
    RKObjectAttributeMapping* elementMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"id" toKeyPath:@"userID"];
    [expectThat(elementMapping.sourceKeyPath) should:be(@"id")];
    [expectThat(elementMapping.destinationKeyPath) should:be(@"userID")];
}

- (void)itShouldDescribeElementMappings {
    RKObjectAttributeMapping* elementMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"id" toKeyPath:@"userID"];
    [expectThat([elementMapping description]) should:be(@"RKObjectKeyPathMapping: id => userID")];
}

#pragma mark - RKObjectMapping Specs

- (void)itShouldDefineMappingFromAnElementToAProperty {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    RKObjectAttributeMapping* idMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"id" toKeyPath:@"userID"];
    [mapping addAttributeMapping:idMapping];
    assertThat([mapping mappingForKeyPath:@"id"], is(sameInstance(idMapping)));
}

- (void)itShouldAddMappingsToAttributeMappings {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    RKObjectAttributeMapping* idMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"id" toKeyPath:@"userID"];
    [mapping addAttributeMapping:idMapping];
    [expectThat([mapping.mappings containsObject:idMapping]) should:be(YES)];
    [expectThat([mapping.attributeMappings containsObject:idMapping]) should:be(YES)];
}

- (void)itShouldAddMappingsToRelationshipMappings {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    RKObjectRelationshipMapping* idMapping = [RKObjectRelationshipMapping mappingFromKeyPath:@"id" toKeyPath:@"userID" withMapping:nil];
    [mapping addRelationshipMapping:idMapping];
    [expectThat([mapping.mappings containsObject:idMapping]) should:be(YES)];
    [expectThat([mapping.relationshipMappings containsObject:idMapping]) should:be(YES)];
}

- (void)itShouldGenerateAttributeMappings {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    assertThat([mapping mappingForKeyPath:@"name"], is(nilValue()));
    [mapping mapKeyPath:@"name" toAttribute:@"name"];
    assertThat([mapping mappingForKeyPath:@"name"], isNot(nilValue()));
}

- (void)itShouldGenerateRelationshipMappings {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    RKObjectMapping* anotherMapping = [RKObjectMapping mappingForClass:[NSDictionary class]];
    assertThat([mapping mappingForKeyPath:@"another"], is(nilValue()));
    [mapping mapRelationship:@"another" withMapping:anotherMapping];
    assertThat([mapping mappingForKeyPath:@"another"], isNot(nilValue()));
}

- (void)itShouldRemoveMappings {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    RKObjectAttributeMapping* idMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"id" toKeyPath:@"userID"];
    [mapping addAttributeMapping:idMapping];
    assertThat(mapping.mappings, hasItem(idMapping));
    [mapping removeMapping:idMapping];
    assertThat(mapping.mappings, isNot(hasItem(idMapping)));
}

- (void)itShouldRemoveMappingsByKeyPath {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    RKObjectAttributeMapping* idMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"id" toKeyPath:@"userID"];
    [mapping addAttributeMapping:idMapping];
    assertThat(mapping.mappings, hasItem(idMapping));
    [mapping removeMappingForKeyPath:@"id"];
    assertThat(mapping.mappings, isNot(hasItem(idMapping)));
}

- (void)itShouldRemoveAllMappings {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    [mapping mapAttributes:@"one", @"two", @"three", nil];
    assertThat(mapping.mappings, hasCountOf(3));
    [mapping removeAllMappings];
    assertThat(mapping.mappings, is(empty()));
}

- (void)itShouldGenerateAnInverseMappings {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];    
    [mapping mapKeyPath:@"first_name" toAttribute:@"firstName"];
    [mapping mapAttributes:@"city", @"state", @"zip", nil];
    RKObjectMapping* otherMapping = [RKObjectMapping mappingForClass:[RKSpecAddress class]];
    [otherMapping mapAttributes:@"street", nil];
    [mapping mapRelationship:@"address" withMapping:otherMapping];
    RKObjectMapping* inverse = [mapping inverseMapping];
    assertThat(inverse.objectClass, is(equalTo([NSMutableDictionary class])));
    assertThat([inverse mappingForKeyPath:@"firstName"], isNot(nilValue()));
}

- (void)itShouldLetYouRetrieveMappingsByAttribute {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    RKObjectAttributeMapping* attributeMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"name" toKeyPath:@"nameAttribute"];
    [mapping addAttributeMapping:attributeMapping];
    assertThat([mapping mappingForAttribute:@"nameAttribute"], is(equalTo(attributeMapping)));
}

- (void)itShouldLetYouRetrieveMappingsByRelationship {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    RKObjectRelationshipMapping* relationshipMapping = [RKObjectRelationshipMapping mappingFromKeyPath:@"friend" toKeyPath:@"friendRelationship" withMapping:mapping];
    [mapping addRelationshipMapping:relationshipMapping];
    assertThat([mapping mappingForRelationship:@"friendRelationship"], is(equalTo(relationshipMapping)));
}

#pragma mark - RKObjectMapper Specs

- (void)itShouldPerformBasicMapping {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    RKObjectAttributeMapping* idMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"id" toKeyPath:@"userID"];
    [mapping addAttributeMapping:idMapping];
    RKObjectAttributeMapping* nameMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"name" toKeyPath:@"name"];
    [mapping addAttributeMapping:nameMapping];
    
    RKObjectMapper* mapper = [RKObjectMapper new];
    id userInfo = RKSpecParseFixture(@"user.json");
    RKSpecUser* user = [RKSpecUser user];
    BOOL success = [mapper mapFromObject:userInfo toObject:user atKeyPath:@"" usingMapping:mapping];
    [mapper release];
    [expectThat(success) should:be(YES)];
    [expectThat(user.userID) should:be(31337)];
    [expectThat(user.name) should:be(@"Blake Watters")];
}

- (void)itShouldMapACollectionOfSimpleObjectDictionaries {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    RKObjectAttributeMapping* idMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"id" toKeyPath:@"userID"];
    [mapping addAttributeMapping:idMapping];
    RKObjectAttributeMapping* nameMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"name" toKeyPath:@"name"];
    [mapping addAttributeMapping:nameMapping];
   
    RKObjectMapper* mapper = [RKObjectMapper new];
    id userInfo = RKSpecParseFixture(@"users.json");
    NSArray* users = [mapper mapCollection:userInfo atKeyPath:@"" usingMapping:mapping];
    [expectThat([users count]) should:be(3)];
    RKSpecUser* blake = [users objectAtIndex:0];
    [expectThat(blake.name) should:be(@"Blake Watters")];
    [mapper release];
}
                                    
- (void)itShouldDetermineTheObjectMappingByConsultingTheMappingProviderWhenThereIsATargetObject {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    RKObjectMappingProvider* provider = [[RKObjectMappingProvider new] autorelease];
    [provider setMapping:mapping forKeyPath:@""];
    id mockProvider = [OCMockObject partialMockForObject:provider];
        
    id userInfo = RKSpecParseFixture(@"user.json");
    RKObjectMapper* mapper = [RKObjectMapper mapperWithObject:userInfo mappingProvider:mockProvider];
    mapper.targetObject = [RKSpecUser user];
    [mapper performMapping];
    
    [mockProvider verify];
}

- (void)itShouldAddAnErrorWhenTheKeyPathMappingAndObjectClassDoNotAgree {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    RKObjectMappingProvider* provider = [[RKObjectMappingProvider new] autorelease];
    [provider setMapping:mapping forKeyPath:@""];
    id mockProvider = [OCMockObject partialMockForObject:provider];
    
    id userInfo = RKSpecParseFixture(@"user.json");
    RKObjectMapper* mapper = [RKObjectMapper mapperWithObject:userInfo mappingProvider:mockProvider];
    mapper.targetObject = [NSDictionary new];
    [mapper performMapping];
    [expectThat([mapper errorCount]) should:be(1)];
}

- (void)itShouldMapToATargetObject {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    RKObjectAttributeMapping* idMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"id" toKeyPath:@"userID"];
    [mapping addAttributeMapping:idMapping];
    RKObjectAttributeMapping* nameMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"name" toKeyPath:@"name"];
    [mapping addAttributeMapping:nameMapping];
    
    RKObjectMappingProvider* provider = [[RKObjectMappingProvider new] autorelease];
    [provider setMapping:mapping forKeyPath:@""];
    id mockProvider = [OCMockObject partialMockForObject:provider];
    
    id userInfo = RKSpecParseFixture(@"user.json");
    RKObjectMapper* mapper = [RKObjectMapper mapperWithObject:userInfo mappingProvider:mockProvider];
    RKSpecUser* user = [RKSpecUser user];
    mapper.targetObject = user;
    RKObjectMappingResult* result = [mapper performMapping];
    
    [mockProvider verify];
    [expectThat(result) shouldNot:be(nil)];
    [expectThat([result asObject] == user) should:be(YES)];
    [expectThat(user.name) should:be(@"Blake Watters")];
}

- (void)itShouldCreateANewInstanceOfTheAppropriateDestinationObjectWhenThereIsNoTargetObject {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    RKObjectAttributeMapping* nameMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"name" toKeyPath:@"name"];
    [mapping addAttributeMapping:nameMapping];
    
    RKObjectMappingProvider* provider = [[RKObjectMappingProvider new] autorelease];
    [provider setMapping:mapping forKeyPath:@""];
    id mockProvider = [OCMockObject partialMockForObject:provider];
    
    id userInfo = RKSpecParseFixture(@"user.json");
    RKObjectMapper* mapper = [RKObjectMapper mapperWithObject:userInfo mappingProvider:mockProvider];
    id mappingResult = [[mapper performMapping] asObject];
    [expectThat([mappingResult isKindOfClass:[RKSpecUser class]]) should:be(YES)];
}

- (void)itShouldDetermineTheMappingClassForAKeyPathByConsultingTheMappingProviderWhenMappingADictionaryWithoutATargetObject {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];        
    RKObjectMappingProvider* provider = [[RKObjectMappingProvider new] autorelease];
    [provider setMapping:mapping forKeyPath:@""];
    id mockProvider = [OCMockObject partialMockForObject:provider];
    [[mockProvider expect] mappingsByKeyPath];
        
    id userInfo = RKSpecParseFixture(@"user.json");
    RKObjectMapper* mapper = [RKObjectMapper mapperWithObject:userInfo mappingProvider:mockProvider];
    [mapper performMapping];
    [mockProvider verify];
}

- (void)itShouldMapWithoutATargetMapping {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    RKObjectAttributeMapping* idMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"id" toKeyPath:@"userID"];
    [mapping addAttributeMapping:idMapping];
    RKObjectAttributeMapping* nameMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"name" toKeyPath:@"name"];
    [mapping addAttributeMapping:nameMapping];
    
    RKObjectMappingProvider* provider = [[RKObjectMappingProvider new] autorelease];
    [provider setMapping:mapping forKeyPath:@""];
    id mockProvider = [OCMockObject partialMockForObject:provider];
    
    id userInfo = RKSpecParseFixture(@"user.json");
    RKObjectMapper* mapper = [RKObjectMapper mapperWithObject:userInfo mappingProvider:mockProvider];
    RKSpecUser* user = [[mapper performMapping] asObject];
    [expectThat([user isKindOfClass:[RKSpecUser class]]) should:be(YES)];
    [expectThat(user.name) should:be(@"Blake Watters")];
}

- (void)itShouldMapACollectionOfObjects {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    RKObjectAttributeMapping* idMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"id" toKeyPath:@"userID"];
    [mapping addAttributeMapping:idMapping];
    RKObjectAttributeMapping* nameMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"name" toKeyPath:@"name"];
    [mapping addAttributeMapping:nameMapping];
    RKObjectMappingProvider* provider = [[RKObjectMappingProvider new] autorelease];
    [provider setMapping:mapping forKeyPath:@""];
    
    id userInfo = RKSpecParseFixture(@"users.json");
    RKObjectMapper* mapper = [RKObjectMapper mapperWithObject:userInfo mappingProvider:provider];
    RKObjectMappingResult* result = [mapper performMapping];
    NSArray* users = [result asCollection];
    [expectThat([users isKindOfClass:[NSArray class]]) should:be(YES)];
    [expectThat([users count]) should:be(3)];
    RKSpecUser* user = [users objectAtIndex:0];
    [expectThat([user isKindOfClass:[RKSpecUser class]]) should:be(YES)];
    [expectThat(user.name) should:be(@"Blake Watters")];
}

- (void)itShouldMapACollectionOfObjectsWithDynamicKeys {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    mapping.forceCollectionMapping = YES;
    [mapping mapKeyOfNestedDictionaryToAttribute:@"name"];    
    RKObjectAttributeMapping* idMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"(name).id" toKeyPath:@"userID"];
    [mapping addAttributeMapping:idMapping];
    RKObjectMappingProvider* provider = [[RKObjectMappingProvider new] autorelease];
    [provider setMapping:mapping forKeyPath:@"users"];
    
    id userInfo = RKSpecParseFixture(@"DynamicKeys.json");
    RKObjectMapper* mapper = [RKObjectMapper mapperWithObject:userInfo mappingProvider:provider];
    RKObjectMappingResult* result = [mapper performMapping];
    NSArray* users = [result asCollection];
    [expectThat([users isKindOfClass:[NSArray class]]) should:be(YES)];
    [expectThat([users count]) should:be(2)];
    RKSpecUser* user = [users objectAtIndex:0];
    [expectThat([user isKindOfClass:[RKSpecUser class]]) should:be(YES)];
    [expectThat(user.name) should:be(@"blake")];
    user = [users objectAtIndex:1];
    [expectThat([user isKindOfClass:[RKSpecUser class]]) should:be(YES)];
    [expectThat(user.name) should:be(@"rachit")];
}

- (void)itShouldMapACollectionOfObjectsWithDynamicKeysAndRelationships {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    mapping.forceCollectionMapping = YES;
    [mapping mapKeyOfNestedDictionaryToAttribute:@"name"];
    
    RKObjectMapping* addressMapping = [RKObjectMapping mappingForClass:[RKSpecAddress class]];
    [addressMapping mapAttributes:@"city", @"state", nil];
    [mapping mapKeyPath:@"(name).address" toRelationship:@"address" withMapping:addressMapping];
    RKObjectMappingProvider* provider = [[RKObjectMappingProvider new] autorelease];
    [provider setMapping:mapping forKeyPath:@"users"];
    
    id userInfo = RKSpecParseFixture(@"DynamicKeysWithRelationship.json");
    RKObjectMapper* mapper = [RKObjectMapper mapperWithObject:userInfo mappingProvider:provider];
    RKObjectMappingResult* result = [mapper performMapping];
    NSArray* users = [result asCollection];
    [expectThat([users isKindOfClass:[NSArray class]]) should:be(YES)];
    [expectThat([users count]) should:be(2)];
    RKSpecUser* user = [users objectAtIndex:0];
    [expectThat([user isKindOfClass:[RKSpecUser class]]) should:be(YES)];
    [expectThat(user.name) should:be(@"blake")];
    user = [users objectAtIndex:1];
    [expectThat([user isKindOfClass:[RKSpecUser class]]) should:be(YES)];
    [expectThat(user.name) should:be(@"rachit")];
    [expectThat(user.address) shouldNot:be(nil)];
    [expectThat(user.address.city) should:be(@"New York")];
}

- (void)itShouldMapANestedArrayOfObjectsWithDynamicKeysAndArrayRelationships {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKExampleGroupWithUserArray class]];
    [mapping mapAttributes:@"name", nil];

    
    RKObjectMapping* userMapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    userMapping.forceCollectionMapping = YES;
    [userMapping mapKeyOfNestedDictionaryToAttribute:@"name"];
    [mapping mapKeyPath:@"users" toRelationship:@"users" withMapping:userMapping];
    
    RKObjectMapping* addressMapping = [RKObjectMapping mappingForClass:[RKSpecAddress class]];
    [addressMapping mapAttributes:
        @"city", @"city",
        @"state", @"state",
        @"country", @"country",
        nil
     ];
    [userMapping mapKeyPath:@"(name).address" toRelationship:@"address" withMapping:addressMapping];
    RKObjectMappingProvider* provider = [[RKObjectMappingProvider new] autorelease];
    [provider setMapping:mapping forKeyPath:@"groups"];
    
    id userInfo = RKSpecParseFixture(@"DynamicKeysWithNestedRelationship.json");
    RKObjectMapper* mapper = [RKObjectMapper mapperWithObject:userInfo mappingProvider:provider];
    RKObjectMappingResult* result = [mapper performMapping];
    
    NSArray* groups = [result asCollection];
    [expectThat([groups isKindOfClass:[NSArray class]]) should:be(YES)];
    [expectThat([groups count]) should:be(2)];
    
    RKExampleGroupWithUserArray* group = [groups objectAtIndex:0];
    [expectThat([group isKindOfClass:[RKExampleGroupWithUserArray class]]) should:be(YES)];
    [expectThat(group.name) should:be(@"restkit")];
    NSArray * users = group.users;
    [expectThat([users count]) should:be(2)];
    RKSpecUser* user = [users objectAtIndex:0];
    [expectThat([user isKindOfClass:[RKSpecUser class]]) should:be(YES)];
    [expectThat(user.name) should:be(@"blake")];
    user = [users objectAtIndex:1];
    [expectThat([user isKindOfClass:[RKSpecUser class]]) should:be(YES)];
    [expectThat(user.name) should:be(@"rachit")];
    [expectThat(user.address) shouldNot:be(nil)];
    [expectThat(user.address.city) should:be(@"New York")];
    
    group = [groups objectAtIndex:1];
    [expectThat([group isKindOfClass:[RKExampleGroupWithUserArray class]]) should:be(YES)];
    [expectThat(group.name) should:be(@"others")];
    users = group.users;
    [expectThat([users count]) should:be(1)];
    user = [users objectAtIndex:0];
    [expectThat([user isKindOfClass:[RKSpecUser class]]) should:be(YES)];
    [expectThat(user.name) should:be(@"bjorn")];
    [expectThat(user.address) shouldNot:be(nil)];
    [expectThat(user.address.city) should:be(@"Gothenburg")];
    [expectThat(user.address.country) should:be(@"Sweden")];
}

- (void)itShouldMapANestedArrayOfObjectsWithDynamicKeysAndSetRelationships {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKExampleGroupWithUserSet class]];
    [mapping mapAttributes:@"name", nil];
    
    
    RKObjectMapping* userMapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    userMapping.forceCollectionMapping = YES;
    [userMapping mapKeyOfNestedDictionaryToAttribute:@"name"];
    [mapping mapKeyPath:@"users" toRelationship:@"users" withMapping:userMapping];
    
    RKObjectMapping* addressMapping = [RKObjectMapping mappingForClass:[RKSpecAddress class]];
    [addressMapping mapAttributes:
        @"city", @"city",
        @"state", @"state",
        @"country", @"country",
        nil
    ];
    [userMapping mapKeyPath:@"(name).address" toRelationship:@"address" withMapping:addressMapping];
    RKObjectMappingProvider* provider = [[RKObjectMappingProvider new] autorelease];
    [provider setMapping:mapping forKeyPath:@"groups"];
    
    id userInfo = RKSpecParseFixture(@"DynamicKeysWithNestedRelationship.json");
    RKObjectMapper* mapper = [RKObjectMapper mapperWithObject:userInfo mappingProvider:provider];
    RKObjectMappingResult* result = [mapper performMapping];
    
    NSArray* groups = [result asCollection];
    [expectThat([groups isKindOfClass:[NSArray class]]) should:be(YES)];
    [expectThat([groups count]) should:be(2)];
    
    RKExampleGroupWithUserSet* group = [groups objectAtIndex:0];
    [expectThat([group isKindOfClass:[RKExampleGroupWithUserSet class]]) should:be(YES)];
    [expectThat(group.name) should:be(@"restkit")];
    
    
    NSSortDescriptor * sortByName =[[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease];
    NSArray * descriptors = [NSArray arrayWithObject:sortByName];;
    NSArray * users = [group.users sortedArrayUsingDescriptors:descriptors];
    [expectThat([users count]) should:be(2)];
    RKSpecUser* user = [users objectAtIndex:0];
    [expectThat([user isKindOfClass:[RKSpecUser class]]) should:be(YES)];
    [expectThat(user.name) should:be(@"blake")];
    user = [users objectAtIndex:1];
    [expectThat([user isKindOfClass:[RKSpecUser class]]) should:be(YES)];
    [expectThat(user.name) should:be(@"rachit")];
    [expectThat(user.address) shouldNot:be(nil)];
    [expectThat(user.address.city) should:be(@"New York")];
    
    group = [groups objectAtIndex:1];
    [expectThat([group isKindOfClass:[RKExampleGroupWithUserSet class]]) should:be(YES)];
    [expectThat(group.name) should:be(@"others")];
    users = [group.users sortedArrayUsingDescriptors:descriptors];
    [expectThat([users count]) should:be(1)];
    user = [users objectAtIndex:0];
    [expectThat([user isKindOfClass:[RKSpecUser class]]) should:be(YES)];
    [expectThat(user.name) should:be(@"bjorn")];
    [expectThat(user.address) shouldNot:be(nil)];
    [expectThat(user.address.city) should:be(@"Gothenburg")];
    [expectThat(user.address.country) should:be(@"Sweden")];
}


- (void)itShouldBeAbleToMapFromAUserObjectToADictionary {    
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[NSMutableDictionary class]];
    RKObjectAttributeMapping* idMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"userID" toKeyPath:@"id"];
    [mapping addAttributeMapping:idMapping];
    RKObjectAttributeMapping* nameMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"name" toKeyPath:@"name"];
    [mapping addAttributeMapping:nameMapping];
    RKObjectMappingProvider* provider = [[RKObjectMappingProvider new] autorelease];
    [provider setMapping:mapping forKeyPath:@""];
    
    RKSpecUser* user = [RKSpecUser user];
    user.name = @"Blake Watters";
    user.userID = [NSNumber numberWithInt:123];
    
    RKObjectMapper* mapper = [RKObjectMapper mapperWithObject:user mappingProvider:provider];
    RKObjectMappingResult* result = [mapper performMapping];
    NSDictionary* userInfo = [result asObject];
    [expectThat([userInfo isKindOfClass:[NSDictionary class]]) should:be(YES)];
    [expectThat([userInfo valueForKey:@"name"]) should:be(@"Blake Watters")];
}

- (void)itShouldMapRegisteredSubKeyPathsOfAnUnmappableDictionaryAndReturnTheResults {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    RKObjectAttributeMapping* idMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"id" toKeyPath:@"userID"];
    [mapping addAttributeMapping:idMapping];
    RKObjectAttributeMapping* nameMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"name" toKeyPath:@"name"];
    [mapping addAttributeMapping:nameMapping];
    RKObjectMappingProvider* provider = [[RKObjectMappingProvider new] autorelease];
    [provider setMapping:mapping forKeyPath:@"user"];
    
    id userInfo = RKSpecParseFixture(@"nested_user.json");
    RKObjectMapper* mapper = [RKObjectMapper mapperWithObject:userInfo mappingProvider:provider];
    NSDictionary* dictionary = [[mapper performMapping] asDictionary];
    [expectThat([dictionary isKindOfClass:[NSDictionary class]]) should:be(YES)];
    RKSpecUser* user = [dictionary objectForKey:@"user"];
    [expectThat(user) shouldNot:be(nil)];
    [expectThat(user.name) should:be(@"Blake Watters")];
}

#pragma mark Mapping Error States

- (void)itShouldAddAnErrorWhenYouTryToMapAnArrayToATargetObject {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    RKObjectAttributeMapping* idMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"id" toKeyPath:@"userID"];
    [mapping addAttributeMapping:idMapping];
    RKObjectAttributeMapping* nameMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"name" toKeyPath:@"name"];
    [mapping addAttributeMapping:nameMapping];
    RKObjectMappingProvider* provider = [[RKObjectMappingProvider new] autorelease];
    [provider setMapping:mapping forKeyPath:@""];
    
    id userInfo = RKSpecParseFixture(@"users.json");
    RKObjectMapper* mapper = [RKObjectMapper mapperWithObject:userInfo mappingProvider:provider];
    mapper.targetObject = [RKSpecUser user];
    [mapper performMapping];
    [expectThat([mapper errorCount]) should:be(1)];
    [expectThat([[mapper.errors objectAtIndex:0] code]) should:be(RKObjectMapperErrorObjectMappingTypeMismatch)];
}

- (void)itShouldAddAnErrorWhenAttemptingToMapADictionaryWithoutAnObjectMapping {
    id userInfo = RKSpecParseFixture(@"user.json");
    RKObjectMappingProvider* provider = [[RKObjectMappingProvider new] autorelease];
    RKObjectMapper* mapper = [RKObjectMapper mapperWithObject:userInfo mappingProvider:provider];
    [mapper performMapping];
    [expectThat([mapper errorCount]) should:be(1)];
    [expectThat([[mapper.errors objectAtIndex:0] localizedDescription]) should:be(@"Could not find an object mapping for keyPath: ''")];
}

- (void)itShouldAddAnErrorWhenAttemptingToMapACollectionWithoutAnObjectMapping {
    RKObjectMappingProvider* provider = [[RKObjectMappingProvider new] autorelease];
    id userInfo = RKSpecParseFixture(@"users.json");
    RKObjectMapper* mapper = [RKObjectMapper mapperWithObject:userInfo mappingProvider:provider];
    [mapper performMapping];
    [expectThat([mapper errorCount]) should:be(1)];
    [expectThat([[mapper.errors objectAtIndex:0] localizedDescription]) should:be(@"Could not find an object mapping for keyPath: ''")];
}

#pragma mark RKObjectMapperDelegate Specs

- (void)itShouldInformTheDelegateWhenMappingBegins {
    id mockDelegate = [OCMockObject niceMockForProtocol:@protocol(RKObjectMapperDelegate)];
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    RKObjectMappingProvider* provider = [[RKObjectMappingProvider new] autorelease];
    [provider setMapping:mapping forKeyPath:@""];
    
    id userInfo = RKSpecParseFixture(@"users.json");
    RKObjectMapper* mapper = [RKObjectMapper mapperWithObject:userInfo mappingProvider:provider];
    [[mockDelegate expect] objectMapperWillBeginMapping:mapper];
    mapper.delegate = mockDelegate;
    [mapper performMapping];
    [mockDelegate verify];
}

- (void)itShouldInformTheDelegateWhenMappingEnds {
    id mockDelegate = [OCMockObject niceMockForProtocol:@protocol(RKObjectMapperDelegate)];
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    RKObjectMappingProvider* provider = [[RKObjectMappingProvider new] autorelease];
    [provider setMapping:mapping forKeyPath:@""];
    
    id userInfo = RKSpecParseFixture(@"users.json");
    RKObjectMapper* mapper = [RKObjectMapper mapperWithObject:userInfo mappingProvider:provider];
    [[mockDelegate stub] objectMapperWillBeginMapping:mapper];
    [[mockDelegate expect] objectMapperDidFinishMapping:mapper];
    mapper.delegate = mockDelegate;
    [mapper performMapping];
    [mockDelegate verify];
}

- (void)itShouldInformTheDelegateWhenCheckingForObjectMappingForKeyPathIsSuccessful {
    id mockDelegate = [OCMockObject niceMockForProtocol:@protocol(RKObjectMapperDelegate)];
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    RKObjectMappingProvider* provider = [[RKObjectMappingProvider new] autorelease];
    [provider setMapping:mapping forKeyPath:@""];
    
    id userInfo = RKSpecParseFixture(@"user.json");
    RKObjectMapper* mapper = [RKObjectMapper mapperWithObject:userInfo mappingProvider:provider];
    [[mockDelegate expect] objectMapper:mapper didFindMappableObject:[OCMArg any] atKeyPath:@""withMapping:mapping];
    mapper.delegate = mockDelegate;
    [mapper performMapping];
    [mockDelegate verify];
}

- (void)itShouldInformTheDelegateWhenCheckingForObjectMappingForKeyPathIsNotSuccessful {
    RKObjectMappingProvider* provider = [[RKObjectMappingProvider new] autorelease];
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    [provider setMapping:mapping forKeyPath:@"users"];
    
    id userInfo = RKSpecParseFixture(@"user.json");
    RKObjectMapper* mapper = [RKObjectMapper mapperWithObject:userInfo mappingProvider:provider];
    id mockDelegate = [OCMockObject niceMockForProtocol:@protocol(RKObjectMapperDelegate)];
    [[mockDelegate expect] objectMapper:mapper didNotFindMappableObjectAtKeyPath:@"users"];
    mapper.delegate = mockDelegate;
    [mapper performMapping];
    [mockDelegate verify];
}

- (void)itShouldInformTheDelegateOfError {
    id mockProvider = [OCMockObject niceMockForClass:[RKObjectMappingProvider class]];
    id mockDelegate = [OCMockObject niceMockForProtocol:@protocol(RKObjectMapperDelegate)];
    
    id userInfo = RKSpecParseFixture(@"users.json");
    RKObjectMapper* mapper = [RKObjectMapper mapperWithObject:userInfo mappingProvider:mockProvider];
    [[mockDelegate expect] objectMapper:mapper didAddError:[OCMArg isNotNil]];
    mapper.delegate = mockDelegate;
    [mapper performMapping];
    [mockDelegate verify];
}

- (void)itShouldNotifyTheDelegateWhenItWillMapAnObject {
    RKObjectMappingProvider* provider = [[RKObjectMappingProvider new] autorelease];
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    [provider setMapping:mapping forKeyPath:@""];
    id mockDelegate = [OCMockObject niceMockForProtocol:@protocol(RKObjectMapperDelegate)];
    
    id userInfo = RKSpecParseFixture(@"user.json");
    RKObjectMapper* mapper = [RKObjectMapper mapperWithObject:userInfo mappingProvider:provider];
    [[mockDelegate expect] objectMapper:mapper willMapFromObject:userInfo toObject:[OCMArg any] atKeyPath:@"" usingMapping:mapping];
    mapper.delegate = mockDelegate;
    [mapper performMapping];
    [mockDelegate verify];
}

- (void)itShouldNotifyTheDelegateWhenItDidMapAnObject {
    id mockDelegate = [OCMockObject niceMockForProtocol:@protocol(RKObjectMapperDelegate)];
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    RKObjectAttributeMapping* nameMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"name" toKeyPath:@"name"];
    [mapping addAttributeMapping:nameMapping];
    RKObjectMappingProvider* provider = [[RKObjectMappingProvider new] autorelease];
    [provider setMapping:mapping forKeyPath:@""];
    
    id userInfo = RKSpecParseFixture(@"user.json");
    RKObjectMapper* mapper = [RKObjectMapper mapperWithObject:userInfo mappingProvider:provider];
    [[mockDelegate expect] objectMapper:mapper didMapFromObject:userInfo toObject:[OCMArg any] atKeyPath:@"" usingMapping:mapping];
    mapper.delegate = mockDelegate;
    [mapper performMapping];
    [mockDelegate verify];
}

- (BOOL)fakeValidateValue:(inout id *)ioValue forKey:(NSString *)inKey error:(out NSError **)outError {
    *outError = [NSError errorWithDomain:RKErrorDomain code:1234 userInfo:nil];
    return NO;
}

- (void)itShouldNotifyTheDelegateWhenItFailedToMapAnObject {    
    id mockDelegate = [OCMockObject niceMockForProtocol:@protocol(RKObjectMapperDelegate)];
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:NSClassFromString(@"OCPartialMockObject")];
    [mapping mapAttributes:@"name", nil];
    RKObjectMappingProvider* provider = [[RKObjectMappingProvider new] autorelease];
    [provider setMapping:mapping forKeyPath:@""];
    
    id userInfo = RKSpecParseFixture(@"user.json");
    RKObjectMapper* mapper = [RKObjectMapper mapperWithObject:userInfo mappingProvider:provider];
    RKSpecUser* exampleUser = [[RKSpecUser new] autorelease];
    id mockObject = [OCMockObject partialMockForObject:exampleUser];
    [[[mockObject expect] andCall:@selector(fakeValidateValue:forKey:error:) onObject:self] validateValue:[OCMArg anyPointer] forKey:OCMOCK_ANY error:[OCMArg anyPointer]];
    mapper.targetObject = mockObject;
    [[mockDelegate expect] objectMapper:mapper didFailMappingFromObject:userInfo toObject:[OCMArg any] withError:[OCMArg any] atKeyPath:@"" usingMapping:mapping];
    mapper.delegate = mockDelegate;
    [mapper performMapping];
    [mockObject verify];
    [mockDelegate verify];
}

#pragma mark - RKObjectMappingOperationSpecs

- (void)itShouldBeAbleToMapADictionaryToAUser {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[NSMutableDictionary class]];
    RKObjectAttributeMapping* idMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"id" toKeyPath:@"userID"];
    [mapping addAttributeMapping:idMapping];
    RKObjectAttributeMapping* nameMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"name" toKeyPath:@"name"];
    [mapping addAttributeMapping:nameMapping];
    
    NSMutableDictionary* dictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:123], @"id", @"Blake Watters", @"name", nil];
    RKSpecUser* user = [RKSpecUser user];
    
    RKObjectMappingOperation* operation = [[RKObjectMappingOperation alloc] initWithSourceObject:dictionary destinationObject:user mapping:mapping];
    [operation performMapping:nil];    
    [expectThat(user.name) should:be(@"Blake Watters")];
    [expectThat(user.userID) should:be(123)];    
    [operation release];
}

- (void)itShouldConsiderADictionaryContainingOnlyNullValuesForKeysMappable {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[NSMutableDictionary class]];
    RKObjectAttributeMapping* idMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"id" toKeyPath:@"userID"];
    [mapping addAttributeMapping:idMapping];
    RKObjectAttributeMapping* nameMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"name" toKeyPath:@"name"];
    [mapping addAttributeMapping:nameMapping];
    
    NSMutableDictionary* dictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNull null], @"name", nil];
    RKSpecUser* user = [RKSpecUser user];
    
    RKObjectMappingOperation* operation = [[RKObjectMappingOperation alloc] initWithSourceObject:dictionary destinationObject:user mapping:mapping];
    BOOL success = [operation performMapping:nil];
    assertThatBool(success, is(equalToBool(YES)));
    assertThat(user.name, is(equalTo([NSNull null])));
    [operation release];
}

- (void)itShouldBeAbleToMapAUserToADictionary {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[NSMutableDictionary class]];
    RKObjectAttributeMapping* idMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"userID" toKeyPath:@"id"];
    [mapping addAttributeMapping:idMapping];
    RKObjectAttributeMapping* nameMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"name" toKeyPath:@"name"];
    [mapping addAttributeMapping:nameMapping];
    
    RKSpecUser* user = [RKSpecUser user];
    user.name = @"Blake Watters";
    user.userID = [NSNumber numberWithInt:123];
    
    NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];
    RKObjectMappingOperation* operation = [[RKObjectMappingOperation alloc] initWithSourceObject:user destinationObject:dictionary mapping:mapping];
    BOOL success = [operation performMapping:nil];
    [expectThat(success) should:be(YES)];
    [expectThat([dictionary valueForKey:@"name"]) should:be(@"Blake Watters")];
    [expectThat([dictionary valueForKey:@"id"]) should:be(123)];
    [operation release];
}

- (void)itShouldReturnNoWithoutErrorWhenGivenASourceObjectThatContainsNoMappableKeys {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[NSMutableDictionary class]];
    RKObjectAttributeMapping* idMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"id" toKeyPath:@"userID"];
    [mapping addAttributeMapping:idMapping];
    RKObjectAttributeMapping* nameMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"name" toKeyPath:@"name"];
    [mapping addAttributeMapping:nameMapping];
    
    NSMutableDictionary* dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"blue", @"favorite_color", @"coffee", @"preferred_beverage", nil];
    RKSpecUser* user = [RKSpecUser user];
    
    RKObjectMappingOperation* operation = [[RKObjectMappingOperation alloc] initWithSourceObject:dictionary destinationObject:user mapping:mapping];
    NSError* error = nil;
    BOOL success = [operation performMapping:&error];
    [expectThat(success) should:be(NO)];
    [expectThat(error) should:be(nil)];
    [operation release];
}

- (void)itShouldInformTheDelegateOfAnErrorWhenMappingFailsBecauseThereIsNoMappableContent {
    id mockDelegate = [OCMockObject niceMockForProtocol:@protocol(RKObjectMappingOperationDelegate)];
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[NSMutableDictionary class]];
    RKObjectAttributeMapping* idMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"id" toKeyPath:@"userID"];
    [mapping addAttributeMapping:idMapping];
    RKObjectAttributeMapping* nameMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"name" toKeyPath:@"name"];
    [mapping addAttributeMapping:nameMapping];
    
    NSMutableDictionary* dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"blue", @"favorite_color", @"coffee", @"preferred_beverage", nil];
    RKSpecUser* user = [RKSpecUser user];
    
    RKObjectMappingOperation* operation = [[RKObjectMappingOperation alloc] initWithSourceObject:dictionary destinationObject:user mapping:mapping];
    operation.delegate = mockDelegate;
    BOOL success = [operation performMapping:nil];
    [expectThat(success) should:be(NO)];
    [mockDelegate verify];
}

- (void)itShouldSetTheErrorWhenMappingOperationFails {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[NSMutableDictionary class]];
    RKObjectAttributeMapping* idMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"id" toKeyPath:@"userID"];
    [mapping addAttributeMapping:idMapping];
    RKObjectAttributeMapping* nameMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"name" toKeyPath:@"name"];
    [mapping addAttributeMapping:nameMapping];
    
    NSMutableDictionary* dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"FAILURE", @"id", nil];
    RKSpecUser* user = [RKSpecUser user];
    id mockObject = [OCMockObject partialMockForObject:user];
    [[[mockObject expect] andCall:@selector(fakeValidateValue:forKey:error:) onObject:self] validateValue:[OCMArg anyPointer] forKey:OCMOCK_ANY error:[OCMArg anyPointer]];
    
    RKObjectMappingOperation* operation = [[RKObjectMappingOperation alloc] initWithSourceObject:dictionary destinationObject:mockObject mapping:mapping];
    NSError* error = nil;
    [operation performMapping:&error];
    [expectThat(error) shouldNot:be(nil)];
    [operation release];
}

#pragma mark - Attribute Mapping

- (void)itShouldMapAStringToADateAttribute {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    RKObjectAttributeMapping* birthDateMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"birthdate" toKeyPath:@"birthDate"];
    [mapping addAttributeMapping:birthDateMapping];
    
    NSDictionary* dictionary = RKSpecParseFixture(@"user.json");
    RKSpecUser* user = [RKSpecUser user];
    RKObjectMappingOperation* operation = [[RKObjectMappingOperation alloc] initWithSourceObject:dictionary destinationObject:user mapping:mapping];
    NSError* error = nil;
    [operation performMapping:&error];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter new] autorelease];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    [expectThat([dateFormatter stringFromDate:user.birthDate]) should:be(@"11/27/1982")];
}

- (void)itShouldMapStringToURL {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    RKObjectAttributeMapping* websiteMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"website" toKeyPath:@"website"];
    [mapping addAttributeMapping:websiteMapping];
    
    NSDictionary* dictionary = RKSpecParseFixture(@"user.json");
    RKSpecUser* user = [RKSpecUser user];
    RKObjectMappingOperation* operation = [[RKObjectMappingOperation alloc] initWithSourceObject:dictionary destinationObject:user mapping:mapping];
    NSError* error = nil;
    [operation performMapping:&error];
    
    [expectThat(user.website) shouldNot:be(nil)];
    [expectThat([user.website isKindOfClass:[NSURL class]]) should:be(YES)];
    [expectThat([user.website absoluteString]) should:be(@"http://restkit.org/")];
}

- (void)itShouldMapAStringToANumberBool {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    RKObjectAttributeMapping* websiteMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"is_developer" toKeyPath:@"isDeveloper"];
    [mapping addAttributeMapping:websiteMapping];
    
    NSDictionary* dictionary = RKSpecParseFixture(@"user.json");
    RKSpecUser* user = [RKSpecUser user];
    RKObjectMappingOperation* operation = [[RKObjectMappingOperation alloc] initWithSourceObject:dictionary destinationObject:user mapping:mapping];
    NSError* error = nil;
    [operation performMapping:&error];
    
    [expectThat([[user isDeveloper] boolValue]) should:be(YES)]; 
}

- (void)itShouldMapAShortTrueStringToANumberBool {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    RKObjectAttributeMapping* websiteMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"is_developer" toKeyPath:@"isDeveloper"];
    [mapping addAttributeMapping:websiteMapping];
    
    NSDictionary* dictionary = [RKSpecParseFixture(@"user.json") mutableCopy];
    RKSpecUser* user = [RKSpecUser user];
    [dictionary setValue:@"T" forKey:@"is_developer"];
    RKObjectMappingOperation* operation = [[RKObjectMappingOperation alloc] initWithSourceObject:dictionary destinationObject:user mapping:mapping];
    NSError* error = nil;
    [operation performMapping:&error];
    
    [expectThat([[user isDeveloper] boolValue]) should:be(YES)]; 
}

- (void)itShouldMapAShortFalseStringToANumberBool {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    RKObjectAttributeMapping* websiteMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"is_developer" toKeyPath:@"isDeveloper"];
    [mapping addAttributeMapping:websiteMapping];
    
    NSDictionary* dictionary = [RKSpecParseFixture(@"user.json") mutableCopy];
    RKSpecUser* user = [RKSpecUser user];
    [dictionary setValue:@"f" forKey:@"is_developer"];
    RKObjectMappingOperation* operation = [[RKObjectMappingOperation alloc] initWithSourceObject:dictionary destinationObject:user mapping:mapping];
    NSError* error = nil;
    [operation performMapping:&error];
    
    [expectThat([[user isDeveloper] boolValue]) should:be(NO)]; 
}

- (void)itShouldMapAYesStringToANumberBool {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    RKObjectAttributeMapping* websiteMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"is_developer" toKeyPath:@"isDeveloper"];
    [mapping addAttributeMapping:websiteMapping];
    
    NSDictionary* dictionary = [RKSpecParseFixture(@"user.json") mutableCopy];
    RKSpecUser* user = [RKSpecUser user];
    [dictionary setValue:@"yes" forKey:@"is_developer"];
    RKObjectMappingOperation* operation = [[RKObjectMappingOperation alloc] initWithSourceObject:dictionary destinationObject:user mapping:mapping];
    NSError* error = nil;
    [operation performMapping:&error];
    
    [expectThat([[user isDeveloper] boolValue]) should:be(YES)]; 
}

- (void)itShouldMapANoStringToANumberBool {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    RKObjectAttributeMapping* websiteMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"is_developer" toKeyPath:@"isDeveloper"];
    [mapping addAttributeMapping:websiteMapping];
    
    NSDictionary* dictionary = [RKSpecParseFixture(@"user.json") mutableCopy];
    RKSpecUser* user = [RKSpecUser user];
    [dictionary setValue:@"NO" forKey:@"is_developer"];
    RKObjectMappingOperation* operation = [[RKObjectMappingOperation alloc] initWithSourceObject:dictionary destinationObject:user mapping:mapping];
    NSError* error = nil;
    [operation performMapping:&error];
    
    [expectThat([[user isDeveloper] boolValue]) should:be(NO)]; 
}

- (void)itShouldMapAStringToANumber {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    RKObjectAttributeMapping* websiteMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"lucky_number" toKeyPath:@"luckyNumber"];
    [mapping addAttributeMapping:websiteMapping];
    
    NSDictionary* dictionary = RKSpecParseFixture(@"user.json");
    RKSpecUser* user = [RKSpecUser user];
    RKObjectMappingOperation* operation = [[RKObjectMappingOperation alloc] initWithSourceObject:dictionary destinationObject:user mapping:mapping];
    NSError* error = nil;
    [operation performMapping:&error];
    
    [expectThat(user.luckyNumber) should:be(187)]; 
}

- (void)itShouldMapAStringToADecimalNumber {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    RKObjectAttributeMapping* websiteMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"weight" toKeyPath:@"weight"];
    [mapping addAttributeMapping:websiteMapping];
    
    NSDictionary* dictionary = RKSpecParseFixture(@"user.json");
    RKSpecUser* user = [RKSpecUser user];
    RKObjectMappingOperation* operation = [[RKObjectMappingOperation alloc] initWithSourceObject:dictionary destinationObject:user mapping:mapping];
    NSError* error = nil;
    [operation performMapping:&error];
    
    NSDecimalNumber* weight = user.weight;
    [expectThat([weight isKindOfClass:[NSDecimalNumber class]]) should:be(YES)];
    [expectThat([weight compare:[NSDecimalNumber decimalNumberWithString:@"131.3"]]) should:be(NSOrderedSame)];
}


- (void)itShouldMapANumberToAString {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    RKObjectAttributeMapping* websiteMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"lucky_number" toKeyPath:@"name"];
    [mapping addAttributeMapping:websiteMapping];
    
    NSDictionary* dictionary = RKSpecParseFixture(@"user.json");
    RKSpecUser* user = [RKSpecUser user];
    RKObjectMappingOperation* operation = [[RKObjectMappingOperation alloc] initWithSourceObject:dictionary destinationObject:user mapping:mapping];
    NSError* error = nil;
    [operation performMapping:&error];
    
    [expectThat(user.name) should:be(@"187")]; 
}

- (void)itShouldMapANumberToANSDecimalNumber {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    RKObjectAttributeMapping* websiteMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"lucky_number" toKeyPath:@"weight"];
    [mapping addAttributeMapping:websiteMapping];
    
    NSDictionary* dictionary = RKSpecParseFixture(@"user.json");
    RKSpecUser* user = [RKSpecUser user];
    RKObjectMappingOperation* operation = [[RKObjectMappingOperation alloc] initWithSourceObject:dictionary destinationObject:user mapping:mapping];
    NSError* error = nil;
    [operation performMapping:&error];
    
    NSDecimalNumber* weight = user.weight;
    [expectThat([weight isKindOfClass:[NSDecimalNumber class]]) should:be(YES)];
    [expectThat([weight compare:[NSDecimalNumber decimalNumberWithString:@"187"]]) should:be(NSOrderedSame)];
}

- (void)itShouldMapANumberToADate {
    NSDateFormatter* dateFormatter = [[NSDateFormatter new] autorelease];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    NSDate* date = [dateFormatter dateFromString:@"11/27/1982"];
    
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    RKObjectAttributeMapping* birthDateMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"dateAsNumber" toKeyPath:@"birthDate"];
    [mapping addAttributeMapping:birthDateMapping];
    
    NSMutableDictionary* dictionary = [RKSpecParseFixture(@"user.json") mutableCopy];
    [dictionary setValue:[NSNumber numberWithInt:[date timeIntervalSince1970]] forKey:@"dateAsNumber"];
    RKSpecUser* user = [RKSpecUser user];
    RKObjectMappingOperation* operation = [[RKObjectMappingOperation alloc] initWithSourceObject:dictionary destinationObject:user mapping:mapping];
    NSError* error = nil;
    [operation performMapping:&error];
    
    [expectThat([dateFormatter stringFromDate:user.birthDate]) should:be(@"11/27/1982")];
}

- (void)itShouldMapANestedKeyPathToAnAttribute {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    RKObjectAttributeMapping* countryMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"address.country" toKeyPath:@"country"];
    [mapping addAttributeMapping:countryMapping];
    
    NSDictionary* dictionary = RKSpecParseFixture(@"user.json");
    RKSpecUser* user = [RKSpecUser user];
    RKObjectMappingOperation* operation = [[RKObjectMappingOperation alloc] initWithSourceObject:dictionary destinationObject:user mapping:mapping];
    NSError* error = nil;
    [operation performMapping:&error];
    
    [expectThat(user.country) should:be(@"USA")];
}

- (void)itShouldMapANestedArrayOfStringsToAnAttribute {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    RKObjectAttributeMapping* countryMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"interests" toKeyPath:@"interests"];
    [mapping addAttributeMapping:countryMapping];
    
    NSDictionary* dictionary = RKSpecParseFixture(@"user.json");
    RKSpecUser* user = [RKSpecUser user];
    RKObjectMappingOperation* operation = [[RKObjectMappingOperation alloc] initWithSourceObject:dictionary destinationObject:user mapping:mapping];
    NSError* error = nil;
    [operation performMapping:&error];
    
    NSArray* interests = [NSArray arrayWithObjects:@"Hacking", @"Running", nil];
    assertThat(user.interests, is(equalTo(interests)));
}

- (void)itShouldMapANestedDictionaryToAnAttribute {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    RKObjectAttributeMapping* countryMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"address" toKeyPath:@"addressDictionary"];
    [mapping addAttributeMapping:countryMapping];
    
    NSDictionary* dictionary = RKSpecParseFixture(@"user.json");
    RKSpecUser* user = [RKSpecUser user];
    RKObjectMappingOperation* operation = [[RKObjectMappingOperation alloc] initWithSourceObject:dictionary destinationObject:user mapping:mapping];
    NSError* error = nil;
    [operation performMapping:&error];
    
    NSDictionary* address = [NSDictionary dictionaryWithKeysAndObjects:
                             @"city", @"Carrboro",
                             @"state", @"North Carolina",
                             @"id", [NSNumber numberWithInt:1234],
                             @"country", @"USA", nil];
    assertThat(user.addressDictionary, is(equalTo(address)));
}

- (void)itShouldNotSetAPropertyWhenTheValueIsTheSame {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    RKObjectAttributeMapping* nameMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"name" toKeyPath:@"name"];
    [mapping addAttributeMapping:nameMapping];
    
    NSDictionary* dictionary = RKSpecParseFixture(@"user.json");
    RKSpecUser* user = [RKSpecUser user];
    user.name = @"Blake Watters";
    id mockUser = [OCMockObject partialMockForObject:user];
    [[mockUser reject] setName:OCMOCK_ANY];
    RKObjectMappingOperation* operation = [[RKObjectMappingOperation alloc] initWithSourceObject:dictionary destinationObject:user mapping:mapping];
    NSError* error = nil;
    [operation performMapping:&error];
}

- (void)itShouldNotSetTheDestinationPropertyWhenBothAreNil {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    RKObjectAttributeMapping* nameMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"name" toKeyPath:@"name"];
    [mapping addAttributeMapping:nameMapping];
    
    NSMutableDictionary* dictionary = [RKSpecParseFixture(@"user.json") mutableCopy];
    [dictionary setValue:[NSNull null] forKey:@"name"];
    RKSpecUser* user = [RKSpecUser user];
    user.name = nil;
    id mockUser = [OCMockObject partialMockForObject:user];
    [[mockUser reject] setName:OCMOCK_ANY];
    RKObjectMappingOperation* operation = [[RKObjectMappingOperation alloc] initWithSourceObject:dictionary destinationObject:user mapping:mapping];
    NSError* error = nil;
    [operation performMapping:&error];
}

- (void)itShouldSetNilForNSNullValues {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    RKObjectAttributeMapping* nameMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"name" toKeyPath:@"name"];
    [mapping addAttributeMapping:nameMapping];
    
    NSDictionary* dictionary = [RKSpecParseFixture(@"user.json") mutableCopy];
    [dictionary setValue:[NSNull null] forKey:@"name"];
    RKSpecUser* user = [RKSpecUser user];
    user.name = @"Blake Watters";
    id mockUser = [OCMockObject partialMockForObject:user];
    [[mockUser expect] setName:nil];
    RKObjectMappingOperation* operation = [[RKObjectMappingOperation alloc] initWithSourceObject:dictionary destinationObject:user mapping:mapping];
    NSError* error = nil;
    [operation performMapping:&error];
    [mockUser verify];
}

- (void)itShouldOptionallySetDefaultValueForAMissingKeyPath {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    RKObjectAttributeMapping* nameMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"name" toKeyPath:@"name"];
    [mapping addAttributeMapping:nameMapping];
    
    NSMutableDictionary* dictionary = [RKSpecParseFixture(@"user.json") mutableCopy];
    [dictionary removeObjectForKey:@"name"];
    RKSpecUser* user = [RKSpecUser user];
    user.name = @"Blake Watters";
    id mockUser = [OCMockObject partialMockForObject:user];
    [[mockUser expect] setName:nil];
    RKObjectMappingOperation* operation = [[RKObjectMappingOperation alloc] initWithSourceObject:dictionary destinationObject:user mapping:mapping];
    id mockMapping = [OCMockObject partialMockForObject:mapping];
    BOOL returnValue = YES;
    [[[mockMapping expect] andReturnValue:OCMOCK_VALUE(returnValue)] shouldSetDefaultValueForMissingAttributes];
    NSError* error = nil;
    [operation performMapping:&error];
    [mockUser verify];
}

- (void)itShouldOptionallyIgnoreAMissingSourceKeyPath {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    RKObjectAttributeMapping* nameMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"name" toKeyPath:@"name"];
    [mapping addAttributeMapping:nameMapping];
    
    NSMutableDictionary* dictionary = [RKSpecParseFixture(@"user.json") mutableCopy];
    [dictionary removeObjectForKey:@"name"];
    RKSpecUser* user = [RKSpecUser user];
    user.name = @"Blake Watters";
    id mockUser = [OCMockObject partialMockForObject:user];
    [[mockUser reject] setName:nil];
    RKObjectMappingOperation* operation = [[RKObjectMappingOperation alloc] initWithSourceObject:dictionary destinationObject:user mapping:mapping];
    id mockMapping = [OCMockObject partialMockForObject:mapping];
    BOOL returnValue = NO;
    [[[mockMapping expect] andReturnValue:OCMOCK_VALUE(returnValue)] shouldSetDefaultValueForMissingAttributes];
    NSError* error = nil;
    [operation performMapping:&error];
    [expectThat(user.name) should:be(@"Blake Watters")];
}

#pragma mark - Relationship Mapping

- (void)itShouldMapANestedObject {
    RKObjectMapping* userMapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    RKObjectAttributeMapping* nameMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"name" toKeyPath:@"name"];
    [userMapping addAttributeMapping:nameMapping];
    RKObjectMapping* addressMapping = [RKObjectMapping mappingForClass:[RKSpecAddress class]];
    RKObjectAttributeMapping* cityMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"city" toKeyPath:@"city"];
    [addressMapping addAttributeMapping:cityMapping];
    
    RKObjectRelationshipMapping* hasOneMapping = [RKObjectRelationshipMapping mappingFromKeyPath:@"address" toKeyPath:@"address" withMapping:addressMapping];
    [userMapping addRelationshipMapping:hasOneMapping];
    
    RKObjectMapper* mapper = [RKObjectMapper new];
    id userInfo = RKSpecParseFixture(@"user.json");
    RKSpecUser* user = [RKSpecUser user];
    BOOL success = [mapper mapFromObject:userInfo toObject:user atKeyPath:@"" usingMapping:userMapping];
    [mapper release];
    [expectThat(success) should:be(YES)];
    [expectThat(user.name) should:be(@"Blake Watters")];
    [expectThat(user.address) shouldNot:be(nil)];
}

- (void)itShouldMapANestedObjectToCollection {
    RKObjectMapping* userMapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    RKObjectAttributeMapping* nameMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"name" toKeyPath:@"name"];
    [userMapping addAttributeMapping:nameMapping];
    RKObjectMapping* addressMapping = [RKObjectMapping mappingForClass:[RKSpecAddress class]];
    RKObjectAttributeMapping* cityMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"city" toKeyPath:@"city"];
    [addressMapping addAttributeMapping:cityMapping];
    
    RKObjectRelationshipMapping* hasOneMapping = [RKObjectRelationshipMapping mappingFromKeyPath:@"address" toKeyPath:@"friends" withMapping:addressMapping];
    [userMapping addRelationshipMapping:hasOneMapping];
    
    RKObjectMapper* mapper = [RKObjectMapper new];
    id userInfo = RKSpecParseFixture(@"user.json");
    RKSpecUser* user = [RKSpecUser user];
    BOOL success = [mapper mapFromObject:userInfo toObject:user atKeyPath:@"" usingMapping:userMapping];
    [mapper release];
    [expectThat(success) should:be(YES)];
    [expectThat(user.name) should:be(@"Blake Watters")];
    [expectThat(user.friends) shouldNot:be(nil)];
    [expectThat([user.friends count]) should:be(1)];
}

- (void)itShouldMapANestedObjectCollection {
    RKObjectMapping* userMapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    RKObjectAttributeMapping* nameMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"name" toKeyPath:@"name"];
    [userMapping addAttributeMapping:nameMapping];
    
    RKObjectRelationshipMapping* hasManyMapping = [RKObjectRelationshipMapping mappingFromKeyPath:@"friends" toKeyPath:@"friends" withMapping:userMapping];
    [userMapping addRelationshipMapping:hasManyMapping];
    
    RKObjectMapper* mapper = [RKObjectMapper new];
    id userInfo = RKSpecParseFixture(@"user.json");
    RKSpecUser* user = [RKSpecUser user];
    BOOL success = [mapper mapFromObject:userInfo toObject:user atKeyPath:@"" usingMapping:userMapping];
    [mapper release];
    [expectThat(success) should:be(YES)];
    [expectThat(user.name) should:be(@"Blake Watters")];
    [expectThat(user.friends) shouldNot:be(nil)];
    [expectThat([user.friends count]) should:be(2)];
    NSArray* names = [NSArray arrayWithObjects:@"Jeremy Ellison", @"Rachit Shukla", nil];
    assertThat([user.friends valueForKey:@"name"], is(equalTo(names)));
}

- (void)itShouldMapANestedArrayIntoASet {
    RKObjectMapping* userMapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    RKObjectAttributeMapping* nameMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"name" toKeyPath:@"name"];
    [userMapping addAttributeMapping:nameMapping];
    
    RKObjectRelationshipMapping* hasManyMapping = [RKObjectRelationshipMapping mappingFromKeyPath:@"friends" toKeyPath:@"friendsSet" withMapping:userMapping];
    [userMapping addRelationshipMapping:hasManyMapping];
    
    RKObjectMapper* mapper = [RKObjectMapper new];
    id userInfo = RKSpecParseFixture(@"user.json");
    RKSpecUser* user = [RKSpecUser user];
    BOOL success = [mapper mapFromObject:userInfo toObject:user atKeyPath:@"" usingMapping:userMapping];
    [mapper release];
    [expectThat(success) should:be(YES)];
    [expectThat(user.name) should:be(@"Blake Watters")];
    [expectThat(user.friendsSet) shouldNot:be(nil)];
    [expectThat([user.friendsSet isKindOfClass:[NSSet class]]) should:be(YES)];
    [expectThat([user.friendsSet count]) should:be(2)];
    NSSet* names = [NSSet setWithObjects:@"Jeremy Ellison", @"Rachit Shukla", nil];
    assertThat([user.friendsSet valueForKey:@"name"], is(equalTo(names)));
}

- (void)itShouldNotSetThePropertyWhenTheNestedObjectIsIdentical {
    RKSpecUser* user = [RKSpecUser user];
    RKSpecAddress* address = [RKSpecAddress address];
    address.addressID = [NSNumber numberWithInt:1234];
    user.address = address;
    id mockUser = [OCMockObject partialMockForObject:user];
    [[mockUser reject] setAddress:OCMOCK_ANY];
    
    RKObjectMapping* userMapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    RKObjectAttributeMapping* nameMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"name" toKeyPath:@"name"];
    [userMapping addAttributeMapping:nameMapping];
    RKObjectMapping* addressMapping = [RKObjectMapping mappingForClass:[RKSpecAddress class]];
    RKObjectAttributeMapping* idMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"id" toKeyPath:@"addressID"];
    [addressMapping addAttributeMapping:idMapping];
    
    RKObjectRelationshipMapping* hasOneMapping = [RKObjectRelationshipMapping mappingFromKeyPath:@"address" toKeyPath:@"address" withMapping:addressMapping];
    [userMapping addRelationshipMapping:hasOneMapping];
    
    RKObjectMapper* mapper = [RKObjectMapper new];
    id userInfo = RKSpecParseFixture(@"user.json");
    [mapper mapFromObject:userInfo toObject:user atKeyPath:@"" usingMapping:userMapping];
    [mapper release];
}

- (void)itShouldNotSetThePropertyWhenTheNestedObjectCollectionIsIdentical {
    RKObjectMapping* userMapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    RKObjectAttributeMapping* idMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"id" toKeyPath:@"userID"];
    RKObjectAttributeMapping* nameMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"name" toKeyPath:@"name"];
    [userMapping addAttributeMapping:idMapping];
    [userMapping addAttributeMapping:nameMapping];
    
    RKObjectRelationshipMapping* hasManyMapping = [RKObjectRelationshipMapping mappingFromKeyPath:@"friends" toKeyPath:@"friends" withMapping:userMapping];
    [userMapping addRelationshipMapping:hasManyMapping];
    
    RKObjectMapper* mapper = [RKObjectMapper new];
    id userInfo = RKSpecParseFixture(@"user.json");
    RKSpecUser* user = [RKSpecUser user];
    
    // Set the friends up
    RKSpecUser* jeremy = [RKSpecUser user];
    jeremy.name = @"Jeremy Ellison";
    jeremy.userID = [NSNumber numberWithInt:187];
    RKSpecUser* rachit = [RKSpecUser user];
    rachit.name = @"Rachit Shukla"; 
    rachit.userID = [NSNumber numberWithInt:7];
    user.friends = [NSArray arrayWithObjects:jeremy, rachit, nil];
    
    id mockUser = [OCMockObject partialMockForObject:user];
    [[mockUser reject] setFriends:OCMOCK_ANY];
    [mapper mapFromObject:userInfo toObject:mockUser atKeyPath:@"" usingMapping:userMapping];
    [mapper release];
    [mockUser verify];
}

- (void)itShouldOptionallyNilOutTheRelationshipIfItIsMissing {
    RKSpecUser* user = [RKSpecUser user];
    RKSpecAddress* address = [RKSpecAddress address];
    address.addressID = [NSNumber numberWithInt:1234];
    user.address = address;
    id mockUser = [OCMockObject partialMockForObject:user];
    [[mockUser expect] setAddress:nil];
    
    RKObjectMapping* userMapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    RKObjectAttributeMapping* nameMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"name" toKeyPath:@"name"];
    [userMapping addAttributeMapping:nameMapping];
    RKObjectMapping* addressMapping = [RKObjectMapping mappingForClass:[RKSpecAddress class]];
    RKObjectAttributeMapping* idMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"id" toKeyPath:@"addressID"];
    [addressMapping addAttributeMapping:idMapping];
    RKObjectRelationshipMapping* relationshipMapping = [RKObjectRelationshipMapping mappingFromKeyPath:@"address" toKeyPath:@"address" withMapping:addressMapping];
    [userMapping addRelationshipMapping:relationshipMapping];
    
    NSMutableDictionary* dictionary = [RKSpecParseFixture(@"user.json") mutableCopy];
    [dictionary removeObjectForKey:@"address"];    
    id mockMapping = [OCMockObject partialMockForObject:userMapping];
    BOOL returnValue = YES;
    [[[mockMapping expect] andReturnValue:OCMOCK_VALUE(returnValue)] setNilForMissingRelationships];
    RKObjectMappingOperation* operation = [[RKObjectMappingOperation alloc] initWithSourceObject:dictionary destinationObject:mockUser mapping:mockMapping];
    
    NSError* error = nil;
    [operation performMapping:&error];
    [mockUser verify];
}

- (void)itShouldNotNilOutTheRelationshipIfItIsMissingAndCurrentlyNilOnTheTargetObject {
    RKSpecUser* user = [RKSpecUser user];
    user.address = nil;
    id mockUser = [OCMockObject partialMockForObject:user];
    [[mockUser reject] setAddress:nil];
    
    RKObjectMapping* userMapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    RKObjectAttributeMapping* nameMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"name" toKeyPath:@"name"];
    [userMapping addAttributeMapping:nameMapping];
    RKObjectMapping* addressMapping = [RKObjectMapping mappingForClass:[RKSpecAddress class]];
    RKObjectAttributeMapping* idMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"id" toKeyPath:@"addressID"];
    [addressMapping addAttributeMapping:idMapping];
    RKObjectRelationshipMapping* relationshipMapping = [RKObjectRelationshipMapping mappingFromKeyPath:@"address" toKeyPath:@"address" withMapping:addressMapping];
    [userMapping addRelationshipMapping:relationshipMapping];
    
    NSMutableDictionary* dictionary = [RKSpecParseFixture(@"user.json") mutableCopy];
    [dictionary removeObjectForKey:@"address"];    
    id mockMapping = [OCMockObject partialMockForObject:userMapping];
    BOOL returnValue = YES;
    [[[mockMapping expect] andReturnValue:OCMOCK_VALUE(returnValue)] setNilForMissingRelationships];
    RKObjectMappingOperation* operation = [[RKObjectMappingOperation alloc] initWithSourceObject:dictionary destinationObject:mockUser mapping:mockMapping];
    
    NSError* error = nil;
    [operation performMapping:&error];
    [mockUser verify];
}

#pragma mark - RKObjectMappingProvider

- (void)itShouldRegisterRailsIdiomaticObjects {    
    RKObjectManager* objectManager = RKSpecNewObjectManager();
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    [mapping mapAttributes:@"name", @"website", nil];
    [mapping mapKeyPath:@"id" toAttribute:@"userID"];
    
    [objectManager.router routeClass:[RKSpecUser class] toResourcePath:@"/humans/:userID"];
    [objectManager.router routeClass:[RKSpecUser class] toResourcePath:@"/humans" forMethod:RKRequestMethodPOST];
    [objectManager.mappingProvider registerMapping:mapping withRootKeyPath:@"human"];
    
    RKSpecUser* user = [RKSpecUser new];
    user.userID = [NSNumber numberWithInt:1];
    
    RKSpecResponseLoader* loader = [RKSpecResponseLoader responseLoader];
    loader.timeout = 5;
    [objectManager getObject:user delegate:loader];
    [loader waitForResponse];
    assertThatBool(loader.success, is(equalToBool(YES)));
    assertThat(user.name, is(equalTo(@"Blake Watters")));
    
    [objectManager postObject:user delegate:loader];
    [loader waitForResponse];
    assertThatBool(loader.success, is(equalToBool(YES)));
    assertThat(user.name, is(equalTo(@"My Name")));
    assertThat(user.website, is(equalTo([NSURL URLWithString:@"http://restkit.org/"])));
}

- (void)itShouldReturnAllMappingsForAClass {
    RKObjectMapping* firstMapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    RKObjectMapping* secondMapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    RKObjectMapping* thirdMapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    RKObjectMappingProvider* mappingProvider = [[RKObjectMappingProvider new] autorelease];
    [mappingProvider addObjectMapping:firstMapping];
    [mappingProvider addObjectMapping:secondMapping];
    [mappingProvider setMapping:thirdMapping forKeyPath:@"third"];
    assertThat([mappingProvider objectMappingsForClass:[RKSpecUser class]], is(equalTo([NSArray arrayWithObjects:firstMapping, secondMapping, thirdMapping, nil])));
}

- (void)itShouldReturnAllMappingsForAClassAndNotExplodeWithRegisteredDynamicMappings {
    RKObjectMappingProvider* provider = [[RKObjectMappingProvider new] autorelease];
    RKObjectMapping* boyMapping = [RKObjectMapping mappingForClass:[Boy class]];
    [boyMapping mapAttributes:@"name", nil];
    RKObjectMapping* girlMapping = [RKObjectMapping mappingForClass:[Girl class]];
    [girlMapping mapAttributes:@"name", nil];
    RKDynamicObjectMapping* dynamicMapping = [RKDynamicObjectMapping dynamicMapping];
    [dynamicMapping setObjectMapping:boyMapping whenValueOfKeyPath:@"type" isEqualTo:@"Boy"];
    [dynamicMapping setObjectMapping:girlMapping whenValueOfKeyPath:@"type" isEqualTo:@"Girl"];
    [provider setMapping:dynamicMapping forKeyPath:@"dynamic"];
    RKObjectMapping* firstMapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    RKObjectMapping* secondMapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    [provider addObjectMapping:firstMapping];
    [provider setMapping:secondMapping forKeyPath:@"second"];
    NSException* exception = nil;
    NSArray *actualMappings = nil;
    @try {
        actualMappings = [provider objectMappingsForClass:[RKSpecUser class]];
    }
    @catch (NSException * e) {
        exception = e;
    }
    [expectThat(exception) should:be(nil)];
    assertThat(actualMappings, is(equalTo([NSArray arrayWithObjects:firstMapping, secondMapping, nil])));
}

#pragma mark - RKDynamicObjectMapping

- (void)itShouldMapASingleObjectDynamically {
    RKObjectMapping* boyMapping = [RKObjectMapping mappingForClass:[Boy class]];
    [boyMapping mapAttributes:@"name", nil];
    RKObjectMapping* girlMapping = [RKObjectMapping mappingForClass:[Girl class]];
    [girlMapping mapAttributes:@"name", nil];
    RKDynamicObjectMapping* dynamicMapping = [RKDynamicObjectMapping dynamicMapping];
    dynamicMapping.objectMappingForDataBlock = ^ RKObjectMapping* (id mappableData) {
        if ([[mappableData valueForKey:@"type"] isEqualToString:@"Boy"]) {
            return boyMapping;
        } else if ([[mappableData valueForKey:@"type"] isEqualToString:@"Girl"]) {
            return girlMapping;
        }
        
        return nil;
    };
    
    RKObjectMappingProvider* provider = [[RKObjectMappingProvider new] autorelease];
    [provider setMapping:dynamicMapping forKeyPath:@""];
    id mockProvider = [OCMockObject partialMockForObject:provider];
    
    id userInfo = RKSpecParseFixture(@"boy.json");
    RKObjectMapper* mapper = [RKObjectMapper mapperWithObject:userInfo mappingProvider:mockProvider];
    Boy* user = [[mapper performMapping] asObject];
    assertThat(user, is(instanceOf([Boy class])));
    assertThat(user.name, is(equalTo(@"Blake Watters")));
}

- (void)itShouldMapASingleObjectDynamicallyWithADeclarativeMatcher {
    RKObjectMapping* boyMapping = [RKObjectMapping mappingForClass:[Boy class]];
    [boyMapping mapAttributes:@"name", nil];
    RKObjectMapping* girlMapping = [RKObjectMapping mappingForClass:[Girl class]];
    [girlMapping mapAttributes:@"name", nil];
    RKDynamicObjectMapping* dynamicMapping = [RKDynamicObjectMapping dynamicMapping];
    [dynamicMapping setObjectMapping:boyMapping whenValueOfKeyPath:@"type" isEqualTo:@"Boy"];
    [dynamicMapping setObjectMapping:girlMapping whenValueOfKeyPath:@"type" isEqualTo:@"Girl"];
    
    RKObjectMappingProvider* provider = [[RKObjectMappingProvider new] autorelease];
    [provider setMapping:dynamicMapping forKeyPath:@""];
    id mockProvider = [OCMockObject partialMockForObject:provider];
    
    id userInfo = RKSpecParseFixture(@"boy.json");
    RKObjectMapper* mapper = [RKObjectMapper mapperWithObject:userInfo mappingProvider:mockProvider];
    Boy* user = [[mapper performMapping] asObject];
    assertThat(user, is(instanceOf([Boy class])));
    assertThat(user.name, is(equalTo(@"Blake Watters")));
}

- (void)itShouldACollectionOfObjectsDynamically {
    RKObjectMapping* boyMapping = [RKObjectMapping mappingForClass:[Boy class]];
    [boyMapping mapAttributes:@"name", nil];
    RKObjectMapping* girlMapping = [RKObjectMapping mappingForClass:[Girl class]];
    [girlMapping mapAttributes:@"name", nil];
    RKDynamicObjectMapping* dynamicMapping = [RKDynamicObjectMapping dynamicMapping];
    [dynamicMapping setObjectMapping:boyMapping whenValueOfKeyPath:@"type" isEqualTo:@"Boy"];
    [dynamicMapping setObjectMapping:girlMapping whenValueOfKeyPath:@"type" isEqualTo:@"Girl"];
    
    RKObjectMappingProvider* provider = [[RKObjectMappingProvider new] autorelease];
    [provider setMapping:dynamicMapping forKeyPath:@""];
    id mockProvider = [OCMockObject partialMockForObject:provider];
    
    id userInfo = RKSpecParseFixture(@"mixed.json");
    RKObjectMapper* mapper = [RKObjectMapper mapperWithObject:userInfo mappingProvider:mockProvider];
    NSArray* objects = [[mapper performMapping] asCollection];
    assertThat(objects, hasCountOf(2));
    assertThat([objects objectAtIndex:0], is(instanceOf([Boy class])));
    assertThat([objects objectAtIndex:1], is(instanceOf([Girl class])));
    Boy* boy = [objects objectAtIndex:0];
    Girl* girl = [objects objectAtIndex:1];
    assertThat(boy.name, is(equalTo(@"Blake Watters")));
    assertThat(girl.name, is(equalTo(@"Sarah")));
}

- (void)itShouldMapARelationshipDynamically {
    RKObjectMapping* boyMapping = [RKObjectMapping mappingForClass:[Boy class]];
    [boyMapping mapAttributes:@"name", nil];
    RKObjectMapping* girlMapping = [RKObjectMapping mappingForClass:[Girl class]];
    [girlMapping mapAttributes:@"name", nil];
    RKDynamicObjectMapping* dynamicMapping = [RKDynamicObjectMapping dynamicMapping];
    [dynamicMapping setObjectMapping:boyMapping whenValueOfKeyPath:@"type" isEqualTo:@"Boy"];
    [dynamicMapping setObjectMapping:girlMapping whenValueOfKeyPath:@"type" isEqualTo:@"Girl"];
    [boyMapping mapKeyPath:@"friends" toRelationship:@"friends" withMapping:dynamicMapping];
    
    RKObjectMappingProvider* provider = [[RKObjectMappingProvider new] autorelease];
    [provider setMapping:dynamicMapping forKeyPath:@""];
    id mockProvider = [OCMockObject partialMockForObject:provider];
    
    id userInfo = RKSpecParseFixture(@"friends.json");
    RKObjectMapper* mapper = [RKObjectMapper mapperWithObject:userInfo mappingProvider:mockProvider];
    Boy* blake = [[mapper performMapping] asObject];
    NSArray* friends = blake.friends;
    
    assertThat(friends, hasCountOf(2));
    assertThat([friends objectAtIndex:0], is(instanceOf([Boy class])));
    assertThat([friends objectAtIndex:1], is(instanceOf([Girl class])));
    Boy* boy = [friends objectAtIndex:0];
    Girl* girl = [friends objectAtIndex:1];
    assertThat(boy.name, is(equalTo(@"John Doe")));
    assertThat(girl.name, is(equalTo(@"Jane Doe")));
}

- (void)itShouldBeAbleToDeclineMappingAnObjectByReturningANilObjectMapping {
    RKObjectMapping* boyMapping = [RKObjectMapping mappingForClass:[Boy class]];
    [boyMapping mapAttributes:@"name", nil];
    RKObjectMapping* girlMapping = [RKObjectMapping mappingForClass:[Girl class]];
    [girlMapping mapAttributes:@"name", nil];
    RKDynamicObjectMapping* dynamicMapping = [RKDynamicObjectMapping dynamicMapping];
    dynamicMapping.objectMappingForDataBlock = ^ RKObjectMapping* (id mappableData) {
        if ([[mappableData valueForKey:@"type"] isEqualToString:@"Boy"]) {
            return boyMapping;
        } else if ([[mappableData valueForKey:@"type"] isEqualToString:@"Girl"]) {
            // NO GIRLS ALLOWED(*$!)(*
            return nil;
        }
        
        return nil;
    };
    
    RKObjectMappingProvider* provider = [[RKObjectMappingProvider new] autorelease];
    [provider setMapping:dynamicMapping forKeyPath:@""];
    id mockProvider = [OCMockObject partialMockForObject:provider];
    
    id userInfo = RKSpecParseFixture(@"mixed.json");
    RKObjectMapper* mapper = [RKObjectMapper mapperWithObject:userInfo mappingProvider:mockProvider];
    NSArray* boys = [[mapper performMapping] asCollection];
    assertThat(boys, hasCountOf(1));
    Boy* user = [boys objectAtIndex:0];
    assertThat(user, is(instanceOf([Boy class])));
    assertThat(user.name, is(equalTo(@"Blake Watters")));
}

- (void)itShouldBeAbleToDeclineMappingObjectsInARelationshipByReturningANilObjectMapping {
    RKObjectMapping* boyMapping = [RKObjectMapping mappingForClass:[Boy class]];
    [boyMapping mapAttributes:@"name", nil];
    RKObjectMapping* girlMapping = [RKObjectMapping mappingForClass:[Girl class]];
    [girlMapping mapAttributes:@"name", nil];
    RKDynamicObjectMapping* dynamicMapping = [RKDynamicObjectMapping dynamicMapping];
    dynamicMapping.objectMappingForDataBlock = ^ RKObjectMapping* (id mappableData) {
        if ([[mappableData valueForKey:@"type"] isEqualToString:@"Boy"]) {
            return boyMapping;
        } else if ([[mappableData valueForKey:@"type"] isEqualToString:@"Girl"]) {
            // NO GIRLS ALLOWED(*$!)(*
            return nil;
        }
        
        return nil;
    };
    [boyMapping mapKeyPath:@"friends" toRelationship:@"friends" withMapping:dynamicMapping];
    
    RKObjectMappingProvider* provider = [[RKObjectMappingProvider new] autorelease];
    [provider setMapping:dynamicMapping forKeyPath:@""];
    id mockProvider = [OCMockObject partialMockForObject:provider];
    
    id userInfo = RKSpecParseFixture(@"friends.json");
    RKObjectMapper* mapper = [RKObjectMapper mapperWithObject:userInfo mappingProvider:mockProvider];
    Boy* blake = [[mapper performMapping] asObject];
    assertThat(blake, is(notNilValue()));
    assertThat(blake.name, is(equalTo(@"Blake Watters")));
    assertThat(blake, is(instanceOf([Boy class])));
    NSArray* friends = blake.friends;
    
    assertThat(friends, hasCountOf(1));
    assertThat([friends objectAtIndex:0], is(instanceOf([Boy class])));
    Boy* boy = [friends objectAtIndex:0];
    assertThat(boy.name, is(equalTo(@"John Doe")));
}

- (void)itShouldMapATargetObjectWithADynamicMapping {
    RKObjectMapping* boyMapping = [RKObjectMapping mappingForClass:[Boy class]];
    [boyMapping mapAttributes:@"name", nil];
    RKDynamicObjectMapping* dynamicMapping = [RKDynamicObjectMapping dynamicMapping];
    dynamicMapping.objectMappingForDataBlock = ^ RKObjectMapping* (id mappableData) {
        if ([[mappableData valueForKey:@"type"] isEqualToString:@"Boy"]) {
            return boyMapping;
        }
        
        return nil;
    };
    
    RKObjectMappingProvider* provider = [RKObjectMappingProvider objectMappingProvider];
    [provider setMapping:dynamicMapping forKeyPath:@""];
    
    id userInfo = RKSpecParseFixture(@"boy.json");
    Boy* blake = [[Boy new] autorelease];
    RKObjectMapper* mapper = [RKObjectMapper mapperWithObject:userInfo mappingProvider:provider];
    mapper.targetObject = blake;
    Boy* user = [[mapper performMapping] asObject];
    assertThat(user, is(instanceOf([Boy class])));
    assertThat(user.name, is(equalTo(@"Blake Watters")));
}

- (void)itShouldBeBackwardsCompatibleWithTheOldClassName {
    RKObjectMapping* boyMapping = [RKObjectMapping mappingForClass:[Boy class]];
    [boyMapping mapAttributes:@"name", nil];
    RKObjectDynamicMapping* dynamicMapping = (RKObjectDynamicMapping *) [RKObjectDynamicMapping dynamicMapping];
    dynamicMapping.objectMappingForDataBlock = ^ RKObjectMapping* (id mappableData) {
        if ([[mappableData valueForKey:@"type"] isEqualToString:@"Boy"]) {
            return boyMapping;
        }
        
        return nil;
    };
    
    RKObjectMappingProvider* provider = [RKObjectMappingProvider objectMappingProvider];
    [provider setMapping:dynamicMapping forKeyPath:@""];
    
    id userInfo = RKSpecParseFixture(@"boy.json");
    Boy* blake = [[Boy new] autorelease];
    RKObjectMapper* mapper = [RKObjectMapper mapperWithObject:userInfo mappingProvider:provider];
    mapper.targetObject = blake;
    Boy* user = [[mapper performMapping] asObject];
    assertThat(user, is(instanceOf([Boy class])));
    assertThat(user.name, is(equalTo(@"Blake Watters")));
}

- (void)itShouldFailWithAnErrorIfATargetObjectIsProvidedAndTheDynamicMappingReturnsNil {
    RKObjectMapping* boyMapping = [RKObjectMapping mappingForClass:[Boy class]];
    [boyMapping mapAttributes:@"name", nil];
    RKDynamicObjectMapping* dynamicMapping = [RKDynamicObjectMapping dynamicMapping];
    dynamicMapping.objectMappingForDataBlock = ^ RKObjectMapping* (id mappableData) {
        return nil;
    };
    
    RKObjectMappingProvider* provider = [RKObjectMappingProvider objectMappingProvider];
    [provider setMapping:dynamicMapping forKeyPath:@""];
    
    id userInfo = RKSpecParseFixture(@"boy.json");
    Boy* blake = [[Boy new] autorelease];
    RKObjectMapper* mapper = [RKObjectMapper mapperWithObject:userInfo mappingProvider:provider];
    mapper.targetObject = blake;
    Boy* user = [[mapper performMapping] asObject];
    assertThat(user, is(nilValue()));
    assertThat(mapper.errors, hasCountOf(1));
}

- (void)itShouldFailWithAnErrorIfATargetObjectIsProvidedAndTheDynamicMappingReturnsTheIncorrectType {
    RKObjectMapping* girlMapping = [RKObjectMapping mappingForClass:[Girl class]];
    [girlMapping mapAttributes:@"name", nil];
    RKDynamicObjectMapping* dynamicMapping = [RKDynamicObjectMapping dynamicMapping];
    dynamicMapping.objectMappingForDataBlock = ^ RKObjectMapping* (id mappableData) {
        if ([[mappableData valueForKey:@"type"] isEqualToString:@"Girl"]) {
            return girlMapping;
        }
        
        return nil;
    };
    
    RKObjectMappingProvider* provider = [RKObjectMappingProvider objectMappingProvider];
    [provider setMapping:dynamicMapping forKeyPath:@""];
    
    id userInfo = RKSpecParseFixture(@"girl.json");
    Boy* blake = [[Boy new] autorelease];
    RKObjectMapper* mapper = [RKObjectMapper mapperWithObject:userInfo mappingProvider:provider];
    mapper.targetObject = blake;
    Boy* user = [[mapper performMapping] asObject];
    assertThat(user, is(nilValue()));
    assertThat(mapper.errors, hasCountOf(1));
}

#pragma mark - Date and Time Formatting

- (void)itShouldAutoConfigureDefaultDateFormatters {
    [RKObjectMapping setDefaultDateFormatters:nil];
    NSArray *dateFormatters = [RKObjectMapping defaultDateFormatters];
    assertThat(dateFormatters, hasCountOf(2));
    assertThat([[dateFormatters objectAtIndex:0] dateFormat], is(equalTo(@"yyyy-MM-dd'T'HH:mm:ss'Z'")));
    assertThat([[dateFormatters objectAtIndex:1] dateFormat], is(equalTo(@"MM/dd/yyyy")));
    NSTimeZone *UTCTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    assertThat([[dateFormatters objectAtIndex:0] timeZone], is(equalTo(UTCTimeZone)));
    assertThat([[dateFormatters objectAtIndex:1] timeZone], is(equalTo(UTCTimeZone)));
}

- (void)itShouldLetYouSetTheDefaultDateFormatters {
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    NSArray *dateFormatters = [NSArray arrayWithObject:dateFormatter];
    [RKObjectMapping setDefaultDateFormatters:dateFormatters];
    assertThat([RKObjectMapping defaultDateFormatters], is(equalTo(dateFormatters)));
}

- (void)itShouldLetYouAppendADateFormatterToTheList {
    [RKObjectMapping setDefaultDateFormatters:nil];
    assertThat([RKObjectMapping defaultDateFormatters], hasCountOf(2));
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [RKObjectMapping addDefaultDateFormatter:dateFormatter];
    assertThat([RKObjectMapping defaultDateFormatters], hasCountOf(3));
}

- (void)itShouldLetYouConfigureANewDateFormatterFromAStringAndATimeZone {
    [RKObjectMapping setDefaultDateFormatters:nil];
    assertThat([RKObjectMapping defaultDateFormatters], hasCountOf(2));
    NSTimeZone *EDTTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"EDT"];
    [RKObjectMapping addDefaultDateFormatterForString:@"mm/dd/YYYY" inTimeZone:EDTTimeZone];
    assertThat([RKObjectMapping defaultDateFormatters], hasCountOf(3));
    NSDateFormatter *dateFormatter = [[RKObjectMapping defaultDateFormatters] objectAtIndex:2];
    assertThat(dateFormatter.timeZone, is(equalTo(EDTTimeZone)));
}

- (void)itShouldConfigureANewDateFormatterInTheUTCTimeZoneIfPassedANilTimeZone {
    [RKObjectMapping setDefaultDateFormatters:nil];
    assertThat([RKObjectMapping defaultDateFormatters], hasCountOf(2));
    [RKObjectMapping addDefaultDateFormatterForString:@"mm/dd/YYYY" inTimeZone:nil];
    assertThat([RKObjectMapping defaultDateFormatters], hasCountOf(3));
    NSDateFormatter *dateFormatter = [[RKObjectMapping defaultDateFormatters] objectAtIndex:2];
    NSTimeZone *UTCTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    assertThat(dateFormatter.timeZone, is(equalTo(UTCTimeZone)));
}

#pragma mark - Object Serialization
// TODO: Move to RKObjectSerializerSpec

- (void)itShouldSerializeHasOneRelatioshipsToJSON {
    RKObjectMapping* userMapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    [userMapping mapAttributes:@"name", nil];
    RKObjectMapping* addressMapping = [RKObjectMapping mappingForClass:[RKSpecAddress class]];
    [addressMapping mapAttributes:@"city", @"state", nil];
    [userMapping hasOne:@"address" withMapping:addressMapping];
    
    RKSpecUser *user = [RKSpecUser new];
    user.name = @"Blake Watters";
    RKSpecAddress *address = [RKSpecAddress new];
    address.state = @"North Carolina";
    user.address = address;
    
    RKObjectMapping *serializationMapping = [userMapping inverseMapping];
    RKObjectSerializer* serializer = [RKObjectSerializer serializerWithObject:user mapping:serializationMapping];
    NSError* error = nil;
    NSString *JSON = [serializer serializedObjectForMIMEType:RKMIMETypeJSON error:&error];
    assertThat(error, is(nilValue()));
    assertThat(JSON, is(equalTo(@"{\"name\":\"Blake Watters\",\"address\":{\"state\":\"North Carolina\"}}")));
}

- (void)itShouldSerializeHasManyRelationshipsToJSON {
    RKObjectMapping* userMapping = [RKObjectMapping mappingForClass:[RKSpecUser class]];
    [userMapping mapAttributes:@"name", nil];
    RKObjectMapping* addressMapping = [RKObjectMapping mappingForClass:[RKSpecAddress class]];
    [addressMapping mapAttributes:@"city", @"state", nil];
    [userMapping hasMany:@"friends" withMapping:addressMapping];
    
    RKSpecUser *user = [RKSpecUser new];
    user.name = @"Blake Watters";
    RKSpecAddress *address1 = [RKSpecAddress new];
    address1.city = @"Carrboro";
    RKSpecAddress *address2 = [RKSpecAddress new];
    address2.city = @"New York City";
    user.friends = [NSArray arrayWithObjects:address1, address2, nil];
    
    
    RKObjectMapping *serializationMapping = [userMapping inverseMapping];
    RKObjectSerializer* serializer = [RKObjectSerializer serializerWithObject:user mapping:serializationMapping];
    NSError* error = nil;
    NSString *JSON = [serializer serializedObjectForMIMEType:RKMIMETypeJSON error:&error];
    assertThat(error, is(nilValue()));
    assertThat(JSON, is(equalTo(@"{\"name\":\"Blake Watters\",\"friends\":[{\"city\":\"Carrboro\"},{\"city\":\"New York City\"}]}")));
}

- (void)itShouldSerializeManagedHasManyRelationshipsToJSON {
    RKSpecNewManagedObjectStore();
    RKObjectMapping* humanMapping = [RKObjectMapping mappingForClass:[RKHuman class]];
    [humanMapping mapAttributes:@"name", nil];
    RKObjectMapping* catMapping = [RKObjectMapping mappingForClass:[RKCat class]];
    [catMapping mapAttributes:@"name", nil];
    [humanMapping hasMany:@"cats" withMapping:catMapping];
    
    RKHuman *blake = [RKHuman object];
    blake.name = @"Blake Watters";
    RKCat *asia = [RKCat object];
    asia.name = @"Asia";
    RKCat *roy = [RKCat object];
    roy.name = @"Roy";
    blake.cats = [NSSet setWithObjects:asia, roy, nil];    
    
    RKObjectMapping *serializationMapping = [humanMapping inverseMapping];
    RKObjectSerializer* serializer = [RKObjectSerializer serializerWithObject:blake mapping:serializationMapping];
    NSError* error = nil;
    NSString *JSON = [serializer serializedObjectForMIMEType:RKMIMETypeJSON error:&error];
    NSDictionary *parsedJSON = [JSON performSelector:@selector(objectFromJSONString)];
    assertThat(error, is(nilValue()));
    assertThat([parsedJSON valueForKey:@"name"], is(equalTo(@"Blake Watters")));
    NSArray *catNames = [[parsedJSON valueForKeyPath:@"cats.name"] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    assertThat(catNames, is(equalTo([NSArray arrayWithObjects:@"Asia", @"Roy", nil])));
}

@end
