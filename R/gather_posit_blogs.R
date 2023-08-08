# gather posit blogs
gather_posit_blogs = function(days) {
  
  # https://community.rstudio.com/t/how-to-follow-the-posit-blog-using-rss-feed/158416
  posit_blogs = c('https://posit.co/feed', # Posit blog
                  'https://www.tidyverse.org/blog/index.xml', # Tidyverse blog
                  'https://blogs.rstudio.com/ai/index.xml', # AI blog
                  'https://rviews.rstudio.com/index.xml', # R Views
                  'https://shiny.rstudio.com/feed/blog.xml' # Shiny blog
                  )
  
  # RSS feed aggregation & cleaning ----
  get_rss_feed <- function(i) {
    rss_line <<- i
    # check for a successful GET
    if(httr::GET(i)$status == 200) {
      df = tidyfeed(i)
    }
  }
  
  rss_feed = 
    lapply(posit_blogs, get_rss_feed) %>%
    bind_rows() |>
    mutate(feed_title = case_when(
      str_detect(feed_title, 'Tidyverse') ~ 'Tidyverse',
      str_detect(feed_title, 'AI Blog') ~ 'AI Blog',
      TRUE ~ feed_title
    )) |>
    transmute(blog = feed_title,
              blog_name = feed_title,
              blog_link = feed_link,
              title = item_title,
              link = item_link,
              summary = item_description,
              date = as.character(as.Date(item_pub_date)),
              author = NA,
              image = NA
              )
  
  if(!'blog' %in% names(rss_feed)) {rss_feed$blog = NA_character_}
  if(!'blog_link' %in% names(rss_feed)) {rss_feed$blog_link = NA_character_}
  if(!'title' %in% names(rss_feed)) {rss_feed$title = NA_character_}
  if(!'link' %in% names(rss_feed)) {rss_feed$link = NA_character_}
  if(!'summary' %in% names(rss_feed)) {rss_feed$summary = NA_character_}
  if(!'date' %in% names(rss_feed)) {rss_feed$date = NA_character_}
  
  # gather and filter to those from yesterday
  blogs = rss_feed %>%
    mutate(date = str_replace_all(date, '/', '-')) %>%
    filter(date >= today() - ddays({{days}}))
  
  
  # final cleanup ----
  if(nrow(blogs) > 0) {
    
    # clean up 'item_description' (from Tidyverse blog) and truncate characters
    blogs = blogs |>
      rowwise() |>
      mutate(summary = str_replace(summary, 
                                   '#quarto-content>\\* \\{  padding-top: 0px;  \\}',
                                   ''),
             summary = str_squish(summary)
             ) |>
      mutate(begin = str_locate(summary, '-->')) |>
      mutate(begin = ifelse(is.na(begin), 1, begin + 3)) |>
      mutate(descr = substr(summary, begin, nchar(summary))) |>
      ungroup() |>
      mutate(descr = ifelse(nchar(summary) > nchar(descr),
                            paste(descr, ' ...'),
                            descr)) |>
      mutate(summary = descr) |>
      select(-descr, -begin) |>
      arrange(desc(date))
    
    blogs
    
  }
  
  
}
