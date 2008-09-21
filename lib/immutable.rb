module Immutable
  class CannotOverrideMethod < StandardError; end

  def self.included(mod)
    mod.extend(ClassMethods)
  end

  module ClassMethods
    def immutable_method(*args)
      opts = args.last.is_a?(Hash) ? args.pop : {}
      
      args.each do |method|
        alias_method "orig_#{method}", method
      end

      @args = args; @opts = opts
      module_eval do
        def self.method_added(sym)
          if @args
            @args.each do |method|
              if method && sym == method.to_sym && !called_by_method_added
                unless @opts[:silent]
                  raise CannotOverrideMethod, "Cannot override the immutable method: #{sym}"
                end

                self.module_eval <<-"end;"
                  def #{method.to_s}(*args, &block)
                    orig_#{method.to_s}(*args, &block)
                  end
                end;
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

      def self.called_by_method_added
        # This is a little brittle, suggestions?
        caller[3] =~ /eval.*in.*method_added/
      end
    end # def immutable_method()

    alias immutable_methods immutable_method

  end # module ClassMethods
end # module Immutable
