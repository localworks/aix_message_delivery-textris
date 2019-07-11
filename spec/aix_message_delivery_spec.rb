RSpec.describe AixMessageDelivery do
  before do
    class AixMessage
      class << self
        def messages
          @messages ||= []
        end
      end

      def send!(phone, message)
        self.class.messages << [phone, message]
      end

      def shorten_url!(_url)
        'https://ans.la/UxNyC2'
      end
    end
  end

  it 'has a version number' do
    expect(AixMessageDelivery::VERSION).not_to be nil
  end

  let(:delivery) { described_class.new(message) }

  describe 'send sms' do
    let(:message) do
      Textris::Message.new(
        to: '+48 600 700 800',
        content: 'Some text'
      )
    end

    it do
      expect_any_instance_of(AixMessage).to receive(:send!).once
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
      expect_any_instance_of(AixMessage).to receive(:send!).twice
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
      expect_any_instance_of(AixMessage).to receive(:send!).once do |ctx, phone, msg|
        expect(msg).to include('https://ans.la/UxNyC2')
      end
      delivery.deliver_to_all
    end
  end
end
