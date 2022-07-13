# generate cran card
generate_cran_card = function(i, cran) {
  bgColor = '#FFFFFF'
  
  # date of interest
  target_date = unique(cran$date)[i]
  
  df = cran |> 
    filter(date == target_date) |>
    select(label)
  
  # break into 3 columns
  n_cols = 3
  rows_per_col = ceiling(nrow(df)/n_cols)
  
  empty_rows_to_add = 0
  if(nrow(df) %% n_cols != 0) {empty_rows_to_add = n_cols - (nrow(df) %% n_cols)}
  
  packages = c(df$label, rep(NA, empty_rows_to_add))
  
  out = tibble(
    col1 = packages[(0 * rows_per_col + 1):(1 * rows_per_col)],
    col2 = packages[(1 * rows_per_col + 1):(2 * rows_per_col)],
    col3 = packages[(2 * rows_per_col + 1):(3 * rows_per_col)]
  )
  
  # generate table (set NA to empty character)
  options(knitr.kable.NA = '')
  
  package_table = kbl(out, 
                      escape = F,
                      align = 'l',
                      col.names = NULL
  ) |>
    kable_paper(full_width = T) |>
    row_spec(1:nrow(out), extra_css = 'border: 1px solid #FFFFFF; family="Source Sans Pro') |>
    scroll_box(height = "250px")
  
  
  # final output
  HTML(paste0('<div class="card" style="background-color: ', bgColor, '";>
              <h4 style="padding-top: 10px;"><b>CRAN <i class="fas fa-cube"></i> updates,  ', target_date, '</b></h4>
              <br>
              <div style="margin-left: 10px; margin-right: 10px;"></div>', 
              package_table, 
              '<br>
              <p>Hover on a package above for a description.</p>
              <p>Click on a package to visit it\'s website.</p>
              </div>'
  )
  )
}