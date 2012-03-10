require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Numeric do
  describe "to_money" do
    subject { 3 }
    it { subject.to_money.should == Money.new('3') }
    it { (subject * -1).to_money.should == Money.new('-3') }
  end
end

describe Float do
  describe "to_money" do
    subject { 3.53 }
    it { subject.to_money.should == Money.new('3.53') }
    it { (subject * -1).to_money.should == Money.new('-3.53') }
    it { subject.to_money.precision.should == Money.precision }
    it { subject.to_money.round_mode.should == Money.round_mode }
    it { subject.to_money(3).precision.should == 3 }
    it { subject.to_money(nil, :up).round_mode.should == :up }
  end
end

describe String do
  describe "to_money" do
    subject { '3.53' }
    it { subject.to_money.should == Money.new('3.53') }
    it { subject.to_money.precision.should == Money.precision }
    it { subject.to_money.round_mode.should == Money.round_mode }
    it { subject.to_money(3).precision.should == 3 }
    it { subject.to_money(nil, :up).round_mode.should == :up }
  end
end