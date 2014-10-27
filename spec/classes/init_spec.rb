require 'spec_helper'
describe 'cobbler' do

  context 'with defaults for all parameters' do
    it { should contain_class('cobbler') }
  end
end
