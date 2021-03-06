---
title: "Spotify Data EDA"
author: "Collin Smith"
date: "7/6/2022"
---

Welcome! If you haven't yet read section one of this series, I'd highly
recommend you begin there before reading this section. If you've already done
so, welcome back! In this section we will cover the EDA of the data collected,
and use visualizations to get some information out of our data. In the next
section, we'll use what we learned here to apply a clustering algorithm to
the dataset and see if any interesting patterns emerge in the results.




To begin, let's read in our dataframe that we saved at the end of section one.


```r
df <- read_csv("working-data.csv", show_col_types = F)
```


# Exploratory Data Analysis (EDA)

With the data sorted and filtered to only include relevant variables, we are
now ready to begin using statistical summaries and creating visualizations
to glean insights from. We will be exploring the data to discover patterns, 
identify anomalies (or outliers), and to make some informed observations that
will help us to better understand the dataset.

## Statistical Summary

We'll start our analysis by looking at a basic statistical summary of the
quantitative variables in our dataset. We can easily find what variables to 
include by using a `select()` statement.


```r
df %>% 
  select(where(is.numeric)) %>%
  summary()
```

```
##   acousticness       danceability        energy       instrumentalness  
##  Min.   :0.000283   Min.   :0.1410   Min.   :0.0316   Min.   :0.000000  
##  1st Qu.:0.062250   1st Qu.:0.5070   1st Qu.:0.5355   1st Qu.:0.000000  
##  Median :0.200000   Median :0.6130   Median :0.6700   Median :0.000000  
##  Mean   :0.316191   Mean   :0.6031   Mean   :0.6441   Mean   :0.013541  
##  3rd Qu.:0.539500   3rd Qu.:0.7075   3rd Qu.:0.7845   3rd Qu.:0.000269  
##  Max.   :0.981000   Max.   :0.8750   Max.   :0.9640   Max.   :0.486000  
##     liveness         loudness        speechiness        valence      
##  Min.   :0.0593   Min.   :-25.426   Min.   :0.0261   Min.   :0.0546  
##  1st Qu.:0.1110   1st Qu.: -8.411   1st Qu.:0.0946   1st Qu.:0.2520  
##  Median :0.1840   Median : -6.687   Median :0.1730   Median :0.3860  
##  Mean   :0.2645   Mean   : -7.278   Mean   :0.2053   Mean   :0.4124  
##  3rd Qu.:0.3490   3rd Qu.: -5.392   3rd Qu.:0.2980   3rd Qu.:0.5550  
##  Max.   :0.9760   Max.   : -2.527   Max.   :0.6410   Max.   :0.9430  
##   duration_ms          key              mode            tempo       
##  Min.   : 26882   Min.   : 0.000   Min.   :0.0000   Min.   : 57.75  
##  1st Qu.:177096   1st Qu.: 1.000   1st Qu.:0.0000   1st Qu.: 89.50  
##  Median :213772   Median : 5.000   Median :1.0000   Median :119.97  
##  Mean   :228138   Mean   : 4.804   Mean   :0.6034   Mean   :119.52  
##  3rd Qu.:271508   3rd Qu.: 8.000   3rd Qu.:1.0000   3rd Qu.:146.50  
##  Max.   :500960   Max.   :11.000   Max.   :1.0000   Max.   :191.92  
##  time_signature 
##  Min.   :1.000  
##  1st Qu.:4.000  
##  Median :4.000  
##  Mean   :3.955  
##  3rd Qu.:4.000  
##  Max.   :5.000
```

These values tell us some great cursory information about the data.

**Some observations:**

* **acousticness** has the widest range of all Spotify's metrics, but the mean
and 3rd quartile suggest the max may be an anomaly
* **danceability** and **energy** have relatively similar summaries, suggesting
possible correlation between the two. Values tend to trend upwards, indicating
the minimum value in both of these variables may be outliers (potentially even
the same track? worth investigating)
* **instrumentalness** doesn't contain any values > 0.5, Spotify's threshold 
intended to represent instrumental tracks, as per their documentation linked
above. This suggests the discography does not contain any purely instrumental
tracks
* **liveness** having a max of `0.976` suggests Spotify is 
confident that at least one track was performed live (documentation lists 0.8
as the likelihood threshold). This max is very far from the rest of the measures
for **liveness**, indicating a likely outlier
* **loudness**, measured in decibels (dB) also has a relatively wide range, 
with all values < 0. Spotify lists typical range as falling between -60 and 0, 
suggesting Mac's music trends towards the upper side of this traditional range
* **speechiness** tends to be lower than Spotify's typical value range for rap
music (0.33 - 0.66 as per documentation). This suggests Mac's tracks have more
sections that do not contain vocals in them. Investigating this on a per-album
basis could yield interesting findings
* **valence** sees a wide range of values, with the mean and median falling just
under the halfway point between the min and max. However, the 3rd quartile value
tells us that the max value is likely an anomaly
* **duration_ms** seems to hold a rather tight distribution for the most part, 
with both the min and the max values seemingly pretty distant from the typical
values in the variable
* **tempo** holds some surprising values. The mean and median suggest that ~120
is Mac's typical tempo, which is higher than the 
[average hip-hop tempo range](https://www.izotope.com/en/learn/using-different-tempos-to-make-beats-for-different-genres.html).
The linked source offers that typically, the higher the beats per minute (BPM),
or tempo, the more energy and uplifting a track is. Knowing this, it would be 
interesting to investigate the relationship between **tempo**, **energy**,
**valence**, and **danceability**. I'd expect, at the very least, a weak 
positive correlation between all those variables

## Visualizations

### Per Album Plots

This section will focus on some simple but important plots, mostly involving 
counts and frequencies of measures. This will give a good overview of our data 
at a high level before we delve into specifics and multivariate interactions.


```r
album_palette = c(
  "K.I.D.S. (Deluxe)" = "#387228",
  "Best Day Ever" = "#C315AA",
  "Blue Slide Park" = "#3540F2",
  "Macadelic" = "#767092",
  "Watching Movies with the Sound Off (Deluxe Edition)" = "#DA252A",
  "Live From Space" = "#FE675C",
  "Faces" = "#FDBB1E",
  "GO:OD AM" = "#A2A2A2",
  "The Divine Feminine" = "#DDC1BE",
  "Swimming" = "#668099",
  "Circles (Deluxe)" = "#464646"
  )

df %>% 
  group_by(
    album_name,
    album_release_date) %>%
  tally() %>%
  ggplot(
    aes(x = stringr::str_wrap(album_name, 9) %>% reorder(album_release_date), 
        y = n,
        fill = album_name)) +
  geom_col() +
  geom_text(aes(label = n), 
            vjust = -0.2, 
            size = 3.5) +
  scale_y_continuous(limits = c(0, 26)) +
  labs(x = "", 
       y = "",
       title = "Tracks Per Mac Miller Album",
       subtitle = "Ordered by Release Date") +
  scale_fill_manual(values = album_palette) +
  theme(legend.position = "none")
```

<img src="mm-eda_files/figure-html/album-track-counts-1.png" style="display: block; margin: auto;" />

From this plot we can see that Mac's earlier albums tended to have a couple
more songs than his later releases, with *Faces* being the outlier of the
discography as a whole. This could partly be due to *Faces* originally being
released as a mixtape rather than a formal album, so perhaps it did not go
through the same revision processes that an album might see before release.

#### Duration {.tabset .tabset-fade}

Let's also take a look at track duration trends for each album, as well as each
album's total runtime.

##### Overview


```r
df %>%
  group_by(album_name) %>%
  ggplot(aes(
    x = stringr::str_wrap(album_name, 9) %>% reorder(album_release_date),
    y = duration_ms,
    fill = album_name)) +
  geom_boxplot() +
  geom_point(alpha = 0.4, shape = "diamond") +
  labs(x = "",
       y = "Track Duration (ms)",
       title = "Track Duration by Album") +
  scale_fill_manual(values = album_palette) +
  theme(legend.position = "none")
```

<img src="mm-eda_files/figure-html/track-duration-by-album-1.png" style="display: block; margin: auto;" />

This plot tells us that even though they typically had fewer tracks on them, 
Mac's later albums contained tracks that, on average, were longer than tracks on
earlier albums. This can almost be thought of as a focus on "quality over
quantity" when it comes to the later albums. Furthermore, the plot shows that
earlier albums had less variation in track duration, while later albums saw
more variety. It is interesting to see how *The Divine Feminine*, the album
with the fewest tracks, not only contains the longest track in the dataset, but
also two tracks that are significantly longer than the rest of the album. This
could very well be an example of careful song selection to help each album
maintain a relatively similar total runtime. We'll examine that below.


```r
df %>%
  group_by(album_name) %>%
  summarise(album_name, 
            runtime = sum(duration_ms), 
            album_release_date,
            .groups = "keep") %>%
  ggplot(aes(
    x = stringr::str_wrap(album_name, 9) %>% reorder(album_release_date),
    y = runtime,
    fill = album_name)) +
  geom_col() +
  labs(x = "",
       y = "Runtime (ms)",
       title = "Total Album Runtimes") +
  scale_fill_manual(values = album_palette) +
  theme(legend.position = "none")
```

<img src="mm-eda_files/figure-html/album-runtimes-1.png" style="display: block; margin: auto;" />

By comparing this plot with the information about each album's number of tracks,
we can see that there is a very clear correlation between number of tracks and
album runtime. For example, even though *K.I.D.S.* has a lower average track
duration than *Swimming*, the total runtime is still longer for *K.I.D.S.*, due
to the difference in track count. Generally, longer albums are subject to a bit
more criticism, as too long of a runtime can start to make the listener become
disinterested if the music doesn't provide enough variation. Knowing this, it
again makes sense that *Faces* has such a higher runtime than any other work, as
it's original release as a mixtape meant that it didn't go through the same
revisions and polishing processes that formal albums do. This runtime plot also
confirms our previous theory of Mac's later albums revolving more around the
substance of each individual track rather than making a longer, less focused 
album. We can also see from the plot that the concept of keeping longer songs
on *The Divine Feminine* does not really appear to have had a substantial 
impact on the album's total runtime, as it is still significantly shorter than
all other works.


```r
album_trends <- df %>%
  group_by(album_name) %>%
  summarise(
    album_name,
    album_release_date,
    average_track_length = mean(duration_ms),
    track_count = n(),
    .groups = "keep") %>%
  ggplot(
    aes(
      x = stringr::str_wrap(album_name, 9) %>% reorder(album_release_date)))

avg_track_len_plot <- album_trends +
  geom_line(aes(y = average_track_length, group = 1)) +
  geom_point(aes(y = average_track_length)) +
  geom_smooth(
    aes(y = average_track_length, group = 1), 
    method = "lm",
    formula = y ~ x,
    alpha = 0.5,
    lty = "dotted",
    se = FALSE) +
  labs(x = "",
       y = "Average Duration (ms)",
       title = "Average Track Duration Trend") +
  scale_y_continuous(
    breaks = c(2e+05, 2.4e+05, 2.8e+05, 3.2e+05),
    labels = c("200K", "240K", "280K", "320K"))

total_tracks_plot <- album_trends +
  geom_line(aes(y = track_count, group = 1)) +
  geom_point(aes(y = track_count)) +
  geom_smooth(
    aes(y = track_count, group = 1), 
    method = "lm",
    formula = y ~ x,
    alpha = 0.5,
    lty = "dotted",
    se = FALSE) +
  labs(x = "",
       y = "Tracks Per Album",
       title = "Tracks per Album Trend")

avg_track_len_plot
total_tracks_plot
```

<img src="mm-eda_files/figure-html/album-trends-1.png" style="display: block; margin: auto;" /><img src="mm-eda_files/figure-html/album-trends-2.png" style="display: block; margin: auto;" />

While not too severe, these plots reveal that over the course of his career,
Mac's albums tended to contain less songs, but those songs were of longer
duration.

##### Album-Specific


```r
album_names <- arrange(df, df$album_release_date) %>% 
  .$album_name %>% 
  unique()

figures = list()

for(i in album_names){
  
  figures[[i]] <- df %>%
    filter(album_name == i) %>%
    ggplot(
      aes(x = reorder(fct_inorder(track_name), desc(fct_inorder(track_name))), 
          y = duration_ms, fill = i)) +
    geom_col() +
    labs(x = "",
         y = "Track Duration (ms)",
         title = i) +
    scale_y_continuous(limits = c(0, 5.5e+05)) +
    coord_flip() +
    #ggthemes::theme_clean() +
    scale_fill_manual(values = album_palette) +
    theme(legend.position = "none",
          plot.title.position = "plot")
  
}

aligned_figs <- cowplot::align_plots(plotlist = figures, align = "v")

lapply(aligned_figs, function(x) {cowplot::ggdraw(x)})
```

<img src="mm-eda_files/figure-html/track-durations-by-album-1.png" style="display: block; margin: auto;" /><img src="mm-eda_files/figure-html/track-durations-by-album-2.png" style="display: block; margin: auto;" /><img src="mm-eda_files/figure-html/track-durations-by-album-3.png" style="display: block; margin: auto;" /><img src="mm-eda_files/figure-html/track-durations-by-album-4.png" style="display: block; margin: auto;" /><img src="mm-eda_files/figure-html/track-durations-by-album-5.png" style="display: block; margin: auto;" /><img src="mm-eda_files/figure-html/track-durations-by-album-6.png" style="display: block; margin: auto;" /><img src="mm-eda_files/figure-html/track-durations-by-album-7.png" style="display: block; margin: auto;" /><img src="mm-eda_files/figure-html/track-durations-by-album-8.png" style="display: block; margin: auto;" /><img src="mm-eda_files/figure-html/track-durations-by-album-9.png" style="display: block; margin: auto;" /><img src="mm-eda_files/figure-html/track-durations-by-album-10.png" style="display: block; margin: auto;" /><img src="mm-eda_files/figure-html/track-durations-by-album-11.png" style="display: block; margin: auto;" />

#### Explicitness

Let's take a quick look at the proportion of explicit and non-explicit (clean)
tracks on each album.


```r
exp_plot <- df %>%
  group_by(album_name, 
           album_release_date) %>%
  count(explicit) %>%
  ggplot(
    aes(x = stringr::str_wrap(album_name, 9) %>% reorder(album_release_date),
        y = n,
        fill = explicit)) + 
  geom_col(position = "fill", 
           color = "black", 
           alpha = 0.8, 
           width = 0.95) +
  labs(x = "",
       y = "",
       title = "Proportion of Explicit Tracks",
       subtitle = "Per Album, ordered by Release Date",
       fill = "Explicit") +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = c("FALSE" = "lightgreen", 
                               "TRUE" = "coral")) +
  theme(legend.position = c(0.725, 1.1),
        legend.direction = "horizontal",
        legend.box.background = element_rect(color = "lightgrey"))

exp_table <- df %>%
  group_by(album_name) %>%
  summarise(n_tracks = n(),
            n_explicit = sum(explicit == TRUE),
            prop_explicit = round(n_explicit / n_tracks, 2),
            album_release_date,
            .groups = "keep") %>%
  arrange(album_release_date) %>%
  distinct() %>%
  select("Album Name" = album_name,
         "Track Count" = n_tracks,
         "Explicit Tracks" = n_explicit,
         "Prop. Explicit" = prop_explicit)

exp_plot
```

<img src="mm-eda_files/figure-html/explicit-overview-plot-1.png" style="display: block; margin: auto;" />

```r
exp_table
```

```
## # A tibble: 11 x 4
##    `Album Name`                  `Track Count` `Explicit Trac~` `Prop. Explicit`
##    <chr>                                 <int>            <int>            <dbl>
##  1 K.I.D.S. (Deluxe)                        18               16             0.89
##  2 Best Day Ever                            16               16             1   
##  3 Blue Slide Park                          16               16             1   
##  4 Macadelic                                17               15             0.88
##  5 Watching Movies with the Sou~            19               19             1   
##  6 Live From Space                          14               14             1   
##  7 Faces                                    25               24             0.96
##  8 GO:OD AM                                 17               17             1   
##  9 The Divine Feminine                      10                8             0.8 
## 10 Swimming                                 13               12             0.92
## 11 Circles (Deluxe)                         14                2             0.14
```

Some observations from this plot and table:

* All but one of the albums contained a proportion of explicit tracks >= 0.8
* *Circles*, Mac's last album is the only work that contains more clean
tracks than explicit tracks

#### Acousticness

Per Spotify's 
[documentation](https://developer.spotify.com/documentation/web-api/reference/#/operations/get-several-audio-features),
**acousticness** is "*A confidence measure from 0.0 to 1.0 of whether or not 
the track is acoustic. 1.0 represents high confidence that the track is 
acoustic. According to 
[Wikipedia](https://en.wikipedia.org/wiki/Acoustic_music),
acoustic music is generally thought of as music that primary features
features that produce sound through physical properties, as opposed to electric
or digital amplification (think grand piano versus digital keyboard). 



```r
df %>% 
  group_by(album_name, 
           album_release_date) %>%
  ggplot(
    aes(x = stringr::str_wrap(album_name, 9) %>% reorder(album_release_date),
        y = acousticness,
        fill = album_name)) +
  geom_boxplot() +
  labs(x = "",
       y = "",
       title = "Summary of Acousticness",
       subtitle = "Per Album, ordered by Release Date") +
  theme(legend.position = "none") +
  scale_fill_manual(values = album_palette)

df %>%
  group_by(album_name, album_release_date) %>%
  ggplot(
    aes(y = stringr::str_wrap(album_name, 28) %>% reorder(album_release_date),
        x = acousticness,
        fill = album_name)) +
  ggridges::geom_density_ridges2() +
  labs(x = "",
       y = "",
       title = "Density of Acousticness Measures",
       subtitle = "Per Album") +
  scale_fill_manual(values = album_palette) +
  theme(legend.position = "none")
```

```
## Picking joint bandwidth of 0.12
```

```r
df %>%
  group_by(album_name, 
           album_release_date) %>%
  summarise(avg_acousticness = mean(acousticness)) %>%
  ggplot(aes(x = album_release_date, 
             y = avg_acousticness)) +
  geom_line(color = "lightblue", size = 1.5) +
  geom_point() +
  ggrepel::geom_text_repel(aes(label = album_name), force = ) +
  labs(y = "Acousticness",
       x = "Album Release Year",
       title = "Average Acousticness Per Album",
       subtitle = "Ordered by Release Date")
```

```
## `summarise()` has grouped output by 'album_name'. You can override using the
## `.groups` argument.
```

<img src="mm-eda_files/figure-html/acousticness-explore-1.png" style="display: block; margin: auto;" /><img src="mm-eda_files/figure-html/acousticness-explore-2.png" style="display: block; margin: auto;" /><img src="mm-eda_files/figure-html/acousticness-explore-3.png" style="display: block; margin: auto;" />

From these plots we can see a clear trend of increasing **acousticness** towards
the later works of Mac's career. We can also see greater variation in the 
values of later albums, suggesting the possibility of more distinct sonic 
changes from album to album later in his career.

### Measure Distributions

This section will focus on displaying some simple yet informative information
regarding Spotify's quantitative metrics:

* **acousticness**
* **danceability**
* **energy**
* **instrumentalness**
* **liveness**
* **speechiness**
* **valence**


```r
measures <- c(
  "acousticness",
  "danceability",
  "energy",
  "instrumentalness",
  "liveness",
  "speechiness",
  "valence"
)

df %>%
  select(all_of(measures)) %>%
  gather() %>%
  mutate(key = factor(key)) %>%
  filter(value > 0.1) %>%
  ggplot(aes(x = value, 
             color = key)) +
  geom_density(size = 1.25) +
  labs(x = "Value",
       y = "Density",
       color = "Measure",
       title = "Spotify Measure Density Plot") +
  scale_color_brewer(type = "qual", palette = 7)
```

<img src="mm-eda_files/figure-html/spot-measure-density-1.png" style="display: block; margin: auto;" />

From this plot, we can see that **danceability** and **energy** seem to have
very similar density curves. It is definitely worth investigating if there is
any correlation between those two measures. Additionally, within the code to
construct the plot, you'll notice there is a `filter()` statement to set the
lower limit of the values to 0.1. This was done to exclude the enormous amount
of **instrumentalness** observations that lie between 0 and 0.1, which stretched
the y-axis by far too much for the rest of the density curves to be observed.

### Multivariate Plots

Here we will be investigating some of the questions posed above by looking at
the interaction between specific variables.


```r
df %>%
  select(danceability, energy) %>%
  ggplot(aes(x = danceability,
             y = energy)) +
  geom_point() +
  lims(x = c(0, 1), 
       y = c(0, 1)) +
  labs(x = "Danceability",
       y = "Energy",
       title = "Energy vs. Danceability Scatter Plot")
```

<img src="mm-eda_files/figure-html/danceability-energy-plot-1.png" style="display: block; margin: auto;" />

```r
df %>%
  select(tempo, energy) %>%
  ggplot(aes(x = tempo,
             y = energy)) +
  geom_point() +
  labs(x = "Tempo",
       y = "Energy",
       title = "Does higher Tempo = higher energy?")
```

<img src="mm-eda_files/figure-html/tempo-energy-1.png" style="display: block; margin: auto;" />

From this plot, it appears that there is *not* any strong relationship between
**tempo** and **energy**, as previously theorized.


```r
df %>%
  select(tempo, valence) %>%
  ggplot(aes(x = tempo,
             y = valence)) +
  geom_point() +
  labs(x = "Tempo",
       y = "Energy",
       title = "Does higher Tempo = higher valence?")
```

<img src="mm-eda_files/figure-html/tempo-valence-1.png" style="display: block; margin: auto;" />

The same statement holds true for **tempo** and **valence**. There is no
discernible pattern to be identified here.


```r
df %>%
  select(tempo, danceability) %>%
  ggplot(aes(x = tempo,
             y = danceability)) +
  geom_point() +
  labs(x = "Tempo",
       y = "Energy",
       title = "Does higher Tempo = higher danceability?")
```

<img src="mm-eda_files/figure-html/tempo-danceability-1.png" style="display: block; margin: auto;" />

Once again, no clear pattern is shown, this time between **tempo** and
**danceability**.

### Correlation Plot

To get a better idea of how these variables are connected, if at all, we can
use a correlation plot. These are a great way to invesitgate connectivity 
across variables and understand how they influence each other.


```r
library(corrplot)
```


```r
df_corrs = cor(select(df, where(is.numeric)))
corrplot(df_corrs, method = "square")
```

<img src="mm-eda_files/figure-html/corr-plot-1.png" style="display: block; margin: auto;" />

This is great! We don't have very much correlation at all, which means each
measure provides valuable information about the observation. There are only a
few instances of correlation, such as a negative correlation between 
**loudness**, and **acousticness**, and another negative correlation between
**energy** and **acousticness**. This does sort of make sense - a track that
has a high value for the **acousticness** measure is likely using less
electronic amplification, and as such would probably be a little quieter, and
so would have a lower **loudness** measure. The interaction between **energy**
and **acousticness** is a little more surprising to me, but the best I can
interpret it is that Mac tended to use more acoustic sounds in his more somber,
or laid-back tracks. We also see one positive correlation between **loudness**
and **energy**. Let's take a quick look at a scatter plot of those two variables
to further investigate.


```r
df %>%
  select(energy, loudness) %>%
  ggplot(aes(x = loudness,
             y = energy)) +
  geom_point() +
  labs(x = "Loudness (dB)",
       y = "Energy",
       title = "Energy as a function of Loudness")
```

<img src="mm-eda_files/figure-html/energy-loudness-plot-1.png" style="display: block; margin: auto;" />

Wow! That is a pretty strong correlation for sure. That tight grouping of points
shows that there is a very well-defined relationship between **loudness** and
**energy**. As both of these variables also have a negative correlation with
**acousticness**, we really only need to keep one of them moving forward. By
using the correlation plot from before, we can see that **loudness** has lower
correlations across the board, so we'll keep that going into the next section.


```r
df <- select(df, -energy)
write_csv(df, "section-two-end-df.csv")
```
 
Thanks for reading this section! The third and final section of this project
will revolve around applying a clustering algorithm to this data to see what
kind of groups emerge. I'm hoping to get some clusters that include tracks from
a couple different albums to see if some signatures of Mac's music are
identifiable over his career.
 
