require 'textris'
require 'uri'

class AixMessageTestDelivery < Textris::Delivery::Base
  def deliver(to)
    content = shorten_urls_in_message(message.content)

    raise "Message Too Long (#{content.size}, must be <= 70): #{content}" \
      if content.size > 70

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
