Exploring Mac Miller’s Discography with Spotify API
================
Collin Smith
2022-05-19

Hello, and welcome to my very first Markdown publication. I am still
relatively new to R, with about 2 years of exposure and experience with
the language. The vast majority of my time spent with R has been for
university courses. Throughout this time I have learned a great deal
from books like Hadley Wickham’s [R for Data
Science](https://r4ds.had.co.nz/), as well as tutorials, articles, and
markdown pages from sites such as [RPubs](https://rpubs.com/),
[R-bloggers](https://www.r-bloggers.com/), and [Towards Data
Science](https://towardsdatascience.com/). My hope is that this project
can in turn be used to help someone else down the road, as others have
helped me.

In this project, we will be exploring how to use Spotify’s API and the
**spotifyr** package to access data about a particular artists
discography. We’ll also be utilizing the **genius** package to retrieve
lyrics for songs, allowing for sentiment to be explored and visualized.

### Obtaining Spotify API Credentials

To begin, we will first need to head over to the [Spotify for
Developers](https://developer.spotify.com/dashboard/) page, where we
will be registering an application to obtain an API key. Once you’ve
logged in, select “Create an App” and fill out the required fields.
Completing this will give you access to two important fields: your
**client id** and your **client secret** (or API key). These fields will
be used to let the API know who is accessing it and that you have proper
authentication. To get started, first install the **spotifyr** package
if you don’t already have it.

``` r
install.packages("spotifyr")
```

Next, we can use the following code to pass out authentication
credentials to the API, giving us access.

``` r
Sys.setenv(SPOTIFY_CLIENT_ID = 'your client id')
Sys.setenv(SPOTIFY_CLIENT_SECRET = 'your client secret')
access_token <- get_spotify_access_token()
```

Now that you are authenticated with the API, we can begin using the
**spotifyr** package’s functions to retrieve information. In this
project, we will be analyzing Mac Miller’s discography and exploring how
his sound changed throughout his career. To get information regarding a
single artist’s discography, we can use the
`get_artist_audio_features()` function. The function will return a
dataframe containing information about all of the artists’ music that is
hosted on Spotify. The function takes many possible arguments, but for
the sake of this project, we only need to pass in one: the name of the
artist for which we wish to get information.

``` r
library(spotifyr)
mm_data <- get_artist_audio_features(artist = "Mac Miller")
```

To check that this function performed as expected, let’s take a very
quick glance at the returned dataframe.

``` r
colnames(mm_data)
```

    ##  [1] "artist_name"                  "artist_id"                   
    ##  [3] "album_id"                     "album_type"                  
    ##  [5] "album_images"                 "album_release_date"          
    ##  [7] "album_release_year"           "album_release_date_precision"
    ##  [9] "danceability"                 "energy"                      
    ## [11] "key"                          "loudness"                    
    ## [13] "mode"                         "speechiness"                 
    ## [15] "acousticness"                 "instrumentalness"            
    ## [17] "liveness"                     "valence"                     
    ## [19] "tempo"                        "track_id"                    
    ## [21] "analysis_url"                 "time_signature"              
    ## [23] "artists"                      "available_markets"           
    ## [25] "disc_number"                  "duration_ms"                 
    ## [27] "explicit"                     "track_href"                  
    ## [29] "is_local"                     "track_name"                  
    ## [31] "track_preview_url"            "track_number"                
    ## [33] "type"                         "track_uri"                   
    ## [35] "external_urls.spotify"        "album_name"                  
    ## [37] "key_name"                     "mode_name"                   
    ## [39] "key_mode"

``` r
unique(mm_data$album_name)
```

    ##  [1] "Faces"                                              
    ##  [2] "Circles (Deluxe)"                                   
    ##  [3] "Circles"                                            
    ##  [4] "Swimming"                                           
    ##  [5] "The Divine Feminine"                                
    ##  [6] "Best Day Ever (5th Anniversary Remastered Edition)" 
    ##  [7] "GO:OD AM"                                           
    ##  [8] "Live From Space"                                    
    ##  [9] "Watching Movies with the Sound Off (Deluxe Edition)"
    ## [10] "Watching Movies with the Sound Off"                 
    ## [11] "Mac Miller : Live From London (With The Internet)"  
    ## [12] "Macadelic (Remastered Edition)"                     
    ## [13] "Blue Slide Park (Commentary Version)"               
    ## [14] "Blue Slide Park (Edited Version)"                   
    ## [15] "Blue Slide Park"                                    
    ## [16] "K.I.D.S. (Deluxe)"                                  
    ## [17] "K.I.D.S."

``` r
head(mm_data$track_name)
```

    ## [1] "Inside Outside"                          
    ## [2] "Here We Go"                              
    ## [3] "Friends (feat. ScHoolboy Q)"             
    ## [4] "Angel Dust"                              
    ## [5] "Malibu"                                  
    ## [6] "What Do You Do (feat. Sir Michael Rocks)"

``` r
dim(mm_data)
```

    ## [1] 305  39
