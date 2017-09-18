##########################################################
###
##  File: rethinkdb_helper.rb
##  Desc: Encapsulates some basic utility functions
##  By:   Dewayne VanHoozer (dvanhoozer@gmail.com)
#
# TODO: Review the nobrainer gem to see if this stuff is moot
# TODO: Reorganize the methods into separate files within lib
#

require 'forwardable'

require 'rethinkdb'

class RethinkdbHelper
  include RethinkDB::Shortcuts
  extend Forwardable

  DEFAULTS = {
    host:               ENV['RDB_HOST']     || 'localhost',
    port:              (ENV['RDB_PORT']     || '28015').to_i, # SMELL: is to_i necessary?
    db:                 ENV['RDB_DB']       || 'test',
    table:              ENV['RDB_TABLE']    || 'test',
    auth_key:           ENV['RDB_AUTH_KEY'] || 'unknown',
    drop:               false,
    create_if_missing:  false
  }

  # TODO: Pass some methods to r for fullfillment
  #       connect, db, table
  #def_delegators :r, :connect, :db, :table

  def_delegators :@connection, :close, :reconnect, :use, :noreply_wait

  def_delegators :@table, :filter, :get, :get_all, :between, :eq_join,
                          :inner_join, :outer_join, :index_create

  # TODO: Limited to one table per instance, consider
  #       support for multiple table per db support;
  #       consider multiple db per instance support.
  def initialize(options={})
    @options = DEFAULTS.merge(options)

    @connection = connect

    db_drop if db_exist? && drop?

    unless  db_exist?
      if create_if_missing?
        db_create
      else
        raise "db: '#{@options[:db]}' does not exist"
      end
    end

    use(@options[:db])

    unless table_exist?
      if create_if_missing?
        table_create
      else
        raise "table: '#{@options[:table]}' does not exist"
      end
    end

    @table = r.table(@options[:table])
  end # def initialize

  def table_wait(*options)
    @table.wait(options).run
  end

  def table_status(table_name=@options[:table])
    r.table_status(table_name).run
  end

  def reconfigure(options={})
    @taboe.reconfigure(options).run
  end
  alias :table_reconfigure :reconfigure

  def rebalance
    @table.rebalance.run
  end
  alias :table_rebalance :rebalance

  def table_config
    @table.config.run
  end

  def db_config
    @db.config.run
  end


  def db_wait(*options)
    @db.wait(options).run
  end

  def server_wait(*options)
    r.wait(options).run
  end

  def connect(options={host: @options[:host], port: @options[:port]})
    r.connect(options).repl
  end

  def db_drop(db_name=@options[:db])
    @db    = nil
    @table = nil
    r.db_drop(db_name).run
  end
  alias :drop_db   :db_drop
  alias :db_delete :db_drop
  alias :delete_db :db_drop

  #def use(db_name=@options[:db])
  #  @connection.use(db_name)
  #end

  def db(db_name=@options[:db])
    @db = r.db(db_name)
  end

  def table(table_name=@options[:table],options={})
    @table = r.table(table_name, options)
  end

  def get_table(table_name=@options[:table], options)
    r.table(table_name, options).run
  end

  def sync
    @table.sync.run
  end
  alias :flush :sync


  def table_create(table_name=@options[:table], options={})
    @table = r.table_create(table_name, options).run
  end
  alias :create_table :table_create

  def table_drop(table_name=@options[:table])
    @table = nil
    @db.table_drop(table_name)
  end
  alias :drop_table   :table_drop
  alias :delete_table :table_drop
  alias :table_delete :table_drop

  def changes(options={})
    @table.changes(options).run(connect)
  end

  def db_exist?(db_name=@options[:db])
    db_list.include?(db_name)
  end

  def db_create(db_name=@options[:db])
    @db = r.db_create(db_name).run
  end
  alias :create_db :db_create

  def db_list
    r.db_list.run
  end
  alias :list_db :db_list

  def table_list
    r.table_list.run
  end
  alias :list_table :table_list

  def table_exist?(table_name=@options[:table])
    table_list.include?(table_name)
  end

  def index_wait(*indexes)
    @table.index_wait(indexes).run
  end
  alias :wait_on_index  :index_wait
  alias :wait_for_index :index_wait
  alias :wait_index     :index_wait

  def create_simple_index(field_name)
    @table.index_create(field_name.to_s).run
  end

  def index_list
    @table.index_list.run
  end
  alias :list_indexes :index_list

  def index_drop(index_name)
    @table.index_drop(index_name).run
  end
  alias :drop_index   :index_drop
  alias :delete_index :index_drop
  alias :index_delete :index_drop

  def index_wait(index_name)
    @table.index_wait(index_name).run
  end
  alias :wait_on_index :index_wait

  def drop?
    @options[:drop]
  end

  def create_if_missing?
    @options[:create_if_missing]
  end

  def get_key(key)
    @table.get(key).run
  end

  def get_all_keys(keys, options={})
    @table.get_all([keys].flatten, options).run
  end

  def get_between_keys(lower_key, upper_key, options={})
    @table.between(lower_key, upper_key, options).run
  end
  alias :between_keys :get_between_keys


  def join(foreign_key, table_name,options={})
    @table.eq_join(foreign_key,
      r.table(table_name), options).without({:right => "id"}).zip().run
  end

  # payloads is an array of hashes or a single
  # hash document.
  def insert(payloads, options={})
    payloads = [payloads].flatten
    raise 'No document provided' if payloads.empty?
    invalid_payloads = false
    payloads.map{|doc| invalid_payloads &&= !doc.is_a?(Hash)}
    raise 'Invalid document: must be Hash' if invalid_payloads
    @table.insert(payloads.flatten, options).run
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
  def search(params={})
    raise 'No search terms' if params.empty?
    field_name    = params.keys.first
    search_regex  = params[field_name]

    @table.filter{|document| document[field_name].
              match(search_regex)}.
          run
  end

  #def close
  #  @connection.close
  #end

end # class RethinkdbHelper

RDB = RethinkdbHelper unless defined?(RDB)
