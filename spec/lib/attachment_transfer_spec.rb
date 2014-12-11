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

  it "transfer file from qiniu to s3" do
    VCR.use_cassette('transfer_qiniu_to_s3') do
      AttachmentTransfer.transfer_s3 attachment
    end
  end

  it "delete file from both qiniu and s3" do
    VCR.use_cassette('delete_from_qiniu_and_s3') do
      AttachmentTransfer.delete attachment
    end
  end
end
