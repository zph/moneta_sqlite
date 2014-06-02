require "moneta_sqlite/version"

require 'sqlite3'
require 'moneta'

module Moneta

  module Adapters
    class Sqlite
      def initialize(options = {})
        table = options[:table] || 'moneta'
        @backend = options[:backend] ||
          begin
            raise ArgumentError, 'Option :file is required' unless options[:file]
            ::SQLite3::Database.new(options[:file])
          end
        @backend.busy_timeout(options[:busy_timeout] || 1000)
        @backend.execute("create table if not exists #{table} (k blob not null primary key, v blob)")
        @stmts =
          [@exists  = @backend.prepare("select exists(select 1 from #{table} where k = ?)"),
           @select  = @backend.prepare("select v from #{table} where k = ?"),
           @replace = @backend.prepare("replace into #{table} values (?, ?)"),
           @delete  = @backend.prepare("delete from #{table} where k = ?"),
           @clear   = @backend.prepare("delete from #{table}"),
           @keys    = @backend.prepare("select k from #{table}"),
           @create  = @backend.prepare("insert into #{table} values (?, ?)")]
      end

      def keys
        @keys.execute!.map(&:first)
      end
    end
  end
end

module Moneta
  class Transformer < Proxy
    class << self
      def compile_key_transformer(klass, key, key_opts)
        klass.class_eval <<-end_eval, __FILE__, __LINE__
          def key?(key, options = {})
            @adapter.key?(#{key}, #{without key_opts})
          end
          def keys
            @adapter.keys
          end
          def increment(key, amount = 1, options = {})
            @adapter.increment(#{key}, amount, #{without key_opts})
          end
          def load(key, options = {})
            @adapter.load(#{key}, #{without :raw, key_opts})
          end
          def store(key, value, options = {})
            @adapter.store(#{key}, value, #{without :raw, key_opts})
          end
          def delete(key, options = {})
            @adapter.delete(#{key}, #{without :raw, key_opts})
          end
          def create(key, value, options = {})
            @adapter.create(#{key}, value, #{without :raw, key_opts})
          end
        end_eval
      end

      def compile_key_value_transformer(klass, key, key_opts, load, load_opts, dump, dump_opts)
        klass.class_eval <<-end_eval, __FILE__, __LINE__
          def key?(key, options = {})
            @adapter.key?(#{key}, #{without key_opts})
          end
          def keys
            @adapter.keys
          end
          def increment(key, amount = 1, options = {})
            @adapter.increment(#{key}, amount, #{without key_opts})
          end
          def load(key, options = {})
            value = @adapter.load(#{key}, #{without :raw, key_opts, load_opts})
            value && !options[:raw] ? #{load} : value
          end
          def store(key, value, options = {})
            @adapter.store(#{key}, options[:raw] ? value : #{dump}, #{without :raw, key_opts, dump_opts})
            value
          end
          def delete(key, options = {})
            value = @adapter.delete(#{key}, #{without :raw, key_opts, load_opts})
            value && !options[:raw] ? #{load} : value
          end
          def create(key, value, options = {})
            @adapter.create(#{key}, options[:raw] ? value : #{dump}, #{without :raw, key_opts, dump_opts})
          end
        end_eval
      end
    end
  end
end
