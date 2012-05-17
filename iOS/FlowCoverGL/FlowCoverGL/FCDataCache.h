/**
 * @brief Header file of the DataCache interface.
 * @author Jackey Cheung
 */
#import <Foundation/Foundation.h>


/**
 * @brief A general purpose data cache facility.
 * @details
 * This interface maintains a cache of arbitrary data. Once created, with a
 * specific capacity, this facility makes sure the number of cached items will
 * not exceed the given capacity. As new data are added in, old data will be
 * removed before adding in new data, starting from the oldest data.
 * @remark
 * Also the facility itself is generally purposed, it is used as the texture
 * cache, which stores texture references for use by OpenGL ES.
 */
@interface FCDataCache : NSObject
{
  /**
   * @brief Capacity of the cache.
   */
  int fCapacity;
  /**
   * @brief The dictionary that stores texture references.
   */
  NSMutableDictionary *fDictionary;
  /**
   * @brief
   * The array that stores ages of textures, the oldest will be removed first
   * when cached item gets over capacity.
   */
  NSMutableArray *fAge;
}

/**
 * @brief Initialize the cache to the specified capacity.
 *
 * @param[in] cap Capacity of the cache.
 * @returns @c id of the newly created object.
 */
- (id)initWithCapacity:(int)cap;

/**
 * @brief Returns the data of the given key.
 *
 * @param[in] key Key to the item to be retrieved.
 * @returns @c id of the data, or null if the key is not defined.
 */
- (id)objectForKey:(id)key;

/**
 * @brief Stores the given data to the cache.
 * @details Removes the oldest record if necessary.
 *
 * @param[in] value Value to be stored to the cache.
 * @param[in] key Key to the value.
 */
- (void)setObject:(id)value forKey:(id)key;

/**
 * @brief Removes the item at the specified index.
 * @param[in] key Key to the item to be updated.
 */
- (void)removeObjectForKey:(id)key;

/**
 * @brief Trancates the cache to left only specified number of objects.
 * @param[in] size The number of objects to be left in the cache.
 */
- (void)truncateToSize:(int)size;


@end
