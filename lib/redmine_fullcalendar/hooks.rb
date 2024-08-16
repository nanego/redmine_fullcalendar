module RedmineFullcalendar

  class Hooks < Redmine::Hook::ViewListener
    def view_layouts_base_html_head(context)
      stylesheet_link_tag("fullcalendar", :plugin => "redmine_fullcalendar") +
        javascript_include_tag("fullcalendar-6.1.15/packages/core/index.global", :plugin => "redmine_fullcalendar") +
        javascript_include_tag("fullcalendar-6.1.15/packages/core/locales-all.global", :plugin => "redmine_fullcalendar") +
        javascript_include_tag("fullcalendar-6.1.15/packages/daygrid/index.global", :plugin => "redmine_fullcalendar")
    end
  end

  class ModelHook < Redmine::Hook::Listener
    def after_plugins_loaded(_context = {})
      # require_relative 'xxx_patch'
    end
  end

end
