# url = "https://win-builder.r-project.org/8esWmBov13K0/"
# url = "/8esWmBov13K0"
# path = file.path(getwd(), "check_win_devel")
# path.dump = "C:/Users/Carlos/Downloads"
#
# download_win_devel_report(url, path.dump)
# url = folder
# path.dump = file.path(path.dump, path)


test_that("is_folder() works", {
  expect_equal(2 * 2, 4)
})

test_that("validate_url() works", {
  expect_equal(2 * 2, 4)
})

test_that("get_parent_folder() works", {
  expect_equal(2 * 2, 4)
})
