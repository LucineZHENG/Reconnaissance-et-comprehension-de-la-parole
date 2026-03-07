# Reconnaissance et compréhension de la parole  
## Détection de mots-clés basée sur les modèles de Markov cachés

Ce projet implémente un système simple de **détection de mots-clés (Keyword Spotting, KWS)** basé sur les **modèles de Markov cachés (HMM, Hidden Markov Models)**.  
L’objectif est de détecter des mots-clés spécifiques dans un flux de parole continu.

Le corpus utilisé dans ce projet provient d’enregistrements audio en français sur le thème du **football**. Le système vise à identifier des mots-clés prédéfinis dans un flux vocal continu tout en ignorant les segments non pertinents.

Ce projet a été réalisé dans le cadre du **Master 2 Sciences du Langage – parcours Langue et Informatique**.

---

# Objectifs du projet

- Construire un **modèle de reconnaissance vocale basé sur les HMM**
- Implémenter un système de **détection de mots-clés (Keyword Spotting)**
- Entraîner et tester les modèles acoustiques
- Construire un **réseau de décodage (Decoding Network)**
- Analyser les performances du système

Les systèmes de détection de mots-clés sont utilisés dans plusieurs domaines :

- Détection de mots d’activation pour les assistants vocaux
- Localisation de mots-clés dans des transcriptions médiatiques
- Recherche automatique dans des enregistrements de réunions
- Systèmes de recherche d’information vocale

---

# Structure du projet

```
Reconnaissance-et-comprehension-de-la-parole
│
├── Football/                # Données audio, paramètres acoustiques, modèles HMM
├── configs/                 # Fichiers de configuration
├── lists/                   # Dictionnaires, listes de phonèmes, réseaux
├── tmp/                     # Fichiers temporaires
├── generateNet2.pl          # Génération du réseau de détection
├── runAlign.pl              # Alignement forcé (Forced Alignment)
├── runApprentissage.pl      # Script d'entraînement des modèles
├── runParamApp.pl           # Extraction des paramètres (entraînement)
├── runParamTest.pl          # Extraction des paramètres (test)
├── runDetections1.pl        # Expérience de détection 1
├── runDetections2.pl        # Expérience de détection 2
├── runDetections3.pl        # Expérience de détection 3
├── transcription.txt        # Transcriptions des données audio
└── rapport.pdf              # Rapport du projet
```

---

# Données et mots-clés

Le système utilise **10 mots-clés**, répartis en deux catégories :

## 1. Mots fréquents dans le corpus

- france  
- match  
- concert  
- monde  
- bresil  

## 2. Mots thématiques liés au football

- zidane  
- ballon  
- but  
- supporters  
- ronaldo  

Le système utilise une architecture **Keywords + Filler Model**, permettant de distinguer :

- les mots-clés
- la parole non pertinente
- les segments de silence

---

# Méthodologie

## 1 Prétraitement du corpus

Les données audio sont divisées en deux ensembles :

- **Corpus d’entraînement** : les 2 premières minutes de chaque enregistrement  
- **Corpus de test** : la dernière minute de l’audio  

Les données d’entraînement sont segmentées en plusieurs **tours de parole (Tours)** avec annotation phonétique.

---

## 2 Modèles acoustiques

Le système utilise des **modèles de Markov cachés (HMM)**.

Les étapes principales sont :

1. Extraction des **coefficients MFCC**
2. Entraînement de **modèles monophones**
3. **Alignement forcé (Forced Alignment)**
4. Mise à jour des paramètres des modèles

---

## 3 Réseau de décodage

Structure du réseau :

```
sil -> keyword -> sil
       |
     filler
```

- **Keyword models** : modèles des mots-clés
- **Filler / World model** : modélisation de la parole non pertinente
- **sil** : silence

Le processus de reconnaissance utilise **l’algorithme de Viterbi**.

---

# Étapes d’exécution

## 1 Entraînement des modèles

```bash
perl runParamApp.pl
perl runApprentissage.pl
```

## 2 Construction du réseau

```bash
HParse configs/grammairePhoneme.txt configs/networkPhoneme
```

## 3 Extraction des paramètres pour le test

```bash
perl runParamTest.pl
```

## 4 Reconnaissance vocale

```bash
HVite -T 1 \
-H donnees/Football/hmms/hmm.3/HMMmacro \
-w configs/networkPhoneme \
-l donnees/Football/resultats \
lists/dictPhoneme \
lists/phonesFootballHTK \
donnees/Football/param/test/*.mfc
```

## 5 Évaluation des résultats

```bash
HResults -p \
-L donnees/Football/param/test/DAP \
lists/phonesFootballHTK \
donnees/Football/resultats/*.rec
```

---

# Expériences de détection de mots-clés

Les expériences de détection sont réalisées avec les scripts suivants :

```bash
perl runDetections1.pl
perl runDetections2.pl
perl runDetections3.pl
```

Les résultats sont évalués avec :

```
HResults
```

---

# Résultats expérimentaux

Les performances du système sont évaluées à l’aide des indicateurs suivants :

- **Hits** : détections correctes
- **False Alarms (FA)** : fausses alarmes
- **Accuracy**
- **Figure of Merit (FOM)**

Les résultats montrent que :

- certains mots-clés peuvent être détectés
- le taux de fausses alarmes reste élevé
- la **FOM reste proche de zéro**

Les principales raisons sont :

- durée limitée des données de test
- grand nombre de fausses alarmes
- paramètres du réseau de décodage encore à optimiser

---

# Technologies utilisées

- **HTK (Hidden Markov Model Toolkit)**
- **Perl**
- **Python** (prétraitement des données)
- **Praat** (annotation phonétique)

---

# Perspectives d'amélioration

Plusieurs améliorations sont possibles :

- utiliser un corpus d’entraînement plus large
- améliorer le dictionnaire phonétique
- optimiser la structure du réseau de mots-clés
- ajuster les paramètres de **reward / penalty**
- intégrer des approches d’apprentissage profond :
  - **DNN-HMM**
  - **End-to-End ASR**

---

# Auteur

**ZHENG RUIXING**

Master 2  
Sciences du Langage – Langue et Informatique
