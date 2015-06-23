//
//  PMCache.m
//  PlayMakr
//
//  Created by Oliver Andrews on 2015-06-23.
//  Copyright (c) 2015 Oliver Andrews. All rights reserved.
//

#import "PMCache.h"
#import "PMConstants.h"

@interface PMCache()

@property (nonatomic, strong) NSCache *cache;
- (void)setAttributes:(NSDictionary *)attributes forSkill:(PFObject *)skill;
@end

@implementation PMCache

@synthesize cache;

#pragma mark - Initialization

+ (id)sharedCache {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (id)init {
    self = [super init];
    if (self) {
        self.cache = [[NSCache alloc] init];
    }
    return self;
}

#pragma mark - PAPCache

- (void)clear {
    [self.cache removeAllObjects];
}

-(void)setAttributesForSkill:(PFObject *)skill endorsers:(NSArray *)endorsers endorsedByCurrentUser:(BOOL)endorsedByCurrentUser {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithBool:endorsedByCurrentUser],kPMSkillAttributesIsEndorsedByCurrentUserKey,
                                [NSNumber numberWithInt:(int)[endorsers count]],kPMSkillAttributesEndorseCountKey,
                                endorsers,kPMSkillAttributesEndorsersKey,
                                nil];
    [self setAttributes:attributes forSkill:skill];
}

- (NSDictionary *)attributesForSkill:(PFObject *)skill {
    NSString *key = [self keyForSkill:skill];
    return [self.cache objectForKey:key];
}
-(NSNumber *)endorseCountForSkill:(PFObject *)skill {
    NSDictionary *attributes = [self attributesForSkill:skill];
    if (attributes) {
        return [attributes objectForKey:kPMSkillAttributesEndorseCountKey];
    }
    
    return [NSNumber numberWithInt:0];
}

-(NSArray *)endorsersForSkill:(PFObject *)skill {
    NSDictionary *attributes = [self attributesForSkill:skill];
    if (attributes) {
        return [attributes objectForKey:kPMSkillAttributesEndorsersKey];
    }
    
    return [NSArray array];
}
-(void)setSkillIsEndorsedByCurrentUser:(PFObject *)skill endorsed:(BOOL)endorsed {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForSkill:skill]];
    [attributes setObject:[NSNumber numberWithBool:endorsed] forKey:kPMSkillAttributesIsEndorsedByCurrentUserKey];
    [self setAttributes:attributes forSkill:skill];
}
-(BOOL)isSkillEndorsedByCurrentUser:(PFObject *)skill {
    NSDictionary *attributes = [self attributesForSkill:skill];
    if (attributes) {
        return [[attributes objectForKey:kPMSkillAttributesIsEndorsedByCurrentUserKey] boolValue];
    }
    
    return NO;
}

-(void)incrementEndorserCountForSkill:(PFObject *)skill {
    NSNumber *endorserCount = [NSNumber numberWithInt:[[self endorseCountForSkill:skill] intValue] + 1];
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForSkill:skill]];
    [attributes setObject:endorserCount forKey:kPMSkillAttributesEndorseCountKey];
    [self setAttributes:attributes forSkill:skill];
}

-(void)decrementEndorserCountForSkill:(PFObject *)skill {
    NSNumber *endorserCount = [NSNumber numberWithInt:[[self endorseCountForSkill:skill] intValue] - 1];
    if ([endorserCount intValue] < 0) {
        return;
    }
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForSkill:skill]];
    [attributes setObject:endorserCount forKey:kPMSkillAttributesEndorseCountKey];
    [self setAttributes:attributes forSkill:skill];
}

- (void)setAttributesForUser:(PFUser *)user skillCount:(NSNumber *)count followedByCurrentUser:(BOOL)following {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                count,kPMUserAttributesSkillCountKey,
                                [NSNumber numberWithBool:following],kPMUserAttributesIsFollowedByCurrentUserKey,
                                nil];
    [self setAttributes:attributes forUser:user];
}

- (NSDictionary *)attributesForUser:(PFUser *)user {
    NSString *key = [self keyForUser:user];
    return [self.cache objectForKey:key];
}

- (NSNumber *)skillCountForUser:(PFUser *)user {
    NSDictionary *attributes = [self attributesForUser:user];
    if (attributes) {
        NSNumber *skillCount = [attributes objectForKey:kPMUserAttributesSkillCountKey];
        if (skillCount) {
            return skillCount;
        }
    }
    
    return [NSNumber numberWithInt:0];
}

- (BOOL)followStatusForUser:(PFUser *)user {
    NSDictionary *attributes = [self attributesForUser:user];
    if (attributes) {
        NSNumber *followStatus = [attributes objectForKey:kPMUserAttributesIsFollowedByCurrentUserKey];
        if (followStatus) {
            return [followStatus boolValue];
        }
    }
    
    return NO;
}

- (void)setSkillCount:(NSNumber *)count user:(PFUser *)user {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForUser:user]];
    [attributes setObject:count forKey:kPMUserAttributesSkillCountKey];
    [self setAttributes:attributes forUser:user];
}

- (void)setFollowStatus:(BOOL)following user:(PFUser *)user {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForUser:user]];
    [attributes setObject:[NSNumber numberWithBool:following] forKey:kPMUserAttributesIsFollowedByCurrentUserKey];
    [self setAttributes:attributes forUser:user];
}


#pragma mark - ()

- (void)setAttributes:(NSDictionary *)attributes forSkill:(PFObject *)skill {
    NSString *key = [self keyForSkill:skill];
    [self.cache setObject:attributes forKey:key];
}

- (void)setAttributes:(NSDictionary *)attributes forUser:(PFUser *)user {
    NSString *key = [self keyForUser:user];
    [self.cache setObject:attributes forKey:key];
}

- (NSString *)keyForSkill:(PFObject *)skill {
    return [NSString stringWithFormat:@"skill_%@", [skill objectId]];
}

- (NSString *)keyForUser:(PFUser *)user {
    return [NSString stringWithFormat:@"user_%@", [user objectId]];
}

@end
