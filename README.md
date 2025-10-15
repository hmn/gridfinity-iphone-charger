# Gridfinity iPhone charger OpenSCAD model

Gridfinity iPhone charger OpenSCAD model remixed/inspired by https://makerworld.com/en/models/707172-gridfinity-parametric-phone-charging-tray

I needed alternative cable routing and support for different covers with camera cutout that are close to the magsafe charger.

It is rewritten to use latest version of the [gridfinity-rebuilt-openscad](https://github.com/kennetek/gridfinity-rebuilt-openscad) library.

Created a generator script `main.py` to flatten the OpenSCAD files by resolving the `use <...>` and `include <...>` statements recursively. This makes it possible to use in the MakerWorld Parametric Model Maker which does not support these statements.

## Online customiser

You can also use the online version of this project hosted on [MakerWorld](https://makerworld.com).

- Link:

## Running locally

Running locally using OpenSCAD.

1. Install OpenSCAD. This project relies on features available in the **OpenSCAD Developer Version**. Make sure to download it from [OpenSCAD Developer Version](https://openscad.org/downloads.html#snapshots).

2. Clone or download this repository to your local machine:

   ```bash
   git clone https://github.com/hmn/gridfinity-iphone-charger.git
   cd gridfinity-iphone-charger
   git submodule update --init --recursive
   ```

   Alternatively, you can download the ZIP file from the repository page and extract it.

3. Enable OpenSCAD Features.

   - Open OpenSCAD application
   - Go to `Menu > Edit > Preferences`.
   - In the **Preferences** dialog go to the **Advanced** Tab:
     - Backend: select **manifold** option. Makes OpenSCAD faster.
   - An then go to the **Features** Tab:
     - Check **textmetrics**: Enables text related features for the base text.

4. Open the project files in OpenSCAD. **Note:** You must use the developer version of OpenSCAD for this project. Download it here: [OpenSCAD Developer Version](https://openscad.org/downloads.html#snapshots).

## Generating flattened OpenSCAD file

See `flat/README.md` for instructions on how to generate the flattened OpenSCAD file using `main.py`.
