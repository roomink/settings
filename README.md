# Settings

This gem provides ruby applications with a global `Settings` object loaded
from YAML files.

## Installation

```ruby
# Gemfile
gem 'settings', github: 'roomink/settings'
```

## Usage

`Settings` is a nested `Hashie::Mash` populated with values from these files
in your app's root:

* `config/settings.yml`
* `config/settings/#{Rails.env}.yml`
* `config/settings.local.yml`
* `config/settings/#{Rails.env}.local.yml`

The files are loaded in that exact order so environment-specific settings
overwrite global settings, and local settings override them both.
Missing files are silently skipped.

When the `Rails` constant isn't defined `Settings` will look after
`ENV['RAILS_ENV']` and `ENV['RACK_ENV']`. If they're also not found
the default value of `:development` will be used.

Then you can call methods corresponding to keys in your YAML files:

```ruby
Settings.redis.host # => localhost
Settings.redis.db   # => 0
```

### Settings for another environment

Usually `Settings` works with data for your current environment determined by
the process described above. But sometimes you may need your settings
for another environment. Here's how you can do that:

```ruby
Settings.for(:test).redis.db # => 1
```

There is also a `Settings.map` method which yields setting sets for
all configurations and returns them as a hash keyed by the environments:

```ruby
Settings.map(&:redis)
# => { development: { host: 'localhost', port: 6379, db: 0 }, test: ... }
```

### Reloading data

Settings are automatically filled with data from YAML files on the first call
and cached for subsequent calls (this applies to settings for all environments).
If you need to reload this data without restarting the app you can do this:

```ruby
Settings.reload!
```

This call just flushes the cache - the files will be loaded next time
you access some value.

### Environments list

By default settings are loaded for `development`, `test` and `production`
environments. If you need to load settings for some custom environment you need
to configure `settings` to use it:

``` ruby
Settings::Utils.environments << :staging
```

**Important: this must be done before the first call to settings
data!** Changing the environments list after the data was loaded
will have no effect (read the "Reloading data" section above for details on
how the data is being loaded).

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
