class Doc < ActiveRecord::Base
	self.primary_key = :doc_id
	has_many :snippets, :dependent => :destroy
end
