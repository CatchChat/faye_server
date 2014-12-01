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
    allow(TransferAttachmentsJob).to receive(:enqueue)
    VCR.use_cassette('transfer_qiniu_to_s3') do
      AttachmentTransfer.transfer_s3 attachment
    end
  end
end
