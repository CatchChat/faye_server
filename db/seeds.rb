# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
User.destroy_all
user = User.create username:       'ruanwztest',
                   password:       'ruanwztest',
                   mobile:         '12345678',
                   node_password:  '62d30f88375b7f4f1461aa0e19b47e6e52c6141409a8c5e6bcb2c45e8186a4a1'
user.access_tokens << token = AccessToken.create(token: 'test-token', active: true)
token.save

user.sms_verification_codes << sms_code = SmsVerificationCode.create(mobile: user.mobile, token: '12345', active: true)
sms_code.save

friend = User.create username:       'tumayun',
                     password:       '123456',
                     mobile:         '87654321',
                     node_password:  '62d30f88375b7f4f1461aa0e19b47e6e52c6141409a8c5e6bcb2c45e8186a4a1'

friend_request = user.friend_requests.create!(friend_id: friend.id)
friend_request.accept!

group = user.groups.create!(name: 'group')
group.friendships << user.friendships.last
