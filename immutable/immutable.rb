module Immutable
  def self.included(mod)
    mod.extend(ClassMethods)
  end

  module ClassMethods
    def immutable_method(*args)
      args.each do |method|
        alias_method "orig_#{method}", method
      end

      @args = args
      module_eval do
        def self.method_added(sym)
          @args.each do |method|
            if method
              if sym == method.to_sym 
                unless called_by_method_added
                  self.module_eval <<-"end;"
                    def #{method.to_s}(*args, &block)
                      orig_#{method.to_s}(*args, &block)
                    end
                  end;
                end # called_by_method_added
              end # method.to_sym
            end # method
          end # @args.each
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
  end # module ClassMethods
end # module Immutable
