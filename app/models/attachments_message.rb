class AttachmentsMessage < ActiveRecord::Base
  belongs_to :message
  belongs_to :attachment
end
