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

revigo.names <- c("term_ID","description","frequency","uniqueness","dispensability","representative");
revigo.data <- rbind(c("GO:0003341","cilium movement",0.05787618949763395,0.9752494683044487,0.00567725,"cilium movement"),
c("GO:0003356","regulation of cilium beat frequency",0.0026260519041485736,0.8811788049047516,0.09833978,"regulation of cilium beat frequency"),
c("GO:0000018","regulation of DNA recombination",0.03929770330486638,0.834505350986426,0.67547984,"regulation of cilium beat frequency"),
c("GO:0000381","regulation of alternative mRNA splicing, via spliceosome",0.03007660459333708,0.8382745617115412,0.22397988,"regulation of cilium beat frequency"),
c("GO:0001558","regulation of cell growth",0.06314491388760292,0.8435690984963239,0.64138001,"regulation of cilium beat frequency"),
c("GO:0001938","positive regulation of endothelial cell proliferation",0.011371801979863634,0.8216299315002671,0.3762596,"regulation of cilium beat frequency"),
c("GO:0007088","regulation of mitotic nuclear division",0.049755373292779556,0.8458405932878289,0.19680649,"regulation of cilium beat frequency"),
c("GO:0010811","positive regulation of cell-substrate adhesion",0.014808938269597336,0.8140978201394273,0.45104272,"regulation of cilium beat frequency"),
c("GO:0016476","regulation of embryonic cell shape",0.0007379538262290928,0.8763019885845178,0.10512306,"regulation of cilium beat frequency"),
c("GO:0032006","regulation of TOR signaling",0.06742637572626539,0.8363304264099365,0.69999173,"regulation of cilium beat frequency"),
c("GO:0035066","positive regulation of histone acetylation",0.0023767431790711773,0.8200208118445881,0.39017317,"regulation of cilium beat frequency"),
c("GO:0042981","regulation of apoptotic process",0.3304504047992528,0.8545662847705758,0.2307312,"regulation of cilium beat frequency"),
c("GO:0044030","regulation of DNA methylation",0.004248220675318832,0.8533940567543116,0.16523299,"regulation of cilium beat frequency"),
c("GO:0045586","regulation of gamma-delta T cell differentiation",0.0010770136923343517,0.862050104148852,0.51802458,"regulation of cilium beat frequency"),
c("GO:0045596","negative regulation of cell differentiation",0.08422313556381318,0.7943358981429737,0.687985,"regulation of cilium beat frequency"),
c("GO:0045844","positive regulation of striated muscle tissue development",0.0004554039378080438,0.830011811739415,0.4311221,"regulation of cilium beat frequency"),
c("GO:0045893","positive regulation of DNA-templated transcription",0.7260634621010682,0.7394206837945441,0.58745848,"regulation of cilium beat frequency"),
c("GO:0048714","positive regulation of oligodendrocyte differentiation",0.002267047340037123,0.8030647038612264,0.61977303,"regulation of cilium beat frequency"),
c("GO:0051726","regulation of cell cycle",0.513692317731139,0.8608724632575354,0.16020856,"regulation of cilium beat frequency"),
c("GO:0061045","negative regulation of wound healing",0.010155175401485939,0.818955549201369,0.46933325,"regulation of cilium beat frequency"),
c("GO:0070372","regulation of ERK1 and ERK2 cascade",0.03385612486551041,0.8426620723895518,0.63156673,"regulation of cilium beat frequency"),
c("GO:1901796","regulation of signal transduction by p53 class mediator",0.012861006097659281,0.8508020712651814,0.17809513,"regulation of cilium beat frequency"),
c("GO:1902857","positive regulation of non-motile cilium assembly",0.0009673178533002974,0.813068352750667,0.56794734,"regulation of cilium beat frequency"),
c("GO:1902895","positive regulation of miRNA transcription",0.0070305060471825736,0.8018208856617453,0.67497632,"regulation of cilium beat frequency"),
c("GO:1902958","positive regulation of mitochondrial electron transport, NADH to ubiquinone",0.00042216277446439096,0.8328487383504476,0.16553955,"regulation of cilium beat frequency"),
c("GO:1904439","negative regulation of iron ion import across plasma membrane",0.00012631642070588074,0.8802444044217647,0.10502977,"regulation of cilium beat frequency"),
c("GO:1904992","positive regulation of adenylate cyclase-inhibiting dopamine receptor signaling pathway",0.0001595575840495336,0.8264015275767788,0.41677607,"regulation of cilium beat frequency"),
c("GO:2000020","positive regulation of male gonad development",0.000917456108284818,0.8246444108238322,0.5237295,"regulation of cilium beat frequency"),
c("GO:0006509","membrane protein ectodomain proteolysis",0.0039224572745510345,0.953780773626584,0.03461181,"membrane protein ectodomain proteolysis"),
c("GO:0006468","protein phosphorylation",4.356287697349047,0.8926530511419031,0.57251346,"membrane protein ectodomain proteolysis"),
c("GO:0006487","protein N-linked glycosylation",0.10606922811326183,0.8968863712920191,0.38583971,"membrane protein ectodomain proteolysis"),
c("GO:0006508","proteolysis",5.339292055631215,0.9235228613536438,0.35803535,"membrane protein ectodomain proteolysis"),
c("GO:0016567","protein ubiquitination",1.0613338355851507,0.9083083782312927,0.18218075,"membrane protein ectodomain proteolysis"),
c("GO:0016573","histone acetylation",0.0876768924352187,0.8793827431365056,0.6469635,"membrane protein ectodomain proteolysis"),
c("GO:0018009","N-terminal peptidyl-L-cysteine N-palmitoylation",0.0002858740047554143,0.9042059760168311,0.25397142,"membrane protein ectodomain proteolysis"),
c("GO:0018216","peptidyl-arginine methylation",0.044772522907566,0.8795318402603173,0.35868898,"membrane protein ectodomain proteolysis"),
c("GO:0018279","protein N-linked glycosylation via asparagine",0.012020004665064863,0.9090810920964387,0.63521108,"membrane protein ectodomain proteolysis"),
c("GO:0019800","peptide cross-linking via chondroitin 4-sulfate glycosaminoglycan",0.0009141319919504529,0.8934208526624263,0.53627727,"membrane protein ectodomain proteolysis"),
c("GO:0006879","intracellular iron ion homeostasis",0.11165706767132985,1,-0,"intracellular iron ion homeostasis"),
c("GO:0007274","neuromuscular synaptic transmission",0.004075366625931837,0.9907847223000026,0.00478593,"neuromuscular synaptic transmission"),
c("GO:0006355","regulation of DNA-templated transcription",9.928869561442351,0.7786018084430345,0.66327447,"neuromuscular synaptic transmission"),
c("GO:0006357","regulation of transcription by RNA polymerase II",1.9000449520251896,0.8080556689292594,0.35004445,"neuromuscular synaptic transmission"),
c("GO:0035556","intracellular signal transduction",3.775488119059742,0.8101919967238287,0.34225706,"neuromuscular synaptic transmission"),
c("GO:0007623","circadian rhythm",0.04570327548118828,0.9866636923986922,-0,"circadian rhythm"),
c("GO:0008150","biological_process",100,1,-0,"biological_process"),
c("GO:0008283","cell population proliferation",0.11222216744817197,0.9952917305050235,-0,"cell population proliferation"),
c("GO:0009312","oligosaccharide biosynthetic process",0.2620367665216809,0.9733346749044887,-0,"oligosaccharide biosynthetic process"),
c("GO:0019082","viral protein processing",0.0010404484126563336,1,-0,"viral protein processing"),
c("GO:0030705","cytoskeleton-dependent intracellular transport",0.06978649832366475,0.9762098574411673,0.00575281,"cytoskeleton-dependent intracellular transport"),
c("GO:0006406","mRNA export from nucleus",0.07855551721372038,0.9182369969117322,0.66676731,"cytoskeleton-dependent intracellular transport"),
c("GO:0048254","snoRNA localization",0.0011933577640371367,0.9761649095555034,0.14626869,"cytoskeleton-dependent intracellular transport"),
c("GO:0031297","replication fork processing",0.02551924109892228,0.9415208148632587,0.06326591,"replication fork processing"),
c("GO:0000398","mRNA splicing, via spliceosome",0.5040390838961423,0.9214892162736159,0.29909706,"replication fork processing"),
c("GO:0006353","DNA-templated transcription termination",0.18465466237399147,0.9320797520151509,0.18484164,"replication fork processing"),
c("GO:0006366","transcription by RNA polymerase II",0.2610229110396995,0.9304425632889668,0.40191926,"replication fork processing"),
c("GO:0032543","mitochondrial translation",0.07408790486033343,0.9138320888937389,0.23675721,"replication fork processing"),
c("GO:0042118","endothelial cell activation",0.001362887697089766,0.9328060283313149,0.00449462,"endothelial cell activation"),
c("GO:0046784","viral mRNA export from host cell nucleus",0.0010072072493126807,1,0,"viral mRNA export from host cell nucleus"),
c("GO:0051145","smooth muscle cell differentiation",0.004829941033832757,0.8961897292504787,0.00483452,"smooth muscle cell differentiation"),
c("GO:0001649","osteoblast differentiation",0.015005061133324888,0.887191204258255,0.66961681,"smooth muscle cell differentiation"),
c("GO:0007283","spermatogenesis",0.0962464643452124,0.8824963570707857,0.45781996,"smooth muscle cell differentiation"),
c("GO:0007368","determination of left/right symmetry",0.029095990274699324,0.8810074998464511,0.50223563,"smooth muscle cell differentiation"),
c("GO:0007422","peripheral nervous system development",0.011222216744817196,0.8828483251205795,0.43908551,"smooth muscle cell differentiation"),
c("GO:0007507","heart development",0.09448800680433317,0.8588758532155072,0.62070871,"smooth muscle cell differentiation"),
c("GO:0030154","cell differentiation",0.9971218803542166,0.86989251034908,0.63561261,"smooth muscle cell differentiation"),
c("GO:0042475","odontogenesis of dentin-containing tooth",0.009603372089981303,0.8867136242465756,0.49868129,"smooth muscle cell differentiation"),
c("GO:0060325","face morphogenesis",0.004856533964507678,0.8936941973389578,0.38233391,"smooth muscle cell differentiation"),
c("GO:0097421","liver regeneration",0.0012831089050649993,0.8896336540170119,0.35833108,"smooth muscle cell differentiation"),
c("GO:0061640","cytoskeleton-dependent cytokinesis",0.0476445594204576,0.9860714594527261,0.00560077,"cytoskeleton-dependent cytokinesis"),
c("GO:0000278","mitotic cell cycle",0.37766282909624294,0.9853585975724316,0.5972745,"cytoskeleton-dependent cytokinesis"),
c("GO:0071347","cellular response to interleukin-1",0.011524711331244436,0.9791121597697094,0.0050996,"cellular response to interleukin-1"),
c("GO:0035767","endothelial cell chemotaxis",0.001246543625386981,0.9101594971975024,0.38840645,"cellular response to interleukin-1"),
c("GO:0035924","cellular response to vascular endothelial growth factor stimulus",0.013273196523120576,0.977337869989971,0.18272911,"cellular response to interleukin-1"),
c("GO:0090161","Golgi ribbon formation",0.0037761961558389614,0.8940976093967371,0.00476443,"Golgi ribbon formation"),
c("GO:0000462","maturation of SSU-rRNA from tricistronic rRNA transcript (SSU-rRNA, 5.8S rRNA, LSU-rRNA)",0.03841348835992521,0.8355313570797873,0.65251946,"Golgi ribbon formation"),
c("GO:0006325","chromatin organization",0.8645860379867383,0.8654032458329028,0.40501086,"Golgi ribbon formation"),
c("GO:0006338","chromatin remodeling",0.5550642696286493,0.865336015360957,0.47927166,"Golgi ribbon formation"),
c("GO:0007007","inner mitochondrial membrane organization",0.0287436339432566,0.8732116076791505,0.35194603,"Golgi ribbon formation"),
c("GO:0007010","cytoskeleton organization",0.8590214672430109,0.8489088070467737,0.50128543,"Golgi ribbon formation"),
c("GO:0016226","iron-sulfur cluster assembly",0.30904641972227476,0.8259907063231481,0.58804104,"Golgi ribbon formation"),
c("GO:0030036","actin cytoskeleton organization",0.31812125731509194,0.8529259013778214,0.61424339,"Golgi ribbon formation"),
c("GO:0030198","extracellular matrix organization",0.08963147283982549,0.8859927147702303,0.32224417,"Golgi ribbon formation"),
c("GO:0042254","ribosome biogenesis",1.647518482336128,0.8377924297473431,0.54325511,"Golgi ribbon formation"),
c("GO:0044572","[4Fe-4S] cluster assembly",0.0007013885465510747,0.8776794916398062,0.65297848,"Golgi ribbon formation"),
c("GO:0045815","transcription initiation-coupled chromatin remodeling",0.004819968684829661,0.7251195363193353,0.62238682,"Golgi ribbon formation"),
c("GO:0050808","synapse organization",0.04208663690939885,0.8915730773142081,0.2654128,"Golgi ribbon formation"),
c("GO:0051260","protein homooligomerization",0.1444262064955028,0.8566840981549473,0.42212345,"Golgi ribbon formation"),
c("GO:0060271","cilium assembly",0.17449948697250553,0.8374321590662488,0.58103711,"Golgi ribbon formation"),
c("GO:1904234","positive regulation of aconitate hydratase activity",0.00034570809877398944,0.9040277784467775,-0,"positive regulation of aconitate hydratase activity"),
c("GO:0090630","activation of GTPase activity",0.020855505881807786,0.8813477435356845,0.55521384,"positive regulation of aconitate hydratase activity"));

stuff <- data.frame(revigo.data);
names(stuff) <- revigo.names;

stuff$frequency <- as.numeric( as.character(stuff$frequency) );
stuff$uniqueness <- as.numeric( as.character(stuff$uniqueness) );
stuff$dispensability <- as.numeric( as.character(stuff$dispensability) );

# by default, outputs to a PDF file
pdf( file="revigo_treemap.pdf", width=16, height=9 ) # width and height are in inches

# check the tmPlot command documentation for all possible parameters - there are a lot more
treemap(
  stuff,
  index = c("representative","description"),
  vSize = "uniqueness",
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

