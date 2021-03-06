class ReprocessListingImageJob < ActiveJob::Base

  include DelayedAirbrakeNotification

  def perform(listing_image_id, style)
    listing_image = ListingImage.find_by_id(listing_image_id)

    listing_image.image.reprocess_without_delay! style.to_sym
  end
end
