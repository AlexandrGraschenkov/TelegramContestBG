# TelegramChart
![Swift version](https://img.shields.io/badge/Swift-5.0-orange.svg) 
[![Donate](https://img.shields.io/badge/Donate-PayPal-blue.svg)](https://paypal.me/gralexdev)


<img src="https://github.com/AlexandrGraschenkov/TelegramContestBG/raw/master/readme_images/logo_title.jpg" alt="Demo" width="702px" />
This code is used to build a solution for Telegram <a href="https://contest.com/docs/ios2021-r1">iOS Animation Contest 2021</a>. I've taken 4'th place(again). I think it's a good result because I have a regular job and am working on this competition only in the evening. It was pretty exciting the first couple of days while you built the settings screen abd BG view. The rest of the contest it's just digging inside telegram code and struggling with it.
<br><br>

---
In this repo you can find implementation for: 
- Background drawing of gradient with `Metal` (with displacement distortion)
- Setting implementation with non trivial slider control

<img src="https://github.com/AlexandrGraschenkov/TelegramContestBG/raw/master/readme_images/bg.gif" alt="Background GIF" width="220px" /> &nbsp;
<img src="https://github.com/AlexandrGraschenkov/TelegramContestBG/raw/master/readme_images/slider.gif" alt="Slider GIF" width="220px" />

### Details
1) Slider control was build on top 4 standart `UISlider`
2) Background was draw with simple `fragment shader`:
<img src="https://github.com/AlexandrGraschenkov/TelegramContestBG/raw/master/readme_images/fragment.jpg" alt="Demo" width="100%" />


### Licence
The code under `MIT licence`. Do whatever you want.
