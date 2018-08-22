Font Tool
=========
A macOS application to inspect font information.

### Build

Font Tools is a CMake project and bases on FreeType and Harfbuzz. It
relies on pkg-config to find those packages. Homebrew is recomaned to
manage the packages.

**Install dependencies:**

    brew install freetype harfbuzz lua icu4c
    
**Get the Repo:**

    git clone --recurse-submodules https://github.com/frinkr/font-tool.git

**Build:**

    cd font-tool
    make
    
Find the app at 'font-tool/build/font-tool/Debug/Font Tool.app'
    
### Usage
Intuited & Simple

![Alt text](http://i.imgur.com/xJNubF4.png "Select Typeface")
![Alt text](http://i.imgur.com/LE1mEfS.png "Main Window")

### License
MIT
