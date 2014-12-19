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
      expect(signature).to eq '1871200944f4d3327420012cfc2622a9025c84bd723f87cf00bf264c52bcbe54'

    end

    it "provide download url for s3" do
      s3_download_url = subject.get_download_url key: 'webcam.jpg'
      expect(s3_download_url).to eq 'https://ruanwz-test.s3.cn-north-1.amazonaws.com.cn/webcam.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAOGBVMZAU5EZPGPIQ%2F20141114%2Fcn-north-1%2Fs3%2Faws4_request&X-Amz-Date=20141114T082500Z&X-Amz-Expires=86400&X-Amz-Signature=6de2f0171f6c2eec726ec8df7f7e28370f3e11d892b9930c0c5f858905c6726b&X-Amz-SignedHeaders=Host'
    end

    it "upload file for s3" do

      t = Tempfile.new ['test-key', '.jpeg']
      VCR.use_cassette('s3_upload_file') do
        code = subject.upload_file file_location: t.path,
                                             key: 'test-key.jpg',
                                             message_id: '12345'

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

    it "delete file" do

      Timecop.freeze(Time.local(2014,12,12,10,17))
      t = Tempfile.new ['test-delete-key', '.jpeg']
      VCR.use_cassette('s3_delete_file') do
        code = subject.upload_file file_location: t.path,
                                             key: 'test-delete-key.jpg',
                                             message_id: '12345'

        expect(code).to eq 204

        resp = subject.delete_file key: 'test-delete-key.jpg'
        expect(resp).to be true

      end

      Timecop.return
    end
  end

  context 'global s3' do
    before do
      Timecop.freeze(Time.local(2014,11,20,17,00))
    end

    subject {@cdn}
    it "upload file and queue a message to sqs" do
      skip "not ready in CN-region" if  ENV['AWS_REGION'] == 'cn-north-1'

      t = Tempfile.new ['test-key', '.jpeg']
      t.write 'abc'
      t.close
      VCR.use_cassette('s3_global_upload_file') do
       code = subject.upload_file file_location: t.path,
                                  key: 'test-key.jpg',
                                  message_id: '1234'
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
