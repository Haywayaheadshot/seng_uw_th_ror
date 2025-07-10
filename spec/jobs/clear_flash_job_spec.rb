class ClearFlashJob < ApplicationJob
  queue_as :default

  def perform(session_id)
    Turbo::StreamsChannel.broadcast_replace_to(
      "flash_#{session_id}",
      target: 'flash_container',
      partial: 'shared/flash',
      locals: { notice: nil, alert: nil }
    )
  end
end
