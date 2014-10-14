Panorific
=========

**An immersive, intuitive, motion-based way to explore high-quality panoramas and photos on an iOS device. Panorific is implemented in Swift.**

## Installation
[CocoaPods](http://cocoapods.org) is the recommended method of installing Panorific. Simply add the following line to your `Podfile`:

#### Podfile

``` ruby
pod 'Panorific'
```

## Usage

1. If you're not using Storyboards skip this step. Drag a UIViewController from the Object Library onto the Storyboard and change its class to `PanorificViewController` in the Identity Inspector.
2. In the presenting view controller's prepareForSegue function, set the image property of the appearing PanorificViewController.
``` Swift
override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowPanorificSegue" {
            let destination = segue.destinationViewController as PanorificViewController
            destination.image = UIImage(named: "BreathtakingImage")
        }
    }
```

## Contact

Naji Dmeiri

- http://najidmeiri.com
- http://github.com/ndmeiri

## License

Panorific is available under the MIT License. See the LICENSE file for more info.
