require_relative '../rails_helper'

describe NodePassword do

  before do
    create :user
    @client = double()
    @client.extend NodePassword
    # following token comes from mongodb legacy data combined with id and token
  end

  it "convert plain text to node api password" do
    password = 'node'
    expect(@client.plain_text_to_node_password(password)).to eq '62d30f88375b7f4f1461aa0e19b47e6e52c6141409a8c5e6bcb2c45e8186a4a1'
  end

  it "check_node_username_password" do
   expect(@client.check_node_username_password('ruanwztest','node')).to be_an_instance_of User
  end
end
