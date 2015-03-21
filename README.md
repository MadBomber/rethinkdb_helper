# RethinkdbHelper

My convention as a wrapper around the rethinkdb gem.
Under Development.
Don't use it.

This class is oriented around exploring the rethinkdb API.

I have not looked at the nobrainer gem yet.  You ought to.

The rethinkdb-cli gem looks pretty simple.  I'm thinking
about putting a REPL into this helper gem as well.  Maybe
at a bin directory with a cli program that invokes the REPL.

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
    drop:   false,        # default - drop/delete the db
    create_if_missing: true   # created db/table if they are missing
  )
  options={}
  db.insert([Hash, Hash, Hash ...], options) # takes array of hashes or json
  cursor = db.search(field_name: field_value_regex)
  cursor.each {|d| ap d}
  etc.
```

If you were to insert an actual JSON string it would not work.  Of course
being a wrapper and all that I could check the class and IF STRING then
ASSUME its a JSON string then do a JSON.parse on it to get a Hash to
pass to the native (sic.) #insert method of the rethinkdb.

Sometimes you must use symbols
to access to the (Hash) document's fields.  Other times in other methods the
field name must be a string.  Go figure.


## Development

  ** Insert Fun Here **

## Contributing

1. Fork it ( https://github.com/MadBomber/rethinkdb_helper/fork )
2. Create your feature branch (`git checkout -b new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin new-feature`)
5. Create a new Pull Request
