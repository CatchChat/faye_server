Redis.current = Redis::Store.new(Settings.redis.store.to_h.symbolize_keys)
