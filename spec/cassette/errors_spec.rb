# frozen_string_literal: true

describe Cassette::Errors do
  describe Cassette::Errors::Base do
    describe '#code' do
      it 'returns the HTTP status code accordlingly' do
        expect(Cassette::Errors::Forbidden.new.code).to be(403)
        expect(Cassette::Errors::NotFound.new.code).to be(404)
        expect(Cassette::Errors::InternalServerError.new.code).to be(500)
      end
    end
  end

  describe '.raise_by_code' do
    it 'raises the correct exception for the status code' do
      expect { described_class.raise_by_code(404) }.to raise_error(Cassette::Errors::NotFound)
      expect { described_class.raise_by_code(403) }.to raise_error(Cassette::Errors::Forbidden)
      expect { described_class.raise_by_code(412) }.to raise_error(Cassette::Errors::PreconditionFailed)
      expect { described_class.raise_by_code(500) }.to raise_error(Cassette::Errors::InternalServerError)
    end

    it 'raises internal server error for unmapped errors' do
      expect { described_class.raise_by_code(406) }.to raise_error(Cassette::Errors::InternalServerError)
      expect { described_class.raise_by_code(200) }.to raise_error(Cassette::Errors::InternalServerError)
    end
  end
end
