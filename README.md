# no linux é nessario:
 sudo apt-get install libstdc++6

# comando para eliminar as exportacoes da dll menos o metodo  extractText
strip --keep-symbol=extractText ./libTextExtraction.so -o libout.so
strip --keep-symbol=extractText /home/insinfo/Documents/pdf-text-extraction/linux/TextExtraction/libTextExtraction.so -o libout.so