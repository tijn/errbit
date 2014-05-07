class ExceptionFiltersController < ApplicationController
  before_filter :require_admin!
  respond_to :html

  expose(:exception_filter, attributes: :filter_params)
  expose(:exception_filters) { ExceptionFilter.all }
  expose(:apps) { App.all.sort }

  def create
    if exception_filter.save
      flash[:success] = t('controllers.filters.flash.create.success')
      redirect_to exception_filter_url(exception_filter)
    else
      render :new
    end
  end

  def update
    if exception_filter.update_attributes filter_params
      flash[:success] = t('controllers.filters.flash.update.success')
      redirect_to exception_filter_url(exception_filter)
    else
      render :edit
    end
  end

  def destroy
    exception_filter.destroy
    flash[:success] = t('controllers.filters.flash.destroy.success')
    redirect_to exception_filters_url
  end

  private

  def filter_params
    params.require(:exception_filter).permit(:message, :url, :error_class,
                                             :where, :description, :app_id)
  end
end
