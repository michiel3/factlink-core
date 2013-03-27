require 'spec_helper'

class Basefact < OurOhm;end
class Fact < Basefact;end
class GraphUser < OurOhm;end

describe Channel::Overtaker do
  include AddFactToChannelSupport

  def create_channel(opts={})
    ch = Channel.create(opts)
    ch.singleton_class.send :include, Channel::Overtaker
    ch
  end

  let(:ch1) {create_channel created_by: u1, title: "Something" }
  let(:ch2) {create_channel created_by: u1, title: "Diddly"}

  let(:subch1) {create_channel created_by: u1, title: "Sub"}

  let(:u1) { GraphUser.create }

  let (:f1) { create :fact }
  let (:f2) { create :fact }

  before do
    Fact.stub(:invalid,false)
  end

  describe :take_over do
    it "should move all internal facts" do
      add_fact_to_channel f1, ch1
      add_fact_to_channel f2, ch2
      ch1.take_over(ch2)
      expect(ch1.facts).to match_array [f1,f2]
    end
    it "should move all deleted facts" do
      add_fact_to_channel f1, ch1
      ch2.remove_fact f1
      ch1.take_over(ch2)
      expect(ch1.facts).to match_array []
    end
    it "should take over contained_channels" do
      ch2.add_channel subch1
      ch1.take_over ch2
      expect(ch1.contained_channels.all).to match_array [subch1]
      expect(subch1.containing_channels.all).to match_array [ch1,ch2]
    end
  end
end
