# icons

## Gallery

https://caltopo.github.io/icons/

## Summary

This repository provides community-provided icons for import into CalTopo.

- Icons must not be larger than 24x24. They will be scaled to 24x24 by CalTopo otherwise.
- Icon files must not be greater than 10KB in size. They will be rejected by CalTopo otherwise.
  - You can use the Python tool "scour" to reduce the size of SVG files (e.g. `scour -i big.svg -o small.svg`).
- Icons can be in SVG or PNG format.
  - For those using GiMP to create icons, note that GiMP does not support creating SVG images.
  - SVG icons may not be able to have their colors overridden in CalTopo, even if you set the colorable setting.
- CalTopo provides some custom icon features available only through a Pro subscription
  - See documentation here: https://training.caltopo.com/all_users/accounts/account-items#icons
  - Custom icons can be stored in your CalTopo account and added to your map through the normal icon selector dialog window.
  - Pro subscribers also have the ability to colorize their icons.
- CalTopo (free edition) supports fixed-color custom icons via URL.
  - Icon URLs would be the GitHub URL with the query string `?raw=true`.
  - Enter the URL in the URL field in the icon selector dialog window.
- There are also some free icons available here:
  - https://mapicons.mapsmarker.com/category/markers/
  - https://github.com/free-icons/free-icons
- ChatGPT or Google Gemini may also be used to generate icons, but the quality of the generated icons vary.

_(This repository is not affilitated in any way with the CalTopo app or CalTopo, LLC)_
