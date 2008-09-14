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

  dont_rape(:foo)
end

describe "Module Foo.foo() after redefining" do
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

#################
# Class version #
#################
class Bar
  include SelfDefense

  def bar
    :fast
  end

  dont_rape(:bar)
end

describe "Class Bar.bar() after redefining" do
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
