/**
 * @brief Implementation of DataCache interface.
 * @author Jackey Cheung
 */
#import "FCDataCache.h"


@implementation FCDataCache


- (id)initWithCapacity:(int)cap
{
  if(nil != (self = [super init]))
  {
    fCapacity   = cap;
    fDictionary = [[NSMutableDictionary alloc] initWithCapacity:cap];
    fAge = [[NSMutableArray alloc] initWithCapacity:cap];
  }
  return self;
}

- (void)dealloc
{
  [fDictionary release];
  [fAge release];
  [super dealloc];
}

- (id)objectForKey:(id)key
{
  // Pull key out of age array and move to front, indicates recently used.
  NSUInteger index = [fAge indexOfObject:key];
  if(index == NSNotFound) return nil;
  if(index != 0)
  {
    [fAge removeObjectAtIndex:index];
    [fAge insertObject:key atIndex:0];
  }
  return [fDictionary objectForKey:key];
}  /* objectForKey */

- (void)setObject:(id)value forKey:(id)key
{
  // Update the age of the inserted object and delete the oldest if needed.
  NSUInteger index = [fAge indexOfObject:key];
  if(index != 0)
  {
    if(index != NSNotFound) [fAge removeObjectAtIndex:index];

    [fAge insertObject:key atIndex:0];

    if([fAge count] > fCapacity)
    {
      id delKey = [fAge lastObject];
      [fDictionary removeObjectForKey:delKey];
      [fAge removeLastObject];
    }
  }
  [fDictionary setObject:value forKey:key];
}  /* setObject */

- (void)removeObjectForKey:(id)key
{
  NSUInteger index = [fAge indexOfObject:key];
  if(index != NSNotFound)
  {
    [fAge removeObjectAtIndex:index];
    [fDictionary removeObjectForKey:key];
  }
}

- (void)removeAllObjects
{
  [fAge removeAllObjects];
  [fDictionary removeAllObjects];
}

- (void)truncateToSize:(int)size
{
  id delKey;
  while([fAge count] > size)
  {
    delKey = [fAge lastObject];
    [fDictionary removeObjectForKey:delKey];
    [fAge removeLastObject];
  }
}


@end
