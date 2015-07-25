#
# == ApplicationHelper
#
module ApplicationHelper
  def current_year
    Time.zone.now.year
  end

  def mapbox_gon_params
    gon.push(
      mapbox_username: Figaro.env.mapbox_username,
      mapbox_key: Figaro.env.mapbox_map_key,
      mapbox_access_token: Figaro.env.mapbox_access_token,
      name: @setting.name,
      subtitle: @setting.subtitle,
      address: @map.address,
      city: @map.city,
      postcode: @map.postcode,
      latitude: @map.latitude,
      longitude: @map.longitude
    )
  end

  def title_for_category(category)
    link = link_to category.title, category.menu_link(category.name), class: 'l-page-title-link'
    content_tag(:h2, link, class: 'l-page-title', id: category.name.downcase)
  end

  def background_from_color_picker(category)
    "background-color: #{category.color}" unless category.nil? || category.color.blank?
  end

  #
  # == Site validation
  #
  def google_bing_site_verification
    "#{google_site_verification} #{bing_site_verification}"
  end

  def google_site_verification
    content_tag(:meta, nil, name: 'google-site-verification', content: Figaro.env.google_site_verification) unless Figaro.env.google_site_verification.blank?
  end

  def bing_site_verification
    content_tag(:meta, nil, name: 'msvalidate.01', content: Figaro.env.bing_site_verification) unless Figaro.env.bing_site_verification.blank?
  end
end
