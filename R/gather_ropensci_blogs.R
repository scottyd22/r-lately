# gather ropensci blogs
gather_ropensci_blogs = function(days) {
  
  site = 'https://ropensci.org/blog/index.xml'
  
  get_rss_feed <- function(i) {
    # check for a successful GET
    if(httr::GET(i)$status == 200) {
      df = tidyfeed(i)
    }
    
  }
  
  get_rss_feed(site) |>
    select(contains('item_')) |>
    mutate(date = as.Date(item_pub_date),
           blog = 'ropensci blog',
           author = '',
           title = item_title,
           link = item_link,
           summary = item_description,
           image = NA
    ) |>
    select(-contains('item_')) |>
    filter(date >= today() - ddays({{days}})) |>
    arrange(desc(date))
}