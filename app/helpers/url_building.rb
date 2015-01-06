module UrlBuilding

  class ExternalUrlBuilder

    def self.static_map_url(geo_latitude, geo_longitude, zoom = 8, size = '640x480', color = 'blue', label = 'P')

      basuUrl = '//maps.googleapis.com/maps/api/staticmap?center=#geo_latitude#,#geo_longitude#&zoom=#zoom#&size=#size#&markers=color:#color#|label:#label#|#geo_latitude#,#geo_longitude#'
      
      outputUrl = basuUrl.gsub(
          /#geo_latitude#|#geo_longitude#|#zoom#|#size#|#color#|#label#/,
          '#geo_latitude#' => geo_latitude,
          '#geo_longitude#' => geo_longitude,
          '#zoom#' => zoom,
          '#size#' => size,
          '#color#' => color,
          '#label#' => label
      )

# <%=@photo.geo_latitude%>
# <%=@photo.geo_longitude%>
      #zoom = 8
      #600x300
      #color=blue
      #label=P
    #  WINDOWS_8_APP_URL
    #  .expand(app_id: app.id, language: language)
    #  .to_s
    end
  end
end