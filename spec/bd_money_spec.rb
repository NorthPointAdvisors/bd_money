require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Money do

  let(:amt) { '3.53' }
  let(:neg_amt) { '-3.53' }
  let(:other_amt) { 1.01 }
  subject { Money.new amt, 2, :half_down }
  let(:neg_subject) { Money.new neg_amt, 2, :half_down }

  describe "class precision" do
    it { Money.precision.should == 2 }
    it "should support customization" do
      old_value       = Money.instance_variable_get :@precision
      Money.precision = 3
      Money.precision.should == 3
      Money.instance_variable_set :@precision, old_value
    end
    it { expect { Money.precision = '3' }.to raise_error(RuntimeError) }
  end

  describe "class round mode" do
    it { Money.round_mode.should == :half_up }
    it "should support customization" do
      old_value        = Money.instance_variable_get :@round_mode
      Money.round_mode = :floor
      Money.round_mode.should == :floor
      Money.instance_variable_set :@round_mode, old_value
    end
    it { expect { Money.round_mode = :not_there }.to raise_error(RuntimeError) }
  end

  describe "class convert" do
    describe "strings" do
      it { Money.convert('3.53').to_s.should == '3.53' }
      it { Money.convert('-3.53').to_s.should == '-3.53' }
    end
    describe "integers" do
      it { Money.convert(3).to_s.should == '3.00' }
      it { Money.convert(-3).to_s.should == '-3.00' }
    end
    describe "floats" do
      it { Money.convert(3.53).to_s.should == '3.53' }
      it { Money.convert(-3.53).to_s.should == '-3.53' }
    end
  end

  describe "class clean" do
    it { Money.clean(1).should == '1' }
    it { Money.clean(1.1).should == '1.1' }
    it { Money.clean('$ 3,456,789.01').should == '3456789.01' }
    it { Money.clean('3_456_789.01').should == '3456789.01' }
    it { Money.clean('[ $ 3,456,789.01 ]').should == '[3456789.01]' }
    it { Money.clean('You owe me $ 35.50').should == 'Youoweme35.50' }
  end

  describe "class valid?" do
    it { Money.valid?(1).should be_true }
    it { Money.valid?('1').should be_true }
    it { Money.valid?(1.1).should be_true }
    it { Money.valid?('3456789.01').should be_true }
    it { Money.valid?('$ 3.45').should_not be_true }
    it { Money.valid?('[3.45]').should_not be_true }
    it { Money.valid?('0.01').should be_true }
    it { Money.valid?('.01').should_not be_true }
    it { Money.valid?('-0.01').should be_true }
    it { Money.valid?('-.01').should_not be_true }
  end

  describe "initialize" do
    describe "defaults" do
      subject { Money.new '3.53' }
      it { subject.to_s.should == '3.53' }
      it { subject.precision.should == 2 }
      it { subject.round_mode.should == :half_up }
    end
    describe "custom" do
      subject { Money.new '3.53', 1, :floor }
      it { subject.to_s.should == '3.5' }
      it { subject.precision.should == 1 }
      it { subject.round_mode.should == :floor }
    end
    describe "customize" do
      describe "amount" do
        it { subject.amount = '5.35'; subject.to_s.should == '5.35' }
      end
      describe "precision" do
        it { subject.precision = 4; subject.precision.should == 4 }
        it { expect { Money.precision = '4' }.to raise_error(RuntimeError) }
      end
      describe "round_mode" do
        it { subject.round_mode = :floor; subject.round_mode.should == :floor }
        it { expect { Money.round_mode = :not_there }.to raise_error(RuntimeError) }
      end
    end
  end

  describe "convert" do
    describe "strings" do
      it { subject.convert('3.53').to_s.should == '3.53' }
      it { subject.convert('-3.53').to_s.should == '-3.53' }
    end
    describe "integers" do
      it { subject.convert(3).to_s.should == '3.00' }
      it { subject.convert(-3).to_s.should == '-3.00' }
    end
    describe "floats" do
      it { subject.convert(3.53).to_s.should == '3.53' }
      it { subject.convert(-3.53).to_s.should == '-3.53' }
    end
  end

  describe Comparable do
    let(:amt) { 5.35 }
    describe "eql" do
      it { subject.eql?(Money.new(amt)).should be_true }
      it { subject.eql?(amt).should be_true }
      it { subject.eql?(amt.to_s).should be_true }
    end
    describe "<=>" do
      it { subject.<=>(amt).should == 0 }
      it { subject.<=>(amt + 1).should == -1 }
      it { subject.<=>(amt - 1).should == 1 }
    end
  end

  describe "Operations" do
    describe "+" do
      subject { Money.new(amt) + other_amt }
      it { should be_a Money }
      it { should == 4.54 }
    end
    describe "-" do
      subject { Money.new(amt) - other_amt }
      it { should be_a Money }
      it { should == 2.52 }
    end
    describe "*" do
      subject { Money.new(amt) * other_amt }
      it { should be_a Money }
      it { subject.to_s.should == '3.57' }
    end
    describe "/" do
      subject { Money.new(amt) / other_amt }
      it { should be_a Money }
      it { subject.to_s.should == '3.50' }
    end
    describe "**" do
      subject { Money.new(amt) ** other_amt }
      it { should be_a Money }
      it { should == 3.53 }
    end
    describe "%" do
      subject { Money.new(amt) % other_amt }
      it { should be_a Money }
      it { should == 0.50 }
    end
    describe "to_credit" do
      it { subject.object_id.should_not == subject.to_credit.object_id }
      it { subject.to_credit.should == 3.53 }
      it { neg_subject.to_credit.should == 3.53 }
    end
    describe "to_credit!" do
      it { o = Money.new(amt); o.object_id.to_s.should == o.to_credit!.object_id.to_s }
      it { subject.to_credit!.should == 3.53 }
      it { neg_subject.to_credit!.should == 3.53 }
    end
    describe "credit?" do
      it { subject.should be_credit }
      it { neg_subject.should_not be_credit }
    end
    describe "to_debit" do
      it { subject.object_id.should_not == subject.to_credit.object_id }
      it { subject.to_debit.should == -3.53 }
      it { neg_subject.to_debit.should == -3.53 }
    end
    describe "to_debit!" do
      it { subject.object_id.to_s.should == subject.to_debit!.object_id.to_s }
      it { subject.to_debit!.should == -3.53 }
      it { neg_subject.to_debit!.should == -3.53 }
    end
    describe "debit?" do
      it { subject.should_not be_debit }
      it { neg_subject.should be_debit }
    end
    describe "zero?" do
      it { subject.should_not be_zero }
      it { neg_subject.should_not be_zero }
      it { Money.new('0').should be_zero }
      it { Money.new('0.0').should be_zero }
    end
    describe "to_i" do
      describe "positive" do
        subject { Money.new(3.21).to_i }
        it { subject.should == 3 }
        it { subject.should be_a Integer }
      end
      describe "negative" do
        subject { Money.new(-3.21).to_i }
        it { subject.should == -3 }
        it { subject.should be_a Integer }
      end
    end
    describe "to_f" do
      describe "positive" do
        subject { Money.new(3.21).to_f }
        it { subject.should == 3.21 }
        it { subject.should be_a Float }
      end
      describe "negative" do
        subject { Money.new(-3.21).to_f }
        it { subject.should == -3.21 }
        it { subject.should be_a Float }
      end
    end
  end

  describe "to_s" do
    describe "no decimals" do
      let(:amt) { '3' }
      it { subject.to_s.should == "#{amt}.00" }
      it { subject.to_s(0).should == amt }
      it { subject.to_s(1).should == "#{amt}.0" }
      it { subject.to_s(2).should == "#{amt}.00" }
      it { subject.to_s(3).should == "#{amt}.000" }
      it { subject.to_s(4).should == "#{amt}.0000" }
      it { subject.to_s(5).should == "#{amt}.00000" }
      it { subject.to_s(6).should == "#{amt}.000000" }
    end
    describe "one decimal" do
      let(:amt) { '3.5' }
      it { subject.to_s.should == "#{amt}0" }
      it { subject.to_s(0).should == amt[0, 1] }
      it { subject.to_s(1).should == amt[0, 3] }
      it { subject.to_s(2).should == "#{amt}0" }
      it { subject.to_s(3).should == "#{amt}00" }
      it { subject.to_s(4).should == "#{amt}000" }
      it { subject.to_s(5).should == "#{amt}0000" }
      it { subject.to_s(6).should == "#{amt}00000" }
    end
    describe "two decimals" do
      let(:amt) { '3.53' }
      it { subject.to_s.should == amt }
      it { subject.to_s(0).should == amt[0, 1] }
      it { subject.to_s(1).should == amt[0, 3] }
      it { subject.to_s(2).should == amt }
      it { subject.to_s(3).should == "#{amt}0" }
      it { subject.to_s(4).should == "#{amt}00" }
      it { subject.to_s(5).should == "#{amt}000" }
      it { subject.to_s(6).should == "#{amt}0000" }
    end
    describe "three decimals" do
      let(:amt) { '3.534' }
      it { subject.to_s.should == amt[0, 4] }
      it { subject.to_s(0).should == amt[0, 1] }
      it { subject.to_s(1).should == amt[0, 3] }
      it { subject.to_s(2).should == amt[0, 4] }
      it { subject.to_s(3).should == amt }
      it { subject.to_s(4).should == "#{amt}0" }
      it { subject.to_s(5).should == "#{amt}00" }
      it { subject.to_s(6).should == "#{amt}000" }
    end
    describe "four decimals" do
      let(:amt) { '3.5343' }
      it { subject.to_s.should == amt[0, 4] }
      it { subject.to_s(0).should == amt[0, 1] }
      it { subject.to_s(1).should == amt[0, 3] }
      it { subject.to_s(2).should == amt[0, 4] }
      it { subject.to_s(3).should == amt[0, 5] }
      it { subject.to_s(4).should == amt }
      it { subject.to_s(5).should == "#{amt}0" }
      it { subject.to_s(6).should == "#{amt}00" }
    end
    describe "five decimals" do
      let(:amt) { '3.53434' }
      it { subject.to_s.should == amt[0, 4] }
      it { subject.to_s(0).should == amt[0, 1] }
      it { subject.to_s(1).should == amt[0, 3] }
      it { subject.to_s(2).should == amt[0, 4] }
      it { subject.to_s(3).should == amt[0, 5] }
      it { subject.to_s(4).should == amt[0, 6] }
      it { subject.to_s(5).should == amt }
      it { subject.to_s(6).should == "#{amt}0" }
    end
    describe "six decimals" do
      let(:amt) { '3.534343' }
      it { subject.to_s.should == amt[0, 4] }
      it { subject.to_s(0).should == amt[0, 1] }
      it { subject.to_s(1).should == amt[0, 3] }
      it { subject.to_s(2).should == amt[0, 4] }
      it { subject.to_s(3).should == amt[0, 5] }
      it { subject.to_s(4).should == amt[0, 6] }
      it { subject.to_s(5).should == amt[0, 7] }
      it { subject.to_s(6).should == amt }
    end
  end

  describe "format" do
    let(:amt) { '1234567.12' }
    let(:neg_amt) { '-1234567.12' }
    it { subject.formatted().should == '$ 1,234,567.12' }
    it { subject.formatted(:no_cents).should == '$ 1,234,567' }
    it { subject.formatted(:no_commas).should == '$ 1234567.12' }
    it { subject.formatted(:precision => 1).should == '$ 1,234,567.1' }
    it { subject.formatted(:no_commas, :precision => 1).should == '$ 1234567.1' }
    it { neg_subject.formatted().should == '$ -1,234,567.12' }
    it { neg_subject.formatted(:no_cents).should == '$ -1,234,567' }
    it { neg_subject.formatted(:no_commas).should == '$ -1234567.12' }
    it { neg_subject.formatted(:precision => 1).should == '$ -1,234,567.1' }
    it { neg_subject.formatted(:no_commas, :precision => 1).should == '$ -1234567.1' }
  end

  describe "forwarded" do
    describe "power" do
      subject { Money.new(amt).power 2 }
      it { should be_a Money }
      it { subject.to_s.should == '12.46' }
    end
  end

  describe "Rounding" do
    let(:pos_amt1) { Money.new '1.4' }
    let(:pos_amt2) { Money.new '1.5' }
    let(:pos_amt3) { Money.new '1.6' }
    let(:neg_amt1) { Money.new '-1.4' }
    let(:neg_amt2) { Money.new '-1.5' }
    let(:neg_amt3) { Money.new '-1.6' }
    describe "up" do
      it { pos_amt1.to_i(:up).should == 2 }
      it { pos_amt2.to_i(:up).should == 2 }
      it { pos_amt3.to_i(:up).should == 2 }
      it { neg_amt1.to_i(:up).should == -2 }
      it { neg_amt2.to_i(:up).should == -2 }
      it { neg_amt3.to_i(:up).should == -2 }
    end
    describe "down" do
      it { pos_amt1.to_i(:down).should == 1 }
      it { pos_amt2.to_i(:down).should == 1 }
      it { pos_amt3.to_i(:down).should == 1 }
      it { neg_amt1.to_i(:down).should == -1 }
      it { neg_amt2.to_i(:down).should == -1 }
      it { neg_amt3.to_i(:down).should == -1 }
    end
    describe "half_up" do
      it { pos_amt1.to_i(:half_up).should == 1 }
      it { pos_amt2.to_i(:half_up).should == 2 }
      it { pos_amt3.to_i(:half_up).should == 2 }
      it { neg_amt1.to_i(:half_up).should == -1 }
      it { neg_amt2.to_i(:half_up).should == -2 }
      it { neg_amt3.to_i(:half_up).should == -2 }
    end
    describe "half_down" do
      it { pos_amt1.to_i(:half_down).should == 1 }
      it { pos_amt2.to_i(:half_down).should == 1 }
      it { pos_amt3.to_i(:half_down).should == 2 }
      it { neg_amt1.to_i(:half_down).should == -1 }
      it { neg_amt2.to_i(:half_down).should == -1 }
      it { neg_amt3.to_i(:half_down).should == -2 }
    end
    describe "half_even" do
      it { pos_amt1.to_i(:half_even).should == 1 }
      it { pos_amt2.to_i(:half_even).should == 2 }
      it { pos_amt3.to_i(:half_even).should == 2 }
      it { neg_amt1.to_i(:half_even).should == -1 }
      it { neg_amt2.to_i(:half_even).should == -2 }
      it { neg_amt3.to_i(:half_even).should == -2 }
    end
    describe "ceiling" do
      it { pos_amt1.to_i(:ceiling).should == 2 }
      it { pos_amt2.to_i(:ceiling).should == 2 }
      it { pos_amt3.to_i(:ceiling).should == 2 }
      it { neg_amt1.to_i(:ceiling).should == -1 }
      it { neg_amt2.to_i(:ceiling).should == -1 }
      it { neg_amt3.to_i(:ceiling).should == -1 }
    end
    describe "floor" do
      it { pos_amt1.to_i(:floor).should == 1 }
      it { pos_amt2.to_i(:floor).should == 1 }
      it { pos_amt3.to_i(:floor).should == 1 }
      it { neg_amt1.to_i(:floor).should == -2 }
      it { neg_amt2.to_i(:floor).should == -2 }
      it { neg_amt3.to_i(:floor).should == -2 }
    end
  end

end
