#' Verify if elements of a vector of URLs redirects to a folder or a file
#'
#' @param vec_of_urls character vector; URLs to verify if they're folder or
#'   not.
#'
#' @return boolean vector. Each element is
#' * `TRUE` if it's a folder;
#' * `FALSE` if it's a file.
#'
#' @import purrr
#' @import utils
is_folder = function(vec_of_urls) {
  sapply(
    vec_of_urls,
    function(url) {
      url |>
        strsplit("") |>
        purrr::pluck(1) |>
        utils::tail(1) |>{\(.) . == "/"}()
    }) |>
    unname()
}


#' Validate parameters of the function `download_report()`
#'
#' @param url character; url.
#'
#' @return character; url standardized.
#'
#' @import purrr
validate_url = function(url) {
  if (grepl("win-builder.r-project.org", url, fixed = TRUE)) {
    url = url |>
      strsplit("/") |>
      purrr::pluck(1) |>
      rev() |>
      purrr::pluck(1) |>
      {\(.) paste0("/", .)}()
  } else if (nchar(url) == 12) {
    url = paste0("/", url)
  }

  url
}


#' Get the parent folder of a url folder
#'
#' @param path character; a url path, must be a folder, i.e., to end with "/".
#'
#' @return character.
get_folder_name = function(path) {
  path |>
    strsplit("/") |>
    purrr::pluck(1) |>
    rev() |>
    purrr::pluck(1)
}


#' Initializes a folder to save the downloads and adds it to the `.Rbuildignore`
#'
#' @param folder character; folder to initialize package structure.
#'
#' @export
init = function(folder = getwd()) {
  if (!dir.exists(file.path(folder, "check_win_devel"))) dir.create(file.path(folder, "check_win_devel"))
  if ( file.path(folder, ".Rbuildignore") |> {\(.) file.exists(.) & !("^check_win_devel$" %in% readLines(.))}() ) write("^check_win_devel$", file = file.path(folder, ".Rbuildignore"), append = TRUE)
}


#' Download win-devel report
#'
#' @param url character; url like "win-builder.r-project.org/..."
#' @param path.dump character; local path to store the download, the DEFAULT is
#'   the folder `check_win_devel` at the current working directory.
#'
#' @examples
#' \dontrun{
#' download_report("https://win-builder.r-project.org/8esWmBov13K0")
#' # or
#' download_report("8esWmBov13K0")
#' }
#'
#' @export
#'
#' @import purrr
#' @import rvest
#' @import stringr
#' @import utils
download_report = function(url, path.dump = file.path(getwd(), "check_win_devel")) {
  url = validate_url(url)

  page = url |>
    {\(.) paste0("https://win-builder.r-project.org/", .)}() |>
    rvest::read_html()

  path = url |>
    get_folder_name()

  if(path == substr(url, 2, 13)) {
    path = page |>
      rvest::html_element("pre") |>
      rvest::html_text() |>
      substr(33, 51) |>
      {\(.) gsub("[.]", "_", .)}()  |>
      {\(.) gsub(":", "h", .)}()    |>
      {\(.) gsub("    ", "_", .)}() |>
      stringr::str_replace("(\\d{2})_(\\d{2})_(\\d{4})_(\\d{2}h\\d{2})", "\\3_\\1_\\2_\\4") |>
      {\(.) paste0(., "_", path)}()
  }

  links = page |>
    rvest::html_elements("a") |>
    rvest::html_attr("href") |>
    utils::tail(-1)

  files = links |>
    {\(.) .[!is_folder(.)]}()

  folder = setdiff(links, files) |>
    rev() |>
    purrr::pluck(1)

  dir.create(file.path(path.dump, path))

  for (file in files) {
    file.name = file |>
      get_folder_name()

    try(
      download.file(url = paste0("https://win-builder.r-project.org", file),
                    destfile = file.path(path.dump, path, file.name))
    )
  }

  if (length(folder)) {
    download_report(folder, file.path(path.dump, path))
  }
}
