module Socialable
  module Twitter

    Provider = Struct.new(:authentication) do
      # @note easy access to facebook api using the latest auth token
      def client
        @client ||= begin
                      ::Twitter::REST::Client.new do |config|
                        config.consumer_key        = ENV['TWITTER_APP_ID']
                        config.consumer_secret     = ENV['TWITTER_APP_SECRET']
                        config.access_token        = authentication.auth_token
                        config.access_token_secret = authentication.secret
                      end
                    end
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
        return regenerate_auth_token if expired?

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

      def update_with_media(tweet, file, options = {})
        client.update_with_media(tweet, file, options)
      end

      def oauth
        # @oauth ||= Koala::Facebook::OAuth.new(Rails.configuration.facebook.id, Rails.configuration.facebook.secret)
      end
    end
  end
end