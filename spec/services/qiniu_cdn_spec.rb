require 'rails_helper'
require 'timecop'
require 'vcr_helper'
require 'services_helper'
describe Cdn do
  before do
    Timecop.freeze(Time.local(2014,11,25,15,54))
  end

  after do
    Timecop.return
  end

  context 'qiniu' do
    before do
      access_key    = ENV["qiniu_access_key"]
      secret_key    = ENV["qiniu_secret_key"]

      @client_init_hash    = {client_init: 'test', access_key: access_key, secret_key: secret_key}
      @cdn_init_hash    = {cdn_init: 'test', access_key: access_key, secret_key: secret_key}
      @qiniu_client = QiniuCdn.new @client_init_hash
      @cdn          = Cdn.new(@qiniu_client, @cdn_init_hash)
    end

    subject {@cdn}

    it "fail if validation not pass" do
      expect {
        subject.get_upload_token bucket: 'ruanwz-public'
      }.to raise_error
    end

    it "provide upload token for qiniu" do
      qiniu_upload_token = subject.get_upload_token bucket: 'ruanwz-public',
                                                       test: 'abc',
                                                       key: 'test-key',
                                              callback_url: 'http://ruanwz.ngrok.com/hi',
                                              callback_body: "key=$(key)&bucket=$(bucket)&message_id=$(x:message_id)",
                                                     x_vars: {:'x:message_id' => '1234321'}
      expect(qiniu_upload_token).to eq "BBHE3ccYQ8VQhEIvZbJARrte1U3ic2Om6CW7mxvN:fru8z8N_5tHIxm-mpIENURtvsuM=:eyJzY29wZSI6InJ1YW53ei1wdWJsaWM6dGVzdC1rZXkiLCJjYWxsYmFja1VybCI6Imh0dHA6Ly9ydWFud3oubmdyb2suY29tL2hpIiwiY2FsbGJhY2tCb2R5Ijoia2V5PSQoa2V5KVx1MDAyNmJ1Y2tldD0kKGJ1Y2tldClcdTAwMjZtZXNzYWdlX2lkPSQoeDptZXNzYWdlX2lkKSIsImRlYWRsaW5lIjoxNDE2OTA1NjQwfQ=="
    end

    it "provide download url for qiniu" do
      qiniu_download_url = subject.get_download_url url: "http://hello.qiniu.com/a/b/c.jpg"
      expect(qiniu_download_url).to eq "http://hello.qiniu.com/a/b/c.jpg?e=1416905640&token=BBHE3ccYQ8VQhEIvZbJARrte1U3ic2Om6CW7mxvN:6-eJeo77BGbyt8pc3voFtbWrF-M="
    end

    it "upload file for qiniu" do

      t = Tempfile.new 'abc'
      VCR.use_cassette('qiniu_upload_file') do
        code = subject.upload_file file_location: t.path,
                                          bucket: 'ruanwz-public',
                                             key: 'test-key',
                                    callback_url: 'http://ruanwz.ngrok.com/api/v4/attachments/callback/qiniu',
                                    callback_body: "key=$(key)&bucket=$(bucket)&message_id=$(x:message_id)",
                                           x_vars: {:'x:message_id' => '1'}

        expect(code).to eq 200
      end

    end
  end

end
