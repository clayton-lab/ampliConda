tree = phyloseq::phy_tree(ps)
samp = data.frame(phyloseq::otu_table(ps))

adiv <- data.frame(
    phyloseq::estimate_richness(ps, 
        measures = c("Observed", "Shannon", "Chao1", "Simpson", "InvSimpson", "Fisher")
        ),
    "PD" = picante::pd(samp, tree, include.root=FALSE)[,1],
    dplyr::select(as_tibble(phyloseq::sample_data(ps)), sample, group, time, id)) %>%
    dplyr::select(-se.chao1)