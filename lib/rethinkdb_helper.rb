##########################################################
###
##  File: rethinkdb_helper.rb
##  Desc: Encapsulates some basic utility functions
##  By:   Dewayne VanHoozer (dvanhoozer@gmail.com)
#
require 'rethinkdb'

class RethinkdbHelper
  include RethinkDB::Shortcuts

  DEFAULTS = {
    host:               ENV['RETHINKDB_HOST']  || 'localhost',
    port:              (ENV['RETHINKDB_PORT']  || '28015').to_i,
    db:                 ENV['RETHINKDB_DB']    || 'test',
    table:              ENV['RETHINKDB_TABLE'] || 'test',
    drop:               false,
    create_if_missing:  false
  }

  # TODO: Limited to one table per instance, consider
  #       support for multiple table per db support;
  #       consider multiple db per instance support.
  def initialize(options={})
    @options = DEFAULTS.merge(options)

    @connection = r.connect(
      host: @options[:host],
      port: @options[:port]
    ).repl

    r.db_drop(@options[:db]) if db_exist? && drop?

    unless  db_exist?
      if create_if_missing?
        r.db_create(@options[:db]).run
      else
        raise "db: '#{@options[:db]}' does not exist"
      end
    end

    @connection.use(@options[:db])

    unless table_exist?
      if create_if_missing?
        r.table_create(@options[:table]).run
      else
        raise "table: '#{@options[:table]}' does not exist"
      end
    end

    @table = r.table(@options[:table])
  end # def initialize

  def db_exist?
    r.db_list.run.include?(@options[:db])
  end

  def table_exist?
    r.table_list.run.include?($options[:table])
  end

  def drop?
    @options[:drop]
  end

  def create_if_missing?
    @options[:create_if_missing]
  end

  # payloads is an array of hashes or a single
  # hash document.
  def insert(*payloads)
    raise 'No document provided' if payloads.empty?
    invalid_payloads = false
    payloads.map{|doc| invalid_payloads &&= !doc.is_a?(Hash)}
    raise 'Invalid document: must be Hash' if invalid_payloads
    @table.insert(payloads).run
  end
  alias :add  :insert
  alias :load :insert

  # TODO: Currently limited to one search field and regex
  #       consider how to use more than one field
  #
  # returns an enumerable cursor into the database for
  # documents that match the search terms.
  #
  # params is a hash where the key is the symbolized field_name
  # and its value is the regex by which to filter
  def filter(params={})
    raise 'No search terms' if params.empty?
    field_name    = params.keys.first
    search_regex  = params[field_name]

    @table.filter{|document| document[field_name].
              match(search_regex)}.
          run
  end
  alias :search :filter

  def close
    @connection.close
  end

end # class RethinkdbHelper

ReDBH = RethinkdbHelper unless defined?(ReDBH)
