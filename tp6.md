```bash
base64 -d AffichezMoi > fichier_a_analyser.bin
file fichier_a_analyser.bin
```

```console
fichier_a_analyser.bin: GIF image data, version 89a, 705 x 457
```


```bash
hexdump -C fichier_a_analyser.bin | head -n 20
strings fichier_a_analyser.bin
```
```console

```


```bash
Get-FileHash -LiteralPath fichier_a_analyser.bin -Algorithm SHA256
```
```console

Algorithm       Hash                                                                   Path
---------       ----                                                                   ----
SHA256          5117805C488BC398A23BB68F24FB472E96BE534144E08C7B0F7E9832BAF156BE       C:\github\s…
```

```bash
sudo apt install libimage-exiftool-perl
exiftool fichier_a_analyser.bin
```