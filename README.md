# RethinkdbHelper

My convention as a wrapper around the rethinkdb gem.
Under Development.
Don't use it.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rethinkdb_helper'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rethinkdb_helper

## Usage

```ruby
  db = RethinkdbHelper.new(
    host:   'localhost',  # default
    port:   28015,        # default
    db:     'test',       # default
    table:  'test',       # default
    create_if_missing: true   # created db/table if they are missing
  )
  db.insert(json_documents) # takes array of hashes or json
  cursor = db.search(:field_name, field_value_regex)
  puts cursor.count
  cursor.each {|d| ap d}
  etc.
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/rethinkdb_helper/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
