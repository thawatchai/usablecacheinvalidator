require 'rubygems' if RUBY_VERSION < "1.9"
require 'sinatra/base'

class CacheInvalidator < Sinatra::Base
  configure do
    set :username, ENV["USERNAME"] || "usablecacheinvalidator"
    set :password, ENV["PASSWORD"] || "knowledgevolution"
    set :cache_root, ENV["CACHE_ROOT"] || "#{settings.root}/tmp"
  end

  helpers do
    def protected!
      unless authorized?
        response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
        throw(:halt, [401, "Not authorized\n"])
      end
    end

    def authorized?
      @auth ||=  Rack::Auth::Basic::Request.new(request.env)
      @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [settings.username, settings.password]
    end
  end

  post '/invalidate' do
    protected!
    filename = "#{settings.cache_root}/#{params["filename"]}"
    if File.exists?(filename)
      File.delete(filename)
      "File \"#{filename}\" was successfully deleted."
    else
      "File \"#{filename}\" not found."
    end
  end
end
