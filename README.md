# eh_Utilities

Godot Plugin with basic helpers and common scripts / custom resources / custom classes I reuse across projects and even across addons.

Feel free to use them in your projects, I'm trying to document how to use them in their comments, and eventually setup a wiki/docs site for them, but meanwhile, if anything is confusing or undocumented fell free to open an issue or get in touch though email or twitter and I'll be happy to explain. 

The addon folder is organized into three types of "utilities".
- Custom Nodes
- Custom Reources
- Helpers

## Custom Nodes

For now they are organized into nodes that can only be used for 2D games, nodes that can only be used for 3D games, and whatever is outside of these folders can be used in any type of game.

## Custom Resources

Not much here yet but as the name says, things that are used as resources.

## Helpers

Here we have more generic stuff, anything in the "static" folder can be used without instances, as they only have static functions, so you can use them directly from their class_name.

Whatever is outside this folder inherits from `Reference` and can be used to add useful behavior to other scripts by adding instances of them to it and calling their public methods. 



## License
This is Licensed under MIT as you and see in the LICENSE file, so use it however you want, in any comercial projects or not, just link this repository or this readme in the credits or somewhere.

## Support
If you like this project and want to support it, any improvements pull request is welcomed!

Or if you prefer, you can also send a tip through [ko-fi](https://ko-fi.com/eh_jogos) or take a look at my [patreon](https://www.patreon.com/eh_jogos)!
