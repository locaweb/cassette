# encoding: UTF-8



describe Cassette::Errors do
  describe Cassette::Errors::Base do
    describe '#code' do
      it 'returns the HTTP status code accordlingly' do
        expect(Cassette::Errors::Forbidden.new.code).to eql(403)
        expect(Cassette::Errors::NotFound.new.code).to eql(404)
        expect(Cassette::Errors::InternalServerError.new.code).to eql(500)
      end
    end
  end

  describe '.raise_by_code' do
    it 'raises the correct exception for the status code' do
      expect { Cassette::Errors.raise_by_code(404) }.to raise_error(Cassette::Errors::NotFound)
      expect { Cassette::Errors.raise_by_code(403) }.to raise_error(Cassette::Errors::Forbidden)
      expect { Cassette::Errors.raise_by_code(412) }.to raise_error(Cassette::Errors::PreconditionFailed)
      expect { Cassette::Errors.raise_by_code(500) }.to raise_error(Cassette::Errors::InternalServerError)
    end

    it 'raises internal server error for unmapped errors' do
      expect { Cassette::Errors.raise_by_code(406) }.to raise_error(Cassette::Errors::InternalServerError)
      expect { Cassette::Errors.raise_by_code(200) }.to raise_error(Cassette::Errors::InternalServerError)
    end
  end
end
