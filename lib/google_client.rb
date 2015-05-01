require 'google/api_client'

class GoogleClient

  def self.init_client_if_nil
    @client ||= init
    @client.authorization.access_token = @access_token if @client.authorization.access_token.blank?
  end

  def self.init
    @client = Google::APIClient.new({:application_name => "ezonline",:application_version => "1.0"})
    @client.authorization.client_id = ENV["google_id"]
    @client.authorization.client_secret = ENV["google_secret"]
    @client.authorization.scope = ['https://www.googleapis.com/auth/drive','https://www.googleapis.com/auth/userinfo.profile','https://www.googleapis.com/auth/userinfo.email']
    @client.authorization.redirect_uri = ENV["google_redirect_uri"]
    @client
  end

  def self.get_access
    @access_token
  end

  def self.set_access access_token
    @access_token = access_token unless access_token.blank?
  end

  def self.get_refresh
    @refresh_token
  end

  def self.set_refresh refresh_token
    @refresh_token = refresh_token unless refresh_token.blank?
  end

  def self.refresh_token
    init
    @client.authorization.grant_type = 'refresh_token'
    @client.authorization.refresh_token = @refresh_token

    @client.authorization.fetch_access_token!
    set_access(@client.authorization.access_token)
    print "REFRESHED!\n"
    print "NEW ACCESS TOKEN: " + @access_token + "\n"
    print "REFRESH TOKEN: " + @refresh_token + "\n"
  end

  def self.build_auth_uri
    init
    unless @refresh_token.blank?
      return @client.authorization.authorization_uri(:approval_prompt => :auto).to_s
    else
      return @client.authorization.authorization_uri(:access_type => :offline, :approval_prompt => :force).to_s
    end
  end

  def self.fetch_token code  # set access token
    @client.authorization.code = code

    @client.authorization.fetch_access_token!
    set_access(@client.authorization.access_token)
    set_refresh(@client.authorization.refresh_token)
  end

  def self.fetch_user  # get authenticated users's credentials
    oauth2 = @client.discovered_api('oauth2', 'v2')
    @client.execute!(:api_method => oauth2.userinfo.get)
  end

  def self.get_user_info
    result = fetch_user
    return result.data if result.status == 200
    puts "An error occurred: #{result.data['error']['message']}"
    return nil
  end

  def self.fetch_file file_title  # get google doc given exact title
    init_client_if_nil
    drive = @client.discovered_api('drive', 'v2')
    @client.execute(
      api_method: drive.files.list,
      parameters: {q: "title = '" + "#{file_title}" + "'" , maxResults: 1, trashed: false})
  end

  def self.download_file download_url  # download google doc content
    init_client_if_nil
    @client.execute(uri: download_url)
  end

  def self.upload tmp, title
    init_client_if_nil
    media = Google::APIClient::UploadIO.new(tmp, 'text/plain', title + '.txt')
    drive = @client.discovered_api('drive', 'v2')
      file = drive.files.insert.request_schema.new({
        'title' => title,
        'description' => 'Compiled',
        'mimeType' => 'text/plain'
      })
      @client.execute(
        :api_method => drive.files.insert,
        :body_object => file,
        :media => media,
        :parameters => {
          'uploadType' => 'multipart',
          'convert' => true,
          'alt' => 'json'})
  end

  def self.add_file(user_id, title)
    begin
      refreshed ||= false
      #squish: remove whitespaces from both ends, compress multiple to one, blank: check if nil or whitespaces
      search_result = fetch_file(title.squish) unless title.blank?

      if search_result.nil?
        return :notice, "Please enter a title."

      elsif search_result.status == 200
        file = search_result.data['items'].first

        unless file.nil?
          download_url = file['exportLinks']['text/plain'] # docs do not have 'downloadUrl'
          link = file['alternateLink']

          if download_url
            result = download_file(download_url)
            if result.status == 200
              return (Filer::parse result.body, file.id, file.title, link, user_id)
              #type, message = FilerParse.perform_async result.body, file.id, file.title, link, session[:user_id]
            else
              return :error, "An error occurred: #{result.data['error']['message']}"
            end # end if result.status == 200
          end # end if download_url

        else # unless
          return :error, "Sorry, EZ Online cannot find a Google Doc with that title."
        end # end unless

      else
        print search_result.status
        raise
      end # end outermost if

    rescue Exception => ex
      unless refreshed # there was already an attempt to refresh google access token
        refresh_token
        refreshed = true
        retry
      end
        print ex.message
        return :error, "An error occured. Please log out first and try again."
    end
  end

end
