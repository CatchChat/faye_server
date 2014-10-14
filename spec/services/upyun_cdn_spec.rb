require 'rails_helper'
require 'timecop'
require 'vcr_helper'
describe Cdn do
  before do

    Timecop.freeze(Time.local(2014,10,15,0,20))

  end

  after do
    Timecop.return
  end

  context 'upyun' do
    before do

      username = ENV["upyun_username"]
      password = ENV["upyun_password"]
      @init_hash = {username: username,
                    password: password}
      @upyun_client = UpyunCdn.new @init_hash
      @cdn = Cdn.new(@upyun_client, @init_hash)

    end

    subject {@cdn}

    it "provide upload token for upyun" do
      upyun_upload_token = subject.get_upload_token bucket: 'ruanwz-public',
                                                 file_path: '/abc.jpg',
                                               file_length: 100,
                                              callback_url: 'http://localhost/callback'
      expect(upyun_upload_token).to eq "UpYun david:0cc4922256f8c3981d9fecc64bee84cc"
    end

    it "provide download token for upyun" do
      upyun_download_token = subject.get_download_token  bucket: 'ruanwz-public',
                                                      file_path: '/abc.jpg'

      expect(upyun_download_token).to eq "UpYun david:4b8b2eec563863dac29033498374e7f7"
    end

    it "upload file for upyun" do

      t = Tempfile.new 'abc.jpg'

      upyun_upload_token = subject.get_upload_token bucket: 'ruanwz-public',
                                                 file_path: '/abc.jpg',
                                               file_length: 0,
                                              callback_url: 'http://localhost/callback'
      subject.get_upload_token
      VCR.use_cassette('upyun_upload_file') do
        code = subject.upload_file file_location: t.path,
        bucket: 'ruanwz-public',
        file_path: '/abc.jpg',
        file_length: 0,
        callback_url: 'http://localhost/callback'

        expect(code).to eq 200
      end

    end
  end

end
