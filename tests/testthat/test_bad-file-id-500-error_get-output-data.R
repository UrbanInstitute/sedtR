test_that("Incorrect fileid", {

  response <- get_output_data("wrong_file_id")

  expect_equal(response$status_code, 500)
  }
  )

