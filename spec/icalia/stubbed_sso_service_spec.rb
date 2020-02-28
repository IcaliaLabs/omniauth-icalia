# frozen_string_literal: true

require 'spec_helper'
require 'icalia/stubbed_sso_service'
require_relative '../shared_examples/of_a_bootable_server'

RSpec.describe Icalia::StubbedSSOService do
  it_behaves_like 'a bootable server'
end