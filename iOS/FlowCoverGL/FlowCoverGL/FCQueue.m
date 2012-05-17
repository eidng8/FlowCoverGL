//
//  FCQueue.m
//  FlowCoverGL
//
//  Created by Jackey Cheung on 2012-5-4.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "FCQueue.h"


@implementation FCQueue

- (id)initWithSize:(int)size
{
  self = [super init];
  if(!self) return nil;
  queue = [[NSMutableArray arrayWithCapacity:size] retain];
  return self;
}

- (void)dealloc
{
  [queue release];
  queue = nil;
  [super dealloc];
}

- (void)enqueue:(id)object
{
  [queue addObject:object];
}

- (id)dequeue
{
  id ret = [[[queue objectAtIndex:0] retain] autorelease];
  [queue removeObjectAtIndex:0];
  return ret;
}

- (BOOL)isEmpty
{
  return [queue count] <= 0;
}

- (void)clear
{
  [queue removeAllObjects];
}

@end
