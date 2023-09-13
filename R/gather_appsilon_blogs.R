# gather appsilon blogs
gather_appsilon_blogs = function(days) {
  
  # function to scrape blogs
  gather_blogs = function() {
    
    site = 'https://appsilon.com/blog/'
    
    blog_data = left_join(
      # blog titles
      read_html(site) |>
        html_nodes('.ArticleThumbnail-module--title--j9lsg') |>
        xml2::as_list() |>
        unlist() |>
        as.data.frame() |>
        rename_at(1, ~paste('title')) |>
        mutate(title = str_squish(title)),
      
      # links, authors, and dates pick up extra rows, so need to join
      bind_cols(
        # title
        read_html(site) |>
          html_nodes('.ArticleThumbnail-module--title--j9lsg') |>
          xml2::as_list() |>
          unlist() |>
          as.data.frame() |>
          rename_at(1, ~paste('title')) |>
          mutate(title = str_squish(title)),
        # link
        read_html(site) |>
          html_nodes('.ArticleThumbnail-module--thumbnail--21F8t') |>
          html_attr('href') |>
          unlist() |>
          as.data.frame() |>
          rename_at(1, ~paste('link')) |>
          mutate(link = paste0('https://appsilon.com', link)),
        # author
        read_html(site) |>
          html_nodes('.UserCard-module--linkName--ElcHI') |>
          xml2::as_list() |>
          unlist() |>
          as.data.frame() |>
          rename_at(1, ~paste('author')) |>
          mutate(author = str_squish(author)),
        
        # date
        read_html(site) |>
          html_nodes('.ArticleThumbnail-module--date--\\+0dfZ') |>
          xml2::as_list() |>
          unlist() |>
          as.data.frame() |>
          rename_at(1, ~paste('date')) |>
          mutate(date = str_squish(date)) |>
          # translate to date format
          mutate(day = substr(date,1,2),
                 year = substr(date, nchar(date)-3, nchar(date)),
                 month_abb = substr(date,4,6)
          ) |>
          left_join(
            tibble(month_abb = month.abb,
                   month = seq(1,12,1))
          ) |>
          mutate(month = ifelse(nchar(month) == 1, paste0('0', month), month)) |>
          mutate(date = paste0(year, '-', month, '-', day)) |>
          select(date)
        
      )
    ) 
    # summary
    blog_summary = read_html(site) |>
      html_nodes('.ArticleThumbnail-module--excerpt--cUknh , .ArticleThumbnail-module--title--j9lsg') |>
      xml2::as_list() |>
      unlist() |>
      as.data.frame() |>
      rename_at(1, ~paste('title')) |>
      mutate(title = str_squish(title)) |>
      mutate(title = str_replace(title, '\n', ''))
    
    blog_summary = blog_summary |>
      mutate(check = ifelse(title %in% blog_data$title, 1, 0)) |>
      mutate(summary = case_when(
        row_number() == 1L ~ lead(title),
        check == 1 & lead(check) == 1 ~ ' ',
        check == 1 ~ lead(title)
      )) |>
      filter(check == 1) |>
      select(-check)
    
    
    # image link
    blog_image = read_html(site) |> 
      html_nodes('.BlogArchive-module--article--LBkYy .ArticleThumbnail-module--thumbnail--21F8t img , .ArticleThumbnail-module--xlarge--atty2 .ArticleThumbnail-module--thumbnail--21F8t img') |>
      html_attr('src') |>
      as.data.frame() |>
      rename_at(1, ~paste0('image')) |> 
      filter(row_number() %% 3 == 0) |>
      mutate(image = paste0('https://appsilon.com', image))
    
    
    # combine
    blogs = left_join(blog_data, blog_summary)
    
    if(nrow(blog_image) == nrow(blog_summary)) {
      blogs = left_join(blogs, blog_image)
    } else {
      blogs = blogs |> mutate(image = NA)
    }
    
    blogs |>
      mutate(blog = 'appsilon blog') |>
      select(date, blog, author, everything())
    
  }
  
  # gather and filter to those from yesterday
  blogs = gather_blogs() |>
    mutate(date = str_replace_all(date, '/', '-')) |>
    filter(date >= today() - ddays({{days}}))
  
  blogs |> arrange(desc(date))
  
}
