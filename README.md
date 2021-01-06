#  Mandelbrot Explorer

A simple Mandelbrot Set exploration app using Metal for macOS and iOS/iPadOS.

This project is still a work in progress, with some obvious features still missing. Also, tvOS
supported may be added in the future.

## Building

Clone this repository using your favorite graphical tool or the command line.

```sh
git clone https://github.com/mmar/mandelbrot-explorer.git
```

Create a `Developer.xcconfig` file with your Team ID and a unique bundle identifier. You
can copy and edit the included template, just make sure not to include it in the Xcode project,
as it will not be commited to Git. Or use the shell:

```sh
cd mandelbrot-explorer
echo "DEVELOPMENT_TEAM = <Your Team ID>" > Developer.xcconfig
echo "PRODUCT_BUNDLE_IDENTIFIER = <Reverse-DNS Identifier>" >> Developer.xcconfig
```

Use Xcode to normally build and deploy to your device(s).

