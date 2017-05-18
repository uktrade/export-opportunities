class UpdateOpportunityStatus
  def initialize(notification_sender = SubscriberNotificationSender.new)
    @notification_sender = notification_sender
  end

  def call(opportunity, status)
    case status
    when 'publish'
      if opportunity.first_published_at
        change_status(opportunity, status)
      else
        opportunity.first_published_at = Time.now.utc
        change_status(opportunity, status) do |opp|
          @notification_sender.call(opp)
        end
      end
    when 'pending'
      change_status(opportunity, status)
    when 'draft'
      opportunity.ragg = :undefined
      change_status(opportunity, status)
    else
      raise ArgumentError, 'Only statuses of publish and pending can be set'
    end
  end

  private

  def change_status(opportunity, status)
    if opportunity.update(status: status)
      yield(opportunity) if block_given?
      SuccessResult.new(opportunity.status)
    else
      FailureResult.new
    end
  end

  class FailureResult
    def success?
      false
    end
  end

  class SuccessResult
    def initialize(new_status)
      @new_status = new_status
    end

    def success?
      true
    end

    def message
      case @new_status
      when 'publish'
        'has been published'
      when 'pending'
        'has been set to pending'
      when 'draft'
        'has been set to draft'
      end
    end
  end
end

class SubscriberNotificationSender
  def call(opportunity)
    SendOpportunityToMatchingSubscriptionsWorker.perform_async(opportunity.id)
  end
end
