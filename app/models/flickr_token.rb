class FlickrToken < ActiveRecord::Base

  STATUS_PENDING = 'pending'
  STATUS_CANCELED = 'cancelled'
  STATUS_ACCEPTED = 'accepted'


  #scope for approving token
  scope :pendingToken, -> { where(status: FlickrToken::STATUS_PENDING).order('id DESC').limit(1) }

  #scope for approved token
  scope :activeToken, -> { where(status: FlickrToken::STATUS_ACCEPTED).order('id DESC').limit(1) }
end