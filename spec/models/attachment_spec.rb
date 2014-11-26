require 'services_helper'
require 'rails_helper'

RSpec.describe Attachment, :type => :model do
  let(:attachment) {FactoryGirl.create(:attachment)}

  it 'returns download url' do
    url = URI(attachment.download_url)
    expect(url.host).to eq "#{ENV['qiniu_attachment_bucket']}.qiniudn.com"
    expect(url.path).to eq "/#{attachment.file}"
    expect(url.query.split('&').map {|str|str.split('=').first}).to eq ['e', 'token']
  end

end
