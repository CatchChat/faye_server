require 'rails_helper'

describe Users::PasswordsController do
  render_views
  let(:user) {FactoryGirl.create(:user, mobile: '1234567')}
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  it 'change password with current password, new password and new password confirm' do
    sign_in user
    put :change_password, current_password: 'ruanwztest', new_password: 'new_password', new_password_confirm: 'new_password', format: 'json'

    expect(subject.current_user.password).to eq 'new_password'
  end

end
