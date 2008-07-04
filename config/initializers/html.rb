module ActionController #:stopdoc:
  module MimeResponds
    module InstanceMethods
      def respond_to(*types, &block)
        # Suppresses HTML respond_to's in Production Environment 
        request_format = self.request.parameters[:format] || 'html'
        raise "HTML is not supported in this environment" if (RAILS_ENV == "production" && request_format == 'html')
        # End Suppress
        raise ArgumentError, "respond_to takes either types or a block, never both" unless types.any? ^ block
        block ||= lambda { |responder| types.each { |type| responder.send(type) } }
        responder = Responder.new(self)
        block.call(responder)
        responder.respond
      end
    end
  end
end