# ============================================================
# DATA9001 作业 2 参考代码：维多利亚州公寓投资分析
# 思路：用"历史特征"训练一个线性回归模型，再把"预测特征"喂进模型，
#       预测下一年各 suburb 的公寓价格，从而给出投资推荐。
# 说明：下面的注释解释每一步"为什么这样做"，方便学习者理解取舍。
# ============================================================

library(tidyverse)  # readr 读数据、dplyr 处理数据、ggplot2 画图都在其中

# ---------- 1. 读取并清洗公寓价格（标签/被解释变量）----------
prices <- read_csv("Data/Apartment_prices.csv", show_col_types = FALSE) %>%
  # NORLANE 的价格被错误录成 "309334x"（数字里混进了字母 x）。
  # parse_number() 会自动抽出其中的数字 309334：
  # 这是"格式错误"而非"缺失"，所以修正格式即可，不必删掉整行、白白损失一个样本。
  mutate(Median_price_2023 = parse_number(Median_price_2023))

# ---------- 2. 读取并清洗历史人口/经济特征 ----------
hist <- read_csv("Data/Historical_demographic.csv", show_col_types = FALSE) %>%
  mutate(
    # POINT LONSDALE 的历史收入缺失。全表只有这一个缺失值，
    # 用中位数填补：中位数对极端值稳健，而且"用典型水平代替缺失"容易解释。
    Historical_median_income = replace_na(
      Historical_median_income,
      median(Historical_median_income, na.rm = TRUE)
    ),
    # 失业率出现负数，显然是错误数据（失业率不可能小于 0）。
    # 用 pmax(x, 0) 把负值截断为 0：既纠正了错误，又保留了"该区失业很低"这一信息，
    # 比直接删除这些 suburb 更好。清洗后另存为新列，保留原始列以便追溯。
    Historical_unemployment_rate_clean = pmax(Historical_unemployment_rate, 0)
  )

# ---------- 3. 用"完全相同"的规则清洗预测特征 ----------
# 关键：预测数据代表"下一年的特征"，只能在最后 predict 时使用，绝不能混入训练，
# 否则会造成数据泄漏。清洗规则必须与历史数据一致，否则训练/预测口径不统一。
proj <- read_csv("Data/Projected_demographic.csv", show_col_types = FALSE) %>%
  mutate(
    Projected_median_income = replace_na(
      Projected_median_income,
      median(Projected_median_income, na.rm = TRUE)
    ),
    Projected_unemployment_rate_clean = pmax(Projected_unemployment_rate, 0)
  )

# ---------- 4. 按 suburb 名合并价格与历史特征 ----------
# 用 inner_join：只保留两张表都出现的 suburb，确保每一行都同时有特征和标签。
analysis_data <- prices %>%
  inner_join(hist, by = "Suburb_name")

# ---------- 5. 构造建模数据 + 变量变换 ----------
model_data <- analysis_data %>%
  # MAFFRA 的价格 4,202,660，远高于第二高的 suburb，是极端离群点。
  # 用 < 1,000,000 把它排除在训练样本外，避免这一个点把回归线强行拉偏。
  filter(Median_price_2023 < 1000000) %>%
  mutate(
    # 价格恒为正且右偏 → 取对数。log 后分布更对称、残差更接近正态，
    # 而且系数可近似解读为"百分比变化"，解释更直观（见"模型解释"部分）。
    log_price = log(Median_price_2023),
    # 把收入换算成"每 1 万元"为单位，让收入系数量级更好读。
    income_10k = Historical_median_income / 10000
  )

# ---------- 6. 先可视化再建模：用图说明数据与变量选择 ----------
# 直方图：展示价格分布右偏，并让 >100 万的离群点一眼可见（支撑上面的剔除决定）。
ggplot(analysis_data, aes(x = Median_price_2023)) +
  geom_histogram(bins = 30, fill = "#2a9d8f", color = "white") +
  labs(
    title = "Distribution of 2023 median apartment prices",
    x = "Median apartment price in 2023",
    y = "Number of suburbs"
  ) +
  theme_minimal()

# 散点图 + 拟合线：检查人口增长与价格是否正相关，作为"是否纳入该变量"的依据。
ggplot(model_data, aes(x = Historical_population_growth, y = Median_price_2023)) +
  geom_point(alpha = 0.55, color = "#23395d") +
  geom_smooth(method = "lm", se = FALSE, color = "#c45824") +
  labs(
    title = "Population growth and apartment prices",
    x = "Historical population growth",
    y = "Median apartment price in 2023"
  ) +
  theme_minimal()

# 散点图：检查清洗后失业率与价格的关系（预期为负相关）。
ggplot(model_data, aes(x = Historical_unemployment_rate_clean, y = Median_price_2023)) +
  geom_point(alpha = 0.55, color = "#23395d") +
  geom_smooth(method = "lm", se = FALSE, color = "#c45824") +
  labs(
    title = "Unemployment and apartment prices",
    x = "Cleaned unemployment rate",
    y = "Median apartment price in 2023"
  ) +
  theme_minimal()

# ---------- 7. 估计线性回归 ----------
# 函数关系：log(Price) = b0 + b1*人口增长 + b2*收入(万) + b3*清洗后失业率 + b4*优先发展区
# 选这四个变量的理由：都能从历史数据得到，也都能在预测数据里找到对应列，
# 且经济上都与住房需求/支付能力相关。
model <- lm(
  log_price ~ Historical_population_growth +
    income_10k +
    Historical_unemployment_rate_clean +
    Historical_priority_growth_area,
  data = model_data
)

summary(model)  # 看系数、标准误、t 值与 R²，判断统计显著性与拟合优度

# ---------- 8. 用预测特征构造预测输入（关键技巧）----------
# transmute 把 projected_* 列改名成与训练时"完全相同"的变量名，
# predict() 才能按名字对上号，让同一个模型作用在下一年的数据上。
projection_input <- proj %>%
  transmute(
    Suburb_name,
    Historical_population_growth = Projected_population_growth,
    income_10k = Projected_median_income / 10000,
    Historical_unemployment_rate_clean = Projected_unemployment_rate_clean,
    Historical_priority_growth_area = Projected_priority_growth_area
  )

# ---------- 9. 预测下一年价格并计算涨幅 ----------
predictions <- projection_input %>%
  mutate(
    pred_log_price_2024 = predict(model, newdata = projection_input),
    # 模型预测的是 log 价格，用 exp() 变回原始"元"尺度才能解读。
    pred_price_2024 = exp(pred_log_price_2024)
  ) %>%
  left_join(prices, by = "Suburb_name") %>%
  mutate(
    pred_uplift_abs = pred_price_2024 - Median_price_2023,      # 预测绝对涨幅
    pred_uplift_pct = pred_price_2024 / Median_price_2023 - 1   # 预测相对涨幅(%)
  )

# 按"预测价格水平"排序：找最高价/最高潜力的 suburb。
predictions %>%
  arrange(desc(pred_price_2024)) %>%
  select(Suburb_name, Median_price_2023, pred_price_2024, pred_uplift_pct) %>%
  head(10)

# 按"相对涨幅"排序（先滤掉当前已超百万的）：找上行空间最大的 suburb。
# 注意：当前价格很低的 suburb 涨幅百分比会被放大，必须结合价格水平一起判断，
# 不能只看涨幅就下结论（这正是最终推荐 SEAFORD 而非纯低价区的原因）。
predictions %>%
  filter(Median_price_2023 < 1000000) %>%
  arrange(desc(pred_uplift_pct)) %>%
  select(Suburb_name, Median_price_2023, pred_price_2024, pred_uplift_pct) %>%
  head(15)

# ---------- 10. 可视化最终推荐 ----------
# 把重点候选 suburb 的预测价格画成条形图，作为报告结论的图形支撑。
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
