require 'spec_helper'


describe "computed opinion" do
  include BeliefExpressions

  before do
    Commands::Topics::UpdateUserAuthority.stub new: (stub call: nil)
  end

  let(:u1) { create(:graph_user) }
  let(:u2) { create(:graph_user) }
  let(:u3) { create(:graph_user) }
  let(:u4) { create(:graph_user) }

  let(:f1) { create(:fact) }
  let(:f2) { create(:fact) }

  # f1 --> f2
  let(:f1sup2) { f2.add_evidence(:supporting, f1, u1) }

  # f1 !-> f2
  let(:f1weak2) { f2.add_evidence(:weakening, f1, u1) }

  before do
    # TODO: remove this once activities are not created in the models any more,
    # but in interactors
    stub_const 'Activity::Subject', Class.new
    Activity::Subject.should_receive(:activity).any_number_of_times
    Fact.any_instance.stub(:add_to_created_facts).and_return(true)
  end

  it "should be unsure when without votes and evidence" do
    opinion?(f1) == _(0.0, 0.0, 1.0, 0.0)
  end

  it "should be belief when both votes are" do
    believes(u1, f1)
    believes(u2, f1)
    opinion?(f1) == _(1.0, 0.0, 0.0, 2.0)
  end

  it "should be disbelief when both votes are" do
    disbelieves(u1, f1)
    disbelieves(u2, f1)
    opinion?(f1) == _(0.0, 1.0, 0.0, 2.0)
  end

  it "should be divided when there's a pro and contra vote" do
    believes(u1, f1)
    disbelieves(u2, f1)
    opinion?(f1) == _(0.5, 0.5, 0.0, 2.0)
  end

  it "should be somewhat believed but with authority 2
      when there's a pro and unsure vote" do
    believes(u1, f1)
    doubts(u2, f1)
    opinion?(f1) == _(0.5, 0.0, 0.5, 2.0)
  end

  it "should propagate to supported facts, but authority is capped to the
      relation's authority" do
    believes(u1, f1)
    believes(u2, f1)
    believes(u2, f1sup2)
    opinion?(f1sup2) == _(1.0, 0.0, 0.0, 1.0)
    opinion?(f2) == _(1.0, 0.0, 0.0, 1.0)
  end

  it "should propagate to supported facts, but authority is capped to the
      supporting fact's authority" do
    believes(u1, f1)
    believes(u1, f1sup2)
    believes(u2, f1sup2)
    opinion?(f1sup2) == _(1.0, 0.0, 0.0, 2.0)
    opinion?(f2) == _(1.0, 0.0, 0.0, 1.0)
  end

  it "should propagate to weakened facts, but authority is capped to the
      relation's authority" do
    believes(u1, f1)
    believes(u2, f1)
    believes(u2, f1weak2)
    opinion?(f1weak2) == _(1.0, 0.0, 0.0, 1.0)
    opinion?(f2) == _(0.0, 1.0, 0.0, 1.0)
  end

  it "should propagate to weakened facts, but authority is capped to the
      weaking fact's authority" do
    believes(u1, f1)
    believes(u1, f1weak2)
    believes(u2, f1weak2)
    opinion?(f1weak2) == _(1.0, 0.0, 0.0, 2.0)
    opinion?(f2) == _(0.0, 1.0, 0.0, 1.0)
  end

  it "should be zero when there is only a supporting fact relation that is
      entirely disputed, even if supporting fact is true" do
    believes(u1, f1)
    believes(u2, f1)
    believes(u1, f1sup2)
    disbelieves(u2, f1sup2)
    opinion?(f1sup2) == _(0.5, 0.5, 0.0, 2.0)
    opinion?(f2) == Opinion.zero
  end

  it "should be zero when there is only a supporting fact relation that is
      unanimously believed but the supporting fact is in dispute" do
    believes(u1, f1)
    disbelieves(u2, f1)
    believes(u1, f1sup2)
    opinion?(f1) == _(0.5, 0.5, 0.0, 2.0)
    opinion?(f1sup2) == _(1.0, 0.0, 0.0, 1.0)
    opinion?(f2) == Opinion.zero
  end

  it "should weigh one vote for supporting evidence as heavily as a direct
      disbelief vote when the supporting fact is strongly believed" do
    believes(u1, f1)
    believes(u2, f1)
    believes(u1, f1sup2)
    disbelieves(u3, f2)
    opinion?(f1) == _(1.0, 0.0, 0.0, 2.0)
    opinion?(f1sup2) == _(1.0, 0.0, 0.0, 1.0)
    opinion?(f2) == _(0.5, 0.5, 0.0, 2.0)
  end

  it "should weigh one vote for supporting evidence as heavily as a direct
      disbelief vote when the supporting fact has equal authority to the
      disbelieving user" do
    believes(u2, f1)
    believes(u1, f1sup2)
    disbelieves(u3, f2)
    opinion?(f1) == _(1.0, 0.0, 0.0, 1.0)
    opinion?(f1sup2) == _(1.0, 0.0, 0.0, 1.0)
    opinion?(f2) == _(0.5, 0.5, 0.0, 2.0)
  end


end
