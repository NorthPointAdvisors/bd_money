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

  money :amount, :round_mode => :half_up, :format => :no_cents
  money :apr, :precision => 4, :round_mode => :floor, :format => :no_commas
end

describe Money do
  describe "default settings" do
    before(:all) { @record = BetterLoanExample.create! :amount => '325.75', :apr => '0.01234' }
    subject { BetterLoanExample.find_by_amount('325.75'.to_money) }
    it { BetterLoanExample.find_by_amount(0.to_money).should be_nil }
    it { subject.id.should == @record.id }
    it { subject.amount.should be_a(Money) }
    it { subject.amount.to_s.should == '325.75' }
    it { subject.amount.format.should == :no_cents }
    it { subject.amount.formatted.should == '$ 325.75' }
    it { subject.apr.should be_a(Money) }
    it { subject.apr.to_s.should == '0.0123' }
    it { subject.apr.format.should == :no_commas }
    it { subject.apr.formatted.should == '$ 0.01' }
    it { subject.apr.formatted(:precision => 3, :unit => "", :spacer => "").should == '0.012' }
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
      found.apr.to_s.should == '0.0123'
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

    describe "should round numbers to the column's' precision" do
      subject { BetterLoanExample.new :amount => 300, :apr => 0.123456789 }
      it { subject.amount.amount.to_s('F').should == '300.0' }
      it { subject.apr.amount.to_s('F').should == '0.1234' }
    end

    describe "should provide valid json encoding" do
      subject { BetterLoanExample.new :amount => 300, :apr => 0.123456789 }
      it { subject.amount.as_json.should == '300.00' }
      it { subject.apr.as_json.should == '0.1234' }
      it { subject.as_json.should == {"apr"=>0.1234, "amount"=>300.00} }
      it { subject.to_json.should == '{"apr":0.1234,"amount":300.00}' }
    end

  end
end
