test_that("is_folder() works", {
  expect_true(is_folder("r-project.org/a/"))
  expect_true(is_folder("r-project.org/a/b/"))
  expect_false(is_folder("r-project.org/c"))
})

test_that("validate_url() works", {
  expect_equal(validate_url("https://win-builder.r-project.org/8esWmBov13K0/"), "/8esWmBov13K0")
  expect_equal(validate_url("8esWmBov13K0"), "/8esWmBov13K0")
  expect_equal(validate_url("/8esWmBov13K0"), "/8esWmBov13K0")
})

test_that("get_folder_name() works", {
  expect_equal(get_folder_name("r-project.org/a/"), "a")
  expect_equal(get_folder_name("r-project.org/a/b/"), "b")
})

test_that("init() works", {
  x = file.path(tempdir(), "test_dwb")
  if (dir.exists(x)) unlink(x)
  dir.create(x)

  file.create(file.path(x, ".Rbuildignore"))
  sink(file.path(x, ".Rbuildignore"))
  sink()

  init(x)

  expect_true(dir.exists(file.path(x, "check_win_devel")))
  expect_true("^check_win_devel$" %in% readLines(file.path(x, ".Rbuildignore")))

  unlink(x)
})
