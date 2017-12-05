require 'spec_helper'

describe Spokes::Middleware::ServiceName, modules: true, middleware: true do
  let(:app) { proc { [200, {}, []] } }
  let(:service_name) { 'nerds' }
  let(:stack) { Spokes::Middleware::ServiceName.new(app, service_name: service_name) }
  let(:stack_exclude_paths) do
    Spokes::Middleware::ServiceName.new(app,
                                        service_name: service_name,
                                        exclude_paths: ['/match/:id'])
  end
  let(:request) { Rack::MockRequest.new(stack) }
  let(:request_exclude_paths) { Rack::MockRequest.new(stack_exclude_paths) }
  let(:env_header_name) { 'HTTP_SERVICE_NAME' }

  it 'errors when the header is not present' do
    response = request.get('/')
    json     = MultiJson.load(response.body)

    expect(response.status).to eq(400)
    expect(response.content_type).to eq('application/json; charset=utf-8')
    expect(json).to have_key('errors')
    expect(json['errors'][0]).to eq('Service-Name is required')
  end

  it 'errors when the header is invalid' do
    response = request.options('/', env_header_name => 'not,valid')
    json     = MultiJson.load(response.body)

    expect(response.status).to eq(400)
    expect(response.content_type).to eq('application/json; charset=utf-8')
    expect(json).to have_key('errors')
    expect(json['errors'][0]).to eq('Service-Name is invalid')
  end

  it 'responds normally when the header is valid' do
    response = request.options('/', env_header_name => 'valid')
    expect(response.status).to eq(200)
  end

  it 'respond with valid if header is invalid but exclude path includes path' do
    response = request_exclude_paths.options('/match/abcd')
    expect(response.status).to eq(200)
  end

  it 'responds with error 400 if path not included in excludes paths' do
    response = request_exclude_paths.options('/match')
    expect(response.status).to eq(400)
  end

  it 'responds with error 400 if path not included in excludes paths' do
    response = request_exclude_paths.options('/match?param=1')
    expect(response.status).to eq(400)
  end

  it 'responds with error 400 if path not included in excludes paths' do
    response = request_exclude_paths.options('/match/')
    expect(response.status).to eq(400)
  end
end
