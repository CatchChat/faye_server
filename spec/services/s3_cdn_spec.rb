require 'rails_helper'
require 'timecop'
require 'vcr_helper'
require 'services_helper'
describe Cdn do
  before do
    Timecop.freeze(Time.local(2014))
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

    # these fields are useless because it is only for global aws
    #it "provide upload form url and fields for s3" do
    #  s3_upload_url, fields = subject.get_upload_form_url_fields key: 'webcam.jpeg'

    #  expect(s3_upload_url).to eq "https://rails-test.s3.cn-north-1.amazonaws.com.cn/"
    #  expect(fields).to eq({
    #    "AWSAccessKeyId" => "AKIAOGBVMZAU5EZPGPIQ",
    #    "key"=>"webcam.jpeg",
    #    "policy"=>"eyJleHBpcmF0aW9uIjoiMjAxMy0xMi0zMVQxNzowMDowMFoiLCJjb25kaXRpb25zIjpbeyJidWNrZXQiOiJyYWlscy10ZXN0In0seyJrZXkiOiJ3ZWJjYW0uanBlZyJ9XX0=",
    #    "signature"=>"Ben/QozHyneedo7aEjhpO+yoaQA="
    #  })

    #end

    it "provide download url for s3" do
      s3_download_url = subject.get_download_url key: 'webcam.jpg'
      expect(s3_download_url).to eq "https://rails-test.s3.cn-north-1.amazonaws.com.cn/webcam.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAOGBVMZAU5EZPGPIQ%2F20131231%2Fcn-north-1%2Fs3%2Faws4_request&X-Amz-Date=20131231T160000Z&X-Amz-Expires=3600&X-Amz-Signature=1fc412adffacb5c52b243f4bf5eeec1c33276d5045db9faa32f9fa9395803b8f&X-Amz-SignedHeaders=Host"
    end

    #it "upload file for s3" do
    #  Timecop.return

    #  t = Tempfile.new ['test-key', '.jpeg']
    #  #VCR.use_cassette('s3_upload_file') do
    #    code = subject.upload_file file_location: t.path,
    #                                         key: 'test-key.jpg'

    #    binding.pry
    #    expect(code).to eq 200
    #  #end

    #end
  end

end
