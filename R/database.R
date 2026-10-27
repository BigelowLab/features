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
    x = template_database(n = 1)
    if (add_feature) x = dplyr::mutate(x, feature = list())  
  } else {
    x = readr::read_csv(file,
                  col_types = "cDccccccnnnn")
    if (add_feature) x = load_feature(x, path = file.path(path, "data"))
  }
  
  return(x)
}

#' @rdname read_database
#' @param x data frame - a database to write
write_database = function(x, 
                          filename = "database",
                          path = features_path()){
  readr::write_csv(dplyr::select(x, -dplyr::any_of("feature")),
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
  x = dplyr::select(x, -dplyr::any_of("feature"))
  
  if (isTRUE(strict_match)){
    if(!identical(colnames(x), colnames(orig))) {
      stop("names of x and on-disk database do not match")
    }
    xtypes = sapply(x, typeof)
    origtypes = sapply(orig, typeof)
    if(!identical(xtypes, origtypes)) {
      stop("data types of x and on-disk database do not match")
    }
  }
  
  if (tolower(check[1]) == "unique"){
    if(any(x$id %in% orig$id)){
      stop("ids in x and on-disk database must be unique")
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
    doi = NA_character_,
    xmin = NA_real_,
    xmax = NA_real_,
    ymin = NA_real_,
    ymax = NA_real_)
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

#' Determine the feature type
#'
#' @export
#' @param x spatial object in the sf family
#' @return character string of the feature type
feature_type = function(x){
  klass = sf::st_geometry(x[1]) |>
    class()
  sub("sfc_", "", klass[1])
}

#' Add a new record
#' 
#' @export
#' @param name chr the programmable short name (required, no spaces, etc)
#' @param longname chr the longer display name (required)
#' @param x spatial object (required, must be writeable by [sf::write_sf()])
#' @param ref chr, optional reference info
#' @param url chr, optional URL
#' @param doi chr, optional URI

add_feature = function(name, longname, x,
                       type = feature_type(x),
                       ref = NA_character_,
                       url = NA_character_,
                       doi = NA_character_){
  if (any(missing(name), missing(longname), missing(x))){
    stop("name, logname and x are required")
  }
  bb = sf::st_bbox(x)
  r = new_record() |>
    dplyr::mutate(name = name[1],
                  longname = longname[1],
                  type = type,
                  ref = ref[1],
                  url = url[1],
                  doi = doi[1],
                  xmin = bb$xmin,
                  xmax = bb$xmax,
                  ymin = bb$ymin,
                  ymax = bb$ymax)
  db = append_database(r)
  write_feature(x,r)
}
                  