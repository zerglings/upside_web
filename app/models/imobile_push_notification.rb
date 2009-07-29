# A push notification that is awaiting delivery.
class ImobilePushNotification < ActiveRecord::Base
  # The device receiving the notification.
  belongs_to :device
  validates_presence_of :device
  
  # The subject of a notification.
  belongs_to :subject, :polymorphic => true
  validates_presence_of :subject

  # The payload in a notification.
  serialize :payload, Hash
  validates_presence_of :payload
end
