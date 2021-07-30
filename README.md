# Katalyst::Healthcheck

Short description and motivation.

## Usage

How to use my plugin.

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

Add to routes:

```
mount Katalyst::Healthcheck::Engine => "/healthcheck"
```

With the above configuration, the following routes will be available:

### /healthcheck/rails

A basic check that tests that the rails application is up and running.

### /healthcheck/tasks

Tests that all background tasks are running as expected. All background tasks to be monitored must register successful
completion of their work using the `Katalyst::Healthcheck.complete_task!` method.

## Contributing

Contribution directions go here.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
