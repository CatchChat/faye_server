require 'spec_helper'
require 'xinge'
require 'timecop'
describe Xinge::AndroidMessage do
  let(:accept_time) { [Xinge::TimeInterval.new(0, 0, 12, 0), Xinge::TimeInterval.new(13, 0, 18, 0)] }
  let(:custom_content) { { catch: 'catch' } }
  let(:style) {
    Xinge::Style.new(
      ring: 1, ring_raw: 'ring', vibrate: 1, lights: 1, clearable: 1, icon_type: 0,
      icon_res: 'catch', style_id: 1, small_icon: 'catch', n_id: 0, builder_id: 0
    )
  }
  let(:action) {
    Xinge::ClickAction.new(action_type: 1, activity: 'catch', aty_attr: { if: 0, pf: 0 })
  }
  subject {
    Xinge::AndroidMessage.new(
      title: 'title', content: 'content', type: Xinge::AndroidMessage::MESSAGE_TYPE_NOTIFICATION,
      expire_time: 3 * 24 * 60 * 60, send_time: Time.now.to_i, custom_content: custom_content,
      accept_time: accept_time, style: style, action: action, multi_pkg: 1, loop_times: 10, loop_interval: 1
    )
  }

  before do
    Timecop.freeze
  end

  after do
    Timecop.return
  end

  it '#format_send_time' do
    expect(subject.format_send_time).to eq Time.find_zone('Beijing').now.strftime('%Y-%m-%d %H:%M:%S')
  end

  describe '#format' do
    it 'NOTIFICATION type' do
      subject.type = Xinge::AndroidMessage::MESSAGE_TYPE_NOTIFICATION
      format_str = "{\"content\":\"content\",\"title\":\"title\",\"accept_time\":[{\"start\":{\"hour\":\"00\",\"min\":\"00\"},\"end\":{\"hour\":\"12\",\"min\":\"00\"}},{\"start\":{\"hour\":\"13\",\"min\":\"00\"},\"end\":{\"hour\":\"18\",\"min\":\"00\"}}],\"custom_content\":{\"catch\":\"catch\"},\"action\":{\"action_type\":1,\"activity\":\"catch\",\"aty_attr\":{\"if\":0,\"pf\":0}},\"ring\":1,\"ring_raw\":\"ring\",\"vibrate\":1,\"lights\":1,\"clearable\":1,\"icon_type\":0,\"icon_res\":\"catch\",\"style_id\":1,\"small_icon\":\"catch\",\"n_id\":0,\"builder_id\":0}"
      expect(subject.format).to eq format_str
    end

    it 'MESSAGE type' do
      subject.type = Xinge::AndroidMessage::MESSAGE_TYPE_MESSAGE
      format_str = "{\"content\":\"content\",\"title\":\"title\",\"accept_time\":[{\"start\":{\"hour\":\"00\",\"min\":\"00\"},\"end\":{\"hour\":\"12\",\"min\":\"00\"}},{\"start\":{\"hour\":\"13\",\"min\":\"00\"},\"end\":{\"hour\":\"18\",\"min\":\"00\"}}],\"custom_content\":{\"catch\":\"catch\"}}"
      expect(subject.format).to eq format_str
    end
  end
end
