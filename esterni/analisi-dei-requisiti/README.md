# Analisi dei requisiti

per creare le immagini dei diagrammi da includere, eseguire il comando

```bash
java \
  -jar \
  $PLANTUML_JAR \
  -checkmetadata \
  -charset UTF-8 \
  -x **/commons/style/*.pu \
  -o img \
  **/**.pu
```

oppure utilizzare il task "build current latex document" di vscode
