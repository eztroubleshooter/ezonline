# Class for the authentication requests. Contains the method for creating new authentication requests
class Request < ActiveRecord::Base
  self.primary_key = :user_id
  default_scope { order('created_at DESC') }
  validates :email, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: true }
  validates :username, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: false }

  # Creates a new authentication requests for the application
  #
  # @param user_id [Decimal] User id of the user who wants access to the application
  # @param email [String] Email of the user who wants access to the application
  # @param username [String] User name of the user who wants access to the application
  # @return [String] 'Sorry, you have no permission to use this application. A request was sent to grant access.',
  # 	if the user sent a request for the first time,
  # 	or 'A request was already sent to the application. Please try again later.'
  # 	if the user already has an existing request
  def self.create_new(user_id, email, username)
  	request = new(user_id: user_id, email: email, username: username)
    return 'Sorry, you have no permission to use this application. A request was sent to grant access.' if request.save
    return 'A request was already sent to the application. Please try again later.'
  end

end
