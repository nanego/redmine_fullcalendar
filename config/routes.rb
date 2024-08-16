# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

get '/projects/:project_id/issues/fullcalendar', :to => 'fullcalendars#index', :as => 'project_fullcalendar'
get 'fullcalendar/issues', :to => 'fullcalendars#issues'
