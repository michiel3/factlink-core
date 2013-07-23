class Opinion < OurOhm
  module Subject
    module FactRelation

      def self.included(klass)
        klass.reference :influencing_opinion, Opinion
      end

      def get_influencing_opinion(depth=0)
        calculate_influencing_opinion if depth > 0
        influencing_opinion || Opinion.zero
      end

      def calculate_influencing_opinion(depth=0)
        net_fact_authority = from_fact.get_opinion(depth).net_authority
        net_relevance_authority = get_user_opinion(depth).net_authority

        authority = [[net_fact_authority, net_relevance_authority].min, 0].max

        evidence_type = OpinionType.for_relation_type(self.type)

        set_opinion :influencing_opinion, Opinion.for_type(evidence_type, authority)
      end

    end
  end
end
