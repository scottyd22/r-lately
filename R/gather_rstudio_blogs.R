# gather rstudio blogs
gather_rstudio_blogs = function(days) {
  
  # function to scrape blogs
  gather_blogs = function() {
    
    # RStudio Blog ----
    # site = 'https://blog.rstudio.com'
    # 
    # rstudio_blog = bind_cols(
    #   # blog titles
    #   read_html(site) |>
    #     html_nodes('.cards h5, .h4') |>
    #     xml2::as_list() |>
    #     unlist() |>
    #     as.data.frame() |>
    #     rename_at(1, ~paste('title')) |>
    #     mutate(title = str_squish(title)),
    #   
    #   # blog links
    #   read_html(site) |>
    #     html_nodes('.cards a, .card-blog a') |>
    #     html_attrs() |>
    #     unlist() |>
    #     as.data.frame() |>
    #     rename_at(1, ~paste('link')),
    #   
    #   # summary
    #   read_html(site) |>
    #     html_nodes('.cards p, .card-description') |>
    #     html_text() |>
    #     as.data.frame() |>
    #     rename_at(1, ~paste('summary')) |>
    #     mutate(summary = str_squish(summary)) |>
    #     mutate(summary = str_replace(summary, '\n', '')) |>
    #     mutate(summary = str_replace(summary, ' Read more ', '')) |>
    #     filter(summary != '' & summary != 'Latest'),
    #   
    #   # date
    #   read_html(site) |>
    #     html_nodes('.card-meta div:nth-child(1)') |>
    #     xml2::as_list() |>
    #     unlist() |>
    #     as.data.frame() |>
    #     rename_at(1, ~paste('date')) |>
    #     mutate(date = str_squish(date)) |>
    #     # translate to date format
    #     mutate(month_abb = substr(date,1,3)) |>
    #     left_join(
    #       tibble(month_abb = month.abb,
    #              month = seq(1,12,1))
    #     ) |>
    #     mutate(month = ifelse(nchar(month) == 1, paste0('0', month), month)) |>
    #     mutate(day = str_squish(substr(date, nchar(date) - 1, nchar(date))),
    #            day = ifelse(nchar(day) == 1, paste0('0', day), day)
    #     ) |>
    #     # if today is Jan - Mar and month scraped is Sep or later, set to prior year; else take current year
    #     mutate(year = ifelse(month(today()) %in% c(1,2,3) & as.numeric(month) >= 9, 
    #                          year(today()) - 1, 
    #                          year(today())
    #     )
    #     ) |>
    #     mutate(date = paste0(year, '-', month, '-', day)) |>
    #     select(date),
    #   
    #   # author
    #   read_html(site) |>
    #     html_nodes('.cards h6, .pt-3 .text-prim') |>
    #     xml2::as_list() |>
    #     unlist() |>
    #     as.data.frame() |>
    #     rename_at(1, ~paste('author')) |>
    #     mutate(author = str_squish(author)),
    #   
    #   # image link
    #   read_html(site) |>
    #     html_nodes('.card-image img, .cards img') |>
    #     html_attrs() |>
    #     unlist() |>
    #     data.frame() |>
    #     rename_at(1, ~paste0('image')) |>
    #     filter(row_number() %% 3 == 2L)
    #   
    # ) |>
    #   mutate(blog = 'rstudio blog') |>
    #   select(date, blog, author, everything())
    
    
    # RStudio R Views ----
    site = 'https://rviews.rstudio.com'
    
    r_views = bind_cols(
      # title
      read_html(site) |>
        html_nodes('a h1') |>
        xml2::as_list() |>
        unlist() |>
        as.data.frame() |>
        rename_at(1, ~paste('title')) |>
        mutate(title = str_squish(title)),
      
      # link
      read_html(site) |>
        html_nodes('.article-more-link a') |>
        html_attrs() |>
        unlist() |>
        as.data.frame() |>
        rename_at(1, ~paste('link')) |>
        mutate(link = paste0(site, link)),
      
      # summary
      read_html(site) |>
        html_nodes('.article-entry') |>
        html_text2() |>
        as.data.frame() |>
        rename_at(1, ~paste('summary')) |>
        mutate(summary = str_squish(summary)) |>
        mutate(summary = str_replace(summary, '\n', '')) |>
        mutate(summary = str_replace(summary, ' Read more', '')) |>
        filter(summary != ''),
      
      # author, date
      read_html(site) |>
        html_nodes('.article-meta div') |>
        xml2::as_list() |>
        unlist() |>
        as.data.frame() |>
        rename_at(1, ~paste('author')) |>
        mutate(author = str_squish(author)) |>
        filter(author != '') |>
        mutate(date = lead(author, 1)) |>
        filter(row_number() %% 2 == 1) 
    ) |>
      mutate(blog = 'r views') |>
      select(date, blog, author, everything()) |>
      mutate(image = NA)
    
    # RStudio Tidyverse Blog ----
    site = 'https://www.tidyverse.org/articles'
    
    tidyverse_blog = bind_cols(
      # title
      read_html(site) |>
        html_nodes('.itemTitle a') |>
        xml2::as_list() |>
        unlist() |>
        as.data.frame() |>
        rename_at(1, ~paste('title')) |>
        mutate(title = str_squish(title)),
      
      # link
      read_html(site) |>
        html_nodes('.itemTitle a') |>
        html_attrs() |>
        unlist() |>
        as.data.frame() |>
        rename_at(1, ~paste('link')) |>
        mutate(link = paste0(site, link)),
      
      # summary
      read_html(site) |>
        html_nodes('.itemDescription') |>
        html_text2() |>
        as.data.frame() |>
        rename_at(1, ~paste('summary')) |>
        mutate(summary = str_squish(summary)) |>
        mutate(summary = str_replace(summary, '\n', '')) |>
        mutate(summary = str_replace(summary, ' Read more ...', '')) |>
        filter(summary != ''),
      
      # author, date
      read_html(site) |>
        html_nodes('.author, .created') |>
        xml2::as_list() |>
        unlist() |>
        as.data.frame() |>
        rename_at(1, ~paste('author')) |>
        mutate(author = str_squish(author)) |>
        filter(author != '') |>
        mutate(date = lead(author, 1)) |>
        filter(row_number() %% 2 == 1),
      
      # image link
      read_html(site) |>
        html_nodes('img') |>
        html_attrs() |>
        unlist() |>
        data.frame() |>
        rename_at(1, ~paste0('image'))
    ) |>
      mutate(blog = 'tidyverse blog') |>
      select(date, author, everything())
    
    # output
    bind_rows(r_views, 
              # rstudio_blog, 
              tidyverse_blog)
    
  }
  
  # gather and filter to those from yesterday
  blogs = gather_blogs() |>
    mutate(date = str_replace_all(date, '/', '-')) |>
    filter(date >= today() - ddays({{days}}))
  
  # clean up '/articles' path (from Tidyverse blog)
  blogs$link = str_replace(blogs$link, '/articles', '')
  
  
  blogs |> 
    arrange(desc(date))
  
}