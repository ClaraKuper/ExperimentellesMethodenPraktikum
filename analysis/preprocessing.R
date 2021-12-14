# Preprocessing script
# Hier wollen wir uns einen Überblick über unsere Daten verschaffen und sie für 
# die Analyse vorbereiten

# Schritt 1: Pfad setzen und Daten laden
setwd("~/Documents/Projects/2021/ExperimentellesMethodenPraktikum/")

# Alle Dateien aus dem Ordner "raw" werde in eine Liste geladen
file_list <- list.files('./raw', pattern = 'data_*')
df <- data.frame()

#####################################################
## FRAGE: WELCHE DATEIEN LIEGEN IN DEM ORDNER RAW? ##
## WOFÜR STEHEN DIE NAMEN DER DATEIEN?             ##
## ANTWORT: ##
#####################################################

for (file in file_list){
  # Jede Datei wird geladen
  df_single <- read.csv(paste('./raw',file, sep = '/'))
  # Die einzelnen Dateien werden zu einem Datensatz zusammengefügt
  df <- rbind(df, df_single)
}

# Daten anzeigen
View(df)

##################################################################
## FRAGE: WAS FÄLLT IHNEN AUF? WELCHE STRUKTUR HABEN DIE DATEN? ## 
## WO FINDEN SIE DIE EINTRÄGE DER ERSTEN VERSUCHSPERSON,        ##
## WO DIE EINTRÄGE DER ZWEITEN VERSUCHSPERSON?                  ##
## ANTWORT: jede zweite na, 1. vp oben, 2. vp unten ##
##################################################################

## ==================================================================== ##
## ===========================   TEIL 1  ============================== ##
## ==================================================================== ##

# Schritt 2: Daten ansehen
# 2a) Wie groß ist der Datensatz
print('So viele Spalten hat der Datensatz:')
ncol(df)

print('So viele Zeilen hat der Datensatz:')
nrow(df)

# 2b) Welche Spalten haben wir
print('Die Spalten heißen: ')
colnames(df)

# 2c) In welchen Spalten steht die uV, in welchen steht die aV?
# uV: angle
df$angle
# aV: mouse_trace_y, mouse_trace_x
df$mouse_trace_x
df$mouse_trace_y

# 2d) Was steht in den anderen Spalten?
<<<<<<< HEAD
# dur - die Dauer eines Trials (sollte immer 1200 ms sein)
df$dur
# start_time - ein Zeitstempel, wann der Trial angefangen hat
df$start_time
# speed - wie viele pixel pro sekunde bewegt sich der Stimulus
df$speed
#start position
df$start_position
# side
df$side
# split time
df$splitTime
#df stimulus
df$stimulus
=======
# dur - die Dauer eines Trials (sollte immer 2000 ms sein)
df$dur
# start_time - ein Zeitstempel, wann der Trial angefangen hat
df$start_time
>>>>>>> 68d76de0c04754f058da8c6adb82b07a53c176fe

################################################################################
## AUFGABE: SCHAUEN SIE SICH MINDESTENS 3 WEITERE ZEILEN AN UND ERLÄUTERN SIE ##
## KURZ, WELCHE INFORMATION IN DIESEN ZEILEN DRINSTEHT.                       ##
################################################################################


# 2e) Gibt es fehlende Werte?
print('Es gibt fehlende Werte im Datensatz: ')
any(is.na(df))

#####################################################################
## FRAGE: GIBT ES ZU DIESEM ZEITPUNKT FEHLENDE WERTE IM DATENSATZ? ##
## WORAN ERKENNEN SIE, OB ES FEHLENDE WERTE GIBT?                  ##
## ANTWORT: ##
#####################################################################

# in einem neuen Datensatz sammeln wir alle Zeilen mit "NA" Werten
na_df <- df[rowSums(is.na(df)) > 0,]
View(na_df)

######################################################################
## FRAGE: WAS HABEN ALLE ZEILEN MIT FEHLENDEN WERTEN GEMEINSAM?     ##
## TIPP: SCHAUEN SIE AUF DIE HINTEREN ZEILEN IM DATENSATZ           ##
## ANTWORT: ##
######################################################################

# Schritt 3: Daten "reinigen"
# In diesem Schritt überlegen wir, ob der Datensatz eine geeignete Struktur hat,  
# um ihn später analysieren zu können

# Die uVs und aVs haben keine Wert in dem Feedback Teil. Wir können den Feedback 
# Teil also für die Analyse verwerfen.

# Hier filtern wir alle Zeilen aus dem 'trial' Teil des Experiments und 
# speichern diesein einem neuen Datensatz.
trial_df <- df[df$test_part == 'trial',]
print("Es gibt fehlende Daten in dem trial Datensatz: ")
any(is.na(trial_df))

#####################################################################
## FRAGE: GIBT ES ZU DIESEM ZEITPUNKT FEHLENDE WERTE IM DATENSATZ? ##
## ANTWORT: ##
#####################################################################

# ungültige Trials entfernen
# wir wollen nur die Trials analysieren, bei denen die Versuchsperson die ganze 
# Zeit mit dem Finger auf dem Punkt war. die Information, ob der Punkt die ganze 
# Zeit angetippt wurde, finden wir in der Spalte "interruptedResponse"
print("Es gab Trials, bei denen die Antwort unterbrochen wurde: ")

any(df$interruptedResponse == 'true')

#(kurze Anmerkung, 'true' ist hier ein Text (string), 
# nicht der logische Operator TRUE)

##########################################################################
## FRAGE: GIBT ES ZU DIESEM ZEITPUNKT UNGÜLTIGE ANTWORTEN IM DATENSATZ? ##
## ANTWORT: ##
##########################################################################

# Wir behalten nur die Fälle, in denen die Antwort nicht unterbrochen wurde
trial_df <- trial_df[trial_df$interruptedResponse == 'false', ]

# 4. Daten in das korrekte Format bringen
# 4a) Datenklassen (Data Types) 
###############################################
## FRAGE: WELCHE DATENKLASSEN KENNEN SIE?    ##
## WIE WERDEN DIESE KLASSEN BEI R ABGEKÜRZT? ##
# ANTWORT: ##
###############################################

# Datenklasse einer einzelnen Spalte anzeigen:
class(trial_df$angle)
# Datenklasen aller Spalten anzeigen:
str(trial_df)

###############################################################
# FRAGE: WELCHE DATENKLASSEN KOMMEN IN DIESEM DATENSATZ VOR? ##
# ANTWORT: ##
###############################################################

# Die Spalten mouse_trace_x und mouse_trace_y sind vom Typ "chr" - also Text. 
# Wir möchten aber, dass in dieses Spalten Nummern stehen (num oder int). 
# Wir müssen das Format von diesen Spalten also umwandeln.
# Die Umwandlung von Text wie "42" in die Zahl 42 funktioniert mit dem Befehl 
# as.numeric("42"). Hier haben wir aber als Text "[42, 43, 44, 45]", 
# und wollen diesen in eine Liste mit numerischen Werten übersetzen.

# Wie das funktioniert, habe ich gegoogelt. Die Lösung habe ich aus diesem Thread 
# übernommen: https://stackoverflow.com/questions/43460359/r-convert-a-stringlist-to-list
# Wir benutzen eine bestimmte Bibliothek: jsonlite
# Möglicherweise ist diese Bibliothek bei Ihnen noch nicht installiert:
install.packages("jsonlite")

# Jetzt können wir die Variablen übersetzen
trial_df$mouse_trace_x <- jsonlite::stream_in(textConnection(trial_df$mouse_trace_x), 
                                              simplifyDataFrame = FALSE)
trial_df$mouse_trace_y <- jsonlite::stream_in(textConnection(trial_df$mouse_trace_y), 
                                              simplifyDataFrame = FALSE)

# Jetzt können wir uns die Datenklassen dieser Spalten ansehen
class(trial_df$mouse_trace_x)
class(trial_df$mouse_trace_y)

str(trial_df)

################################################################
# FRAGE: ZU WELCHER DATENKLASSEN GEHÖREN DIESE SPALTEN JETZT? ##
# ANTWORT: ##
################################################################

# Wir können uns die Daten jetzt in einem ersten Plot ansehen.
# Da uns besonders die Bewegungen der Maus interessieren, plotten wir diese.

# Wir tun dies für jede Versuchsperson individuell. 
# Daher brauchen wir erstmal die Information,
# welche Versuchspersonen-IDs wir überhaupt in diesem haben:
vps <- unique(trial_df$jatosID)

#####################################################
# FRAGE: WIE LAUTEN DIE IDS DER VERUSUCHSPERSONEN? ##
# ANTWORT: ##
#####################################################

# Für jede einzelne Versuchsperson...
for (vp in vps){
  
  # ... filtern wir den Datensatz nach den Daten dieser Person
  v_df <- trial_df[trial_df$jatosID == vp, ]
    
  # ... erstellen wir einen leeren plot
  plot(NULL, xlim=c(50, 700), ylim = c(200,260), ylab = "vertikale Position", 
       xlab = "horizontale Position",  main = vp)
  
  # ... und fügen alle Bewegungen als Linie hinzu
  for (row in 1:nrow(v_df)){
    lines(v_df$mouse_trace_x[[row]], v_df$mouse_trace_y[[row]])
  }
}

#############################################################
# AUFGABE: BESCHREIBEN SIE KURZ, WAS SIE IN DEM PLOT SEHEN ##
# ANTWORT: ##
#############################################################

# Eine wichtige Information ist, wann sich der ablenkende Stimulus abgespaltet hat.
# Der Zeitpunkt zu dem der ablenkende Stimulus gezeigt wurde, ist in der Spalte 
# "splitTime" in Millisekunden angegeben. Wir haben aber die Position der Maus 
# nicht jede Millisekunde, sondern nur alle 33 Millisekunden aufgezeichnet.
# (Der Messabstand ist in der Zeile "refreshRate" angegeben) 
# Um zu wissen, welche Messung zu dem Zeitpunkt an dem sich der ablenkende 
# Stimulus abgespalten hat gehört, teilen wir diesen Zeitpunkt durch den 
# Messabstand (33) und runden zur nächsten vollen Zahl auf.

for (row in 1:nrow(trial_df)){
  trial_df$distractorProbe[row] <- ceiling(trial_df$splitTime[row]/trial_df$refreshRate[row])
}

# Dann können wir diesen Zeitpunkt in unserem Plot anzeigen.

# Für jede einzelne Versuchsperson ... 
for (vp in vps){
  # ... filtern wir den Datensatz nach den Daten dieser Person

  v_df <- trial_df[trial_df$jatosID == vp, ]
  
  # ... erstellen wir einen leeren plot
  plot(NULL, xlim=c(50, 700), ylim = c(200,260), ylab = "vertikale Position",
       xlab = "horizontale Position",  main = vp)
  
  # ... fügen wir alle Bewegungen als Linie hinzu
  for (row in 1:nrow(v_df)){
    lines(v_df$mouse_trace_x[[row]], v_df$mouse_trace_y[[row]])
    idx <- trial_df$distractorProbe[row]
    
    # ... und fügen wir Linien zu den Zeitpunkten hinzu, zu denen der ablenkende 
    # Stimulus sich abgespalten hat. 
    abline(v = trial_df$mouse_trace_x[[row]][idx], col = 'red')
  }
}

################################################################################
# AUFGABE: BESCHREIBEN SIE KURZ, WIE SICH DER START DES ABLENKENDEN STIMULUS  ##
# ÜBER DIE BEWEGUNG VERTEILT.                                                 ##
# ANTWORT: ##
################################################################################

# 4b) Den Referenzrahmen festlegen
# Wir sehen, dass die Zeitpunkte, an denen der ablenkende Stimulus sich abspaltet, 
# sehr unterschiedlich sind. Außerdem sind auch die Start- und Endpunkte der 
# Bewegung verschieden. In diesem Experiment laufen einige der Bewegungen von 
# links nach rechts, andere von rechts nach links. Das erschwert die 
# Interpretation dieses Graphen und auch die statistische Auswertung.
# Wir möchten unsere Daten in einen gemeinsamen Referenzrahmen bringen, 
# bevor wir die Analyse durchführen.

#########################################################
# FRAGE: KENNEN SIE EIN SYNOMYM FÜR "REFERENZRAHMEN?". ##
# ANTWORT: ##
#########################################################

# 4c) Den Ausgangspunkt der Bewegung auf 0 setzen
# Um den Ausgangspunkt der Bewegung auf 0 zu setzen, subtrahieren wir den  
# Startwert der Bewegung von allen anderen Werten. Damit drücken wir jede 
# Bewegung relativ zu Ihrem Ausganspunkt aus.


for (row in 1:nrow(trial_df)){
  # Hier lesen wir die Startwert der Bewegung ab.
  startx <- trial_df$mouse_trace_x[[row]][1]
  starty <- trial_df$mouse_trace_y[[row]][1]
  
  # Hier subtrahieren wir die Startwerte von der Sequenz.
  trial_df$mouse_trace_x[[row]] <- trial_df$mouse_trace_x[[row]]-startx
  trial_df$mouse_trace_y[[row]] <- trial_df$mouse_trace_y[[row]]-starty
  
}

# Danach plotten wir die Sequenz nochmal:
for (vp in vps){
  # Datensatz pro VP
  v_df <- trial_df[trial_df$jatosID == vp, ]

  # Leerer Plot
  plot(NULL, xlim=c(-400, 400), ylim = c(-50,50), ylab = "vertikale Position", 
       xlab = "horizontale Position", main = vp)
  
  # Bewegungslinien
  for (row in 1:nrow(v_df)){
    lines(v_df$mouse_trace_x[[row]], v_df$mouse_trace_y[[row]])
    # Zeitpunkt des ablenkenden Stimulus
    idx <- v_df$distractorProbe[row]
    abline(v = v_df$mouse_trace_x[[row]][idx], col = 'red')
  }
}

##############################################
## FRAGE: WIE HAT SICH DER GRAPH VERÄNDERT? ## 
## WAS FÄLLT JETZT STÄRKER AUF ALS VORHER?  ##
## ANTWORT: ##
##############################################

# 4d) Die x-Richtung und y-Richtung der Bewegung angleichen
# Bei Bewegungen von rechts nach links der Wert der x-Position immer kleiner werden. 

#######################################################################
## AUFGABE: ÜBERPRÜFEN SIE, OB DIE OBENSTEHENDE AUSSAGE KORREKT IST. ##
## ANTWORT: ##
#######################################################################

# Um die beiden Bewegungsrichtungen in den gleichen Referenzrahmen zu bringen, 
# müssen wir die Bewegungen von rechts nach links (oder von links nach rechts) 
# um 180 Grad drehen. Das ist mathematisch equivalent damit, die x-Komponente
# und die y-Komponente der rechts-links Bewegungen mit -1 zu multiplizieren.

for (row in 1:nrow(trial_df)){
  
  # Hier prüfen wir, ob die Bewegung von rechts nach links lief.
  if (trial_df$side[row] == 'r'){
    
    # In den Fällen, in denen die Bewegung von rechts nach links lief
    # multiplizieren wir die x- und die y-Komponente mit -1.
    trial_df$mouse_trace_x[[row]] <- trial_df$mouse_trace_x[[row]] * -1
    trial_df$mouse_trace_y[[row]] <- trial_df$mouse_trace_y[[row]] * -1
    
  }
  
}

# Im nächsten Schritt prüfen wir nochmal den Plot
for (vp in vps){
  
  # Datensatz pro VP
  v_df <- trial_df[trial_df$jatosID == vp,]
  
  # Leerer Plot
  plot(NULL, xlim=c(0, 700), ylim = c(-50,50), ylab = "vertikale Position", 
       xlab = "horizontale Position", main = vp)
  
  # Bewegungslinien
  for (row in 1:nrow(v_df)){
    lines(v_df$mouse_trace_x[[row]], v_df$mouse_trace_y[[row]])
    # Zeitpunkt des ablenkenden Stimulus
    idx <- v_df$distractorProbe[row]
    abline(v = v_df$mouse_trace_x[[row]][idx], col = 'red')
  }
}

#####################################################################
## FRAGE: VERGLEICHEN SIE DIESEN PLOT MIT DEM ERSTEN PLOT, DEN SIE ##
## HEUTE ERSTELLT HABEN. WELCHE UNTERSCHIEDE FALLEN IHNEN AUF ?    ##
## ANTWORT: ##
#####################################################################

# 5) Speichern des Zwischenergebnisses
# Unsere Daten sind jetzt deutlich verschieden von den Rohdaten. Wir speichern 
# den Datensatz an dieser Stelle, um bei Bedarf Zugriff auf ihn zu haben.
save(trial_df, file = "./preprocessed/aligned_dataframe.Rda")

## ==================================================================== ##
## ===========================   TEIL 2  ============================== ##
## ==================================================================== ##


# In den nächsten Schritten wollen wir aus den Daten die Informationen extrahieren,
# die wir für unsere ANOVAs und t-Tests brauchen.

# 6) aus der Position die Geschwindigkeit berechnen
# Spering et al. rechnen Ihre Analysen mit der Geschwindigkeit der Bewegung.
# Wir müssen also die Position der Hand in Geschwindigkeit umrechnen.


###############################################
## FRAGE: WIE BERECHNET MAN GESCHWINDIGKEIT? ##
## ANTWORT: ##
###############################################

# Wir möchten die Geschwindigkeit in Zentimeter pro Sekunde berechen.
# Die Maus-Position in Pixel sind in den Spalten in mouse_trace_x und 
# mouse_trace_y angegeben.
# Die Differenz zwischen den einzelnen Messwerten in Millisekunden ist in der 
# Spalte "refreshRate" gespeichert.
# Wichtige Informationen zur Umrechnung
# 1 cm = 38 px 
ppcm <- 38 
# 1 sec = 1000 ms
msps <- 1000


# 6a) Die Geschwindigkeit in Zentimeter/Messung
for (row in 1:nrow(trial_df)){
  
  # Wir berechnen die Differenz zwischen den einzelnen Einträgen.
  # Danach dividieren wir durch die Zahl von Pixeln pro Zentimeter,
  # um die Differenz in Zentimeter zu erhalten.
  trial_df$mouse_velocity_x[[row]] <- diff(trial_df$mouse_trace_x[[row]])/ppcm
  trial_df$mouse_velocity_y[[row]] <- diff(trial_df$mouse_trace_y[[row]])/ppcm
  
}

# 7b) Geschwindigkeit in Zentimeter/Sekunde
# Im nächsten Schritt teilen wir durch die Zeit, die zwischen den Messungen
# vergangen ist.
trial_df$refreshRateSec <- trial_df$refreshRate/msps

for (row in 1:nrow(trial_df)){
  
  # Wir teilen die zurückgelegte Strecke in Zentimetern durch die dafür 
  # aufgewendete Zeit in Sekunden.
  trial_df$mouse_velocity_x[[row]] <- 
    trial_df$mouse_velocity_x[[row]]/trial_df$refreshRateSec[row]
  
  trial_df$mouse_velocity_y[[row]] <- 
    trial_df$mouse_velocity_y[[row]]/trial_df$refreshRateSec[row]
  
}

# Danach plotten wir die x- und die y-Achsen Geschwindigkeit für jede VP

for (vp in vps){
  
  # Datensatz pro VP
  v_df <- trial_df[trial_df$jatosID == vp,]
  
  # Leerer Plot für die x Richtung
  plot(NULL, xlim=c(0, 60), ylim = c(0,100), ylab = "x-Geschwindigkeit in cm/sec", xlab = "Probe nach Start", main = vp)
  
  # Geschwindigkeit in x Richtung
  for (row in 1:nrow(v_df)){
    lines(v_df$mouse_velocity_x[[row]])
    # Zeitpunkt des ablenkenden Stimulus
    idx <- v_df$distractorProbe[row]
    abline(v = idx, col = 'red')
  }
  
  # Leerer Plot für die y-Richtung
  plot(NULL, xlim=c(0, 60), ylim = c(-10,10), ylab = "y-Geschwindigkeit in cm/sec", xlab = "Probe nach Start", main = vp)
  
  # Geschwindigkeit in y-Richtung
  for (row in 1:nrow(v_df)){
    lines(v_df$mouse_velocity_y[[row]])
    # Zeitpunkt des ablenkenden Stimulus
    idx <- v_df$distractorProbe[row]
    abline(v = idx, col = 'red')
  }
}

#######################################################################
## FRAGE: WELCHE UNTERSCHIEDE SEHEN SIE ZWISCHEN DER GESCHWINDIGKEIT ##
## IN X-RICHTUNG UND DER GESCHWINDIGKEIT IN Y-RICHTUNG?              ##
## WOHER KOMMT DER REGELMÄßIGE ABSTAND ZWISCHEN DEN ZEITPUNKTEN ZU   ##
## DENEN DER IRRELEVANTE STIMULUS AUFTAUCHT?                         ##
## ANTWORT: ##
#######################################################################


# 7) Die für die Analyse relevanten Zeiträume extrahieren
# wir interessieren uns für den Zeitraum, nachdem der ablenkende Stimulus 
# sich von dem Zielreiz abgelöst hat.
# Spering et al. schauen sich 40 ms - Intervalle bis zu 320 ms an. 
# Wir werden uns zunächste größere Intervalle - 99ms, immer 3 Messungen zusammen -
# zwischen 0 und 500 ms nach dem ablenkenden Stimulus ansehen.

# Dadurch ergeben sich für uns 5 Zeiträume:

# Zeitraum 0 - 99

for (row in 1:nrow(trial_df)){
  
  # Den Index des ablenkenden Stimulus extrahieren
  idx <- trial_df$distractorProbe[row]

  # Extrahieren der Probenwerte in dem relevanten Zeitraum
  xsamples <- trial_df$mouse_velocity_x[[row]][idx:(idx+2)]
  ysamples <- trial_df$mouse_velocity_y[[row]][idx:(idx+2)]
  
  # Mitteln und speichern
  trial_df$velx0_99[row] <- mean(xsamples)
  trial_df$vely0_99[row] <- mean(ysamples)
  
}

# Zeitraum 100 - 199
for (row in 1:nrow(trial_df)){
  # Den Index des ablenkenden Stimulus extrahieren
  idx <- trial_df$distractorProbe[row]
  
  # extrahieren der Probenwerte in dem relevanten Zeitraum
  xsamples <- trial_df$mouse_velocity_x[[row]][(idx+3):(idx+5)]
  ysamples <- trial_df$mouse_velocity_y[[row]][(idx+3):(idx+5)]
  
  # Mitteln und speichern
  trial_df$velx100_199[row] <- mean(xsamples)
  trial_df$vely100_199[row] <- mean(ysamples)
  
}

# Zeitraum 200 - 299
for (row in 1:nrow(trial_df)){
  # Den Index des ablenkenden Stimulus extrahieren
  idx <- trial_df$distractorProbe[row]

  # extrahieren der Probenwerte in dem relevanten Zeitraum
  xsamples <- trial_df$mouse_velocity_x[[row]][(idx+6):(idx+8)]
  ysamples <- trial_df$mouse_velocity_y[[row]][(idx+6):(idx+8)]
  
  # Mitteln und speichern
  trial_df$velx200_299[row] <- mean(xsamples)
  trial_df$vely200_299[row] <- mean(ysamples)
  
}

# Zeitraum 300 - 399
for (row in 1:nrow(trial_df)){
  # Den Index des ablenkenden Stimulus extrahieren
  idx <- trial_df$distractorProbe[row]

  # extrahieren der Probenwerte in dem relevanten Zeitraum
  xsamples <- trial_df$mouse_velocity_x[[row]][(idx+9):(idx+11)]
  ysamples <- trial_df$mouse_velocity_y[[row]][(idx+9):(idx+11)]

  # Mitteln und speichern
  trial_df$velx300_399[row] <- mean(xsamples)
  trial_df$vely300_399[row] <- mean(ysamples)
  
}
# Zeitraum 400 - 499

for (row in 1:nrow(trial_df)){
  # Den Index des ablenkenden Stimulus extrahieren
  idx <- trial_df$distractorProbe[row]

  # extrahieren der Probenwerte in dem relevanten Zeitraum
  xsamples <- trial_df$mouse_velocity_x[[row]][(idx+12):(idx+14)]
  ysamples <- trial_df$mouse_velocity_y[[row]][(idx+12):(idx+14)]
  
  # Mitteln und speichern
  trial_df$velx400_499[row] <- mean(xsamples)
  trial_df$vely400_499[row] <- mean(ysamples)
  
}

##################################################################
## FRAGE: WAS SAGEN DIE OBEN BERECHNETEN WERTE AUS?             ##
## WARUM BENUTZEN WIR GEMITTELTE WERTE, ANSTATT JEDEN ZEITPUNKT ## 
## EINZELN ZU BERECHNEN?                                        ##
## ANTWORT: ##
##################################################################


# Zusammenfassung
# Wir haben den Datensatz in eine saubere Form gebracht, und die Geschwindigkeit
# in x- und y-Richtung in verschiedenen Zeitfenstern extrahiert. 
# Schon hier in der Vorverarbeitung haben wir Entscheidungen getroffen, die  
# später unsere Analysen beeinflussen können. Z.B. die Größe der gewählten Zeiträume.

# Deshalb ist es wichtig, die Schritte, die in der Vorverarbeitung gegangen 
# wurden, in Veröffentlichungen deutlich zu beschreiben und, wenn möglich, 
# Rohdaten und das Skript zur Vorverarbeitung ebenfalls zu veröffentlichen!

# Datensatz speichern
# Dies ist jetzt unser vollständig vorverarbeiteter Datensatz. Diesen speichern wir.
save(trial_df, file = "./preprocessed/preprocessed_dataframe.Rda")

# Minimalen Datensatz speichern
# Nicht alle Spalten sind für die Analyse interessant. Um den Datensatz 
# übersichtlicher zu machen, speichern wir eine minimale Version, 
# die wir für die grundlegenden Analysen nutzen können
minimal_df <- trial_df[c('trialID', 'jatosID','angle', 'side',
                         'velx0_99', 'vely0_99', 
                         'velx100_199', 'vely100_199', 
                         'velx200_299', 'vely200_299',
                         'velx300_399','vely300_399',
                         'velx400_499','vely400_499')]

# Diesen Datensatz speichern wir als R Data File
save(minimal_df, file = "./preprocessed/minimal_dataframe.Rda")
write.csv(minimal_df, "./preprocessed/minimal_dataframe.csv")

############################################################
## AUFGABE: ÖFFNEN SIE DIE DATEI "minimal_dataframe.csv". ##
## FEHLEN IRGENDWELCHE DATEN, DIE SIE BRAUCHEN? GIBT ES   ## 
## LEERE EINTRÄGE, SIEHT DAS FORMAT SINNVOLL AUS?         ##
## ANTWORT: ##
############################################################
