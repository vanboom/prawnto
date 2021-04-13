module Prawnto
  module TemplateHandler
    class CompileSupport
      attr_reader :options

      def initialize(controller)
        @controller = controller
        @options = pull_options
        set_headers
      end

      def pull_options
        @controller.send :compute_prawnto_options || {}
      end

      def set_headers
        set_pragma
        set_cache_control
        set_content_type
        set_disposition
      end

      # TODO: kept around from railspdf-- maybe not needed anymore? should check.
      def ie_request?
        return @ie_request if instance_variable_defined?(:@ie_request)
        @ie_request = @controller.request.env['HTTP_USER_AGENT'] =~ /msie/i
      end

      # added to make ie happy with ssl pdf's (per naisayer)
      def ssl_request?
        return @ssl_request if instance_variable_defined?(:@ssl_request)
        protocol = @controller.request.env['SERVER_PROTOCOL']
        @ssl_request = protocol && protocol.downcase == "https"
      end

      # TODO: kept around from railspdf-- maybe not needed anymore? should check.
      def set_pragma
        if ssl_request? && ie_request?
          @controller.headers['Pragma'] = 'public' # added to make ie ssl pdfs work (per naisayer)
        else
          @controller.headers['Pragma'] ||= ie_request? ? 'no-cache' : ''
        end
      end

      # TODO: kept around from railspdf-- maybe not needed anymore? should check.
      def set_cache_control
        if ssl_request? && ie_request?
          @controller.headers['Cache-Control'] = 'maxage=1' # added to make ie ssl pdfs work (per naisayer)
        else
          @controller.headers['Cache-Control'] ||= ie_request? ? 'no-cache, must-revalidate' : ''
        end
      end

      def set_content_type
        @controller.response.content_type ||= Mime::EXTENSION_LOOKUP['pdf']
      end

      def set_disposition
        inline = options[:inline] ? 'inline' : 'attachment'
        filename = options[:filename] ? "filename=\"#{options[:filename]}\"" : nil
        @controller.headers["Content-Disposition"] = [inline,filename].compact.join(';')
      end

    end

  end
end
