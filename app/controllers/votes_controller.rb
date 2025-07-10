class VotesController < ApplicationController
  # before_action :authenticate_user!, except: [:index]
  before_action :set_voting_phase, only: %i[new create]

  def new
    if @voting_phase.nil?
      redirect_to budget_cycles_path, alert: 'No active voting phase available.'
      ClearFlashJob.set(wait: 3.seconds).perform_later(session.id.to_s)
      return
    end
    @budget_projects = @voting_phase.budget_cycle.budget_projects.where(deleted_at: nil)
    @participant = Participant.find_by(id: params[:participant_id]) || Participant.new
    @vote = Vote.new
  end

  def create
    if @voting_phase.nil?
      respond_to do |format|
        format.html do
          redirect_to budget_cycles_path, alert: 'No active voting phase available.'
          ClearFlashJob.set(wait: 3.seconds).perform_later(session.id.to_s)
        end
        format.json { render json: { error: 'No active voting phase available' }, status: :unprocessable_entity }
      end
      return
    end

    unless eligible_to_vote?(@voting_phase)
      respond_to do |format|
        format.html do
          redirect_to budget_cycles_path, alert: 'You are not eligible to vote.'
          ClearFlashJob.set(wait: 3.seconds).perform_later(session.id.to_s)
        end
        format.json { render json: { error: 'You are not eligible to vote' }, status: :forbidden }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace('flash_container', partial: 'shared/flash', locals: { alert: 'You are not eligible to vote.' })
          ClearFlashJob.set(wait: 3.seconds).perform_later(session.id.to_s)
        end
      end
      return
    end

    if user_votes_count >= @voting_phase.max_votes_per_user
      respond_to do |format|
        format.html do
          redirect_to budget_cycles_path, alert: 'You have reached the maximum votes.'
          ClearFlashJob.set(wait: 3.seconds).perform_later(session.id.to_s)
        end
        format.json { render json: { error: 'You have reached the maximum votes' }, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace('flash_container', partial: 'shared/flash', locals: { alert: 'You have reached the maximum votes.' })
          ClearFlashJob.set(wait: 3.seconds).perform_later(session.id.to_s)
        end
      end
      return
    end

    @vote = @voting_phase.votes.build(vote_params.merge(user: current_user, created_at: Time.current))
    respond_to do |format|
      @budget_projects = @voting_phase.budget_cycle.budget_projects.where(deleted_at: nil)
      if @vote.save
        @participant = Participant.find_by(id: vote_params[:participant_id]) || Participant.new
        format.html do
          redirect_to budget_cycle_votes_path(@budget_cycle), notice: 'Vote cast successfully.'
          ClearFlashJob.set(wait: 3.seconds).perform_later(session.id.to_s)
        end
        format.json { render json: @vote.as_json(only: %i[id voting_phase_id budget_project_id participant_id created_at]), status: :created }
        format.turbo_stream do
          @vote = Vote.new
          render turbo_stream: turbo_stream.replace('vote_form', partial: 'votes/form',
                                                                 locals: { vote: @vote, budget_cycle: @budget_cycle, budget_projects: @budget_projects, participant: @participant })
          ClearFlashJob.set(wait: 3.seconds).perform_later(session.id.to_s)
        end
      else
        @budget_projects = @voting_phase.budget_cycle.budget_projects.where(deleted_at: nil)
        @participant = Participant.find_by(id: vote_params[:participant_id]) || Participant.new
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @vote.errors, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace('vote_form', partial: 'votes/form',
                                                                 locals: { vote: @vote, budget_cycle: @budget_cycle, budget_projects: @budget_projects, participant: @participant })
        end
      end
    end
  end

  def index
    @budget_cycle = BudgetCycle.find(params[:budget_cycle_id])
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  private

  def set_voting_phase
    @budget_cycle = BudgetCycle.find(params[:budget_cycle_id])
    @voting_phase = @budget_cycle.current_voting_phase
  end

  def eligible_to_vote?(phase)
    case phase.participant_eligibility
    when 'all' then true
    when 'admins' then current_user&.admin?
    when 'registered_users' then current_user.present?
    else false
    end
  end

  def user_votes_count
    @voting_phase.votes.where(user: current_user).count
  end

  def vote_params
    params.require(:vote).permit(:budget_project_id, :participant_id)
  end
end
