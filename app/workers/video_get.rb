class VideoGet
	include Sidekiq::Worker

	def perform page
		video = VimeoClient::retrieve_video
		response = video.get_all(VimeoModel::USERNAME, { :page => page, :per_page => "1", :sort => "newest" })

		videos = response['videos']['video']

		begin 
			videos.each do |v|
				video = Video.new
				video.video_id = v['id']
				video.title = v['title']
				video.save!
			end

		rescue ActiveRecord::RecordNotUnique	# database already contains this 'latest' video
		end
		
	end

end