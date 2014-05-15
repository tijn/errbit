class Api::V1::ProblemsController < ApplicationController
  respond_to :json, :xml

  def index
    query = {}
    if params.key?(:start_date) && params.key?(:end_date)
      start_date = Time.parse(params[:start_date]).utc
      end_date = Time.parse(params[:end_date]).utc
      query = {:first_notice_at=>{"$lte"=>end_date}, "$or"=>[{:resolved_at=>nil}, {:resolved_at=>{"$gte"=>start_date}}]}
    end
    results = benchmark('[api/v1/problems_controller] query time') do
      fetch_with_query(query).to_a
    end
    respond_to do |format|
      format.any(:html, :json) { render json: Yajl.dump(results) }
      format.xml  { render xml: results }
    end
  end

  def week
    results = []
    query = { last_notice_at: { '$gte' => 1.week.ago.utc },
              '$or' => [{ resolved_at: { '$gte' => 1.week.ago.utc } }] }
    results = fetch_with_query(query).to_a
    respond_to do |format|
      format.any(:html, :json) { render json: results.to_json(methods: :responsible) }
      format.xml  { render xml: results }
    end
  end

  private

  def fetch_with_query(query)
    Problem.where(query).with(consistency: :strong).only(problem_fields)
  end

  def problem_fields
    %w(app_id app_name environment message where first_notice_at last_notice_at
       resolved resolved_at notices_count urgent)
  end
end
