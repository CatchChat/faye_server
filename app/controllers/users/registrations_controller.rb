class Users::Registrations < Devise::RegistrationsController
  include RateLimit
end
