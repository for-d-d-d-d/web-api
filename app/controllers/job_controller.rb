class JobController < ApplicationController
  def percentage_done
    job_id = params[:job_id] # grabbing the job_id from params
    
    @pct_complete = Sidekiq::Status::at   job_id
    render :json => {
      :percentage_done => @pct_complete, # responding with json with the percent complete data
    }
  end
end
