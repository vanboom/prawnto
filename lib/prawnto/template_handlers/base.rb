module Prawnto
  module TemplateHandlers
    class Base < (::Rails::VERSION::MAJOR < 3 ? ::ActionView::TemplateHandler : ::Object)
      include ::ActionView::TemplateHandlers::Compilable if ::Rails::VERSION::MAJOR < 3

      def self.call(template)
        "_prawnto_compile_setup;" +
        "pdf = Prawn::Document.new(@prawnto_options[:prawn]);" +
        "#{template.source}\n" +
        "pdf.render;"
      end

      if ::Rails::VERSION::MAJOR < 3 || (::Rails::VERSION::MAJOR == 3 && ::Rails::VERSION::MINOR < 1)
        def compile(template)
          self.class.call(template)
        end
      end
    end
  end
end


