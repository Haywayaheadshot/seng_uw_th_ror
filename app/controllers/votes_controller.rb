class VotesController < ApplicationController
  def new
    @budget_cycle = BudgetCycle.find(params[:budget_cycle_id])
    @voting_phase = @budget_cycle.current_voting_phase
    if @voting_phase.nil?
      redirect_to root_path, alert: 'No active voting phase available.'
      return
    end
    @budget_projects = @voting_phase.budget_cycle.budget_projects.where(deleted_at: nil)
    @participant = Participant.find_by(id: params[:participant_id]) || Participant.new
    @vote = Vote.new
  end

  def create # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    @budget_cycle = BudgetCycle.find(params[:budget_cycle_id])
    @voting_phase = @budget_cycle.current_voting_phase
    if @voting_phase.nil?
      respond_to do |format|
        format.html { redirect_to root_path, alert: 'No active voting phase available.' }
        format.json { render json: { error: 'No active voting phase available' }, status: :unprocessable_entity }
      end
      return
    end
    @vote = Vote.new(vote_params.merge(voting_phase_id: @voting_phase.id, created_at: Time.current))

    respond_to do |format|
      @budget_projects = @voting_phase.budget_cycle.budget_projects.where(deleted_at: nil)
      if @vote.save
        @participant = Participant.find_by(id: vote_params[:participant_id]) || Participant.new
        format.html { redirect_to budget_cycle_votes_path(@budget_cycle), notice: 'Vote cast successfully.' }
        format.json { render json: @vote.as_json(only: %i[id voting_phase_id budget_project_id participant_id created_at]), status: :created }
        format.turbo_stream do
          @vote = Vote.new # Reset @vote to a new instance for the form
          render turbo_stream: turbo_stream.replace('vote_form', partial: 'votes/form',
                                                                 locals: { vote: @vote, budget_cycle: @budget_cycle,
                                                                           budget_projects: @budget_projects,
                                                                           participant: @participant })
        end
      else
        @budget_projects = @voting_phase.budget_cycle.budget_projects.where(deleted_at: nil)
        @participant = Participant.find_by(id: vote_params[:participant_id]) || Participant.new
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @vote.errors, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace('vote_form', partial: 'votes/form',
                                                                 locals: { vote: @vote, budget_cycle: @budget_cycle,
                                                                           budget_projects: @budget_projects,
                                                                           participant: @participant })
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

  def vote_params
    params.require(:vote).permit(:budget_project_id, :participant_id)
  end
end
