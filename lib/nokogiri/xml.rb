module Nokogiri
  module XML
    class Node
      def traverse_topdown(&block)
        yield(self)
        children.each { |j| j.traverse_topdown(&block) }
      end
    end
  end   
end
