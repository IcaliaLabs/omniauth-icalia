# Omniauth::Icalia

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/omniauth/icalia`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'omniauth-icalia'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install omniauth-icalia

## Usage

TODO: Write usage instructions here

## System Testing on your app

You can use the included service stub in your system tests.

On your spec_helper, or test setup file:

```ruby
require 'omniauth-icalia/service_stubs'
```

Then, in your test setup, call `prepare`:

```ruby
# For example, in RSpec:
before { Icalia::StubbedSSOService.prepare }

# Use a block if you need to set the data returned by the service:
before do 
  Icalia::StubbedSSOService.prepare do |config|
    # Optionally add example data about the expected token owner:
    config.example_resource_owner_id = SecureRandom.uuid
    config.example_resource_owner_given_name = 'George'
    config.example_resource_owner_family_name = 'Harrison'
  end
end
```

If your'e testing a sign-in flow:

```ruby
scenario 'sign-in' do
  # Simulate that the user will sign-in at the SSO site:
  Icalia::StubbedSSOService.sign_in_on_authorize
  visit root_path # or any path in your app that requires authentication

  #...
end
```

If your'e testing a sign-out flow:

```ruby
scenario 'sign-out' do
  # Simulate that the user will sign-in at the SSO site:
  Icalia::StubbedSSOService.sign_in_on_authorize
  visit root_path # or any path in your app that requires authentication

  # Simulate that the user won't sign-in at the SSO site:
  Icalia::StubbedSSOService.do_not_sign_in_on_authorize
  click_link 'Logout'

  # The message coming from Artanis & the Fake Artanis "StubbedSSOService":
  expect(page).to have_content 'Signed out successfully.'
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/omniauth-icalia. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Omniauth::Icalia project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/omniauth-icalia/blob/master/CODE_OF_CONDUCT.md).
