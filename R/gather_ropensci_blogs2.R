# gather posit blogs
gather_ropensci_blogs2 = function(days) {
  
  blogs = c('https://ropensci.org/rbloggers/index.xml')
  
  # RSS feed aggregation & cleaning ----
  get_rss_feed <- function(i) {
    rss_line <<- i
    # check for a successful GET
    if(httr::GET(i)$status == 200) {
      df = tidyfeed(i)
    }
  }
  
  rss_feed = 
    lapply(blogs, get_rss_feed) %>%
    bind_rows() |>
    mutate(feed_title = 'ropensci') |>
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
  
  
  # return output if 1+ rows exist
  if(nrow(blogs) > 0) {blogs}
  
  
}
