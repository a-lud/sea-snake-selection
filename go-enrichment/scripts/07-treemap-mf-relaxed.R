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
revigo.data <- rbind(c("GO:0003674","molecular_function",100,1,-0,"molecular_function"),
c("GO:0003682","chromatin binding",0.167564558880372,0.9518058332478032,-0,"chromatin binding"),
c("GO:0003714","transcription corepressor activity",0.09927928728037316,0.9228800205576029,0.00448174,"transcription corepressor activity"),
c("GO:0001228","DNA-binding transcription activator activity, RNA polymerase II-specific",0.08596293471191944,0.9219728264084021,0.41049296,"transcription corepressor activity"),
c("GO:0003700","DNA-binding transcription factor activity",4.541029350225432,0.9160559502723584,0.57322123,"transcription corepressor activity"),
c("GO:0003735","structural constituent of ribosome",2.271920138196943,0.9806675479533874,-0,"structural constituent of ribosome"),
c("GO:0005200","structural constituent of cytoskeleton",0.12482098119041957,0.9710737735745081,0.64108447,"structural constituent of ribosome"),
c("GO:0003924","GTPase activity",1.2942236889107541,0.960419840921188,-0,"GTPase activity"),
c("GO:0004386","helicase activity",1.2547011919858198,0.9554929677780992,0.03939774,"helicase activity"),
c("GO:0003724","RNA helicase activity",0.31014523410202505,0.9595979961474778,0.51926903,"helicase activity"),
c("GO:0005096","GTPase activator activity",0.28751837219156207,0.9609108168896854,-0,"GTPase activator activity"),
c("GO:0004864","protein phosphatase inhibitor activity",0.05589313405580334,0.9579457907377904,0.62488164,"GTPase activator activity"),
c("GO:0005198","structural molecule activity",3.1283830918306608,1,-0,"structural molecule activity"),
c("GO:0005515","protein binding",5.069467063710899,0.9329199136559219,0.05994491,"protein binding"),
c("GO:0005539","glycosaminoglycan binding",0.12669675487870688,0.9374863382332613,0.03794117,"glycosaminoglycan binding"),
c("GO:0008198","ferrous iron binding",0.04418458750588162,0.9045630118873238,0.03510979,"ferrous iron binding"),
c("GO:0005506","iron ion binding",1.4879205643202251,0.8717873739943729,0.51519727,"ferrous iron binding"),
c("GO:0005509","calcium ion binding",1.4154161691035683,0.8945814183160239,0.23249674,"ferrous iron binding"),
c("GO:0030145","manganese ion binding",0.24534080784486836,0.8908619412641883,0.38328264,"ferrous iron binding"),
c("GO:0046872","metal ion binding",18.212007051596572,0.8599439235217169,0.46402099,"ferrous iron binding"),
c("GO:0008455","alpha-1,6-mannosylglycoprotein 2-beta-N-acetylglucosaminyltransferase activity",0.0037214693728265906,0.9513904141714654,0.02363294,"alpha-1,6-mannosylglycoprotein 2-beta-N-acetylglucosaminyltransferase activity"),
c("GO:0004672","protein kinase activity",3.693417532785571,0.9239782193896532,0.29107314,"alpha-1,6-mannosylglycoprotein 2-beta-N-acetylglucosaminyltransferase activity"),
c("GO:0008168","methyltransferase activity",2.7115211004305637,0.9164913958887342,0.35201182,"alpha-1,6-mannosylglycoprotein 2-beta-N-acetylglucosaminyltransferase activity"),
c("GO:0008237","metallopeptidase activity",1.3516234575179369,0.9218685147633334,0.51677044,"alpha-1,6-mannosylglycoprotein 2-beta-N-acetylglucosaminyltransferase activity"),
c("GO:0016274","protein-arginine N-methyltransferase activity",0.04569669078521527,0.8647397431118711,0.60522927,"alpha-1,6-mannosylglycoprotein 2-beta-N-acetylglucosaminyltransferase activity"),
c("GO:0031491","nucleosome binding",0.02402959063071277,0.9249490711666265,0.03365752,"nucleosome binding"),
c("GO:0001094","TFIID-class transcription factor complex binding",0.0012304637896928478,0.8323888513354089,0.50214091,"nucleosome binding"),
c("GO:0043021","ribonucleoprotein complex binding",0.2887761796210259,0.9142631683652369,0.69541591,"nucleosome binding"),
c("GO:0035091","phosphatidylinositol binding",0.28595431599666365,0.9495980693486049,0.04046271,"phosphatidylinositol binding"),
c("GO:0050661","NADP binding",0.6326251841047266,0.9002770037083472,0.06259063,"NADP binding"),
c("GO:0003677","DNA binding",11.84213116765873,0.8543311239566578,0.50617313,"NADP binding"),
c("GO:0003723","RNA binding",5.183093558779092,0.8664259654561739,0.19323138,"NADP binding"),
c("GO:0005524","ATP binding",13.583021415319921,0.8305494879961169,0.53307204,"NADP binding"),
c("GO:0005525","GTP binding",1.9556198507824765,0.8646179381039109,0.34066453,"NADP binding"),
c("GO:0008327","methyl-CpG binding",0.0030980343860488816,0.8856858046997654,0.16979172,"NADP binding"),
c("GO:0051287","NAD binding",0.9459067336884798,0.8965172301033699,0.32846153,"NADP binding"),
c("GO:0070888","E-box binding",0.005821460907235718,0.8832551013201403,0.6571912,"NADP binding"),
c("GO:1990837","sequence-specific double-stranded DNA binding",0.4443040682742248,0.8524728161506311,0.51168716,"NADP binding"),
c("GO:0051117","ATPase binding",0.011902686392295482,0.8427570682812467,0.03212488,"ATPase binding"),
c("GO:0002039","p53 binding",0.01660305806892216,0.8396971235466372,0.31914838,"ATPase binding"),
c("GO:0005516","calmodulin binding",0.15554156047308434,0.8157231704222713,0.42584917,"ATPase binding"),
c("GO:0008017","microtubule binding",0.3620626029351319,0.8048301211298206,0.50105759,"ATPase binding"),
c("GO:0019904","protein domain specific binding",0.10822886057740579,0.8200606790512324,0.40759553,"ATPase binding"),
c("GO:0042393","histone binding",0.0857578574136373,0.8227441793359189,0.39002194,"ATPase binding"),
c("GO:0042802","identical protein binding",0.34201971498302397,0.8056007887098541,0.46619731,"ATPase binding"),
c("GO:0042803","protein homodimerization activity",0.15462007981280326,0.8092205108050089,0.43759059,"ATPase binding"),
c("GO:0045296","cadherin binding",0.019310078406246423,0.8382698829299974,0.32809757,"ATPase binding"),
c("GO:0070577","lysine-acetylated histone binding",0.01051362949193111,0.8296502025599036,0.31113452,"ATPase binding"),
c("GO:0140030","modification-dependent protein binding",0.05788101666715156,0.8271087989131103,0.35369471,"ATPase binding"),
c("GO:0051537","2 iron, 2 sulfur cluster binding",0.5062565529032712,0.9469957147720839,0.04447767,"2 iron, 2 sulfur cluster binding"),
c("GO:0060090","molecular adaptor activity",0.2018999673407567,1,0,"molecular adaptor activity"),
c("GO:0062153","C5-methylcytidine-containing RNA binding",0.00030351440145756913,0.9213551364602145,0.02595269,"C5-methylcytidine-containing RNA binding"),
c("GO:0003729","mRNA binding",0.29432967285850625,0.8809525702031488,0.41161134,"C5-methylcytidine-containing RNA binding"),
c("GO:0030515","snoRNA binding",0.04065725797542879,0.8962189320480705,0.27361776,"C5-methylcytidine-containing RNA binding"),
c("GO:0034511","U3 snoRNA binding",0.008514809424674507,0.9058186953932422,0.32672243,"C5-methylcytidine-containing RNA binding"),
c("GO:0140463","chromatin-protein adaptor activity",0.0014628847277459412,0.9907107515926408,-0,"chromatin-protein adaptor activity"));

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

