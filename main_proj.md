Exploring Mac Miller’s Discography with Spotify API
================
Collin Smith
2022-05-19

-   [Welcome!](#welcome)
-   [Obtaining Spotify API
    Credentials](#obtaining-spotify-api-credentials)
-   [Gathering the Data](#gathering-the-data)
-   [Checking the Data](#checking-the-data)
    -   [Webscraping](#webscraping)
    -   [Cleaning the scraped data](#cleaning-the-scraped-data)
    -   [Prepping for Merge](#prepping-for-merge)
    -   [Merging the Data](#merging-the-data)

### Welcome!

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

### Gathering the Data

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
head(mm_data$track_name, 15)
```

    ##  [1] "Inside Outside"                          
    ##  [2] "Here We Go"                              
    ##  [3] "Friends (feat. ScHoolboy Q)"             
    ##  [4] "Angel Dust"                              
    ##  [5] "Malibu"                                  
    ##  [6] "What Do You Do (feat. Sir Michael Rocks)"
    ##  [7] "It Just Doesn’t Matter"                  
    ##  [8] "Therapy"                                 
    ##  [9] "Polo Jeans (feat. Earl Sweatshirt)"      
    ## [10] "Happy Birthday"                          
    ## [11] "Wedding"                                 
    ## [12] "Funeral"                                 
    ## [13] "Diablo"                                  
    ## [14] "Ave Maria"                               
    ## [15] "55"

``` r
dim(mm_data)
```

    ## [1] 305  39

Excellent! The returned dataframe contains `305` observations, or in
this case songs, and each observation has `39` variables.

### Checking the Data

We can see from the `unique(mm_data$album_name)` function that the
albums are listed in order of upload date, with Faces being the most
recent album added to Mac’s Spotify page. While this may seem handy, it
is important to note that the order in which albums are uploaded to
Spotify is not always the same order that the albums were released. We
can observe this by taking a look at the `album_release_date` variable.

``` r
library(tidyverse)
library(plotly)
```

``` r
mm_data %>% 
  select(album_name, album_release_date) %>%
  distinct()
```

| album_name                                          | album_release_date |
|:----------------------------------------------------|:-------------------|
| Faces                                               | 2021-10-15         |
| Circles (Deluxe)                                    | 2020-03-19         |
| Circles                                             | 2020-01-17         |
| Swimming                                            | 2018-08-03         |
| The Divine Feminine                                 | 2016-09-16         |
| Best Day Ever (5th Anniversary Remastered Edition)  | 2016-06-03         |
| <GO:OD> AM                                          | 2015-09-18         |
| Live From Space                                     | 2013-12-17         |
| Watching Movies with the Sound Off (Deluxe Edition) | 2013-06-18         |
| Watching Movies with the Sound Off                  | 2013-06-18         |
| Mac Miller : Live From London (With The Internet)   | 2013-01-01         |
| Macadelic (Remastered Edition)                      | 2012-03-23         |
| Blue Slide Park (Commentary Version)                | 2011-11-15         |
| Blue Slide Park (Edited Version)                    | 2011-11-15         |
| Blue Slide Park                                     | 2011-11-08         |
| K.I.D.S. (Deluxe)                                   | 2010-08-13         |
| K.I.D.S.                                            | 2010-08-13         |

This readout implies that Faces is the most recent album to release.
However, by checking Mac’s
[discography](https://en.wikipedia.org/wiki/Mac_Miller_discography), we
can see that Faces was actually released as a mixtape back in 2014, much
earlier than the variable from Spotify’s data would suggest. Since this
project involves analyzing how Mac’s music changed throughout the
duration of his career, it is important to have accurate ordering of
dates associated with the albums.

#### Webscraping

To remedy this, we can use some quick web scraping to pull the release
dates from the wiki page and amend the data.

``` r
# run install.packages('rvest') if you don't have this package already
library(rvest)
url <- "https://en.wikipedia.org/wiki/Mac_Miller_discography"
wp <- read_html(url)
rel_dates <- html_nodes(
  wp, "th i , .plainrowheaders th+ td li:nth-child(1) , th i a") %>%
  html_text()
```

Now, the above code may look a little intimidating if you are new to
webscraping. That’s okay, it looks much scarier than it really is. The
`read_html()` function simply reads the page’s html code and stores it
as a list in your R environment. Then, we need to tell R what parts of
the webpage we want extracted. To do this, I used the
[SelectorGadget](https://chrome.google.com/webstore/detail/selectorgadget/mhjhnkcfbdhnjickkkdbjoemdmbfginb?hl=en)
extension for Chrome. Using the tool makes webscraping very simple, you
just highlight the elements you wish to capture and the tool will give
you the CSS selector for it. That is how the arguments you see in the
`html_nodes()` function were found. Once you’ve identified the nodes,
pass the results to the `html_text()` function and voila! You know have
text from a website stored right in your R environment.

Let’s check out what our scraping resulted in:

``` r
head(rel_dates, 20)
```

    ##  [1] "Blue Slide Park"                    "Blue Slide Park"                   
    ##  [3] "Released: November 8, 2011[16]"     "Watching Movies with the Sound Off"
    ##  [5] "Watching Movies with the Sound Off" "Released: June 18, 2013[20]"       
    ##  [7] "GO:OD AM"                           "GO:OD AM"                          
    ##  [9] "Released: September 18, 2015[22]"   "The Divine Feminine"               
    ## [11] "The Divine Feminine"                "Released: September 16, 2016[24]"  
    ## [13] "Swimming"                           "Swimming"                          
    ## [15] "Released: August 3, 2018[26]"       "Circles"                           
    ## [17] "Circles"                            "Released: January 17, 2020[31]"    
    ## [19] "Live from Space"                    "Live from Space"

#### Cleaning the scraped data

While that looks pretty good, you can see that the album titles are
listed twice, and the release dates could be formatted a little nicer.
Let’s fix that up to a nicer format.

``` r
# Remove duplicates and format into dataframe for manipulation
rel_dates <- matrix(
  unique(rel_dates), ncol = 2, byrow = T) %>%
  as.data.frame()

# Filter out any works that aren't hosted on Spotify
rel_dates <- rel_dates %>% filter(
  V1 %>% tolower() %in% (unique(mm_data$album_name) %>% 
                    gsub("( \\().*", "", .) %>%
                    tolower()))

# Cleaning date text
rel_dates$V2 <- gsub("(?:Released: )", "", rel_dates$V2)
rel_dates$V2 <- gsub(".{4}$", "", rel_dates$V2)

# Converts textual dates to date type object
rel_dates$V2 <- lubridate::parse_date_time(
  rel_dates$V2, orders = "mdy") %>%
  lubridate::as_date()

# Check results to ensure they look as expected
print(rel_dates)
```

    ##                                    V1         V2
    ## 1                     Blue Slide Park 2011-11-08
    ## 2  Watching Movies with the Sound Off 2013-06-18
    ## 3                            GO:OD AM 2015-09-18
    ## 4                 The Divine Feminine 2016-09-16
    ## 5                            Swimming 2018-08-03
    ## 6                             Circles 2020-01-17
    ## 7                     Live from Space 2013-12-17
    ## 8                            K.I.D.S. 2010-08-13
    ## 9                       Best Day Ever 2011-03-11
    ## 10                          Macadelic 2012-03-23
    ## 11                              Faces 2014-05-11

#### Prepping for Merge

Now our release dates are in a more workable format. However, before we
merge the two datasets, let’s first take one more look at the album
names in our main dataframe, `mm_data`.

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

We see from this readout that many albums contain multiple editions,
such as Deluxe releases, remasters, or commentary bonuses. To prevent
our analysis from being biased towards those repeated works, we should
selectively filter out albums that are listed multiple times. Firstly,
the commentary version of Blue Slide Park will be omitted. Next, for any
album that has a deluxe release, we will keep only the deluxe release,
dropping the original album from the dataset. Lastly, we will rename
*Best Day Ever (5th Anniversary Remastered Edition)* and *Macadelic
(Remastered Edition)*. This will help us when merging the datasets.

``` r
# Shortening 'Best Day Ever' album name for merging
mm_data$album_name[
  mm_data$album_name == 
  "Best Day Ever (5th Anniversary Remastered Edition)"] = "Best Day Ever"

# Dropping '(Remastered Edition)' from Macadelic
mm_data$album_name[
  mm_data$album_name == 
  "Macadelic (Remastered Edition)"] = "Macadelic"

# Drop any non-deluxe editions of albums that have deluxe editions
# Note that Blue Slide Park's additional versions were also dropped
# Live From London was dropped as it only included already present songs
mm_data <- filter(mm_data, !(album_name %in% c(
  "Circles", 
  "Watching Movies with the Sound Off", 
  "K.I.D.S.",
  "Mac Miller : Live From London (With The Internet)",
  "Blue Slide Park (Commentary Version)",
  "Blue Slide Park (Edited Version)")))

# Adding " (Deluxe)" onto album names in true release date set for merging
for(i in c(2, 6, 8)){
  if(i == 2){
    rel_dates$V1[i] = str_c(rel_dates$V1[i], " (Deluxe Edition)")}
  else
    rel_dates$V1[i] = str_c(rel_dates$V1[i], " (Deluxe)")}

# Adjusting Capitalization of "Live from Space" to match mm_data$album_name
rel_dates$V1[rel_dates$V1 == "Live from Space"] = "Live From Space"
```

#### Merging the Data

Now that our extra versions have been dropped from the data, we can
finally merge our two datasets to attach the accurate release dates.

``` r
# Performing the merge of the two datasets
mm_data <- left_join(mm_data, rel_dates,
                     by = c("album_name" = "V1"))
mm_data <- mm_data %>% rename("true_rel_date" = "V2")
```

With the merge complete, let’s take a look at the differences between
the original `album_release_date` column and our new `true_rel_date`
column.

``` r
select(mm_data, album_release_date, album_name, true_rel_date) %>%
  unique()
```

|     | album_release_date | album_name                                          | true_rel_date |
|:----|:-------------------|:----------------------------------------------------|:--------------|
| 1   | 2021-10-15         | Faces                                               | 2014-05-11    |
| 26  | 2020-03-19         | Circles (Deluxe)                                    | 2020-01-17    |
| 40  | 2018-08-03         | Swimming                                            | 2018-08-03    |
| 53  | 2016-09-16         | The Divine Feminine                                 | 2016-09-16    |
| 73  | 2016-06-03         | Best Day Ever                                       | 2011-03-11    |
| 89  | 2015-09-18         | <GO:OD> AM                                          | 2015-09-18    |
| 123 | 2013-12-17         | Live From Space                                     | 2013-12-17    |
| 137 | 2013-06-18         | Watching Movies with the Sound Off (Deluxe Edition) | 2013-06-18    |
| 156 | 2012-03-23         | Macadelic                                           | 2012-03-23    |
| 173 | 2011-11-08         | Blue Slide Park                                     | 2011-11-08    |
| 189 | 2010-08-13         | K.I.D.S. (Deluxe)                                   | 2010-08-13    |
