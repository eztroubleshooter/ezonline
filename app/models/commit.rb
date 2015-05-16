# Class for the commits made by the users. Contains the method for creating new commits
class Commit < ActiveRecord::Base
  belongs_to :user
  belongs_to :snippet
  validates :commit_text, presence: true, allow_blank: false, length: {minimum: 50}
  default_scope { order('created_at DESC') }

  # Creates a new commit
  #
  # @param user_id [Decimal] User ID of the user who made the commit
  # @param snippet_id [Decimal] Snippet ID of the edited snippet
  # @param commit_text [String] The text committed by the user to the snippet
  # @return [true] to indicate the commit was successfully created
  # @return [Symbol] to indicate the commit was successfully created
  # @return [String] "Update saved"
  def self.create_new(user_id, snippet_id, commit_text)
  	commit = new(user_id: user_id, snippet_id: snippet_id, commit_text: commit_text)
    return true, :success, "Update saved." if commit.save
  	return false, :notice, "Your commit was empty/too short."
  end

end
