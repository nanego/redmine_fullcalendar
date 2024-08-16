class FullcalendarsController < ApplicationController
  unloadable

  accept_api_auth :issues
  menu_item :fullcalendar

  before_action :find_optional_project, only: [:index]

  def index

  end

  def issues
    @project = Project.find(params[:project_id]) if params[:project_id].present?
    @issues = Issue.open.visible(User.current)
    @issues = @issues.where(project: @project) if @project

    start_field = get_start_field
    if start_field.is_a?(IssueCustomField)
      start_date_sql = IssueQuery.new.date_clause('custom_values', 'value', nil, params[:end].to_date, true)
      starting_statement = "(custom_values.custom_field_id = #{start_field.id} AND #{start_date_sql})"
    else
      start_date_sql = IssueQuery.new.date_clause('issues', 'start_date', nil, params[:end].to_date, false)
      @issues = @issues.where("#{start_date_sql} OR issues.start_date IS NULL")
    end

    end_field = get_end_field
    if end_field.is_a?(IssueCustomField)
      end_date_sql = IssueQuery.new.date_clause('custom_values', 'value', params[:start].to_date, nil, true)
      ending_statement = "(custom_values.custom_field_id = #{end_field.id} AND #{end_date_sql})"
    else
      end_date_sql = IssueQuery.new.date_clause('issues', 'due_date', params[:start].to_date, nil, false)
      @issues = @issues.where("#{end_date_sql} OR issues.due_date IS NULL")
    end

    if start_field.is_a?(IssueCustomField) || end_field.is_a?(IssueCustomField)
      @issues = @issues.joins(:custom_values).where('issues.id = custom_values.customized_id')
      @issues = @issues.where([starting_statement, ending_statement].join(' OR '))
    end

    @issues = @issues.uniq.map do |issue|
      start_date = start_field.is_a?(IssueCustomField) ? casted_date_attribute(issue, start_field) : issue.start_date
      end_date = end_field.is_a?(IssueCustomField) ? casted_date_attribute(issue, end_field) : issue.due_date
      all_day = start_date.present? && end_date.present? && start_date.to_date != end_date.to_date
      {
        id: issue.id,
        title: issue.subject,
        start: start_date,
        end: all_day ? end_date + 1.day : end_date,
        url: issue_url(issue),
        allDay: all_day
      }
    end
    render json: @issues
  end

  private

  def get_start_field
    if Setting.plugin_redmine_fullcalendar['fullcalendar_start_field'].present?
      IssueCustomField.find(Setting.plugin_redmine_fullcalendar['fullcalendar_start_field'])
    else
      "start_date"
    end
  end

  def get_end_field
    if Setting.plugin_redmine_fullcalendar['fullcalendar_end_field'].present?
      IssueCustomField.find(Setting.plugin_redmine_fullcalendar['fullcalendar_end_field'])
    else
      "due_date"
    end
  end

  def casted_date_attribute(issue, field)
    custom_value = CustomValue.where(customized: issue, custom_field: field).first&.value
    if custom_value.present? && custom_value.match(/\d{2}\/\d{2}\/\d{4} \d{2}:\d{2}/)
      custom_value.to_datetime
    else
      nil
    end
  end

end
