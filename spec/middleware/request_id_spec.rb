require 'spec_helper'

describe Spokes::Middleware::RequestID, modules: true, middleware: true do
  let(:app) { proc { [200, {}, []] } }
  let(:service_name) { 'nerds' }
  let(:stack) { Spokes::Middleware::RequestID.new(app, service_name: service_name) }
  let(:request) { Rack::MockRequest.new(stack) }
  let(:env_header_name) { 'action_dispatch.request_id' }

  it 'accepts incoming request ID' do
    response = request.options('/', env_header_name => 'aaaa')
    expect(response.status).to eq(200)
  end

  it 'generates request id when not present' do
    response = request.options('/')
    expect(response.status).to eq(200)
  end
end
