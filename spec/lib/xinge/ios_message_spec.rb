require 'spec_helper'
require 'xinge'
require 'timecop'
describe Xinge::IOSMessage do
  let(:accept_time) { [Xinge::TimeInterval.new(0, 0, 12, 0), Xinge::TimeInterval.new(13, 0, 18, 0)] }
  let(:custom_content) { { catch: 'catch' } }
  subject {
    Xinge::IOSMessage.new(
      alert: 'alert', expire_time: 3 * 24 * 60 * 60, send_time: Time.now.to_i,
      custom_content: custom_content, accept_time: accept_time, badge: 5,
      sound: 'sound', loop_times: 10, loop_interval: 1
    )
  }

  before do
    Timecop.freeze
  end

  after do
    Timecop.return
  end

  it '#format_send_time' do
    expect(subject.format_send_time).to eq Time.now.strftime('%Y-%m-%d %H:%M:%S')
  end

  it '#format' do
    expect(subject.format).to eq "{\"catch\":\"catch\",\"accept_time\":[{\"start\":{\"hour\":\"00\",\"min\":\"00\"},\"end\":{\"hour\":\"12\",\"min\":\"00\"}},{\"start\":{\"hour\":\"13\",\"min\":\"00\"},\"end\":{\"hour\":\"18\",\"min\":\"00\"}}],\"aps\":{\"alert\":\"alert\",\"badge\":5,\"sound\":\"sound\",\"content-available\":0}}"
  end
end
