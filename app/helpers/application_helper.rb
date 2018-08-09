module ApplicationHelper
  ALERT_TYPES = [:error, :info, :success, :warning]

  def bootstrap_flash
    flash_messages = []
    flash.each do |type, message|
      # Skip empty messages, e.g. for devise messages set to nothing in a locale file.
      next if message.blank?

      type = :success if type == :notice
      type = :error   if type == :alert
      next unless ALERT_TYPES.include?(type)

      Array(message).each do |msg|
        text = content_tag(:div,
           content_tag(:button, raw("&times;"), :class => "close", "data-dismiss" => "alert") +
           msg.html_safe, :class => "alert fade in alert-#{type}", :style => "display: block")
        flash_messages << text if message
      end
    end
    flash_messages.join("\n").html_safe
  end

  def bootstrap_form_errors resource, message=nil
    return unless (resource && resource.respond_to?(:errors))

    if resource.errors.any?
      message ||= "Unable to #{action_name} #{resource.class.name.humanize.downcase}."
      content_tag(:div, :class => "alert alert-error", :style => "display: block") do
        content = content_tag(:h3, message)
        content << content_tag(:ul) do
          resource.errors.full_messages.inject("".html_safe) do |items, error|
            items << content_tag(:li, error)
          end
        end
      end
    end
  end

  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

end
