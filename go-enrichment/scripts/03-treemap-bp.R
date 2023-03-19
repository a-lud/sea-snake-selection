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
revigo.data <- rbind(c("GO:0000966","RNA 5'-end processing",0.10864209415606056,0.9064879739417101,0.09613643,"RNA 5'-end processing"),
c("GO:0006396","RNA processing",4.052084515125943,0.8553258824346757,0.53423551,"RNA 5'-end processing"),
c("GO:0034470","ncRNA processing",2.675338577038208,0.8611931133070488,0.58894179,"RNA 5'-end processing"),
c("GO:0034660","ncRNA metabolic process",3.7632919362289554,0.8571178300158353,0.3429036,"RNA 5'-end processing"),
c("GO:0006950","response to stress",4.85393118141787,0.9751898403582899,-0,"response to stress"),
c("GO:0006974","cellular response to DNA damage stimulus",2.553180625866618,0.9646035811095206,0.49129211,"response to stress"),
c("GO:0051716","cellular response to stimulus",11.92665018193055,0.9632229065442832,0.63828901,"response to stress"),
c("GO:0008104","protein localization",3.0453359938674045,0.9666481536101414,-0,"protein localization"),
c("GO:0033036","macromolecule localization",3.699222918000399,0.9815345085845409,0.40083779,"protein localization"),
c("GO:0051641","cellular localization",3.742193769854739,0.9738280480816912,0.41338567,"protein localization"),
c("GO:0008152","metabolic process",65.58850504615819,1,-0,"metabolic process"),
c("GO:0009056","catabolic process",6.089661456369162,0.9633808984664393,0.04835157,"catabolic process"),
c("GO:0009058","biosynthetic process",28.21250331123538,0.9447108612748013,0.07142613,"biosynthetic process"),
c("GO:0006139","nucleobase-containing compound metabolic process",24.03953065737758,0.8365344839456971,0.62483952,"biosynthetic process"),
c("GO:0006807","nitrogen compound metabolic process",49.550089164434496,0.931615089840326,0.14752788,"biosynthetic process"),
c("GO:0016070","RNA metabolic process",13.496068550990763,0.8297305203260004,0.5909548,"biosynthetic process"),
c("GO:0018130","heterocycle biosynthetic process",13.69822468586519,0.8533479823121929,0.55113538,"biosynthetic process"),
c("GO:0019438","aromatic compound biosynthetic process",13.374206446172934,0.8541733616226889,0.54716201,"biosynthetic process"),
c("GO:0034641","cellular nitrogen compound metabolic process",30.54528505178458,0.8964193192683862,0.29997373,"biosynthetic process"),
c("GO:0034654","nucleobase-containing compound biosynthetic process",11.336157480410234,0.8339358461885317,0.52120986,"biosynthetic process"),
c("GO:0043170","macromolecule metabolic process",38.67120377521221,0.9234496724667143,0.19180088,"biosynthetic process"),
c("GO:0044237","cellular metabolic process",52.27297257740313,0.92545667411301,0.23063781,"biosynthetic process"),
c("GO:0044238","primary metabolic process",54.341480421137625,0.9288714801943089,0.22123429,"biosynthetic process"),
c("GO:0044249","cellular biosynthetic process",26.205471674988644,0.8633078058306708,0.68616296,"biosynthetic process"),
c("GO:0044271","cellular nitrogen compound biosynthetic process",18.828945062096654,0.8414835237535037,0.61000433,"biosynthetic process"),
c("GO:0071704","organic substance metabolic process",59.155721653523166,0.9261841527423192,0.25577572,"biosynthetic process"),
c("GO:0090304","nucleic acid metabolic process",18.979959667166867,0.8261081392918336,0.56410817,"biosynthetic process"),
c("GO:1901360","organic cyclic compound metabolic process",27.64011374727202,0.9317694574103592,0.11377484,"biosynthetic process"),
c("GO:1901362","organic cyclic compound biosynthetic process",14.300544593303174,0.8628308205013868,0.55842492,"biosynthetic process"),
c("GO:1901564","organonitrogen compound metabolic process",30.85322786488385,0.9093303931305974,0.2017223,"biosynthetic process"),
c("GO:1901576","organic substance biosynthetic process",27.020538351942346,0.8757840140477655,0.16529832,"biosynthetic process"),
c("GO:0009987","cellular process",80.90928742480475,1,-0,"cellular process"),
c("GO:0016570","histone modification",0.5007315881434488,0.9392754511004547,-0,"histone modification"),
c("GO:0010467","gene expression",16.693722203531454,0.9057295855052689,0.29376382,"histone modification"),
c("GO:0019538","protein metabolic process",19.1169597977714,0.8921394131872611,0.33829603,"histone modification"),
c("GO:0036211","protein modification process",8.944329461413709,0.9052300693174433,0.50056465,"histone modification"),
c("GO:0043412","macromolecule modification",11.34052536927359,0.9139031998073044,0.15592651,"histone modification"),
c("GO:0044260","cellular macromolecule metabolic process",15.643185097800322,0.8889489771206038,0.31968505,"histone modification"),
c("GO:0030030","cell projection organization",0.6618149415904561,0.9472560044196531,0.00950516,"cell projection organization"),
c("GO:0006996","organelle organization",3.5258104170692315,0.9366452373646468,0.68031239,"cell projection organization"),
c("GO:0022607","cellular component assembly",2.5713768386809335,0.9371816030268634,0.64479318,"cell projection organization"),
c("GO:0044085","cellular component biogenesis",4.795792386729822,0.9376634183258706,0.53615507,"cell projection organization"),
c("GO:0070925","organelle assembly",0.6294646414244132,0.9457938012061995,0.66258076,"cell projection organization"),
c("GO:0120036","plasma membrane bounded cell projection organization",0.37564841459761755,0.9501557524881714,0.44954063,"cell projection organization"),
c("GO:0032501","multicellular organismal process",2.3849736911150656,1,-0,"multicellular organismal process"),
c("GO:0032502","developmental process",2.3294642724475,1,0,"developmental process"),
c("GO:0044248","cellular catabolic process",4.056548803362995,0.9222697201848306,0.03414315,"cellular catabolic process"),
c("GO:0006725","cellular aromatic compound metabolic process",26.79292613417935,0.9116274818751905,0.23504502,"cellular catabolic process"),
c("GO:0006793","phosphorus metabolic process",13.445758050270145,0.9268572753719829,0.1534065,"cellular catabolic process"),
c("GO:0006796","phosphate-containing compound metabolic process",13.135671182135214,0.9272792690010634,0.11828842,"cellular catabolic process"),
c("GO:0046483","heterocycle metabolic process",26.784054067682934,0.911636355093624,0.18628936,"cellular catabolic process"),
c("GO:0050896","response to stimulus",14.587937719223396,1,-0,"response to stimulus"),
c("GO:0060537","muscle tissue development",0.04901409535021611,0.8548844285004119,-0,"muscle tissue development"),
c("GO:0003205","cardiac chamber development",0.02270703868004925,0.8446654914586539,0.60565646,"muscle tissue development"),
c("GO:0009888","tissue development",0.43290299434072516,0.833062403869744,0.64319727,"muscle tissue development"),
c("GO:0035239","tube morphogenesis",0.12667210115365785,0.8363355053486285,0.66386673,"muscle tissue development"),
c("GO:0072359","circulatory system development",0.1713415764548585,0.8368084164993452,0.54304457,"muscle tissue development"),
c("GO:0065007","biological regulation",22.890652894010586,1,-0,"biological regulation"),
c("GO:0071840","cellular component organization or biogenesis",9.257238504316515,0.9903706657717553,0.01377613,"cellular component organization or biogenesis"),
c("GO:2000026","regulation of multicellular organismal development",0.23866158045842426,0.8136666082553944,-0,"regulation of multicellular organismal development"),
c("GO:0006355","regulation of DNA-templated transcription",9.928869561442351,0.6205660783494791,0.59882425,"regulation of multicellular organismal development"),
c("GO:0009966","regulation of signal transduction",0.9172500130720875,0.7810302098955819,0.2658838,"regulation of multicellular organismal development"),
c("GO:0010628","positive regulation of gene expression",0.22275900791482073,0.7322214765539462,0.230961,"regulation of multicellular organismal development"),
c("GO:0010646","regulation of cell communication",0.9864082534085572,0.788175328550432,0.27220079,"regulation of multicellular organismal development"),
c("GO:0019222","regulation of metabolic process",12.985497578497595,0.7073484894793203,0.4063976,"regulation of multicellular organismal development"),
c("GO:0023051","regulation of signaling",0.9919794723849535,0.7940311610279581,0.24170876,"regulation of multicellular organismal development"),
c("GO:0048518","positive regulation of biological process",1.9716996037287677,0.7764321303895334,0.28518046,"regulation of multicellular organismal development"),
c("GO:0048519","negative regulation of biological process",2.3667974229987565,0.7712227648069698,0.30652234,"regulation of multicellular organismal development"),
c("GO:0048523","negative regulation of cellular process",1.8278052558467632,0.6851473846864057,0.29653132,"regulation of multicellular organismal development"),
c("GO:0048583","regulation of response to stimulus",1.3331568005952028,0.7868171268328555,0.2683551,"regulation of multicellular organismal development"),
c("GO:0050790","regulation of catalytic activity",0.6853995469827777,0.808155160454012,0.20632477,"regulation of multicellular organismal development"),
c("GO:0050793","regulation of developmental process",1.1758828844673783,0.789942759920626,0.25959592,"regulation of multicellular organismal development"),
c("GO:0050794","regulation of cellular process",20.367259674616214,0.6840138804896715,0.64719805,"regulation of multicellular organismal development"),
c("GO:0050810","regulation of steroid biosynthetic process",0.009377332179244463,0.8111592497001207,0.15353445,"regulation of multicellular organismal development"),
c("GO:0051128","regulation of cellular component organization",0.7906610148267887,0.793383286167207,0.24869653,"regulation of multicellular organismal development"),
c("GO:0051239","regulation of multicellular organismal process",0.537170551400761,0.8075183625912473,0.22271973,"regulation of multicellular organismal development"),
c("GO:0051246","regulation of protein metabolic process",2.1160693002465862,0.7031959818568094,0.36111113,"regulation of multicellular organismal development"),
c("GO:0065009","regulation of molecular function",0.8277348843039647,0.8040948502874397,0.23256911,"regulation of multicellular organismal development"));

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

