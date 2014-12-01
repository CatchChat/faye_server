require 'services_helper'
require 'rails_helper'

RSpec.describe Attachment, :type => :model do
  let(:attachment) {FactoryGirl.create(:attachment, fallback_storage: 's3', fallback_file: 'test-key')}

  it 'returns download url' do
    url = URI(attachment.download_url)
    expect(url.host).to eq "#{ENV['qiniu_attachment_bucket']}.qiniudn.com"
    expect(url.path).to eq "/#{attachment.file}"
    expect(url.query.split('&').map {|str|str.split('=').first}).to eq ['e', 'token']
  end

  it 'returns fallback url' do
    url = URI(attachment.fallback_url)
    expect(url.host).to eq "#{ENV["AWS_PUBLIC_BUCKET"]}.s3.#{ENV["AWS_REGION"]}.amazonaws.com.cn"
  end
end
