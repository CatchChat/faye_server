require_relative '../rails_helper'
require_relative '../services_helper'
require 'vcr_helper'

describe AttachmentTransfer do

  before do
    Timecop.freeze(Time.local(2014,12,1,14,17))
  end

  after do
    Timecop.return
  end

  let(:attachment) {create :attachment}
  let(:attachment2) {create :attachment, fallback_storage: 's3', fallback_file: 'abc'}

  it "transfer file from qiniu to s3" do
    VCR.use_cassette('transfer_qiniu_to_s3') do
      AttachmentTransfer.transfer_s3 attachment
    end
  end

  it "delete file from both qiniu and s3" do
    allow_any_instance_of(Cdn).to receive(:delete_file).and_return(true)
    AttachmentTransfer.delete attachment2
  end
end
