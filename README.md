# Settings

This gem provides ruby applications with a global `Settings` object loaded from YAML files.

## Installation

```ruby
# Gemfile
gem 'settings', github: 'roomink/settings'
```

## Usage

`Settings` is a nested `Hashie::Mash` populated with values from these files in your app's root:

* `config/settings.yml`
* `config/#{Rails.env}.yml`
* `config/settings.local.yml`

The files are loaded in that exact order so environment-specific settings overwrite global settings, and local settings override them both.

Missing files are silently skipped.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
