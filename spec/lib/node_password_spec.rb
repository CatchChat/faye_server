require_relative '../rails_helper'
require_relative '../spec_helper'
require_relative '../../lib/node_password'

describe NodePassword do

  before do
    create :user
    @client = double()
    @client.extend NodePassword
    # following token comes from mongodb legacy data combined with id and token
    allow(@client). to receive(:request) {
      OpenStruct.new headers: {
        'X-CatchChatToken' => 'NTQyYTIyYWU0YjQ0Njg0ZjJlY2IyMzk4Om8xVThMTlB2aDFWWDBSME0=',
        'X-CatchChatAuth'  => Base64.encode64('ruanwztest:ruanwztest') }
    }
  end

  it "convert plain text to node api password" do
    password = 'ruanwztest'
    expect(@client.plain_text_to_node_password(password)).to eq '6c9fa5fcd90f86d56fa271a9b80f649e8e4c327097707cb12d7262ce93537d3d'
  end

  it "check_node_username_password" do
   expect(@client.check_node_username_password).to eq true

  end

  it "check_node_user_id_token" do
   expect(@client.check_node_user_id_token).to eq true

  end

end
