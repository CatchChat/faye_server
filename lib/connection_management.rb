module ActiveRecord
  module ConnectionAdapters
    class ConnectionManagement
      def initialize(app)
        @app = app
      end

      def call(env)
        testing = env['rack.test']

        response = @app.call(env)
        ActiveRecord::Base.clear_active_connections! unless testing

        response
      rescue Exception
        ActiveRecord::Base.clear_active_connections! unless testing
        raise
      end
    end
  end
end
