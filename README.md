# Repository principale per la documentazione di progetto

## Badge

<!-- TODO update badge URL when transferring repo back to organization -->

[![](https://img.shields.io/badge/capitolato-C5-%2343a42b)](https://www.math.unipd.it/~tullio/IS-1/2019/Progetto/C5.pdf)
[![Commitizen friendly](https://img.shields.io/badge/commitizen-friendly-brightgreen.svg)](http://commitizen.github.io/cz-cli/)
![](https://github.com/erclu/project-docs/workflows/Conventional%20Commits/badge.svg)
![](https://github.com/erclu/project-docs/workflows/Best%20practices%20for%20source%20files/badge.svg)
![](https://github.com/erclu/project-docs/workflows/LaTeX%20workflows/badge.svg)

## Compilazione dei documenti

### LuaLaTeX

Per semplificare i problemi relativi a encoding dei file, utilizziamo LuaLaTeX che accetta UTF-8 di default.

I documenti possono essere generati utilizzando il comando:

```bash
lualatex \
  --interaction=nonstopmode \
  --c-style-errors \
  --shell-escape \
  file.tex
```

### UML

I diagrammi PlantUML sono inclusi dopo uno step di pre-compilazione che trasforma il sorgente PlantUML in immagini.

Dopo aver scaricato l'archivio jar di PlantUML, impostare sul proprio sistema la variabile d'ambiente `PLANTUML_JAR=/path/to/plantuml.jar` ed eseguire il comando:

```bash
java \
  -jar $PLANTUML_JAR \
  -checkmetadata \
  -charset UTF-8 \
  -x **/commons/style/*.pu \
  -o img \
  **/**.pu
```

### Syntax Highlighting

Utilizziamo il package minted, che richiede di avere nel proprio sistema la libreria python [Pygments](https://pygments.org/).
