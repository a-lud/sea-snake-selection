# A treemap R script produced by the Revigo server at http://revigo.irb.hr/
# If you found Revigo useful in your work, please cite the following reference:
# Supek F et al. "REVIGO summarizes and visualizes long lists of Gene Ontology
# terms" PLoS ONE 2011. doi:10.1371/journal.pone.0021800

# author: Anton Kratz <anton.kratz@gmail.com>, RIKEN Omics Science Center, Functional Genomics Technology Team, Japan
# created: Fri, Nov 02, 2012  7:25:52 PM
# last change: Fri, Nov 09, 2012  3:20:01 PM

# -----------------------------------------------------------------------------
# If you don't have the treemap package installed, uncomment the following line:
# install.packages( "treemap" );
library(treemap) 								# treemap package by Martijn Tennekes

# Set the working directory if necessary
# setwd("C:/Users/username/workingdir");

# --------------------------------------------------------------------------
# Here is your data from Revigo. Scroll down for plot configuration options.

revigo.names <- c("term_ID","description","frequency","value","uniqueness","dispensability","representative");
revigo.data <- rbind(c("GO:0005829","cytosol",1.6735941329659796,9.340349161269312,0.8556199690879193,0,"cytosol"),
c("GO:0005654","nucleoplasm",1.1935686041353335,8.994881555077603,0.702896521477985,0.12736284,"cytosol"),
c("GO:0005739","mitochondrion",2.7162231428197097,1.5813886860909112,0.6833581764841161,0.37244178,"cytosol"),
c("GO:0005856","cytoskeleton",2.411145188711844,1.5871490558490966,0.7575088747704088,0.23543973,"cytosol"),
c("GO:0031090","organelle membrane",4.796175425665669,2.1822919427077396,0.7176160356118169,0.33141923,"cytosol"),
c("GO:0140513","nuclear protein-containing complex",2.213174163781393,4.02304430262082,0.49096367021945464,0.44612909,"cytosol"),
c("GO:0009897","external side of plasma membrane",0.050705222454031626,2.8083757827214804,0.9922561419872095,4.221E-05,"external side of plasma membrane"),
c("GO:0019814","immunoglobulin complex",0.0056926534124124364,2.9876213790094117,0.8430472501604779,-0,"immunoglobulin complex"),
c("GO:0140535","intracellular protein-containing complex",2.6624264188153304,2.1802090561904377,0.7567711813954763,0.24256547,"immunoglobulin complex"),
c("GO:1902494","catalytic complex",5.012071030217034,2.1947786753939895,0.7466262348898731,0.49103725,"immunoglobulin complex"));

stuff <- data.frame(revigo.data);
names(stuff) <- revigo.names;

stuff$value <- as.numeric( as.character(stuff$value) );
stuff$frequency <- as.numeric( as.character(stuff$frequency) );
stuff$uniqueness <- as.numeric( as.character(stuff$uniqueness) );
stuff$dispensability <- as.numeric( as.character(stuff$dispensability) );

# by default, outputs to a PDF file
pdf( file="revigo_treemap.pdf", width=16, height=9 ) # width and height are in inches

# check the tmPlot command documentation for all possible parameters - there are a lot more
treemap(
  stuff,
  index = c("representative","description"),
  vSize = "value",
  type = "categorical",
  vColor = "representative",
  title = "Revigo TreeMap",
  inflate.labels = FALSE,      # set this to TRUE for space-filling group labels - good for posters
  lowerbound.cex.labels = 0,   # try to draw as many labels as possible (still, some small squares may not get a label)
  bg.labels = "#CCCCCCAA",   # define background color of group labels
								 # "#CCCCCC00" is fully transparent, "#CCCCCCAA" is semi-transparent grey, NA is opaque
  position.legend = "none"
)

dev.off()

