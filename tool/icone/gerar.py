# Gera o ícone do app. Desenho em FORMAS (quadro 108x108 do ícone adaptativo).
# python gerar.py vector|mono > android/app/src/main/res/drawable/ic_launcher_{foreground,monochrome}.xml
# python gerar.py legado > legado.svg && bash render.sh legado.svg 768  (Chrome headless) e
# reduza o PNG para 48/72/96/144/192 px em mipmap-*/ic_launcher.png.
import sys
FUNDO = "#7B5A2E"
LEITOR = "#E9C99A"
CLARO = "#FFF8EE"
# (cor, tipo, dados) num quadro de 108x108 (ícone adaptativo; zona segura = círculo de raio 33)
FORMAS = [
    (LEITOR, "circle", (54, 32.5, 7.2)),
    (LEITOR, "path", "M34.5 49.6C35.4 44.2 42.6 41.6 54 41.6C65.4 41.6 72.6 44.2 73.5 49.6C66.2 47.7 58.6 48.5 54 51.1C49.4 48.5 41.8 47.7 34.5 49.6Z"),
    (CLARO, "path", "M53.2 54.3C47.4 50.7 38.4 50.1 29.5 51.7L29.5 60.3C38.4 58.9 47.4 59.5 53.2 62.6Z"),
    (CLARO, "path", "M54.8 54.3C60.6 50.7 69.6 50.1 78.5 51.7L78.5 60.3C69.6 58.9 60.6 59.5 54.8 62.6Z"),
    (CLARO, "path", "M34.6 64H73.4A1.7 1.7 0 0 1 73.4 67.4H34.6A1.7 1.7 0 0 1 34.6 64Z"),
    (CLARO, "path", "M49.6 67.4H58.4L60.6 79.6H47.4Z"),
    (CLARO, "path", "M43 79.6H65A1.7 1.7 0 0 1 65 83H43A1.7 1.7 0 0 1 43 79.6Z"),
]

def svg(fundo=True, mascara=None, mono=False, quadro="0 0 108 108", px=432):
    s = [f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="{quadro}" width="{px}" height="{px}">']
    if mascara:
        s.append(f'<defs><clipPath id="m">{mascara}</clipPath></defs><g clip-path="url(#m)">')
    if fundo:
        s.append(f'<rect width="108" height="108" fill="{FUNDO}"/>')
    for cor, tipo, d in FORMAS:
        cor = "#FFFFFF" if mono else cor
        if tipo == "circle":
            s.append(f'<circle cx="{d[0]}" cy="{d[1]}" r="{d[2]}" fill="{cor}"/>')
        else:
            s.append(f'<path fill="{cor}" d="{d}"/>')
    if mascara:
        s.append('</g>')
    s.append('</svg>')
    return "\n".join(s)

def circulo_em_path(cx, cy, r):
    return f"M{cx - r} {cy}A{r} {r} 0 1 0 {cx + r} {cy}A{r} {r} 0 1 0 {cx - r} {cy}Z"

def vector(cores=True):
    linhas = ['<?xml version="1.0" encoding="utf-8"?>',
              '<vector xmlns:android="http://schemas.android.com/apk/res/android"',
              '    android:width="108dp" android:height="108dp"',
              '    android:viewportWidth="108" android:viewportHeight="108">']
    for cor, tipo, d in FORMAS:
        if tipo == "circle":
            d = circulo_em_path(*d)
        cor = cor if cores else "#FFFFFFFF"
        linhas.append(f'    <path android:fillColor="{cor}" android:pathData="{d}"/>')
    linhas.append('</vector>')
    return "\n".join(linhas) + "\n"

if __name__ == "__main__":
    modo = sys.argv[1]
    if modo == "svg": print(svg())
    elif modo == "circulo": print(svg(mascara='<circle cx="54" cy="54" r="36"/>'))
    elif modo == "squircle": print(svg(mascara='<rect x="18" y="18" width="72" height="72" rx="16"/>'))
    # Android 7 (sem ícone adaptativo): quadrado arredondado recortado mais perto do desenho.
    elif modo == "legado": print(svg(mascara='<rect x="14" y="14" width="80" height="80" rx="16"/>', quadro="14 14 80 80", px=768))
    elif modo == "loja": print(svg(quadro="0 0 108 108", px=768))
    elif modo == "vector": print(vector(), end="")
    elif modo == "mono": print(vector(False), end="")
