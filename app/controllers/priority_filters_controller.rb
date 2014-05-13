class PriorityFiltersController < ApplicationController
  before_filter :require_admin!
  respond_to :html

  expose(:priority_filter, attributes: :filter_params)
  expose(:priority_filters) { PriorityFilter.all }
  expose(:apps) { App.all.sort }

  def create
    if priority_filter.save
      flash[:success] = t('controllers.filters.flash.create.success')
      redirect_to priority_filter_url(priority_filter)
    else
      render :new
    end
  end

  def update
    if priority_filter.update_attributes filter_params
      flash[:success] = t('controllers.filters.flash.update.success')
      redirect_to priority_filter_url(priority_filter)
    else
      render :edit
    end
  end

  def destroy
    priority_filter.destroy
    flash[:success] = t('controllers.filters.flash.destroy.success')
    redirect_to priority_filters_url
  end

  private

  def filter_params
    params.require(:priority_filter).permit(:message, :url, :error_class,
                                             :where, :description, :app_id)
  end
end
