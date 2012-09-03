require 'rubygems' if RUBY_VERSION < "1.9"
require 'sinatra/base'

class CacheInvalidator < Sinatra::Base
  configure(:production) do
    set :username, ENV["CI_USERNAME"]
    set :password, ENV["CI_PASSWORD"]
    set :cache_root, ENV["CI_CACHE_ROOT"]
  end

  configure(:development, :test) do
    set :username, ENV["CI_USERNAME"] || "usablecacheinvalidator"
    set :password, ENV["CI_PASSWORD"] || "knowledgevolution"
    set :cache_root, ENV["CI_CACHE_ROOT"] || "#{settings.root}/tmp"
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
    if settings.cache_root.to_s.strip == "" # No .blank? method.
      status 422
      "CACHE_ROOT environment variable is not defined."
    elsif params["filename"].to_s.strip == ""
      status 422
      "Please specify a filename as parameter."
    else
      filename = "#{settings.cache_root}/#{params["filename"].gsub("../", "")}"
      if File.exists?(filename)
        File.delete(filename)
        "File \"#{filename}\" was successfully deleted."
      else
        status 422
        "File \"#{filename}\" not found."
      end
    end
  end
end
