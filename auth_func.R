# authentication function

authenticate <- function(){
  
  # Store access token for use in API call functions
  access_token = spotifyr::get_spotify_access_token()

}