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
@interface DataCache : NSObject
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
 * @brief Constructor
 *
 * @param[in] cap Capacity of the cache.
 * @returns @c id of the newly created object.
 */
- (id)initWithCapacity:(int)cap;

/**
 * @brief Returns the texture reference of the given key.
 *
 * @param[in] key Key to the item to be retrieved.
 * @returns @c id of the texture reference, or null if the key is not defined.
 */
- (id)objectForKey:(id)key;

/**
 * @brief Stores the given texture reference to the cache.
 * @details Removes the oldest record if necessary.
 *
 * @param[in] value Value to be stored to the cache.
 * @param[in] key Key to the value.
 */
- (void)setObject:(id)value forKey:(id)key;

@end
