require 'rubygems'
require 'spec'
require 'ruby-debug'

require File.join(File.dirname(__FILE__), '..', 'lib', 'immutable')

##################
# Module version #
##################

module Foo
  include Immutable

  def foo
    :fast
  end

  def bar
    :fast
  end

  immutable_method :foo, :bar, :silent => true
end

# Other Foo modules we can screw with, so specs don't step on each other
Foo2 = Foo.clone
Foo3 = Foo.clone

describe "Module Foo" do
  describe "after redefining" do
    it "should not let foo() be redefined" do
      redefine(Foo, :foo)
      test_it(Foo, :foo)
    end
  
    it "should not let foo() be redefined even if we try twice" do
      redefine(Foo, :foo)
      redefine(Foo, :foo)
      test_it(Foo, :foo)
    end

    it "should not let bar() be redefined" do
      redefine(Foo, :bar)
      test_it(Foo, :bar)
    end

    it "should not let bar() be redefined even if we try twice" do
      redefine(Foo, :bar)
      redefine(Foo, :bar)
      test_it(Foo, :bar)
    end
  end

  describe "after undefining" do
    it "should not let foo() be undefined" do
      undefine(Foo2, :foo)
      test_it(Foo2, :foo)
    end

    it "should not let bar() be undefined" do
      undefine(Foo2, :bar)
      test_it(Foo2, :bar)
    end
  end

  describe "after removing" do
    it "should not let foo() be removed" do
      remove(Foo3, :foo)
      test_it(Foo3, :foo)
    end

    it "should not let bar() be removed" do
      remove(Foo3, :bar)
      test_it(Foo3, :bar)
    end
  end
end

#################
# Class version #
#################

class Bar
  include Immutable

  def foo
    :fast
  end

  def bar
    :fast
  end

  immutable_method :foo, :bar, :silent => true
end

# Other Bar modules we can screw with, so specs don't step on each other
Bar2 = Bar.clone
Bar3 = Bar.clone

class ChildOfBar < Bar
  def foo
    :slow
  end
end

describe "Class Bar" do
  def test_it(klass, method)
    @value = klass.new.send(method)
    @value.should == :fast
  end
 
  describe "after redefining" do
    it "should not let foo() be redefined" do
      redefine(Bar, :foo)
      test_it(Bar, :foo)
    end
  
    it "should not let foo() be redefined even if we try twice" do
      redefine(Bar, :foo)
      redefine(Bar, :foo)
      test_it(Bar, :foo)
    end

    it "should not let bar() be redefined" do
      redefine(Bar, :bar)
      test_it(Bar, :bar)
    end
  
    it "should not let bar() be redefined even if we try twice" do
      redefine(Bar, :bar)
      redefine(Bar, :bar)
      test_it(Bar, :bar)
    end
  end

  describe "after undefining" do
    it "should not let foo() be undefined" do
      undefine(Bar2, :foo)
      test_it(Bar2, :foo)
    end

    it "should not let bar() be undefined" do
      undefine(Bar2, :bar)
      test_it(Bar2, :bar)
    end
  end

  describe "after removing" do
    it "should not let foo() be removed" do
      remove(Bar3, :foo)
      test_it(Bar3, :foo)
    end

    it "should not let bar() be removed" do
      remove(Bar3, :bar)
      test_it(Bar3, :bar)
    end
  end

  describe "child classes" do
    it "should still be able to override method" do
      ChildOfBar.new.foo.should == :slow
    end
  end
end

##############
# Exceptions #
##############

module Boo
  include Immutable

  def boo
    :fast
  end

  def boofoo
    :boofoo_fast
  end

  immutable_method :boofoo, :silent => true
  immutable_method :boo
end

describe "Exceptions" do
  describe "by default" do
    it "should raise exception upon override" do
      lambda do 
        redefine(Boo, :boo)
      end.should raise_error(Immutable::CannotOverrideMethod, /Cannot override the immutable method: boo$/)
    end
  end

  it "should not raise if :silent => true" do
    redefine(Boo, :boofoo)
    test_it(Boo, :boofoo, :boofoo_fast)
  end
end

#########
# Other #
#########

module Bear
  include Immutable

  def foo
    :foo_fast
  end

  def bar
    :bar_fast
  end

  def baz
    :baz_fast
  end

  def boo
    :boo_fast
  end

  # Make sure we can make independent calls to immutable_method
  immutable_method :foo
  immutable_method :bar
  immutable_method :baz, :silent => true
  immutable_method :boo
end

describe "Multiple independent calls to immutable_method()" do
  it "should still recognize foo() is immutable" do
    lambda do
      redefine(Bear, :foo)
    end.should raise_error(Immutable::CannotOverrideMethod, /Cannot override the immutable method: foo$/)
  end

  it "should still recognize bar() is immutable" do
    lambda do
      redefine(Bear, :bar)
    end.should raise_error(Immutable::CannotOverrideMethod, /Cannot override the immutable method: bar$/)
  end

  it "should still recognize baz() is immutable" do
    redefine(Bear, :baz)
    test_it(Bear, :baz, :baz_fast)
  end

  it "should still recognize boo() is immutable" do
    lambda do 
      redefine(Bear, :boo)
    end.should raise_error(Immutable::CannotOverrideMethod, /Cannot override the immutable method: boo$/)
  end
end

##################
# Helper methods #
##################

def redefine(mod, method)
  mod.module_eval <<-"end;"
    def #{method.to_s}
      :slow
    end
  end;
end

def undefine(mod, method)
  mod.module_eval do
    undef_method(method)
  end
end

def remove(mod, method)
  mod.module_eval do
    remove_method(method)
  end
end

def test_it(mod, method, value = :fast)
  @value = Object.instance_eval do
    include mod
    send(method)
  end

  @value.should == value
end
