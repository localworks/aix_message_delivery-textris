require 'textris'
require 'uri'

class AixMessageTestDelivery < Textris::Delivery::Base
  MAX_MESSAGE_LENGTH = 660

  def deliver(to)
    contents = shorten_urls_in_message(message.content)
               .split('<!-- separator -->')

    contents.each do |c|
      raise "Message Too Long (#{c.size}, must be <= #{MAX_MESSAGE_LENGTH}): #{c.inspect}, in #{contents}" \
        if c.size > MAX_MESSAGE_LENGTH
    end

    ::Textris::Delivery::Test.new(message).deliver(to)
  end

  def shorten_urls_in_message(message)
    URI.extract(message)
       .map { |url| [url, 'https://ans.la/UxNyC2'] }.to_h
       .each do |long, short|
      message = message.sub(long, short)
    end

    message
  end
end
