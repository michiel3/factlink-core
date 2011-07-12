require 'spec_helper'

describe Opinion do

  before(:each) do
    @o1 = Opinion.new(2,3,5,7)
    @o2 = Opinion.new(11,13,19,23)
    @o3 = Opinion.new(29,31,37,41)
  end

  after(:each) do
    #@o1.a.should == 3
  end
  
  it "should have Belief set to 1 the initial value" do
    Opinion.new(1.3,0,0,1).b.should == 1.3
  end

  it "should have Disbelief set to the initial value" do
    Opinion.new(0,1.3,0,1).d.should == 1.3
  end

  it "should have Unknown set to the initial value" do
    Opinion.new(0,0,1.3,1).u.should == 1.3
  end

  it "should have Authority set to 0 if unspecified" do
    Opinion.new(0,0,1.3,0).a.should == 0
  end

  it "should have Authority set to specified value " do
    Opinion.new(0,0,1,1.3).a  .should == 1.3
  end
  
  describe "should have working attribute accessors" do
    subject { Opinion.new(0,0,0,0) }
    
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
    a = Opinion.new(1,0,0,1)
    b = Opinion.new(0,1,0,1)
    c = a + b
    a.b.should == 1
    b.d.should == 1
  end


  it "should be equal to an opinion with the same numbers" do
    Opinion.new(1,2,3,4).should == Opinion.new(1,2,3,4)
  end
  
  it "should be unequal to an opinion with different numbers" do
    a = Opinion.new(1,1,1,1)

    a.should_not == Opinion.new(2,1,1,1)
    a.should_not == Opinion.new(1,2,1,1)
    a.should_not == Opinion.new(1,2,1,1)
    a.should_not == Opinion.new(1,2,1,1)
  end
  
  it "should have the proper values when retrieved with for_type without explicit authority" do
    Opinion.for_type(:beliefs).should    == Opinion.new(1,0,0,0)
    Opinion.for_type(:disbeliefs).should == Opinion.new(0,1,0,0)
    Opinion.for_type(:doubts).should     == Opinion.new(0,0,1,0)
  end
  
  it "should have the proper values when retrieved with for_type with explicit authority" do
    Opinion.for_type(:beliefs,1.3).should    == Opinion.new(1,0,0,1.3)
    Opinion.for_type(:disbeliefs,1.3).should == Opinion.new(0,1,0,1.3)
    Opinion.for_type(:doubts,1.3).should     == Opinion.new(0,0,1,1.3)
  end

  it "should result in the same opinion when you sum it with an opinion with 0 authority" do
    a = Opinion.new(1,2,3,1)
    zero = Opinion.new(1000,1000,1000,0)
    a.should == a+zero
  end

  it "should have a commutative + operation" do
    (@o1+@o2).should == (@o2+@o1)
    (@o2+@o3).should == (@o3+@o2)
    (@o1+@o3).should == (@o3+@o1)
  end
  
  it "should have an associative + operation" do
    ((@o1+@o2)+@o3).should == (@o1+(@o2+@o3))
  end
  
  it "should have a combine operation which does the same as the + operation" do
    Opinion.combine([@o1]).should == @o1
    Opinion.combine([@o1,@o2]).should == @o1+@o2
    Opinion.combine([@o1,@o2,@o3]).should == @o1+@o2+@o3
  end
  
  it "should have zero weight when authority is zero" do
    Opinion.new(100,100,100,0).weight.should == 0
  end
  
  it "should have weights which add up" do
    (@o1+@o2).weight.should == @o1.weight + @o2.weight
    (@o1+@o2+@o3).weight.should == @o1.weight + @o2.weight + @o3.weight
  end
end