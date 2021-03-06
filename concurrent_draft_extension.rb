# Uncomment this if you reference any of your controllers in activate
begin
  require_dependency 'application_controller'
rescue MissingSourceFile
  require_dependency 'application'
end

class ConcurrentDraftExtension < Radiant::Extension
  version "0.9"
  description "Enables default draft versions of pages, snippets and layouts, which can be scheduled for promotion to Production"
  url "http://github.com/avonderluft/concurrent_draft/tree/master"

  def activate
    [Page, Snippet, Layout, PagePart].each do |klass|
      klass.send :include, ConcurrentDraft::ModelExtensions
    end
    Page.send :include, ConcurrentDraft::PageExtensions
    Page.send :include, ConcurrentDraft::Tags
    [Admin::PagesController, Admin::SnippetsController, Admin::LayoutsController].each do |klass|
      klass.send :include, ConcurrentDraft::AdminControllerExtensions
      klass.class_eval do
        helper ConcurrentDraft::HelperExtensions
      end
    end
    SiteController.send :include, ConcurrentDraft::SiteControllerExtensions
    %w{page snippet layout}.each do |view|
      admin.send(view).edit.add :main, "admin/draft_controls", :before => "edit_header"
      admin.send(view).edit.form_bottom.delete 'edit_buttons'
      admin.send(view).edit.add :form_bottom, 'admin/edit_buttons'
    end
    admin.page.edit.add :extended_metadata, 'published_meta'
    Time::DATE_FORMATS[:long_civilian] = lambda {|time| time.strftime("%B %d, %Y %I:%M%p").gsub(/(\s+)0(\d+)/, '\1\2') }
  end
end