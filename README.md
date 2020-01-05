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
lualatex --synctex=1 \
         --interaction=nonstopmode \
         --c-style-errors \
         --shell-escape \
         file.tex
```

### UML

Per includere i diagrammi UML utilizziamo un package che richiede la presenza di tool esterni facilmente reperibili:

- Graphviz (in particolare l'eseguibile dot)
- PlantUML

Una volta installati, bisogna impostare due variabili d'ambiente nel proprio sistema operativo:

- `GRAPHVIZ_DOT=/path/to/dot.exe`
- `PLANTUML_JAR=/path/to/plantuml.jar`

---

Prestare attenzione al fatto che dentro ai file plantuml, se si vuole includere un altro file affinché venga compilato correttamente da LaTeX il path del file da includere deve essere relativo al percorso in cui si trova IL ROOT FILE del documento, e NON relativo al percorso in cui si trova il diagramma

---
