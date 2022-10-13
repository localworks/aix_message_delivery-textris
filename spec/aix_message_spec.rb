require "spec_helper"

RSpec.describe AixMessage do
  let(:aix_message) do
    described_class.new(
      token: "XXXXXXXXXXXXXXXXXX",
      client_id: "1234",
      sms_code: "12345"
    )
  end

  describe "#send!" do
    let(:phone) { "818011112222" }
    let(:message) { <<~SMS_TEXT }
      親譲りの無鉄砲で小供の時から損ばかりしている。小学校に居る時分学校の二階から飛び降りて一週間ほど腰を抜かした事がある。なぜそんな無闇をしたと聞く人があるかも知れぬ。別段深い理由でもない。新築の二階から首を出していたら、同級生の一人が冗談に、いくら威張っても、そこから飛び降りる事は出来まい。弱虫やーい。と囃したからである。
      小使に負ぶさって帰って来た時、おやじが大きな眼をして二階ぐらいから飛び降りて腰を抜かす奴があるかと云ったから、この次は抜かさずに飛んで見せますと答えた。（青空文庫より）

      親譲りの無鉄砲で小供の時から損ばかりしている。小学校に居る時分学校の二階から飛び降りて一週間ほど腰を抜かした事がある。なぜそんな無闇をしたと聞く人があるかも知れぬ。別段深い理由でもない。新築の二階から首を出していたら、同級生の一人が冗談に、いくら威張っても、そこから飛び降りる事は出来まい。弱虫やーい。と囃したからである。
      小使に負ぶさって帰って来た時、おやじが大きな眼をして二階ぐらいから飛び降りて腰を抜かす奴があるかと云ったから、この次は抜かさずに飛んで見せますと答えた。（青空文庫より）

      親譲りの無鉄砲で小供の時から損ばかりしている。小学校に居る時分学校の二階から飛び降りて一週間ほど腰を抜かした事がある。なぜそんな無闇をしたと聞く人があるかも知れぬ。別段深い理由でもない。新築の二階から首を出していたら、同級生の一人が冗談に、いくら威張っても、そこから飛び降りる事は出来まい。弱虫やーい。と囃したからである。
    SMS_TEXT

    it do
      VCR.use_cassette("sendsms_success") do
        res = aix_message.send!(phone, message)

        expect(res).to eq(
          "responseCode" => 0,
          "responseMessage" => "Success.",
          "phoneNumber" => "+#{phone}",
          "smsMessage" => message
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
