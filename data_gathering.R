# Contains the code for obtaining data 
# regarding Mac Miller's discography, as
# it currently exists on Spotify.

# Loads any user-defined functions stored in file, and
# performs necessary authentication for API access
source('functions.R')

# retrieve discography
mm_disco <- get_artist_audio_features(artist = 'Mac Miller')