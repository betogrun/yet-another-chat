class Message < ApplicationRecord
  belongs_to :user
  belongs_to :messagable, polymorphic: true
  validates_presence_of :body, :user
end
