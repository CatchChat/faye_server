require 'rails_helper'
require 'timecop'
describe Cdn do
  before do

    Timecop.freeze(Time.local(2014))

    access_key = ENV["qiniu_access_key"]
    secret_key = ENV["qiniu_secret_key"]
    @init_hash = {access_key: access_key,
                 secret_key: secret_key}
    @qiniu_client = QiniuCdn.new @init_hash
  end

  after do
    Timecop.return
  end
  it "provide upload token for qiniu" do
    cdn = Cdn.new(@qiniu_client, @init_hash)
    qiniu_upload_token = cdn.get_upload_token bucket: 'test-bucket',
                                                 key: 'test-key',
                                        callback_url: 'http://localhost/callback'
    expect(qiniu_upload_token).to eq "BBHE3ccYQ8VQhEIvZbJARrte1U3ic2Om6CW7mxvN:PjdZY4UCUxMfZ-obI1TaXbgd2dg=:eyJzY29wZSI6InRlc3QtYnVja2V0OnRlc3Qta2V5IiwiY2FsbGJhY2tVcmwiOiJodHRwOi8vbG9jYWxob3N0L2NhbGxiYWNrIiwiZGVhZGxpbmUiOjEzODg1MDkyMDB9"
  end

  it "provide download url for qiniu" do
    cdn = Cdn.new(@qiniu_client, @init_hash)
    qiniu_download_url = cdn.get_download_url url: "http://hello.qiniu.com/a/b/c.jpg"
    expect(qiniu_download_url).to eq "http://hello.qiniu.com/a/b/c.jpg?e=1388509200&token=BBHE3ccYQ8VQhEIvZbJARrte1U3ic2Om6CW7mxvN:Ff38tdgiw8yFLjzLHrKzwABSogc="
  end
end
