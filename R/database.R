#' Read or write database
#' 
#' @export
#' @param filename chr the name of the file
#' @param add_feature logical, if TRUE add a features column
#' @param path chr, the path to the file
#' @return data frame
read_database = function(filename = "database",
                         add_feature = FALSE,
                         path = features_path()){
  file = file.path(path, filename)
  if (!file.exists(file)){
    x = dplyr::tibble(
      id = NA_character_,
      date = Sys.Date(),
      name = NA_character_,
      longname = NA_character_,
      type = NA_character_,
      ref = NA_character_,
      url = NA_character_,
      doi = NA_character_)
    if (add_feature) x = dplyr::mutate(x, feature = list())  
  } else {
    x = readr::read_csv(file,
                  col_types = "cDcccccc")
    if (add_feature) x = load_feature(x, path = path)
  }
  
  return(x)
}

#' @rdname read_database
#' @param x data frame - a database to write
write_database = function(x, 
                          filename = "database",
                          path = features_path()){
  readr::write_csv(x,
                   file.path(path, filename))
}

#' @rdname read_database
#' @param strict_match logical, if TRUE then really chack the input against the original
#' @param check chr, if "unique" then check that ids are unique, "none" to skip a check
append_database = function(x,
                           filename = "database",
                           check = c("unique", "none")[1],
                           strict_match = TRUE,
                           path = features_path()){
  orig = read_database(filename = filename, path = path)
  if (isTRUE(strict_match)){
    if(!identical(colnames(x), colnames(orig))) {
      stop("names of x and original do not match")
    }
    xtypes = sapply(x, typeof)
    origtypes = sapply(orig, typeof)
    if(!identical(xtypes, origtypes)) {
      stop("data types of x and original do not match")
    }
  }
  
  if (tolower(check[1]) == "unique"){
    if(any(x$id %in% orig$id)){
      stop("ids in x and orig must be unique")
    }
  }
  
  x = dplyr::bind_rows(orig, x)
  write_database(x, filename = filename, path = path)
}


#' Template of a record
#' 
#' `new_record` will have a valid non-conflicting id
#' 
#' @export
#' @param n number of records to create
#' @return one or more rows of template records
template_record = function(n = 1){
  x = dplyr::tibble(
    id = NA_character_,
    date = Sys.Date()[2],
    name = NA_character_,
    longname = NA_character_,
    type = NA_character_,
    ref = NA_character_,
    url = NA_character_,
    doi = NA_character_)
  if (n > 1) x = dplyr::slice(x, rep(1,n))
  return(x)
}


#' @rdname template_record
#' @return data frame with n rows
new_record = function(n = 1){
  
  template_record(n = n) |>
    dplyr::mutate(date = Sys.Date(),
                  id = uuid::UUIDgenerate(n = n, output = "string"))

}