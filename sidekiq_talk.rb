#Sidekiq allows you to move jobs into the background for asynchronous processing.
#It uses threads instead of forks so it is much more efficient with memory compared to Resque.


#brew install redis
#Redis is an extremely fast, atomic key-value store.It allows the storage of strings, sets, sorted sets, lists and hashes. Redis keeps all the data in RAM
#needs redis to run

gem 'sidekiq'

#workers, sidekiq worker module

class PygmentsWorker
  include Sidekiq::Worker
  sidekiq_options queue: "high"
  # sidekiq_options retry: false

  def perform(snippet_id)
    snippet = Snippet.find(snippet_id)
    uri = URI.parse("http://pygments.appspot.com/")
    request = Net::HTTP.post_form(uri, lang: snippet.language, code: snippet.plain_code)
    snippet.update_attribute(:highlighted_code, request.body)
  end
end

 #does a job asynchronous, if error occurse it atuomatically tries again
sidekiq_options retry: false

#features
PygmentsWorker.perform_async(@snippet.id)
# PygmentsWorker.perform_in(1.hour, @snippet.id)


#look to see what when and how sidekiq has worked on your if __FILE__ == $PROGRAM_NAME
  mount Sidekiq::Web, at: '/sidekiq'
