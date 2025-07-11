class VotesController < ApplicationController
  def index
    @budget_cycle = BudgetCycle.find(params[:budget_cycle_id])
    @votes = @budget_cycle.votes
  end

  def new
    @budget_cycle = BudgetCycle.find(params[:budget_cycle_id])
    @voting_phase = @budget_cycle.current_voting_phase
    if @voting_phase.nil?
      redirect_to root_path, alert: 'No active voting phase available.'
      return
    end
    @vote = Vote.new
    @budget_projects = filter_and_sort_projects
    @participants = Participant.all
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
    @budget_project = BudgetProject.find(vote_params[:budget_project_id])

    if @budget_project.budget_category && !within_category_limit?(@budget_project)
      @vote.errors.add(:base, "Cannot vote: category #{@budget_project.budget_category.name} exceeds spending limit")
      respond_to do |format|
        @budget_projects = filter_and_sort_projects
        @participants = Participant.all
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @vote.errors, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace('vote_form', partial: 'votes/form',
                                                                 locals: { vote: @vote, budget_cycle: @budget_cycle, budget_projects: @budget_projects, participants: @participants })
        end
      end
      return
    end

    respond_to do |format|
      @budget_projects = filter_and_sort_projects
      @participants = Participant.all
      if @vote.save
        format.html { redirect_to budget_cycle_votes_path(@budget_cycle), notice: 'Vote cast successfully.' }
        format.json { render json: @vote.as_json(only: %i[id voting_phase_id budget_project_id participant_id created_at]), status: :created }
        format.turbo_stream do
          @vote = Vote.new
          render turbo_stream: turbo_stream.replace('vote_form', partial: 'votes/form',
                                                                 locals: { vote: @vote, budget_cycle: @budget_cycle, budget_projects: @budget_projects, participants: @participants })
        end
      else
        @participants = Participant.all
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @vote.errors, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace('vote_form', partial: 'votes/form',
                                                                 locals: { vote: @vote, budget_cycle: @budget_cycle, budget_projects: @budget_projects, participants: @participants })
        end
      end
    end
  end

  private

  def vote_params
    params.require(:vote).permit(:budget_project_id, :participant_id)
  end

  def filter_and_sort_projects
    projects = @budget_cycle.budget_projects
    projects = projects.where('impact_metrics->>\'estimated_beneficiaries\' >= ?', params[:filter][:min_beneficiaries].to_i) if params[:filter]&.[](:min_beneficiaries).present?
    projects = projects.where('impact_metrics->>\'sustainability_score\' >= ?', params[:filter][:min_sustainability].to_i) if params[:filter]&.[](:min_sustainability).present?
    sort_field = params[:sort]&.to_sym
    if %i[estimated_beneficiaries sustainability_score].include?(sort_field)
      projects.order("impact_metrics->>'#{sort_field}' DESC")
    else
      projects.order(sort_field || :name)
    end
  end

  def within_category_limit?(project)
    return true unless project.budget_category && project.budget_cycle

    total_allocated = project.budget_category.allocated_amount(project.budget_cycle)
    allowed_limit = project.budget_cycle.total_budget * (project.budget_category.spending_limit_percentage / 100.0)
    total_allocated <= allowed_limit
  end
end
