# UsableCacheInvalidator

This is a sinatra app that provides a REST web service to delete a file in a directory. Currently, it has only a `destroy` action. It authenticates using HTTP Basic Authentication.

## Set Up

```
ENV['CACHE_ROOT'] = "the root directory of the cache"
ENV['USERNAME'] = "username for http basic auth"
ENV['PASSWORD'] = "password for http basic auth"
```
