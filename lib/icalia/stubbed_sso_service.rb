require 'sinatra/base'

require 'capybara'
require 'capybara/server'

require 'socket'

module Icalia
  class StubbedSSOService < Sinatra::Base
    FIND_AVAILABLE_PORT = 0
    CODE = 'icalia_oauth_authorization_code'.freeze

    @@sign_in_user_on_authorize = false

    post '/oauth/token' do
      if params[:code] == CODE
        response.headers['Content-Type'] = 'application/json'
        flow = oauth_flows.last
        data = flow.slice('state').merge(
          access_token: 'ACCESS_TOKEN',
          token_type: 'Bearer',
          created_at: DateTime.now.to_i
        )
        flow[:granted_access_data] = data
        data.to_json
      else
        status 400
        {
          error: 'invalid_grant',
          error_description: "Authorization code does not exist: #{code}",
        }.to_json
      end
    end

    get '/sign-in' do
      'Signed out successfully.'
    end

    get '/sign-out' do
      uri = URI(params[:redirect_uri])
      redirect uri
    end

    get '/oauth/authorize' do
      return redirect '/sign-in' unless @@sign_in_user_on_authorize

      store_oauth_flow_data params
      uri = URI(params[:redirect_uri])
      uri.query = URI.encode_www_form(state: params[:state], code: CODE)
      redirect uri
    end

    get '/oauth/token/info' do
      flow = oauth_flows.last
      data = {
        data: {
          id: SecureRandom.uuid,
          type: 'oauth-access-token',
          attributes: {
            scopes: [],
            'expires-at': nil,
            'created-at': Time.at(flow.dig(:granted_access_data, :created_at))
          },
          relationships: {
            'resource-owner': {
              data: { type: 'person', id: example_resource_owner_id }
            }
          }
        },
        included: [
          {
            type: 'person',
            id: example_resource_owner_id,
            attributes: {
              'full-name': example_resource_owner_full_name,
              'given-name': example_resource_owner_given_name,
              'family-name': example_resource_owner_family_name,
              'gender-type': example_resource_owner_gender_type,
              'custom-gender': example_resource_owner_custom_gender
            }
          }
        ]
      }
      response.headers['Content-Type'] = 'application/vnd.api+json'
      data.to_json
    end

    %i[example_resource_owner_id example_resource_owner_given_name
      example_resource_owner_family_name example_resource_owner_gender_type
      example_resource_owner_custom_gender].each do |method_name|
        define_singleton_method method_name do
          class_variable_get("@@#{method_name}")
        end
        
        define_singleton_method "#{method_name}=".to_sym do |value|
          class_variable_set("@@#{method_name}", value)
        end
      end

    %i[oauth_flows store_oauth_flow_data example_resource_owner_id
      example_resource_owner_given_name example_resource_owner_family_name
      example_resource_owner_gender_type example_resource_owner_full_name
      example_resource_owner_custom_gender].each do |method_name|
        define_method method_name do |*args|
          self.class.public_send method_name, *args
        end
      end

    class << self
      def oauth_flows
        @oauth_flows ||= []
      end

      def reset
        oauth_flows.clear
    
        self.example_resource_owner_id = SecureRandom.uuid
        self.example_resource_owner_given_name = 'Example Person'
        self.example_resource_owner_family_name = 'From Artanis'
        self.example_resource_owner_gender_type = 'male'
        self.example_resource_owner_custom_gender = nil
      end
    
      def example_resource_owner_full_name
        [example_resource_owner_given_name, example_resource_owner_family_name]
          .compact.join(' ').strip
      end
    
      def store_oauth_flow_data(data)
        oauth_flows << data
      end

      def url
        "http://localhost:#{server_port}"
      end

      def sign_in_url
        "#{url}/sign-in"
      end
    
      # Taken from FakeStripe.stub_stripe at fake_stripe gem: 
      def prepare
        reset

        yield self if block_given?

        # Since the OAuth flow is performed by the browser, we'll need to boot
        # the Sinatra app instead of just stubbing the app with WebMock...
        boot_once

        OmniAuth::Strategies::Icalia.instances.each do |strategy|
          strategy.options.client_options.tap do |options|
            options.site = url
            options.token_url = "#{url}/oauth/token"
            options.authorize_url = "#{url}/oauth/authorize"
          end
        end
      end

      def sign_in_on_authorize
        @@sign_in_user_on_authorize = true
      end

      def do_not_sign_in_on_authorize
        @@sign_in_user_on_authorize = false
      end

      def teardown
        default_client_options = OmniAuth::Strategies::Icalia
          .default_options
          .client_options
  
        OmniAuth::Strategies::Icalia.instances.each do |strategy|
          strategy.options.client_options.tap do |options|
            options.site = default_client_options.site
            options.token_url = default_client_options.token_url
            options.authorize_url = default_client_options.authorize_url
          end
        end
      end

      # Taken from FakeStripe::Utils at fake_stripe gem: =======================
      def find_available_port
        server = TCPServer.new(FIND_AVAILABLE_PORT)
        server.addr[1]
      ensure
        server.close if server
      end

      # Taken from Bootable at fake_stripe gem: ================================
      def boot(port = find_available_port)
        instance = new
        Capybara::Server.new(instance, port: port).tap(&:boot)
      end
  
      def boot_once
        @boot_once ||= boot(server_port)
      end
  
      def server_port
        @server_port ||= find_available_port
      end
    end
  end
end
