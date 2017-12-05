require 'spec_helper'

describe Spokes::Config::Env do
  after do
    %w[HOMER_SIMPSON TEST_STRING_VAR TEST_INT_VAR TEST_FLOAT_VAR TEST_ARRAY_VAR TEST_SYMBOL_VAR TEST_BOOL_VAR].each do |w|
      ENV.delete(w)
    end
  end

  describe '#manditory' do
    let(:env_loader) do
      lambda do
        Spokes::Config::Env.load do
          mandatory :homer_simpson, string
        end
      end
    end

    it 'raises error if variable is not set' do
      expect(env_loader).to raise_error(KeyError)
    end

    it 'exposes variable once loaded' do
      ENV['HOMER_SIMPSON'] = 'doh'
      expect(env_loader.call.homer_simpson).to eq('doh')
    end
  end

  describe '#optional' do
    let(:env_loader) do
      lambda do
        Spokes::Config::Env.load do
          optional :homer_simpson, string
        end
      end
    end

    it 'exposes variable once loaded' do
      ENV['HOMER_SIMPSON'] = 'doh'
      expect(env_loader.call.homer_simpson).to eq('doh')
    end

    it 'value is nil when variable is not set' do
      expect(env_loader.call.homer_simpson).to eq(nil)
    end
  end

  describe '#default' do
    let(:env_loader) do
      lambda do
        Spokes::Config::Env.load do
          default :homer_simpson, 'derp', string
        end
      end
    end

    it 'exposes variable once loaded' do
      ENV['HOMER_SIMPSON'] = 'doh'
      expect(env_loader.call.homer_simpson).to eq('doh')
    end

    it 'uses default value when varible is not set' do
      expect(env_loader.call.homer_simpson).to eq('derp')
    end
  end

  describe 'type casting' do
    let(:env_loader) do
      lambda do
        Spokes::Config::Env.load do
          optional :test_bool_var, bool
          optional :test_float_var, float
          optional :test_string_var, string
          optional :test_symbol_var, symbol
          optional :test_array_var, array
          optional :test_int_var, int
        end
      end
    end

    it 'does nothing to strings' do
      ENV['TEST_STRING_VAR'] = 'stringy'
      expect(env_loader.call.test_string_var).to eq('stringy')
    end

    it 'casts to integer' do
      ENV['TEST_INT_VAR'] = '123'
      expect(env_loader.call.test_int_var).to eq(123)
    end

    it 'casts to float' do
      ENV['TEST_FLOAT_VAR'] = '1.23'
      expect(env_loader.call.test_float_var).to eq(1.23)
    end

    it 'casts to array' do
      ENV['TEST_ARRAY_VAR'] = 'hello,world'
      expect(env_loader.call.test_array_var).to eq(%w[hello world])
    end

    it 'casts to symbol' do
      ENV['TEST_SYMBOL_VAR'] = 'howdy'
      expect(env_loader.call.test_symbol_var).to eq(:howdy)
    end

    it 'casts to boolean' do
      ENV['TEST_BOOL_VAR'] = 'true'
      expect(env_loader.call.test_bool_var).to eq(true)
    end
  end
end
