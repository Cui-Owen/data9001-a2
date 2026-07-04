library(tidyverse)

prices <- read_csv("Data/Apartment_prices.csv", show_col_types = FALSE) %>%
  mutate(Median_price_2023 = parse_number(Median_price_2023))

hist <- read_csv("Data/Historical_demographic.csv", show_col_types = FALSE) %>%
  mutate(
    Historical_median_income = replace_na(
      Historical_median_income,
      median(Historical_median_income, na.rm = TRUE)
    ),
    Historical_unemployment_rate_clean = pmax(Historical_unemployment_rate, 0)
  )

proj <- read_csv("Data/Projected_demographic.csv", show_col_types = FALSE) %>%
  mutate(
    Projected_median_income = replace_na(
      Projected_median_income,
      median(Projected_median_income, na.rm = TRUE)
    ),
    Projected_unemployment_rate_clean = pmax(Projected_unemployment_rate, 0)
  )

analysis_data <- prices %>%
  inner_join(hist, by = "Suburb_name")

model_data <- analysis_data %>%
  filter(Median_price_2023 < 1000000) %>%
  mutate(
    log_price = log(Median_price_2023),
    income_10k = Historical_median_income / 10000
  )

ggplot(analysis_data, aes(x = Median_price_2023)) +
  geom_histogram(bins = 30, fill = "#2a9d8f", color = "white") +
  labs(
    title = "Distribution of 2023 median apartment prices",
    x = "Median apartment price in 2023",
    y = "Number of suburbs"
  ) +
  theme_minimal()

ggplot(model_data, aes(x = Historical_population_growth, y = Median_price_2023)) +
  geom_point(alpha = 0.55, color = "#23395d") +
  geom_smooth(method = "lm", se = FALSE, color = "#c45824") +
  labs(
    title = "Population growth and apartment prices",
    x = "Historical population growth",
    y = "Median apartment price in 2023"
  ) +
  theme_minimal()

ggplot(model_data, aes(x = Historical_unemployment_rate_clean, y = Median_price_2023)) +
  geom_point(alpha = 0.55, color = "#23395d") +
  geom_smooth(method = "lm", se = FALSE, color = "#c45824") +
  labs(
    title = "Unemployment and apartment prices",
    x = "Cleaned unemployment rate",
    y = "Median apartment price in 2023"
  ) +
  theme_minimal()

model <- lm(
  log_price ~ Historical_population_growth +
    income_10k +
    Historical_unemployment_rate_clean +
    Historical_priority_growth_area,
  data = model_data
)

summary(model)

projection_input <- proj %>%
  transmute(
    Suburb_name,
    Historical_population_growth = Projected_population_growth,
    income_10k = Projected_median_income / 10000,
    Historical_unemployment_rate_clean = Projected_unemployment_rate_clean,
    Historical_priority_growth_area = Projected_priority_growth_area
  )

predictions <- projection_input %>%
  mutate(
    pred_log_price_2024 = predict(model, newdata = projection_input),
    pred_price_2024 = exp(pred_log_price_2024)
  ) %>%
  left_join(prices, by = "Suburb_name") %>%
  mutate(
    pred_uplift_abs = pred_price_2024 - Median_price_2023,
    pred_uplift_pct = pred_price_2024 / Median_price_2023 - 1
  )

predictions %>%
  arrange(desc(pred_price_2024)) %>%
  select(Suburb_name, Median_price_2023, pred_price_2024, pred_uplift_pct) %>%
  head(10)

predictions %>%
  filter(Median_price_2023 < 1000000) %>%
  arrange(desc(pred_uplift_pct)) %>%
  select(Suburb_name, Median_price_2023, pred_price_2024, pred_uplift_pct) %>%
  head(15)

top_predictions <- predictions %>%
  filter(Suburb_name %in% c("DROUIN", "SEAFORD", "SANDRINGHAM", "ASHBURTON", "BACCHUS MARSH"))

ggplot(top_predictions, aes(x = reorder(Suburb_name, pred_price_2024), y = pred_price_2024)) +
  geom_col(fill = "#2a9d8f") +
  coord_flip() +
  labs(
    title = "Top predicted apartment prices for next year",
    x = "Suburb",
    y = "Predicted 2024 price"
  ) +
  theme_minimal()
