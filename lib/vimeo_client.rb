# Contains the methods for the Vimeo client. Connects the application to the Vimeo account of the user.
class VimeoClient

  # Gets the authorization for the Vimeo client
  #
  # @return [void]
  def self.fetch_oauth
    @base = Vimeo::Advanced::Base.new(ENV["vimeo_id"], ENV["vimeo_secret"])
    request_token = @base.get_request_token
    request_token.secret
  end

  # Gets the authorization URL of the Vimeo client
  #
  # @return [void]
  def self.fetch_url
    @base.authorize_url
  end


  # Gets the base for the Vimeo client
  #
  # @return [void]
  def self.get_base
    @base = Vimeo::Advanced::Base.new(ENV["vimeo_id"], ENV["vimeo_secret"])
  end

  # Saves the latest 10 pages
  #
  # @return [void]
  # @note Called upon login or refresh, get latest 10 pages
  def self.save_latest  # called upon login or refresh, get latest 10 pages
    VideoGet.perform_async $redis.get('vimeo_token'), $redis.get('vimeo_secret')
  end

  # Saves the credentials of the Vimeo client. Sets redis attributes to given parameters
  #
  # @param token
  # @param secret
  # @return [void]
  def self.save_credentials token, secret
    $redis.set('vimeo_token', token)
    $redis.set('vimeo_secret', secret)
  end

  # Deletes the credentials of the Vimeo client
  #
  # @return [void]
  def self.delete_credentials
    $redis.del('vimeo_token')
    $redis.del('vimeo_secret')
  end

end
