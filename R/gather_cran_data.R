# gather CRAN data
gather_cran_data = function(days) {
  
  # get cran data ----
  events = pkgsearch::cran_events(limit = 300, releases = T)
  
  # function to extract key components
  get_cran_data = function(i) {
    
    bind_rows(
      # empty frame to ensure any missing elements produce an NA
      tibble(date = NA_character_,
             event = NA_character_,
             package = NA_character_,
             version = NA_character_,
             description = NA_character_,
             url = NA_character_,
             cran = NA_character_
      ),
      
      tibble(date = substr(events[[i]]$date,1,10),
             event = events[[i]]$event,
             package = events[[i]]$package$Package,
             version = events[[i]]$package$Version,
             description = events[[i]]$package$Description,
             url = events[[i]]$package$URL) %>%
        mutate(cran = paste0('https://cran.r-project.org/web/packages/', package, '/index.html'))
      
    ) %>%
      filter(!is.na(package))
    
  }
  
  # filter to released packages as of yesterday (that are already installed)
  df = lapply(1:length(events), get_cran_data) %>%
    bind_rows() %>%
    filter(date >= today() - days) %>%
    filter(event == 'released') %>%
    mutate(description = str_replace_all(description, '<', ''),
           description = str_replace_all(description, '>', '')
    ) %>%
    
    # split url on commas
    rowwise() %>%
    mutate(comma = str_locate(url,',')) %>%
    mutate(url = ifelse(is.na(comma), url, substr(url,1,(comma - 1)))) %>%
    mutate(url = first(url)) %>%
    ungroup() %>%
    
    # split url on spaces
    rowwise() %>%
    mutate(space = str_locate(url,' ')) %>%
    mutate(url = ifelse(is.na(space), url, substr(url,1,(space - 1)))) %>%
    mutate(url = first(url)) %>%
    ungroup() %>%
    
    mutate(url = str_replace(url, '<',''),
           url = str_replace(url, '>',''),
    ) %>%
    mutate(pkg_check = paste(package, version)) %>%
    arrange(desc(date), package) %>%
    mutate(link = ifelse(is.na(url), cran, url)) %>%
    mutate(description = paste0(pkg_check, '\n', description)) %>%
    select(date, package, link, description) %>%
    # alter special characters
    mutate(description = str_replace_all(description, '\\"', '\'')) %>%
    group_by(date) %>%
    mutate(label = paste0('<a href="', link, '" 
                          title="', description, '" 
                          target="_blank">
                          <code> ', 
                          package, 
                          ' </code></a>' )
    ) %>%
    ungroup() %>%
    distinct(date, label)
  
  df
}

