# Disclaimer: Generative AI was used in the creation of this script

# Read in counts file
counts <- read.csv("pipeco_out/03.pai_out/count.tsv", header = TRUE, sep = "\t")
# Calculate the proportion
counts$sig_proportion <- (counts$significant_group / counts$detected_gene_group)

# Calculate overall statistics
overall_mean <- mean(counts$sig_proportion, na.rm = TRUE)
overall_sd <- sd(counts$sig_proportion, na.rm = TRUE)

# Calculate z-scores for each genome
calculate_significance <- function(data) {
  # Get unique genomes
  genomes <- unique(data$genome)
  
  # Create results dataframe
  results <- data.frame(
    genome = character(),
    sig_proportion = numeric(),
    z_score = numeric(),
    significant = logical(),
    stringsAsFactors = FALSE
  )
  
  # Calculate z-score for each genome
  for (genome in genomes) {
    genome_data <- data$sig_proportion[data$genome == genome]
    
    # Calculate z-score
    z_score <- (genome_data - overall_mean) / overall_sd
    
    # Calculate p-value from z-score (two-tailed test)
    p_value <- 2 * pnorm(-abs(z_score))
    
    # Store results
    results <- rbind(results, data.frame(
      genome = genome,
      sig_proportion = genome_data,
      z_score = z_score,
      p_value = p_value,
      significant = p_value < 0.05
    ))
  }
  
  # Adjust p-values for multiple testing using Benjamini-Hochberg method
  results$adjusted_p_value <- p.adjust(results$p_value, method = "BH")
  results$significant_adjusted <- results$adjusted_p_value < 0.05
  
  # Sort by z-score for easier interpretation
  results <- results[order(results$z_score, decreasing = TRUE), ]
  
  return(results)
}

# Run the analysis
genome_results <- calculate_significance(counts)

# Display the results
print(genome_results)

# Create a visualization
library(ggplot2)

# Plot the results
ggplot(genome_results, aes(x = reorder(genome, z_score), y = sig_proportion, fill = significant_adjusted)) +
  geom_bar(stat = "identity") +
  geom_hline(yintercept = overall_mean, linetype = "dashed", color = "red") +
  labs(title = "Significance of Proportion by Genome",
       x = "Genome",
       y = "Significant Proportion",
       fill = "Significantly Different") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5))