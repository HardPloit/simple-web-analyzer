#!/bin/bash

echo "Introduce la URL de la página web: " 
read url

wget --quiet -O pag-temp.html "$url"

title=$(grep -oP '<title>\K(.*)(?=<\/title>)' pag-temp.html)
links=$(grep -oP 'href="\K[^"]+' pag-temp.html)

links_absolutos=""
for link in $links; do
  if [[ $link == http* ]]; then
    links_absolutos+="$link\n"
  else
    links_absolutos+="$url$link\n"
  fi
done

script_contador=$(grep -oP '<script [^>]+>' pag-temp.html | wc -l)
style_contador=$(grep -oP '<link [^>]+stylesheet|<style[^>]*>(.*?)<\/style>' pag-temp.html | wc -l)
image_urls=$(grep -oP '<img [^>]+src="\K[^"]+' pag-temp.html)

imagenes_absolutas=""
for image_url in $image_urls; do
  if [[ $image_url -eq http* ]]; then
    imagenes_absolutas+="$image_url\n"
  else
    imagenes_absolutas+="$url$image_url\n"
  fi
done

meta=$(grep -oP '<meta [^>]+>' pag-temp.html)
robots_txt=$(wget --quiet --output-document=- "$url/robots.txt")
sitemap_xml=$(wget --quiet --output-document=- "$url/sitemap.xml")
encabezados_http=$(curl -I -s "$url")

clear
echo -e "\nTítulo de la página: $title\n"
echo -e "Enlaces encontrados:\n$links_absolutos"
echo -e "\nNúmero de scripts en la página: $script_contador"
echo -e "Número total de archivos de estilo: $style_contador"
echo -e "\nURLs de las imágenes encontradas:\n$imagenes_absolutas"
echo -e "\nEtiquetas meta encontradas:\n$meta"
echo -e "\nContenido de robots.txt:\n$robots_txt"
echo -e "\nContenido de sitemap.xml:\n$sitemap_xml"
echo -e "\nEncabezados HTTP:\n$encabezados_http"

rm pag-temp.html