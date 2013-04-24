module ApplicationHelper
  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def nav_tab(title, url, options = {})
    current_tab = options.delete(:current)
    options[:class] = (current_tab == title) ? 'active' : ''
    label=nil
    icon=nil
    link=""
    icon_class=options.delete(:icon)
    if icon_class
      icon= content_tag(:i, "",class:"#{icon_class[:class]}")
      end
      link= link_to url do
        content_tag(:span,icon.concat(" #{title}"),class:"text")
        end
        content_tag(:li,link,options)
      end

      def currently_at(tab)
        render partial: 'application/menu', locals: {current_tab: tab}
      end

  def devise_error_messages!
    return "" if resource.errors.empty?

    messages = resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
    sentence = I18n.t("errors.messages.not_saved",
                      :count => resource.errors.count,
                      :resource => resource.class.model_name.human.downcase)

    html = <<-HTML
    <div id="error_explanation">
      <h5>#{sentence}</h5>
      <ul>#{messages}</ul>
    </div>
    HTML

    html.html_safe
  end

  def song_downloads_chat(order)
    (3.weeks.ago.to_date..Date.today).map do |date|
      {
          completed_at: date,
          transactions: order.where("date(created_at) = ?", date).size
      }
    end
  end

      def message_for_order(order)
        type = order.item_type
        partial = case type
                when "Wallet"
                  render partial: 'wallets/message',locals: {order:order}
                when "Airtime"
                  render partial: 'airtimes/message', locals:{order:order}
              end
      end

      def payment_form_for_order(order)
        type = order.item_type
        interswitch_params=map_order_to_interswitch_params(order)
        partial = case type
                    when "Wallet"
                      render partial: 'wallets/payment_form',locals: {order:order,interswitch:interswitch_params}
                    when "Airtime"
                      render partial: 'airtimes/payment_form', locals:{order:order,interswitch:interswitch_params}
                  end
      end

      def json_message_partial_order(order)
        type = order.item_type
        case type
          when "Wallet"
            'api/v1/tokens/wallet_message'
          when "Airtime"
            'api/v1/tokens/credit_message'
        end
      end

      def class_for_status(status)
        case status
          when "successful"
            'success'
          when "processing","pending"
            'warning'
          when "failed"
            'danger'
          else
            ""
        end
      end

end
