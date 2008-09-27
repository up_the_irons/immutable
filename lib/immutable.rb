module Immutable
  class CannotOverrideMethod < StandardError; end

  # Random ID changed at each interpreter load
  UNIQ = "_#{object_id}"

  def self.included(mod)
    mod.extend(ClassMethods)
  end

  module ClassMethods
    def immutable_method(*args)
      opts = args.last.is_a?(Hash) ? args.pop : {}
      
      args.each do |method|
        alias_method "#{UNIQ}_old_#{method}", method
      end
      
      @allow_method_override = false

      @args = args; @opts = opts
      module_eval do
        def self.method_added(sym)
          if @args
            @args.each do |method|
              if method && sym == method.to_sym && !@allow_method_override
                unless @opts[:silent]
                  raise CannotOverrideMethod, "Cannot override the immutable method: #{sym}"
                end
                
                allow_method_override do
                  self.module_eval <<-"end;"
                    def #{method}(*args, &block)
                      #{UNIQ}_old_#{method}(*args, &block)
                    end
                  end;
                end
              end 
            end # @args.each
          end # @args
        end # def self.method_added()

        def self.method_undefined(sym)
          method_added(sym)
        end

        def self.method_removed(sym)
          method_added(sym)
        end
      end # module_eval

      def self.allow_method_override
        @allow_method_override = true
        yield
      ensure
        @allow_method_override = false
      end
    end # def immutable_method()

    alias immutable_methods immutable_method

  end # module ClassMethods
end # module Immutable
