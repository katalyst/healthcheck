# Katalyst::Healthcheck

Rails application and background task health monitoring.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'katalyst-healthcheck'
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```bash
$ gem install katalyst-healthcheck
```

## Usage

Configuration:

If running in a cluster environment or if redis is not localhost, redis url should be configured
in an initializer, e.g.
```
Katalyst::Healthcheck.configure do |config|
  config.store.redis.options.url = "redis://hostname:port"
end
```

Add to routes:

```
get '/healthcheck', to: Katalyst::Healthcheck::Route.static(200, "OK")
get '/healthcheck/status', to: Katalyst::Healthcheck::Route.from_tasks
get '/healthcheck/dashboard', to: Katalyst::Healthcheck::Route.from_tasks(detail: true)
```

With the above configuration, the following routes will be available:

### /healthcheck

A basic check that tests that the rails application is up and running.

### /healthcheck/status

Tests that all application background tasks are running as expected. 

All background tasks to be monitored must register successful completion of their work using
the `Katalyst::Healthcheck::Monitored` concern's `healthy!` and `unhealthy` methods, e.g.

``` ruby
include Katalyst::Healthcheck::Monitored

define_task :my_task, "My task description", interval: 1.day

def do_task
  ... task code here ...
  healthy!(:my_task)
rescue Exception => e
  unhealthy!(:my_task, e.message)
end
```

Call `healthy!` at successful completion of a task to mark the task as healthy.
Optionally, calling `unhealthy!` immediately marks that task as unhealthy.
If a task is not marked as `healthy!` within a predefined interval, that task is considered unhealthy.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
