class CommunityJoinedJob < ActiveJob::Base

  include DelayedAirbrakeNotification

  # This before hook should be included in all Jobs to make sure that the service_name is
  # correct as it's stored in the thread and the same thread handles many different communities
  # if the job doesn't have host parameter, should call the method with nil, to set the default service_name

  before_perform do |job|
    # Set the correct service name to thread for I18n to pick it
    ApplicationHelper.store_community_service_name_to_thread_from_community_id(job.arguments.last.id)
  end

  def perform(new_member, community)

    if community.email_admins_about_new_members?
      community.admins.each do |admin|
        email = PersonMailer.new_member_notification(new_member, community, admin)
        if email.present?
          MailCarrier.deliver_now(email)
        end
      end
    end
  end

end
