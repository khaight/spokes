require 'spec_helper'

describe Spokes::Middleware::CORS, modules: true, middleware: true do
  let(:app) { proc { [200, {}, ['hi']] } }
  let(:stack) { Spokes::Middleware::CORS.new(app) }
  let(:request) { Rack::MockRequest.new(stack) }

  it 'does not do anything when the Origin header is not present' do
    response = request.get('/')
    expect(response.status).to eq(200)
    expect(response.body).to eq('hi')
    expect(response.headers['Access-Control-Allow-Origin']).to eq(nil)
  end

  it 'intercepts OPTION requests to render a stub (preflight request)' do
    response = request.options('/', 'Origin' => 'http://localhost', 'HTTP_ORIGIN' => 'http://localhost')
    expect(response.status).to eq(200)
    expect(response.body).to eq('')
    expect(response.headers['Access-Control-Allow-Methods']).to eq('GET, POST, PUT, PATCH, DELETE, OPTIONS')
    expect(response.headers['Access-Control-Allow-Origin']).to eq('http://localhost')
  end

  it 'delegates other calls, adding the CORS headers to the response' do
    response = request.get('/', 'Origin' => 'http://localhost', 'HTTP_ORIGIN' => 'http://localhost')
    expect(response.status).to eq(200)
    expect(response.body).to eq('hi')
    expect(response.headers['Access-Control-Allow-Origin']).to eq('http://localhost')
  end
end
