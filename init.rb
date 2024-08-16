require_relative 'lib/redmine_fullcalendar/hooks'

Redmine::Plugin.register :redmine_fullcalendar do
  name 'Redmine Fullcalendar plugin'
  author 'Vincent ROBERT'
  description 'This plugin integrates FullCalendar into Redmine'
  version '6.1.15'
  url 'http://example.com/path/to/plugin'
  project_module :fullcalendar do

  end
  project_module :fullcalendar do
    permission :use_fullcalendar, { :fullcalendars => [:index] }, public: true, :read => true
  end
  settings :partial => 'settings/fullcalendar_settings',
           :default => {
             'fullcalendar_start_field' => '',
             'fullcalendar_end_field' => '',
           }
end

Redmine::MenuManager.map :project_menu do |menu|
  menu.push :fullcalendar,
            { :controller => 'fullcalendars', :action => 'index' },
            :caption => 'Calendrier',
            :param => :project_id,
            :after => :calendar
end
