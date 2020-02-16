require 'spec_helper'

RSpec.describe OmniAuth::Strategies::Icalia do
  let(:access_token) { instance_double('AccessToken', :options => {}, :[] => 'user') }
  let(:parsed_response) { instance_double('ParsedResponse') }
  let(:response) { instance_double('Response', :parsed => parsed_response) }

  let(:example_overridden_site)          { 'https://example.com' }
  let(:example_overridden_token_url)     { 'https://example.com/oauth/token' }
  let(:example_overridden_authorize_url) { 'https://example.com/oauth/authorize' }
  
  let(:example_options) { {} }

  subject do
    OmniAuth::Strategies::Icalia.new 'ICALIA_CLIENT_KEY',
                                     'ICALIA_CLIENT_SECRET',
                                     example_options
  end

  before :each do
    allow(subject).to receive(:access_token).and_return(access_token)
  end

  describe 'client options' do
    context 'defaults' do
      it 'site is artanis' do
        expect(subject.options.client_options.site).to eq 'https://artanis.icalialabs.com'
      end

      it 'authorize url is artanis authorize url' do
        expect(subject.options.client_options.authorize_url).to eq 'https://artanis.icalialabs.com/oauth/authorize'
      end

      it 'token url is artanis token url' do
        expect(subject.options.client_options.token_url).to eq 'https://artanis.icalialabs.com/oauth/token'
      end
    end

    context 'overrides' do
      let :example_options do 
        {
          client_options: {
            site: example_overridden_site,
            token_url: example_overridden_token_url,
            authorize_url: example_overridden_authorize_url,
          }
        }
      end

      it 'allows overriding the site' do
        expect(subject.options.client_options.site)
          .to eq example_overridden_site
      end
      
      it 'allows overriding the authorize url' do
        expect(subject.options.client_options.authorize_url)
          .to eq example_overridden_authorize_url
      end

      it 'allows overriding the token url' do
        expect(subject.options.client_options.token_url)
          .to eq example_overridden_token_url
      end
    end
  end

  describe '#raw_info', skip: true do
    it 'should use relative paths' do
      expect(access_token).to receive(:get).with('/oauth/token/info?include=resource-owner.email-accounts').and_return(response)
      expect(subject.raw_info).to eq(parsed_response)
    end

    it 'should use the header auth mode' do
      expect(access_token).to receive(:get).with('user').and_return(response)
      subject.raw_info
      expect(access_token.options[:mode]).to eq(:header)
    end
  end

  describe '#info.email', skip: true do
    it 'should use any available email' do
      allow(subject).to receive(:raw_info).and_return({})
      allow(subject).to receive(:email).and_return('you@example.com')
      expect(subject.info['email']).to eq('you@example.com')
    end
  end

  context '#info.urls', skip: true do
    it 'should use html_url from raw_info' do
      allow(subject).to receive(:raw_info).and_return({ 'login' => 'me', 'html_url' => 'http://enterprise/me' })
      expect(subject.info['urls']['icalia']).to eq('http://enterprise/me')
    end
  end

  context '#extra.scope' do
    it 'returns the scope on the returned access_token' do
      expect(subject.scope).to eq('user')
    end
  end

  describe '#callback_url' do
    it 'is a combination of host, script name, and callback path' do
      allow(subject).to receive(:full_host).and_return('https://example.com')
      allow(subject).to receive(:script_name).and_return('/sub_uri')

      expect(subject.callback_url).to eq('https://example.com/sub_uri/auth/icalia/callback')
    end
  end
end