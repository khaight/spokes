require 'rails_helper'

describe Spokes::Versioning::MinorVersioning do
  let(:klass) do
    klass = Class.new
    expect(klass).to receive(:after_filter)
    klass.send(:include, Spokes::Versioning::MinorVersioning)
    klass
  end

  let(:controller) do
    controller = klass.new
    allow(controller).to receive(:all_minor_versions).and_return(minor_versions)
    controller
  end

  let(:header_name) { 'API-Version' }
  let(:default_version) { '2015-03-25' }
  let(:minor_versions) do
    {
      '2015-07-07'    => {},
      default_version => { default: true }
    }
  end
  let(:empty_info) { double('request/response info', headers: {}) }

  it 'uses default version if no version is specified in the header' do
    expect(controller).to receive(:request).and_return(empty_info)
    expect(controller.minor_version).to eq default_version
  end

  it 'uses the version specified in the header' do
    expected     = '2015-07-07'
    request_info = double('request', headers: { header_name => expected })
    expect(controller).to receive(:request).and_return(request_info)
    expect(controller.minor_version).to eq expected
  end

  it 'sets response header to current version' do
    allow(controller).to receive(:response).and_return(empty_info)
    expect(controller).to receive(:minor_version).and_return(default_version)
    controller.set_minor_version_response_header
    expect(controller.response.headers[header_name]).to eq(default_version)
  end
end
