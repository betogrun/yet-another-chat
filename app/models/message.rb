class Message < ApplicationRecord
  belongs_to :user
  belongs_to :messagable, polymorphic: true
  validates_presence_of :body, :user

  after_create_commit {MessageBroadcastJob.perform_later self}
end
