# gather appsilon blogs
gather_appsilon_blogs = function(days) {
  
  # function to scrape blogs
  gather_blogs = function() {
    
    site = 'https://appsilon.com/blog/'
    
    blog = left_join(
      # blog titles
      read_html(site) |>
        html_nodes('a:nth-child(2) .ArticleThumbnail-module--title--j9lsg') |>
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
      ) |>
      
      # bind on summary and image
      bind_cols(
        
        # summary
        read_html(site) |>
          html_nodes('.ArticleThumbnail-module--excerpt--cUknh') |>
          xml2::as_list() |>
          unlist() |>
          as.data.frame() |>
          rename_at(1, ~paste('summary')) |>
          mutate(summary = str_squish(summary)) |>
          mutate(summary = str_replace(summary, '\n', '')),
        
        # image link
        read_html(site) |> 
          html_nodes('.BlogArchive-module--article--LBkYy .ArticleThumbnail-module--thumbnail--21F8t img , .ArticleThumbnail-module--xlarge--atty2 .ArticleThumbnail-module--thumbnail--21F8t img') |> 
          html_attr('src') |> 
          as.data.frame() |>
          rename_at(1, ~paste0('image')) |> 
          filter(row_number() %% 3 == 0) |>
          mutate(image = paste0('https://appsilon.com', image))
        
        ) |>
      mutate(blog = 'appsilon blog') |>
      select(date, blog, author, everything())
    
  }
  
  # gather and filter to those from yesterday
  blogs = gather_blogs() |>
    mutate(date = str_replace_all(date, '/', '-')) |>
    filter(date >= today() - ddays({{days}}))
  
  blogs |> arrange(desc(date))
  
}