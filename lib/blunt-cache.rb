# In-memory cache service.
class BluntCache
  @expire_default = 60

  # Store +data+ in cache by +key+ for +:expire+ seconds (default is 60 sec)
  #   def self.set(key, data, expire: nil)
  def self.set(key, data, options = {})
    expire = options[:expire]
    self.timestamp[key] = Time.now + (expire || self.expire_default)
    self.data[key] = data
    data
  end

  # Get +key+ from cache. Returns nil if not set or expired.
  def self.get(key)
    self.timestamp[key].is_a?(Time) && Time.now < self.timestamp[key] ? self.data[key] : nil
  end

  # Checks if key present in store.
  # Returns true if key exists (even if value is false or nil) and false if key doesn't exist or expired.
  def self.key?(key)
    self.data.key?(key) && self.timestamp[key].is_a?(Time) && Time.now < self.timestamp[key]
  end

  # Get +key+ from cache. Executes +block+, stores it's result and returns it if not set or expired.
  #   def self.fetch(key, expire: nil, &block)
  def self.fetch(key, options = {}, &block)
    expire = options[:expire]
    if self.key?(key)
      self.data[key]
    else
      result = block.call
      self.set key, result, :expire => expire
      result
    end
  end

  # Clear cache
  def self.flush
    @data = {}
    @timestamp = {}
  end

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