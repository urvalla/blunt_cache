# In-memory cache service.
class BluntCache
  @expire_default = 60

  # Store +data+ in cache by +key+ for +:expire+ seconds (default is 60 sec)
  def self.set(key, data, expire: nil)
    self.timestamp[key] = Time.now + (expire || self.expire_default)
    self.data[key] = data
    data
  end

  # Get +key+ from cache. Returns nil if not set or expired.
  def self.get(key)
    self.timestamp[key].is_a?(Time) && Time.now < self.timestamp[key] ? self.data[key] : nil
  end

  # Get +key+ from cache. Executes +block+, stores it's result and returns it if not set or expired.
  def self.fetch(key, expire: nil, &block)
    result = self.get key
    if result.nil?
      self.set key, block.call, expire: expire
    else
      result
    end
  end

  # Clear cache
  def self.flush
    @data = {}
    @timestamp = {}
  end

protected

  def self.data
    @data||= {}
  end

  def self.timestamp
    @timestamp||= {}
  end

  def self.expire_default
    @expire_default||=60
  end
end