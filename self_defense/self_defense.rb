module SelfDefense
  def self.included(mod)
    mod.extend(ClassMethods)
  end

  module ClassMethods
    def immutable_method(*args)
      args.each do |method|
        alias_method :"orig_#{method}", method

        @method = method
        module_eval do
          def self.method_added(sym)
            if @method
              if sym == @method.to_sym 
                unless called_by_method_added
                  self.module_eval <<-"end;"
                    @__skip_redefine = true # Prevent recursion
                    def #{@method.to_s}(*args, &block)
                      orig_#{@method.to_s}(*args, &block)
                    end
                  end;
                end # called_by_method_added
              end # @method.to_sym
            end # @method
          end # def self.method_added()

          def self.method_undefined(sym)
            method_added(sym)
          end

          def self.method_removed(sym)
            method_added(sym)
          end

          def self.called_by_method_added
            caller[1] =~ /in.*method_added/
          end
        end # module_eval
      end # args.each
    end # def dont_rape()
  end # module
end # module
