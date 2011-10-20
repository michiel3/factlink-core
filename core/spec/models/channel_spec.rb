require 'spec_helper'

describe Channel do
  subject {Channel.create(:created_by => u1, :title => "Subject")}

  let(:u1) { FactoryGirl.create(:user).graph_user }
  let(:u2) { FactoryGirl.create(:user).graph_user }
  let(:u3) { FactoryGirl.create(:user).graph_user }
  
  let (:f1) {FactoryGirl.create(:fact) }
  let (:f2) {FactoryGirl.create(:fact) }
  let (:f3) {FactoryGirl.create(:fact) }
  let (:f4) {FactoryGirl.create(:fact) }
  
  describe "initially" do
    it { subject.facts.to_a.should =~ []}
  end
  
  describe "after adding one fact" do
    before do
      subject.add_fact(f1)
      Channel.recalculate_all
    end
    it { subject.facts.to_a.should =~ [f1]}
    describe "and removing an fact" do
      before do
        subject.remove_fact(f1)
        Channel.recalculate_all
      end
      it { subject.facts.to_a.should =~ []}
    end
    
    describe "and removing a fact (not from the Channel but the fact itself) without recalculate" do
      before do
        f1.delete
      end
      it { subject.facts.to_a.should =~ []}
    end
    
    
    describe "after forking" do
      before do
         @fork = subject.fork(u2)
        end  
      
      it {subject.facts.to_a.should =~ [f1]}
      it {@fork.facts.to_a.should =~ [f1]}
      
      describe "and removing the fact from the original" do
        before do
          subject.remove_fact(f1)
          Channel.recalculate_all
        end
        it {subject.facts.to_a.should =~ []}
        it {@fork.facts.to_a.should =~ []}
      end
      describe "and removing the fact from the fork" do
        before do
           @fork.remove_fact(f1)
         end
        it {subject.facts.to_a.should =~ [f1]}
        it {@fork.facts.to_a.should =~ []}
      end
      describe "after adding another fact to the original" do
        before do
           subject.add_fact(f2)
           Channel.recalculate_all
         end
        it {subject.facts.to_a.should =~ [f1,f2]}
        it {@fork.facts.to_a.should =~ [f1,f2]}
      end
      describe "after adding another fact to the fork" do
        before do
           @fork.add_fact(f2)
         end
        it {subject.facts.to_a.should =~ [f1]}
        it {@fork.facts.to_a.should =~ [f1,f2]}
      end
    end
    describe "forking the channel yourself" do
      before do
        @fork = subject.fork(u1) 
      end
    end
  end
  
  describe "#related_users" do
    
    describe "should not contain the owner of the channel" do
      # test this by mocking a calculator and checking whether created by is in excleded users
    end
  end
  
end