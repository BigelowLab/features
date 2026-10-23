#' Read or write a feature, or add features to a database in memory
#' 
#' @export
#' @param x data frame, one or more database records
#' @param path chr the data path
#' @return a named list with one or more features
read_feature = function(x,
                        path = features_path("data")){
 
  dplyr::rowwise(x) |>
    dplyr::group_map(
      function(row, key){
        filename = file.path(path, sprintf("%s.gpkg", row$id))
        sf::read_sf(filename, drivers = "GPKG")
      }
    ) |>
    rlang::set_names(x$id)
}

#' @rdname read_feature
#' @param feature spatial object writable by [sf::write_sf()]
#' @export
write_feature = function(feature, x, 
                         path = features_path("data")){
  if (nrow(x) > 1 && is.list(feature) && (length(feature) == nrow(x))){
    for (i in seq_len(nrow(x))){
       write_feature(feature[[i]], dplyr::slice(x, i), path = path)
    }
  } else {
    filename = file.path(path, sprintf("%s.gpkg", x$id))
    sf::write_sf(feature, filename, driver = "GPKG")
  }
  invisible(feature)
}

#' @rdname read_feature
#' @export
load_feature = function(x,
                        path = features_path("data")){
  x |>
    dplyr::mutate(feature = read_feature(x, path = path))
}
