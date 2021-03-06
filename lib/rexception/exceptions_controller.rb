module Rexception
  class ExceptionsController < ActionController::Base
    STATUSES = Rack::Utils::SYMBOL_TO_STATUS_CODE.select { |_, code| code >= 400 }

    STATUSES.each do |status, code|
      eval <<-RUBY
        def #{status}
          render template_exists?(view) ? view : view(:application), status: #{code}
        end
      RUBY
    end

    layout -> { layout }

    private

    def view(status = status())
      "#{errors_dir}/#{status}"
    end

    def status
      self.class.status(env)
    end

    def layout
      Rexception.layout
    end

    def errors_dir
      Rexception.errors_dir
    end

    class << self
      def call(env)
        action(status(env)).call(env)
      end

      def status(env)
        ActionDispatch::ExceptionWrapper.rescue_responses[exception(env).class.name]
      end

      def exception(env)
        env['action_dispatch.exception']
      end
    end
  end
end
