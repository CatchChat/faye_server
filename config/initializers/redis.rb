redis_options    = Settings.redis.store.to_h.symbolize_keys.except(:namespace)
namespace        = Settings.redis.store.namespace
redis_connection = Redis.new(redis_options)
namespaced_redis = Redis::Namespace.new(namespace, redis: redis_connection)
Redis.current    = namespaced_redis
