require 'services_helper'
require 'rails_helper'

RSpec.describe Attachment, :type => :model do
  let(:attachment) {FactoryGirl.create(:attachment, fallback_storage: 's3', fallback_file: 'test-key')}

  it 'returns download url' do
    expires_in, url = attachment.download_url 100
    expect(expires_in).to eq 100

    expires_in, url = attachment.download_url
    url = URI(url)
    expect(expires_in).to eq 3600*24
    expect(url.host).to eq "#{ENV['qiniu_attachment_bucket']}.qiniudn.com"
    expect(url.path).to eq "/#{attachment.file}"
    expect(url.query.split('&').map {|str|str.split('=').first}).to eq ['e', 'token']
  end

  it 'returns fallback url' do
    expires_in, url = attachment.fallback_url 100
    expect(expires_in).to eq 100
    expires_in, url = attachment.fallback_url
    url = URI(url)
    expect(url.host).to eq "#{ENV["AWS_PUBLIC_BUCKET"]}.s3.#{ENV["AWS_REGION"]}.amazonaws.com.cn"
  end

  it 'self.create_by_parsing_qiniu_private_url' do
    existing_url = "http://#{ENV['qiniu_attachment_bucket']}.qiniudn.com/S1SYur5I1a4qIYIsAY9Djm0i7X8tpbyP.jpg?e=1420088368&token=YSMhpYfzim6GOG-_sqsm3C0CpWI7RAPeq5IxjHeD:dydZ9sQGFkgm8zjyWSMgQMSrmwg="

    attachment = Attachment.create_by_parsing_qiniu_private_url existing_url
    expect(attachment).to be_an_instance_of Attachment
    expect(attachment.storage).to eq 'qiniu'
    expect(attachment.file).to eq 'S1SYur5I1a4qIYIsAY9Djm0i7X8tpbyP.jpg'
  end

  it 'queue to delete storage after destroy' do

  end
end
