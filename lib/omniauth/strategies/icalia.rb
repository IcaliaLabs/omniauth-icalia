require 'omniauth-oauth2'
require 'icalia-sdk-event-core'

module OmniAuth
  module Strategies
    class Icalia < OmniAuth::Strategies::OAuth2
      INFO_PATH = '/oauth/token/info?include=resource-owner.email-accounts'

      option :client_options, {
        site: 'https://artanis.icalialabs.com',
        token_url: 'https://artanis.icalialabs.com/oauth/token',
        authorize_url: 'https://artanis.icalialabs.com/oauth/authorize'
      }

      def request_phase
        super
      end

      def authorize_params
        super.tap do |params|
          %w[scope client_options].each do |v|
            if request.params[v]
              params[v.to_sym] = request.params[v]
            end
          end
        end
      end

      uid { raw_info.resource_owner.id.to_s }

      info do
        personal_info = raw_info.resource_owner
        {
          'full_name' => personal_info.full_name,
          'given_name' => personal_info.given_name,
          'family_name' => personal_info.family_name,
          'gender_type' => personal_info.gender_type,
          'custom_gender' => personal_info.custom_gender,
          'date_of_birth' => personal_info.date_of_birth
        }
      end

      extra do
        { raw_info: raw_info, scope: scope }
      end

      def raw_info
        access_token.options[:mode] = :header
        @raw_info ||= fetch_user_info
      end

      def scope
        access_token['scope']
      end

      def callback_url
        full_host + script_name + callback_path
      end

      private

      def fetch_user_info
        response_body = access_token.get(INFO_PATH).body
        raw_data = ActiveSupport::JSON.decode(response_body)
        ::Icalia::Event::Deserializer.new(raw_data).perform
      end
    end
  end
end
