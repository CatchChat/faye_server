require 'rails_helper'
require 'timecop'
require 'vcr_helper'
require 'services_helper'
describe Cdn do
  before do
    Timecop.freeze(Time.local(2014,11,27,16,16))
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
      expect(qiniu_upload_token.length).to be > 30
    end

    it "provide download url for qiniu" do
      qiniu_download_url = subject.get_download_url url: "http://ruanwz-public.qiniudn.com/test-key"
      expect(qiniu_download_url).to include "token="
    end

    it "upload file for qiniu" do

      t = Tempfile.new 'abc'
      t.write 'abc'
      t.close
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

    it "download file from qiniu in stream mode" do
      VCR.use_cassette('qiniu_download_file') do

        qiniu_download_url = subject.get_download_url url: "http://ruanwz-public.qiniudn.com/test-key"

        uri = URI(qiniu_download_url)

        t = Tempfile.new 'download'
        Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
          request = Net::HTTP::Get.new uri

          http.request request do |response|
            open t.path, 'w' do |io|
              response.read_body do |chunk|
                io.write chunk
              end
            end
          end
        end
        expect(t.size).to eq 3
      end
    end

  end

end
