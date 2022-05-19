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
authentication. To get started, run the following code:

``` r
Sys.setenv(SPOTIFY_CLIENT_ID = 'your client id')
Sys.setenv(SPOTIFY_CLIENT_SECRET = 'your client secret')
access_token <- get_spotify_access_token()
```