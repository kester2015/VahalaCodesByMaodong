function pix = wav2pix_ws1(wav)
wav = wav/1e3;
pix = 4.877020810104930e+05 *wav.^3+...
     -2.158019883383146e+06 *wav.^2+...
    3.049841749826460e+06 *wav+... 
     -1.356595133263381e+06;
 pix = round(pix);
 