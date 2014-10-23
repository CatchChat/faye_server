require 'rails_helper'
require 'timecop'
require 'vcr_helper'
require 'services_helper'
describe Cdn do
  before do
    Timecop.freeze(Time.local(2014,10,23,15,10))
  end

  after do
    Timecop.return
  end

  context 's3' do
    before do
      aws_access_key_id     = ENV["AWS_ACCESS_KEY_ID"]
      aws_secret_access_key = ENV["AWS_SECRET_ACCESS_KEY"]

          @client_init_hash    = {aws_access_key_id: aws_access_key_id,
                              aws_secret_access_key: aws_secret_access_key,
                                             bucket: 'rails-test'}

          @cdn_init_hash    = {aws_access_key_id: aws_access_key_id,
                           aws_secret_access_key: aws_secret_access_key}

      @s3_client = S3Cdn.new @client_init_hash
      @cdn          = Cdn.new(@s3_client, @cdn_init_hash)
    end

    subject {@cdn}

    it "fail if validation not pass" do
      expect {
        subject.get_download_url nokey: 'nofile'
      }.to raise_error
    end

    it "provide upload form url and fields for s3" do
      url, policy, encoded_policy, signature = subject.get_upload_form_url_fields key: 'webcam.jpeg'

      expect(url).to eq "https://rails-test.s3.cn-north-1.amazonaws.com.cn/"
      expect(policy["conditions"].length).to eq 6
      expect(signature).to eq '79abcc7d829358a5ee701728ae5160f79a3e015e87d7e2f518b16c98121031a6'

    end

    it "provide download url for s3" do
      s3_download_url = subject.get_download_url key: 'webcam.jpg'
      expect(s3_download_url).to eq 'https://rails-test.s3.cn-north-1.amazonaws.com.cn/webcam.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAOGBVMZAU5EZPGPIQ%2F20141023%2Fcn-north-1%2Fs3%2Faws4_request&X-Amz-Date=20141023T071000Z&X-Amz-Expires=3600&X-Amz-Signature=ba2a9f1ae5691cff75932348fafa75fdaccb057c4f07cd298d19511ce62b072f&X-Amz-SignedHeaders=Host'
    end

    it "upload file for s3" do

      t = Tempfile.new ['test-key', '.jpeg']
      VCR.use_cassette('s3_upload_file') do
        code = subject.upload_file file_location: t.path,
                                             key: 'test-key.jpg'

        expect(code).to eq 204
      end

    end

    it "upload file for s3 with successful redirect url" do
      t = Tempfile.new ['test-key', '.jpeg']
      VCR.use_cassette('s3_upload_file_with_redirect') do
        code = subject.upload_file file_location: t.path,
                                             key: 'test-key.jpg',
                                             success_action_redirect: 'http://catchchat-callback.herokuapp.com/hi'

        expect(code).to eq 303

        #verify redirect to new url
      end

    end
  end

end
