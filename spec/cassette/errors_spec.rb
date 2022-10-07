# frozen_string_literal: true

describe Cassette::Errors do
  describe Cassette::Errors::Base do
    describe '#code' do
      it 'returns the HTTP status 403 code accordlingly' do
        expect(Cassette::Errors::Forbidden.new.code).to be(403)
      end

      it 'returns the HTTP status code 404 accordlingly' do
        expect(Cassette::Errors::NotFound.new.code).to be(404)
      end

      it 'returns the HTTP status code 500 accordlingly' do
        expect(Cassette::Errors::InternalServerError.new.code).to be(500)
      end
    end
  end

  describe '.raise_by_code' do
    it 'raises the correct exception for the status code 404' do
      expect { described_class.raise_by_code(404) }.to raise_error(Cassette::Errors::NotFound)
    end

    it 'raises the correct exception for the status code 403' do
      expect { described_class.raise_by_code(403) }.to raise_error(Cassette::Errors::Forbidden)
    end

    it 'raises the correct exception for the status code 412' do
      expect { described_class.raise_by_code(412) }.to raise_error(Cassette::Errors::PreconditionFailed)
    end

    it 'raises the correct exception for the status code 500' do
      expect { described_class.raise_by_code(500) }.to raise_error(Cassette::Errors::InternalServerError)
    end

    it 'raises internal server error for unmapped errors 406' do
      expect { described_class.raise_by_code(406) }.to raise_error(Cassette::Errors::InternalServerError)
    end

    it 'raises internal server error for unmapped errors 200' do
      expect { described_class.raise_by_code(200) }.to raise_error(Cassette::Errors::InternalServerError)
    end
  end
end
