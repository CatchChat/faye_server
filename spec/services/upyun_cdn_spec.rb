require 'rails_helper'
require 'timecop'
require 'vcr_helper'
require 'services_helper'
describe Cdn do
  before do
    Timecop.freeze(Time.local(2014,10,18,0,16))
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

    it "fail if validation not pass" do
      expect {
        subject.get_upload_token bucket: 'ruanwz-public'
      }.to raise_error
    end

    it "provide upload token for upyun" do
      upyun_upload_token = subject.get_upload_token bucket: 'ruanwz-public',
                                                 file_path: '/abc.jpg',
                                               file_length: 100,
                                                notify_url: 'http://catchchat-callback.herokuapp.com/hi'
      expect(upyun_upload_token).to eq "UpYun david:80a440dd5d89b0ab95ec6d2e50cb1969"
    end

    it "provide download token for upyun" do
      upyun_download_token = subject.get_download_token  bucket: 'ruanwz-public',
                                                      file_path: '/abc.jpg'

      expect(upyun_download_token).to eq "UpYun david:c842b673c53748ff268ed00a7a9d443b"
    end

    it "upload file for upyun" do

      t = Tempfile.new 'abc.jpg'

      VCR.use_cassette('upyun_upload_file') do
        code = subject.upload_file file_location: t.path,
                                          bucket: 'ruanwz-public',
                                       file_path: '/abc.jpg',
                                     file_length: File.read(t).length
        expect(code).to eq 200
      end
    end

    it "upload file for upyun using form with callback" do

      t = Tempfile.new ['abcd', '.jpg']
      #t = File.open '/tmp/test.jpeg'

      VCR.use_cassette('upyun_callback_upload_file') do
        code = subject.callback_upload_file file_location: t.path,
                                          bucket: 'ruanwz-public',
                                       file_path: '/abcd.jpg',
                                      notify_url: 'http://catchchat-callback.herokuapp.com/hi'
        expect(code).to eq 200
      end

    end
  end
end
