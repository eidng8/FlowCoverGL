/**
 * @brief Header file of the DataCache interface.
 * @author Jackey Cheung
 */
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "FCQueue.h"
#import "FCDataCache.h"


@protocol FCImageCacheDelegate;

/**
 * @brief A image cache facility that supports asynchronous loading.
 * @details
 * Inherets data caching functionalities from DataCache. In addition, it
 * allows loading images asynchronously. When the wanted images are still being
 * loaded, the "Loading" place holder image will be used instead.
 */
@interface FCImageCache : FCDataCache
{
  /**
   * @brief Flags if the background thread for loading image has started.
   */
  BOOL workerStarted;
  /**
   * @brief The queue of image to be loaded.
   */
  FCQueue *loadingQueue;
  /**
   * Stores the "Loading" place holder image.
   */
  UIImage *loadingPlaceHolder;
  
  /**
   * @brief Stores the delegate object
   */
  id<FCImageCacheDelegate> delegate;
}


/**
 * @brief Stores the delegate object
 */
@property (nonatomic, assign) id<FCImageCacheDelegate> delegate;
/**
 * @brief Readonly property pointing to the "Loading" place holder image.
 */
@property (nonatomic, readonly) UIImage *loadingPlaceHolder;


/**
 * @brief Initialize the cache to the specified capacity and loading image.
 * @param[in] cap Capacity of the cache.
 * @param[in] image The image to be used as "Loading" place holder.
 * @returns @c id of the newly created object.
 */
- (id)initWithCapacity:(int)cap loadingImage:(UIImage*)image;

/**
 * @brief Initialize the cache to the specified capacity and loading image.
 * @details
 * This mehods syncrhonously loads the specified image into memory, blocks
 * program flow until the image is loaded into memory.
 * @param[in] cap Capacity of the cache.
 * @param[in] image Name the image to be used as "Loading" place holder.
 * @returns @c id of the newly created object.
 */
- (id)initWithCapacity:(int)cap imageNamed:(NSString*)image;

/**
 * @brief Initialize the cache to the specified capacity and loading image.
 * @details
 * This mehods syncrhonously loads the specified image into memory, blocks
 * program flow until the image is loaded into memory.
 * @param[in] cap Capacity of the cache.
 * @param[in] path Path to the image file to be used as "Loading" place holder.
 * @returns @c id of the newly created object.
 */
- (id)initWithCapacity:(int)cap pathToLoadingImage:(NSString*)path;

/**
 * @brief Returns the image from the given path, loads it if necessary.
 * @details
 * Loads the image designated by @c path into memory, synchronously. This method
 * blocks program flow until the image is loaded.
 * @param[in] path Path to the image to be retrieved.
 * @returns Pointer to the image found, or nil otherwise.
 */
- (UIImage*)imageAtPath:(NSString*)path;

/**
 * @brief Returns the image from the given path, loads it if necessary.
 * @details
 * If @c async is false, it directly calls the imageForPath: method.If @c async
 * is true, the returned image may not be the image wanted. It is possible that
 * this method returns the "Loading" place holder, because the wanted image is
 * not yet loaded into memory. Once the wanted image is loaded, the next call to
 * this method or imageForPath: with the correct key will return pointer wanted
 * image. Or if registered, a delegate will be fire with
 * imageCache:didLoadImage:.
 * @param[in] path Path to the image to be retrieved.
 * @param[in] async True if the loading should be asynchronous.
 * @returns Pointer to the image found and loaded, or "Loading" image otherwise.
 */
- (UIImage*)imageAtPath:(NSString*)path async:(BOOL)async;

@end


/**
 * @brief The delegate to handle ImageCache events.
 */
@protocol FCImageCacheDelegate <NSObject>
@optional
/**
 * @brief Fired when an image has been loaded into memory.
 * @param[in] cache The ImageCache object that fires the event.
 * @param[in] image The loaded image.
 * @param[in] path Path to the loaded image.
 */
- (void)imageCache:(FCImageCache*)cache didLoadImage:(UIImage*)image fromPath:(NSString*)path;

@end

