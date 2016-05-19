module Socialable
  module Facebook

    Provider = Struct.new(:authentication) do
      # @note easy access to facebook api using the latest auth token
      def client
        @client ||= Koala::Facebook::API.new(auth_token)
      end

      def uid
        authentication.uid
      end

      def expired_for_today?
        return true if authentication.nil?
        authentication.expires_at < DateTime.now.utc
      end

      # In case of expiration it will retyrn true
      #
      # @return [Boolean]
      def expired?
        return true if authentication.nil?

        authentication.expires_at < 2.days.from_now
      end

      # Return auth token for accessing to the facebook api endpoints.
      # If the auth token is expired it will regenerate auth token with 60
      # days expiration time.
      #
      # @return [String]
      def auth_token
        authentication.auth_token
      end

      # Using Koala gem it will regenerate auth token using the old
      # auth token and assign to the stored user authentication method.
      def regenerate_auth_token
        new_token = oauth.exchange_access_token_info(authentication.auth_token)

        # Save the new token and its expiry over the old one
        authentication.update_attributes!(
          auth_token:       new_token['access_token'],
          last_expires_at:  authentication.expires_at,
          expires_at:       Time.now + new_token['expires_in'].to_i,
        )

        authentication.auth_token
      end

      def pages
        @pages ||= client.get_connections('me', 'accounts')
      end

      def get_page_access_token(page_id)
        client.get_page_access_token(page_id)
      end

      def post_over_page(page_id, message, picture, link, options = {})
        client.put_connections('306393736195548', 'feed', :message => 'Test message', :picture => "http://art.ngfiles.com/images/328000/328430_jazza_ryuk-death-note.jpg", link: 'http://art.ngfiles.com/images/328000/328430_jazza_ryuk-death-note.jpg' )
      end

      def oauth
        @oauth ||= Koala::Facebook::OAuth.new(Rails.configuration.facebook.id, Rails.configuration.facebook.secret)
      end
    end
  end
end