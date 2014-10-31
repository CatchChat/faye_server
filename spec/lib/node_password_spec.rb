require_relative '../spec_helper'
require_relative '../../lib/node_password'

describe NodePassword do
  it "convert plain text to node api password" do
    password = 'ruanwztest'
    client = Object.new
    client.extend NodePassword
    expect(client.plain_text_to_node_password(password)).to eq '6c9fa5fcd90f86d56fa271a9b80f649e8e4c327097707cb12d7262ce93537d3d'
  end
end
