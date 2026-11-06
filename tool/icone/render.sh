# uso: render.sh nome.svg tamanho  -> nome.png
M=$(cygpath -m "$PWD")
"/c/Program Files/Google/Chrome/Application/chrome.exe" --headless=new --disable-gpu --hide-scrollbars --default-background-color=00000000 --window-size=$2,$2 --screenshot="$M/${1%.svg}.png" "file:///$M/$1" >/dev/null 2>&1
