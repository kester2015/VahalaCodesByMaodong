# Mask drawing tool

These mask drawing tools are based on the [GDSII toolbox](https://sites.google.com/site/ulfgri/numerical/gdsii-toolbox).

## For first time installation:

1. Download the toolbox package.
2. Install Matlab MEX complier by searching `MATLAB Support for MinGW-w64 C/C++ Compiler` in the add-ons.
3. Run `makemex.m` in the toolbox directory.
4. Copy `\Modules` folder from repository and put it into the toolbox.
5. Get a copy of [KLayout](https://klayout.de) and install it.
6. After starting KLayout, check `Use editing mode by default`.
7. Import the macro `loader.rb` from repository. Now a `Load Script` item will be available in `Macros` every time KLayout is started.

## For mask drawing:

1. Create an empty folder in the toolbox, copy the example code inside and double-click to start Matlab. (This is to ensure that the current folder is set up correctly and all cd operations can work)
2. Modify parameters as needed, and run. Now a layout file and a `boolean.rb` should be created in the same folder. If there is no `boolean.rb` then no postprocessing is needed.
3. Copy the layout for backup, open with KLayout, and run the `boolean.rb` script using `Load Script`.
4. Save, close and reopen to finish postprocessing.