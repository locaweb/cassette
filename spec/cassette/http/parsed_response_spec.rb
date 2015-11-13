describe Cassette::Http::ParsedResponse do
  subject(:parsed_response) { described_class.new(xml_response) }

  let(:xml_response) { fixture('cas/success.xml') }

  let(:hash_response) do
    {
      "serviceResponse" => {
        "authenticationSuccess" => {
          "user"=> {
            "__content__" => "test-user"
          },
          "attributes" => {
            "authorities" => {
              "__content__" => "[CUPOM, AUDITING,]"
            },
            "cn" => {
              "__content__" => "Test System"
            }
          }
        }
      }
    }
  end

  it { is_expected.to eq(hash_response) }
end
