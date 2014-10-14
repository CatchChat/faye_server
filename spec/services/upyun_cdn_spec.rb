require 'rails_helper'
require 'timecop'
require 'vcr_helper'
require 'services_helper'
describe Cdn do
  before do
    Timecop.freeze(Time.local(2014,10,15,0,20))
  end

  after do
    Timecop.return
  end

  context 'upyun' do
    before do

      username      = ENV["upyun_username"]
      password      = ENV["upyun_password"]
      @init_hash    = {username: username, password: password}
      @upyun_client = UpyunCdn.new @init_hash
      @cdn          = Cdn.new(@upyun_client, @init_hash)

    end

    subject {@cdn}

    it "provide upload token for upyun" do
      upyun_upload_token = subject.get_upload_token bucket: 'ruanwz-public',
                                                 file_path: '/abc.jpg',
                                               file_length: 100,
                                              callback_url: 'http://localhost/callback'

      expect(upyun_upload_token).to eq "UpYun david:388f0cc6e47895ab40180a9fd06148f9"
    end

    it "provide download token for upyun" do
      upyun_download_token = subject.get_download_token  bucket: 'ruanwz-public',
                                                      file_path: '/abc.jpg'

      expect(upyun_download_token).to eq "UpYun david:7a083e9b66567471346f70f5d05a00d7"
    end

    it "upload file for upyun" do

      t = Tempfile.new 'abc.jpg'

      VCR.use_cassette('upyun_upload_file') do
        code = subject.upload_file file_location: t.path,
                                          bucket: 'ruanwz-public',
                                       file_path: '/abc.jpg',
                                     file_length: File.read(t).length,
                                    callback_url: 'http://localhost/callback'
        expect(code).to eq 200
      end
    end
  end

end
