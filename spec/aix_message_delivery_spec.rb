RSpec.describe AixMessageDelivery do
  let(:delivery) { described_class.new(message) }
  let(:aix_message) { instance_double(AixMessage) }

  before do
    allow(AixMessage)
      .to receive(:new).and_return(aix_message)
    allow(aix_message)
      .to receive(:send!)
    allow(aix_message)
      .to receive(:shorten_url).with('http://example.com/long/path').and_return('https://ans.la/UxNyC2')
  end

  it 'has a version number' do
    expect(AixMessageDelivery::VERSION).not_to be nil
  end

  describe 'send sms' do
    let(:message) do
      Textris::Message.new(
        to: '+48 600 700 800',
        content: 'Some text'
      )
    end

    it do
      expect(aix_message).to receive(:send!).once
      delivery.deliver_to_all
    end
  end

  describe 'send separated message' do
    let(:message) do
      Textris::Message.new(
        to: '+48 600 700 800',
        content: 'Some text<!-- separator -->hoge huga'
      )
    end

    it do
      expect(aix_message).to receive(:send!).twice
      delivery.deliver_to_all
    end
  end

  describe 'shorten url' do
    let(:message) do
      Textris::Message.new(
        to: '+48 600 700 800',
        content: 'Some text http://example.com/long/path'
      )
    end

    it do
      expect(aix_message).to receive(:send!).once do |_phone, msg|
        expect(msg).to include('https://ans.la/UxNyC2')
      end
      delivery.deliver_to_all
    end
  end
end
