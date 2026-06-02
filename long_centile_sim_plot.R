library(dplyr)
library(ggplot2)
library(tidyr)
library(purrr)
library(glue)

# simulate df with a set of characteristics, and desired t1/t2 centiles combos 
# to inspect how longitudinal centiles depend on t1/t2 centile combinations
# using fitted gamlss models, from split One
# Can make this into a plotting function that takes models for t1, t2, long, sim characteristics, and phenotype of interest
long_centile_sim <- function(t1_model, t2_model, long_model,
                             t1_og_df, t2_og_df, long_og_df,
                             phenotype, phenotype_title,
                             t1_centiles, sex, age.t1, site, interscan_interval,
                             true_long_centile = NULL,
                             plot_colors = NULL,
                             qnorm_plot = FALSE) {
  
  #sim df
  sim_df <- tibble(
    t1_centile = t1_centiles,
    sex = sex,
    age.t1 = age.t1,
    interscan_months_t1t2 = interscan_interval,
    true_long_centile = true_long_centile
  ) %>%
    mutate(
      age.t2 = age.t1 + interscan_months_t1t2,
      site = site,
      colors = plot_colors
    )
  
  #T1 get raw values from centiles
  sim_df <- sim_df %>%
    rowwise() %>%
    mutate(
      !!glue("{phenotype}.t1") := {
        t1_centpred <- centile_predict(
          gamlssModel = t1_model,
          sim_df_list = list(
            sim = tibble(age = age.t1, sex = sex, site = site)
          ),
          x_var = "age",
          desiredCentiles = t1_centile,
          df = t1_og_df,
          average_over = FALSE
        )$fanCentiles_sim
        
        t1_centpred[[glue("cent_{t1_centile}")]]
      }
    ) %>%
    ungroup()
  
  #All possible T2 centile values
  candidate_t2_centiles <- seq(0, 0.999, by = 0.001)
  candidate_t2_centiles[candidate_t2_centiles == 0] <- 0.001
  #candidate_t2_centiles <- c(candidate_t2_centiles, 0.999)
  
  #expand subjects X T2 centile
  trajectory.df <- crossing(
    sim_df,
    t2_centile = candidate_t2_centiles
  )
  
  #get T2 raw values based on centile and subject characteristics
  trajectory.df <- trajectory.df %>%
    rowwise() %>%
    mutate(
      !!glue("{phenotype}.t2") := {
        t2_centpred <- centile_predict(
          gamlssModel = t2_model,
          sim_df_list = list(
            sim = tibble(age = age.t2, sex = sex, site = site)
          ),
          x_var = "age",
          desiredCentiles = t2_centile,
          df = t2_og_df,
          average_over = FALSE
        )$fanCentiles_sim
        
        t2_centpred[[glue("cent_{t2_centile}")]]
      }
    ) %>%
    ungroup()
  
  #get longitudinal centile for each possibility
  trajectory.df$longitudinal_centile <-
    pred_og_centile(
      gamlssModel = long_model,
      og.data = long_og_df,
      new.data = trajectory.df %>%
        select(
          all_of(glue("{phenotype}.t2")),
          all_of(glue("{phenotype}.t1")),
          "interscan_months_t1t2",
          "age.t2", "sex", "site"
        ) %>%
        rename(age = age.t2)
    )
  
  #find long centile closest to true long centile
  if (!is.null(true_long_centile)) {
    trajectory.df <- trajectory.df %>%
      group_by(t1_centile) %>%
      mutate(long_cent_plot = longitudinal_centile[which.min(abs(longitudinal_centile - true_long_centile))]) %>%
      ungroup()
  }
  
  #plot
  if (!qnorm_plot) {
    
    plot <- ggplot(
      trajectory.df,
      aes(
        x = t2_centile,
        y = longitudinal_centile,
        color = as.factor(t1_centile),
        group = as.factor(t1_centile)
      )
    ) +
      geom_line(size = 1.5) +
      geom_abline(slope = 1, intercept = 0,
                  linetype = "dashed", color = "grey60") +
      labs(
        title = glue("{phenotype_title}\nLongitudinal Centiles vs T2 Centiles"),
        x = "Timepoint 2 Centile",
        y = "Longitudinal Centile"
      ) +
      coord_equal() +
      theme_minimal() +
      theme(panel.grid = element_blank(),
            plot.title = element_text(size = 18, face = "bold", hjust = 0.5))
    
    if(is.null(true_long_centile)){
      plot <- plot + geom_point(data = trajectory.df %>% filter(t1_centile == t2_centile),
                                  aes(x = t1_centile, y = longitudinal_centile, color = as.factor(t1_centile)),
                                  shape = 16, size = 3)
    } else{
      plot <- plot + geom_point(data = trajectory.df %>% filter(longitudinal_centile == long_cent_plot),
                                  aes(x = t2_centile, y = longitudinal_centile, color = as.factor(t1_centile)),
                                  shape = 16, size = 3)
    }
    
  } else {
    
    plot <- ggplot(
      trajectory.df,
      aes(
        x = qnorm(t2_centile),
        y = qnorm(longitudinal_centile),
        color = factor(t1_centile),
        group = as.factor(t1_centile)
      )
    ) +
      geom_line(size = 1.5) +
      geom_abline(slope = 1, intercept = 0,
                  linetype = "dashed", color = "grey60") +
      labs(
        title = glue("{phenotype_title}\nLongitudinal Centiles vs T2 Centiles"),
        x = "Timepoint 2 Centile",
        y = "Longitudinal Centile"
      ) +
      scale_x_continuous(labels = \(x) glue("{x}\n({round(pnorm(x)*100)})"), limits = c(-3.1, 3.1), breaks = c(-3,-2,-1,0,1,2,3)) +
      scale_y_continuous(labels = \(y) glue("{y}\n({round(pnorm(y)*100)})"), limits = c(-3.1, 3.1), breaks = c(-3,-2,-1,0,1,2,3)) +
      coord_equal() +
      theme_minimal() +
      theme(panel.grid = element_blank(),
            plot.title = element_text(size = 18, face = "bold", hjust = 0.5))
    
    if(is.null(true_long_centile)){
      plot <- plot + geom_point(data = trajectory.df %>% filter(t1_centile == t2_centile),
                                  aes(x = qnorm(t1_centile), y = qnorm(longitudinal_centile), color = as.factor(t1_centile)),
                                  shape = 16, size = 3)
    } else{
      plot <- plot +   geom_point(data = trajectory.df %>% filter(longitudinal_centile == long_cent_plot),
                                  aes(x = qnorm(t2_centile), y = qnorm(longitudinal_centile), color = as.factor(t1_centile)),
                                  shape = 16, size = 3)
    }
  }
  
  #specify colors
  if (is.null(plot_colors)) {
    plot <- plot + scale_color_gradientn(
      colours = colorRampPalette(
        c("#3B82F6", "#6366F1", "#8B5CF6", "#A855F7", "#D946EF")
      )(length(t1_centiles)),
      labels = \(x) {glue("{signif(as.numeric(x),2)*100}%")},
      name = "Centile at Timepoint 1"
    )
  } else {
    plot <- plot + scale_color_manual(values = setNames(trajectory.df$colors, trajectory.df$t1_centile),
                                      labels = \(x) {glue("{signif(as.numeric(x),2)*100}%")},
                                      name = "Centile at Timepoint 1")
  }
  
  plot
}