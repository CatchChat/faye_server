module AuthToken
      def warden
        env['warden']
      end

      def authenticated?
        return true if warden.authenticated?
        if params[:access_token] && access_token = AccessToken.find_by_token(params[:access_token])
          @user = access_token.user
          true
        else
          false
        end
      end

      def current_user
        warden.user || @user
      end
end
