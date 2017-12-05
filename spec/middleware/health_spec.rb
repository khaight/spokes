require 'spec_helper'

describe Spokes::Middleware::Health, modules: true, middleware: true do
  def env(url = '/', *args)
    Rack::MockRequest.env_for(url, *args)
  end

  let(:base_app) do
    lambda do |_env|
      [200, { 'Content-Type' => 'text/plain' }, ['Oi!']]
    end
  end

  let(:app) { Rack::Lint.new Spokes::Middleware::Health.new(base_app, health_options) }
  let(:health_options) { {} }
  let(:status) { subject[0] }
  let(:body) do
    str = ''
    subject[2].each do |s|
      str += s
    end
    str
  end

  describe 'with default options' do
    let(:health_options) { {} }

    describe '/' do
      subject { app.call env('/') }
      it { expect(status).to eq(200) }
      it { expect(body).to eq('Oi!') }
    end

    describe '/status' do
      subject { app.call env('/status') }
      it { expect(status).to eq(200) }
      it { expect(body).to eq('OK') }
    end
  end

  describe 'as json' do
    let(:health_options) { {} }

    describe '/' do
      subject { app.call env('/', 'Content-Type' => 'application/json') }
      it { expect(status).to eq(200) }
      it { expect(body).to eq('Oi!') }
    end

    describe '/status' do
      subject { app.call env('/status', 'CONTENT_TYPE' => 'application/json') }
      it { expect(status).to eq(200) }
      it { expect(JSON.parse(body)['status']).to eq('OK') }
    end
  end

  describe 'with :fail_if' do
    subject { app.call env('/status') }

    describe '== lambda { true }' do
      let(:health_options) { { fail_if: -> { true } } }

      it { expect(status).to eq(503) }
      it { expect(body).to eq('FAIL') }
    end

    describe '== lambda { false }' do
      let(:health_options) { { fail_if: -> { false } } }
      it { expect(status).to eq(200) }
      it { expect(body).to eq('OK') }
    end
  end

  describe 'with :status_code' do
    let(:status_proc) { ->(healthy) { healthy ? 202 : 404 } }
    subject { app.call env('/status') }

    context 'healthy' do
      let(:health_options) { { fail_if: -> { false }, status_code: status_proc } }
      it { expect(status).to eq(202) }
      it { expect(body).to eq('OK') }
    end

    context 'fail' do
      let(:health_options) { { fail_if: -> { true }, status_code: status_proc } }
      it { expect(status).to eq(404) }
      it { expect(body).to eq('FAIL') }
    end
  end

  describe 'with :simple' do
    let(:body_proc) { ->(healthy) { healthy ? 'GOOD' : 'BAD' } }
    subject { app.call env('/status') }

    context 'healthy' do
      let(:health_options) { { fail_if: -> { false }, simple: body_proc } }
      it { expect(status).to eq(200) }
      it { expect(body).to eq('GOOD') }
    end

    context 'fail' do
      let(:health_options) { { fail_if: -> { true }, simple: body_proc } }
      it { expect(status).to eq(503) }
      it { expect(body).to eq('BAD') }
    end
  end
end
