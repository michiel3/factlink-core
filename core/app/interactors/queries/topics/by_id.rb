module Queries
  module Topics
    class ById
      include Pavlov::Query

      arguments :id

      def execute
        KillObject.topic topic
      end

      def topic
        Topic.find id
      end

      def validate
        validate_hexadecimal_string :id, id
      end
    end
  end
end