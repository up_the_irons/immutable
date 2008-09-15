require 'rubygems'
require 'spec'
require 'ruby-debug'
require 'self_defense'

##################
# Module version #
##################

module Foo
  include SelfDefense

  def foo
    :fast
  end

  immutable_method :foo
end

# Other Foo modules we can screw with, so specs don't step on each other
Foo2 = Foo.clone
Foo3 = Foo.clone

describe "Module Foo.foo()" do
  describe "after redefining" do
    def redefine_foo
      Foo.module_eval do
        def foo
          :slow
        end
      end
    end

    def test_it
      @foo = Object.instance_eval do
        include Foo
        foo
      end
  
      @foo.should == :fast
    end
  
    it "should not let foo() be redefined" do
      redefine_foo
      test_it
    end
  
    it "should not let foo() be redefined even if we try twice" do
      redefine_foo
      redefine_foo
      test_it
    end
  end

  describe "after undefining" do
    def undefine_foo 
      Foo2.module_eval do
        undef_method(:foo)
      end
    end

    def test_it
      @foo = Object.instance_eval do
        include Foo2
        foo
      end
  
      @foo.should == :fast
    end

    it "should not let foo() be undefined" do
      undefine_foo
      test_it
    end
  end

  describe "after removing" do
    def remove_foo 
      Foo3.module_eval do
        remove_method(:foo)
      end
    end

    def test_it
      @foo = Object.instance_eval do
        include Foo3
        foo
      end
  
      @foo.should == :fast
    end

    it "should not let foo() be removed" do
      remove_foo
      test_it
    end
  end
end

#################
# Class version #
#################

class Bar
  include SelfDefense

  def bar
    :fast
  end

  immutable_method :bar
end

# Other Bar modules we can screw with, so specs don't step on each other
Bar2 = Bar.clone
Bar3 = Bar.clone

describe "Class Bar.bar()" do
  describe "after redefining" do
    def redefine_bar
      Bar.module_eval do
        def bar
          :slow
        end
      end
    end

    def test_it
      @bar = Bar.new.bar
      @bar.should == :fast
    end
 
    it "should not let bar() be redefined" do
      redefine_bar
      test_it
    end
  
    it "should not let bar() be redefined even if we try twice" do
      redefine_bar
      redefine_bar
      test_it
    end
  end

  describe "after undefining" do
    def undefine_foo 
      Bar2.module_eval do
        undef_method(:bar)
      end
    end

    def test_it
      @bar = Bar2.new.bar
      @bar.should == :fast
    end

    it "should not let foo() be undefined" do
      undefine_foo
      test_it
    end
  end

  describe "after removing" do
    def remove_bar 
      Bar3.module_eval do
        remove_method(:bar)
      end
    end

    def test_it
      @bar = Bar3.new.bar
      @bar.should == :fast
    end

    it "should not let bar() be removed" do
      remove_bar
      test_it
    end
  end
end
