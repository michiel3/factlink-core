require 'spec_helper'

describe Opinion do

  let(:o1) { Opinion.tuple(2,3,5,7) }
  let(:o2) { Opinion.tuple(11,13,19,23) }
  let(:o3) { Opinion.tuple(29,31,37,41) }

  describe ".new" do
    subject {Opinion.tuple(1.3,1.4,1.5,1.6)}
    its(:b) {should == 1.3}
    its(:d) {should == 1.4}
    its(:u) {should == 1.5}
    its(:a) {should == 1.6}
  end

  describe "attributes" do
    subject { Opinion.tuple(0,0,0,0) }

    it { should respond_to :b }
    it { should respond_to :d }
    it { should respond_to :u }
    it { should respond_to :a }

    it { expect {subject.b = 1.3}.to change{subject.b}.to(1.3) }
    it { expect {subject.d = 1.3}.to change{subject.d}.to(1.3) }
    it { expect {subject.u = 1.3}.to change{subject.u}.to(1.3) }
    it { expect {subject.a = 1.3}.to change{subject.a}.to(1.3) }
  end

  it "should not change if you sum it with another one" do
    a = Opinion.tuple(1,0,0,1)
    b = Opinion.tuple(0,1,0,1)
    c = a + b
    a.b.should == 1
    b.d.should == 1
  end

  it "should be equal to an opinion with the same numbers" do
    Opinion.tuple(1,2,3,4).should == Opinion.tuple(1,2,3,4)
  end

  it "should be unequal to an opinion with different numbers" do
    a = Opinion.tuple(1,1,1,1)

    a.should_not == Opinion.tuple(2,1,1,1)
    a.should_not == Opinion.tuple(1,2,1,1)
    a.should_not == Opinion.tuple(1,2,1,1)
    a.should_not == Opinion.tuple(1,2,1,1)
  end

  it "should have the proper values when retrieved with for_type without explicit authority" do
    Opinion.for_type(:believes).should    == Opinion.tuple(1,0,0,0)
    Opinion.for_type(:disbelieves).should == Opinion.tuple(0,1,0,0)
    Opinion.for_type(:doubts).should     == Opinion.tuple(0,0,1,0)
  end

  it "should have the proper values when retrieved with for_type with explicit authority" do
    Opinion.for_type(:believes,1.3).should    == Opinion.tuple(1,0,0,1.3)
    Opinion.for_type(:disbelieves,1.3).should == Opinion.tuple(0,1,0,1.3)
    Opinion.for_type(:doubts,1.3).should      == Opinion.tuple(0,0,1,1.3)
  end

  it "should result in the same opinion when you sum it with an opinion with 0 authority" do
    a = Opinion.tuple(1,2,3,1)
    zero = Opinion.tuple(1000,1000,1000,0)
    a.should == a+zero
  end

  it "should have a + which does not crash when adding opinions with 0 authority" do
    Opinion.tuple(1,2,3)+Opinion.tuple(1,2,3)
  end

  it "should have a commutative + operation" do
    (o1+o2).should == (o2+o1)
    (o2+o3).should == (o3+o2)
    (o1+o3).should == (o3+o1)
  end

  it "should have an associative + operation" do
    ((o1+o2)+o3).should == (o1+(o2+o3))
  end

  it "should have a combine operation which does the same as the + operation" do
    Opinion.combine([]).should == Opinion.zero
    Opinion.combine([o1]).should == o1
    Opinion.combine([o1,o2]).should == o1+o2
    Opinion.combine([o1,o2,o3]).should == o1+o2+o3
  end

  it "should have authorities which add up" do
    (o1+o2).authority.should == o1.authority + o2.authority
    (o1+o2+o3).authority.should == o1.authority + o2.authority + o3.authority
  end

  describe '.real_for' do
    it do
    end
  end
end
