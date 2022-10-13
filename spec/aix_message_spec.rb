require "spec_helper"

RSpec.describe AixMessage do
  let(:aix_message) do
    described_class.new
  end

  describe "#send!" do
    let(:phone) { "810011112222" }
    let(:message) { "Hi! こんにちは 你好 नमस्त" }

    it do
      VCR.use_cassette("sendsms_success") do
        expect(aix_message.send!(phone, message)).to eq(
          "responseCode" => 0,
          "responseMessage" => "Success.",
          "phoneNumber" => "+810011112222",
          "smsMessage" => "Hi! こんにちは 你好 नमस्त"
        )
      end
    end
  end

  describe "#shorten_url!" do
    let(:url) { "https://some.long-url.com/hoge/huga/piyo/asdfasdfasdfasdfasdf" }

    it do
      VCR.use_cassette("shortenurl_success") do
        expect(aix_message.shorten_url!(url)).to eq("https://ai9.jp/ohcO9a")
      end
    end
  end
end
