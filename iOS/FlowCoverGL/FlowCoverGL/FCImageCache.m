/**
 * @brief Implementation of DataCache interface.
 * @author Jackey Cheung
 */
#import "FCImageCache.h"


@implementation FCImageCache
@synthesize delegate, loadingPlaceHolder;


/**
 * @brief Initialize member variables.
 */
- (void)internalInit:(int)cap
{
  workerStarted = NO;
  loadingQueue = [[FCQueue alloc] initWithSize:cap];
}

- (id)initWithCapacity:(int)cap loadingImage:(UIImage*)image
{
  self = [super initWithCapacity:cap];
  if(!self) return nil;
  loadingPlaceHolder = [image retain];
  [self internalInit:cap];
  return self;
}

- (id)initWithCapacity:(int)cap imageNamed:(NSString*)image
{
  self = [super initWithCapacity:cap];
  if(!self) return nil;
  loadingPlaceHolder = [[UIImage imageNamed:image] retain];
  [self internalInit:cap];
  return self;
}

- (id)initWithCapacity:(int)cap pathToLoadingImage:(NSString*)path
{
  self = [super initWithCapacity:cap];
  if(!self) return nil;
  loadingPlaceHolder = [[UIImage imageWithContentsOfFile:path] retain];
  [self internalInit:cap];
  return self;
}

- (void)dealloc
{
  [loadingPlaceHolder release];
  loadingPlaceHolder = nil;
  workerStarted = NO;
  [super dealloc];
}

- (UIImage*)imageAtPath:(NSString*)path
{
  return [self imageAtPath:path async:NO];
}

- (UIImage*)imageAtPath:(NSString*)path async:(BOOL)async
{
  UIImage *p = [self objectForKey:path];
  if(!p)
  {
    if(async)
    {
      p = loadingPlaceHolder;
      [loadingQueue enqueue:path];
      if(!workerStarted)
        [NSThread detachNewThreadSelector:@selector(worker:) toTarget:self withObject:loadingQueue];
    }
    else
    {
      p = [UIImage imageWithContentsOfFile:path];
      [self setObject:p forKey:path];
    }
  }
  return p;
}

/**
 * @brief Handles the event when an image has been loaded from file to memory.
 * @param[in] result Result of loading. The first element is the loaded image.
 *                   The second element is the path to the loaded image.
 */
- (void)handleImageDidLoad:(NSArray*)result
{
  [self setObject:[result objectAtIndex:0] forKey:[result objectAtIndex:1]];
  if(delegate && [delegate respondsToSelector:@selector(imageCache:didLoadImage:fromPath:)])
    [delegate imageCache:self didLoadImage:[result objectAtIndex:0] fromPath:[result objectAtIndex:1]];
}

/**
 * @brief The thread doing the actual loading of image.
 * @param[in] queue The image loading queue.
 */
- (void)worker:(FCQueue*)queue
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  UIImage *image;
  NSString *path;
  workerStarted = YES;
  while(workerStarted)
  {
    while(![queue isEmpty])
    {
      path = [queue dequeue];
      image = [UIImage imageWithContentsOfFile:path];
      if(image)
        [self performSelectorOnMainThread:@selector(handleImageDidLoad:) withObject:[NSArray arrayWithObjects:image, path, nil] waitUntilDone:YES];
    }
    [NSThread sleepForTimeInterval:.01];
  }
  [pool release];
}


@end
