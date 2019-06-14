require 'textris'

class TestWithLengthValidation < Textris::Delivery::Test
  def deliver(to)
    raise 'Message Too Long (Must be <= 70)' if message.content.size > 70

    super
  end
end
