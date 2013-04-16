#!/bin/bash
# Downsamples all retina ...@2x.png images.

python Vendor/localize.py --mainIdiom=en --mainStoryboard=Resources/NIBs/en.lproj/Authentication.storyboard ja vi
python Vendor/localize.py --mainIdiom=en --mainStoryboard=Resources/NIBs/en.lproj/Camera.storyboard ja vi
python Vendor/localize.py --mainIdiom=en --mainStoryboard=Resources/NIBs/en.lproj/Component.storyboard ja vi
python Vendor/localize.py --mainIdiom=en --mainStoryboard=Resources/NIBs/en.lproj/MainStoryboard.storyboard ja vi
python Vendor/localize.py --mainIdiom=en --mainStoryboard=Resources/NIBs/en.lproj/Gallery.storyboard ja vi
python Vendor/localize.py --mainIdiom=en --mainStoryboard=Resources/NIBs/en.lproj/Setting.storyboard ja vi
