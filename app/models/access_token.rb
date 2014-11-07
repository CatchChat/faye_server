class AccessToken < ActiveRecord::Base
  belongs_to :user

  enum device: [:ios, :android].freeze
  enum push_provider: [:jpush, :xinge].freeze
end
