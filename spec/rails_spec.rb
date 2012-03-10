require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'rubygems'
require 'active_record'
require 'bd_money/rails'

ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ':memory:')
ActiveRecord::Migration.verbose = false
ActiveRecord::Schema.define do
  create_table :money_examples, :force => true do |t|
    t.decimal :amount, :precision => 15, :scale => 2
    t.decimal :apr, :precision => 7, :scale => 5
  end
end

class DefaultLoanExample < ActiveRecord::Base
  set_table_name "money_examples"

  money :amount, :apr
end

class BetterLoanExample < ActiveRecord::Base
  set_table_name "money_examples"

  money :amount, :precision => 2, :round_mode => :half_up
  money :apr, :precision => 5, :round_mode => :floor
end

describe Money do
  describe "default settings" do
    it "should allow dynamic finders to work with money objects" do
      record = DefaultLoanExample.create! :amount => '325.75', :apr => '0.01234'
      DefaultLoanExample.find_by_amount(0.to_money).should be_nil
      found = DefaultLoanExample.find_by_amount('325.75'.to_money)
      found.should == record
      found.amount.should be_a(Money)
      found.amount.to_s.should == '325.75'
      found.apr.should be_a(Money)
      found.apr.to_s.should == '0.01'
    end
  end
  describe "custom settings" do
    it "should allow dynamic finders to work with money objects" do
      record = BetterLoanExample.create! :amount => '123.45', :apr => '0.01234'
      BetterLoanExample.find_by_amount(0.to_money).should be_nil
      found = BetterLoanExample.find_by_amount('123.45'.to_money)
      found.should == record
      found.amount.should be_a(Money)
      found.amount.to_s.should == '123.45'
      found.apr.should be_a(Money)
      found.apr.to_s.should == '0.01234'
    end
  end
  describe "setter method" do
    it "should pass on money values" do
      DefaultLoanExample.new(:amount => 1.to_money).amount.should == 1.to_money
    end

    it "should convert string values to money objects" do
      DefaultLoanExample.new(:amount => '2').amount.should == 2.to_money
    end

    it "should convert numeric values to money objects" do
      DefaultLoanExample.new(:amount => 3).amount.should == 3.to_money
    end

    it "should treat blank values as nil" do
      DefaultLoanExample.new(:amount => '').amount.should be_nil
    end

    it "should allow existing amounts to be set to nil with a blank value" do
      me = DefaultLoanExample.new :amount => 500.to_money
      me.update_attribute :amount, nil
      me.amount.should be_nil
    end
  end
end
