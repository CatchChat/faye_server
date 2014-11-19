require 'rails_helper'
require 'timecop'
require 'vcr_helper'
require 'services_helper'
describe Cdn do

  before do
    aws_access_key_id     = ENV["AWS_ACCESS_KEY_ID"]
    aws_secret_access_key = ENV["AWS_SECRET_ACCESS_KEY"]

    @client_init_hash    = {aws_access_key_id: aws_access_key_id,
                        aws_secret_access_key: aws_secret_access_key,
                               sqs_queue_name: 's3-ruanwz-test-post',
                                       bucket: 'ruanwz-test'}


    @s3_client = S3Cdn.new @client_init_hash
    @cdn          = Cdn.new(@s3_client)
  end

  context 's3' do
    before do
      skip "Only test in CN-region" if  ENV['AWS_REGION'] != 'cn-north-1'
      Timecop.freeze(Time.local(2014,11,14,16,25))
    end

    after do
      Timecop.return
    end

    subject {@cdn}

    it "fail if validation not pass" do
      expect {
        subject.get_download_url nokey: 'nofile'
      }.to raise_error
    end

    it "provide upload form url and fields for s3" do
      url, policy, encoded_policy, signature = subject.get_upload_form_url_fields key: 'webcam.jpeg'

      expect(url).to eq "https://ruanwz-test.s3.cn-north-1.amazonaws.com.cn/"
      expect(policy["conditions"].length).to eq 6
      expect(signature).to eq '04aa9aa8b7cb52ef09c7ca695b692f7e7c8cd005dfac4e336c7d595018052363'

    end

    it "provide download url for s3" do
      s3_download_url = subject.get_download_url key: 'webcam.jpg'
      expect(s3_download_url).to eq 'https://ruanwz-test.s3.cn-north-1.amazonaws.com.cn/webcam.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAOGBVMZAU5EZPGPIQ%2F20141114%2Fcn-north-1%2Fs3%2Faws4_request&X-Amz-Date=20141114T082500Z&X-Amz-Expires=3600&X-Amz-Signature=fb03cb107d2d6a0b02a72a4fd86b783dd610ec18623a43dcccdf664e932ec953&X-Amz-SignedHeaders=Host'
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

  context 'global s3' do
    before do
      Timecop.freeze(Time.local(2014,11,17,15,45))
    end

    subject {@cdn}
    it "upload file and queue a message to sqs" do
      skip "not ready in CN-region" if  ENV['AWS_REGION'] == 'cn-north-1'

      t = Tempfile.new ['test-key', '.jpeg']
      t.write 'abc'
      t.close
      VCR.use_cassette('s3_global_upload_file') do
       code = subject.upload_file file_location: t.path, key: 'test-key.jpg'
       expect(code).to eq 204

      end

      VCR.use_cassette('s3_global_upload_file_notification') do
        complete_notification = subject.sqs_receive
        expect(complete_notification).to include("test-key.jpg")
      end
    end

    after do
      Timecop.return
    end
  end

end
