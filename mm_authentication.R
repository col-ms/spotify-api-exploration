library(spotifyr)

# Authentication to allow access to Spotify API
Sys.setenv(SPOTIFY_CLIENT_ID = 
             readr::read_lines("spotify_dev_info.txt")[1])

Sys.setenv(SPOTIFY_CLIENT_SECRET = 
             readr::read_lines("spotify_dev_info.txt")[2])

# Store access token for use in API call functions
access_token = get_spotify_access_token()
