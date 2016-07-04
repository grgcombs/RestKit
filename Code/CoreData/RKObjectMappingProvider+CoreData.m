//
//  RKObjectMappingProvider+CoreData.m
//  RestKit
//
//  Created by Jeff Arena on 1/26/12.
//  Copyright (c) 2012 RestKit. All rights reserved.
//

#import "RKObjectMappingProvider+CoreData.h"
#import "RKOrderedDictionary.h"

@implementation RKObjectMappingProvider (CoreData)

- (void)setObjectMapping:(RKObjectMappingDefinition *)objectMapping forResourcePathPattern:(NSString *)resourcePath withFetchRequestBlock:(RKObjectMappingProviderFetchRequestBlock)fetchRequestBlock {
    RKObjectMappingProviderFetchRequestBlock copiedBlock = [[fetchRequestBlock copy] autorelease];
    [self setEntry:[RKObjectMappingProviderContextEntry contextEntryWithMapping:objectMapping
                                                                       userData:copiedBlock] forResourcePathPattern:resourcePath];
}

- (NSFetchRequest *)fetchRequestForResourcePath:(NSString *)resourcePath {
    RKObjectMappingProviderContextEntry *entry = [self entryForResourcePath:resourcePath];
    if (entry.userData) {
        NSFetchRequest *(^fetchRequestBlock)(NSString *) = entry.userData;
        return fetchRequestBlock(resourcePath);
    }

    return nil;
}

@end
