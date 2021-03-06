test_that("combine_layers() returns expected output", {
  layer_1 <- list(
    geom = "text",
    aes = list(x = 3, y = 30, label = "Some text"),
    facets = list(cyl = 4),
    params = list(colour = "red")
  )

  layer_2 <- list(
    geom = "text",
    aes = list(x = 4, y = 35, label = "Some other text"),
    params = list(colour = "red")
  )

  layer_3 <- list(
    geom = "point",
    aes = list(x = 3, y = 40)
  )

  layer_4 <- list(
    geom = "text",
    aes = list(x = 4, y = 45, label = "Some more text"),
    facets = list(cyl = 4),
    params = list(colour = "black")
  )

  layer_5 <- list(
    geom = "text",
    aes = list(x = 5, y = 45, label = "Even more text"),
    facets = list(cyl = 4),
    params = list(colour = "black")
  )

  layers <- list(layer_1, layer_2, layer_3, layer_4, layer_5)

  result_is_correct <- function(result) {
    result_is_list <- is.list(result)

    sub_elements_are_lists <- all(purrr::map_lgl(result, is.list))

    sub_elements_are_length_4 <- all(purrr::map_lgl(
      result,
      ~ length(.x) == 4
    ))

    all_names_present <- function(x) {
      all(c("geom", "aes", "params", "facets") %in%
        names(x))
    }

    sub_elements_have_correct_names <- all(purrr::map_lgl(
      result,
      all_names_present
    ))

    all(
      result_is_list,
      sub_elements_are_lists,
      sub_elements_are_length_4,
      sub_elements_have_correct_names
    )
  }

  # Check all lists work when included
  expect_true(result_is_correct(combine_layers(layers)))

  # Two of the layers should be combined, as they share geom + facets + params
  expect_length(combine_layers(layers), 4)

  # Check each individual list works separately
  expect_true(all(purrr::map_lgl(
    layers,
    ~ result_is_correct(combine_layers(list(.x)))
  )))

  # Empty list should throw error
  expect_error(combine_layers(list()))

  # Each list element must contain certain sub-elements
  expect_error(combine_layers(lists = list(
    list(somenonsense = 1)
  )))

  # aes sub-element must be a list, not a vector
  expect_error(combine_layers(lists = list(list(
    geom = "text",
    aes = c("a", "b", "c")
  ))))

  # aes sub-element is required
  expect_error(combine_layers(lists = list(list(
    geom = "text",
    params = list(colour = "red")
  ))))
})
